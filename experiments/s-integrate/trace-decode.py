#!/usr/bin/env python3
"""Decode lossless joined Host JSON lines into the public TS observation shape."""
import argparse
import json
import pathlib
import re


def representation(value):
    if isinstance(value, list):
        return [representation(item) for item in value]
    if isinstance(value, dict):
        if set(value) == {"a", "b", "c", "d"}:
            return [value[key] for key in ("a", "b", "c", "d")]
        return {key: representation(item) for key, item in value.items()}
    return value


def outcome(value):
    kind = value["kind"]
    if kind == "Complete":
        return {"ok": True}
    if kind == "SystemFailure":
        return {"ok": False, "error": {"kind": kind, "system": value["system"],
                                        "error": {"code": value["code"]}}}
    if kind == "MissingRuntimeRequirements":
        names = {"ResourceRequired": "resource", "ServiceRequired": "service",
                 "StateRequired": "state"}
        return {"ok": False, "error": {"kind": kind, "requirements": [
            {"kind": names[item["kind"]], "name": item["name"]}
            for item in value["requirements"]]}}
    raise ValueError(f"unsupported public dispatch outcome: {value}")


class Lane:
    def __init__(self, schema, style):
        self.result = {"schema": schema, "style": style, "lane": schema + "/" + style,
                       "rawReservations": [], "reads": [], "readerDiagnostics": [],
                       "ownWrites": [], "snapshots": [], "dispatches": [], "auditEffects": []}
        self.result["foreignLookupDivergence"] = []
        self.bindings = {}
        self.namespaces = {}
        self.raw = []
        self.preflight_active = None
        self.preflights = {}
        self.io = []

    def preflight_io(self, line):
        self.io.append(line)
        marker, schema, label, *rest = line.split(":", 3)
        if schema != self.result["schema"].lower():
            raise ValueError("preflight IO belongs to another schema")
        if marker == "PREFLIGHT-BEGIN":
            if rest or self.preflight_active is not None or label in self.preflights:
                raise ValueError("duplicate or nested preflight interval")
            self.preflight_active = {"missing": label, "invocations": [], "effects": []}
        elif marker == "PREFLIGHT-INVOKE":
            if self.preflight_active is None or len(rest) != 1:
                raise ValueError("invocation outside preflight interval")
            int(rest[0])  # Preserve the actual count marker in actualIOEvents.
            self.preflight_active["invocations"].append(label)
        elif marker == "PREFLIGHT-RESULT":
            if self.preflight_active is None or self.preflight_active["missing"] != label or len(rest) != 1:
                raise ValueError("unmatched preflight result")
            self.preflight_active["result"] = outcome(json.loads(rest[0]))
            self.preflights[label] = self.preflight_active
            self.preflight_active = None
        else:
            raise ValueError("unknown preflight IO marker")

    def key(self, handle):
        if set(handle) != {"namespace", "id"}:
            raise ValueError(f"invalid handle shape: {handle}")
        return handle["namespace"], handle["id"]

    def label(self, handle, world="alpha"):
        key = self.key(handle)
        if world in self.namespaces and key[0] != self.namespaces[world]:
            raise ValueError("foreign handle in a local public query/lifecycle observation")
        return self.bindings[key]

    def row(self, value, world="alpha", optional=False):
        handle = value["handle"]
        result = {"label": self.label(handle, world), "rawId": handle["id"],
                  "main": value["main"], "flag": value["flag"]}
        if optional:
            result["aux"] = value["aux"]
        return result

    def lookup(self, value, world):
        access = value["result"]
        kind = access["kind"]
        if kind == "Found":
            return {"result": "Found", **self.row(access["value"], world)}
        if kind not in ("Mismatch", "Missing"):
            raise ValueError(f"invalid access: {access}")
        return {"result": "QueryMismatch" if kind == "Mismatch" else "MissingEntity",
                "rawHandle": value["handle"]["id"]}

    def main_row(self, value):
        # The pinned Added/Changed public queries declare only Main, unlike Q.
        # Complete Host rows (including Aux/Flag) remain in actualEvents.
        return {"label": self.label(value["handle"]), "rawId": value["handle"]["id"],
                "main": value["main"]}

    def event(self, raw):
        self.raw.append(raw)
        value = representation(raw)
        kind = value["kind"]
        if kind == "Reserved":
            world = value["worldName"]
            key = self.key(value["handle"])
            if key in self.bindings:
                raise ValueError("reserved handle reissued")
            if world in self.namespaces and self.namespaces[world] != key[0]:
                raise ValueError("world namespace changed")
            self.namespaces[world] = key[0]
            if len(set(self.namespaces.values())) != len(self.namespaces):
                raise ValueError("distinct worlds share a namespace")
            self.bindings[key] = value["label"]
            schema = self.result["schema"]
            names = ("Position", "Velocity", "Selected") if schema == "Motion" else ("Vitals", "Armor", "Tracked")
            components = [{"name": name, "value": value["components"][field]}
                          for field, name in zip(("main", "aux", "flag"), names)
                          if value["components"][field] is not None]
            self.result["rawReservations"].append({"world": world, "label": value["label"],
                "rawId": key[1], "rawHandle": key[1], "components": components})
        elif kind == "Read":
            def handles(field):
                return [{"label": self.label(handle), "rawId": handle["id"]}
                        for handle in value[field]]
            self.result["reads"].append({"step": value["step"], "who": value["system"],
                "count": value["count"], "q": [self.row(row) for row in value["query"]],
                "added": [self.main_row(row) for row in value["added"]],
                "changed": [self.main_row(row) for row in value["changed"]],
                "removed": handles("removed"), "despawned": handles("despawned"),
                "messages": value["messages"], "lag": {"messages": value["messageLag"],
                "removed": "unavailable-public-api", "despawned": "unavailable-public-api"}})
        elif kind == "ReadDone":
            reads = [read for read in self.result["reads"]
                     if read["step"] == value["step"] and read["who"] == value["system"]
                     and "traceDiagnostic" not in read]
            if len(reads) != 1:
                raise ValueError("reader completion has no unique actual invocation")
            read = reads[0]
            schema = self.result["schema"]
            missed = []
            if value["messageLag"]:
                missed.append({"kind": "event", "stream": schema + "Ping"})
            if value["removedLag"]:
                missed.append({"kind": "removed", "stream": "Position" if schema == "Motion" else "Vitals"})
            if value["despawnedLag"]:
                missed.append({"kind": "despawned", "stream": "despawned"})
            diagnostic = {"frame": value["frame"], "tick": value["tick"],
                "outcome": {"Success": "ok", "Failure": "failed"}[value["outcome"]["kind"]],
                "missed": missed}
            read["traceDiagnostic"] = diagnostic
            self.result["readerDiagnostics"].append({"step": value["step"],
                "who": value["system"], "count": read["count"], **diagnostic})
        elif kind == "Snapshot":
            world = value["worldName"]
            state = value["world"]
            if self.namespaces.get(world, state["namespace"]) != state["namespace"]:
                raise ValueError("snapshot namespace differs from actual reservations")
            auxiliary = []
            for row in state["rows"]:
                if row["aux"] is not None:
                    handle = {"namespace": state["namespace"], "id": row["id"]}
                    auxiliary.append({"label": self.label(handle, world), "rawId": row["id"],
                                      "aux": row["aux"], "main": row["main"], "flag": row["flag"]})
            self.result["snapshots"].append({"world": world, "name": value["step"],
                "q": [self.row(row, world) for row in value["query"]],
                "plus": [self.row(row, world) for row in value["plus"]],
                "minus": [self.row(row, world) for row in value["minus"]],
                "optional": [self.row(row, world, True) for row in value["optional"]],
                "aux": auxiliary, "ledger": state["ledger"],
                "lookups": {item["label"]: self.lookup(item, world) for item in value["lookups"]},
                "prior": outcome(value["prior"])})
        elif kind == "Dispatch":
            if type(value["tracked"]) is not bool:
                raise ValueError("dispatch tracker membership must be Boolean")
            if not value["tracked"]:
                return
            if value["worldName"] != "alpha":
                raise ValueError("public main dispatch tracker must belong to alpha")
            requested = {"A", "B", "Fast", "TailInner", "TailOuter"}
            counts = {}
            for item in value["counts"]:
                name = item["system"]
                if name in requested:
                    if name in counts:
                        raise ValueError("duplicate selected capture instance in dispatch observation")
                    counts[name] = item["value"]
            capture = {name: counts[name] for name in ("A", "B", "Fast")}
            tails = {"inner": counts["TailInner"][0], "outer": counts["TailOuter"][0]}
            self.result["dispatches"].append({"name": value["step"],
                "result": outcome(value["outcome"]), "counts": capture, "tails": tails})
            self.result["finalCounts"] = capture
            self.result["tails"] = tails
        elif kind == "Provisioning":
            missing = value["missing"]
            if missing not in self.preflights:
                raise ValueError("provisioning event lacks a complete observed IO interval")
            observed = self.preflights[missing]
            result = outcome(value["result"])
            if observed != {"missing": missing, "result": result,
                            "invocations": value["invocations"], "effects": value["effects"]}:
                raise ValueError("provisioning event disagrees with observed calls or IO effects")
            if type(value["actualE2BaseInstances"]) is not bool:
                raise ValueError("base-instance comparison must be Boolean")
            del self.preflights[missing]
            self.result.setdefault("provisioning", []).append({
                "missing": missing, "result": result, "invocations": value["invocations"],
                "effects": value["effects"], "actualE2BaseInstances": value["actualE2BaseInstances"]})
        elif kind == "ForeignLookup":
            receiver, source = value["receiver"], value["source"]
            handle = value["handle"]
            if receiver == source or receiver not in self.namespaces or source not in self.namespaces:
                raise ValueError("foreign lookup requires two observed distinct worlds")
            if handle["namespace"] != self.namespaces[source] or self.label(handle, source) != value["label"]:
                raise ValueError("foreign lookup did not use the observed source handle")
            if value["result"] != {"kind": "Missing"}:
                raise ValueError("foreign lookup violates approved MissingEntity policy")
            self.result["foreignLookupDivergence"].append({
                "receiver": receiver, "source": source, "label": value["label"],
                "rawHandle": handle["id"], "result": {"result": "MissingEntity"}})
        elif kind == "OwnWrites":
            if not value["views"]:
                return
            mains = []
            ledger = None
            reserved = None
            for view in value["views"]:
                if view["kind"] == "Main":
                    access = view["value"]
                    if access["kind"] != "Found":
                        raise ValueError("declared own write did not find Main")
                    main = access["value"]
                    mains.append(main[{"MotionMain": "position", "HealthMain": "vitals"}[main["kind"]]])
                elif view["kind"] == "Ledger":
                    ledger = view["value"]
                elif view["kind"] == "ReservedLookup":
                    reserved = {"Missing": "MissingEntity", "Mismatch": "QueryMismatch", "Found": "Found"}[view["value"]["kind"]]
                else:
                    raise ValueError(f"unknown own view: {view}")
            if value["system"] == "A" and len(mains) == 1:
                entries = [{"who": "A", "main": mains[0], "ledger": ledger, "reserved": reserved}]
            elif value["system"] == "B" and len(mains) == 3:
                entries = [{"who": "B:first", "main": mains[1]},
                           {"who": "B:second", "main": mains[2], "ledger": ledger, "reserved": reserved}]
            else:
                raise ValueError("unexpected closed callback observation sequence")
            self.result["ownWrites"].extend({"step": value["step"], **entry} for entry in entries)
        else:
            raise ValueError(f"unknown event kind: {kind}")

    def finish(self):
        if self.preflight_active is not None or self.preflights:
            raise ValueError("preflight IO/event observations incomplete")
        if any("traceDiagnostic" not in read for read in self.result["reads"]):
            raise ValueError("reader diagnostics incomplete")
        return {**self.result, "actualEvents": self.raw, "actualIOEvents": self.io}


def decode(text):
    lanes = []
    current = None
    for line in text.splitlines():
        if not line.strip():
            continue
        if line.startswith("PREFLIGHT-"):
            if current is None:
                raise ValueError("preflight IO before lane header")
            current.preflight_io(line)
            continue
        if re.fullmatch(r"[AB]:attempt:[0-9]+", line):
            if current is None:
                raise ValueError("Audit effect outside an actual lane")
            if current.preflight_active is not None:
                current.io.append(line)
                current.preflight_active["effects"].append(line)
            else:
                current.result["auditEffects"].append(line)
            continue
        value = json.loads(line)
        if isinstance(value, list):
            if current is None:
                raise ValueError("Host event array before lane header")
            for event in value:
                current.event(event)
        elif value["kind"] == "Lane":
            if current is not None:
                lanes.append(current.finish())
            current = Lane(value["schema"], value["style"])
        elif current is None:
            raise ValueError("Host event before lane header")
        else:
            current.event(value)
    if current is not None:
        lanes.append(current.finish())
    return {"results": lanes, "scope": "decoded actual Host output; comparison required"}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("observed", type=pathlib.Path)
    parser.add_argument("output", type=pathlib.Path)
    args = parser.parse_args()
    args.output.write_text(json.dumps(decode(args.observed.read_text()), indent=2) + "\n")


if __name__ == "__main__":
    main()

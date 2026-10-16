#!/usr/bin/env python3
"""Offline verifier for the source-level persistent-survivor deletion delivery."""
from __future__ import annotations
import gzip, hashlib, importlib.util, json, shutil, sys, tempfile, zipfile
from pathlib import Path, PurePosixPath

HERE = Path(__file__).resolve().parent
DELIVERY_REL = PurePosixPath("experiments/public-scopes/source-survivor-control-v1/delivery-v1")
WORKTREE = PurePosixPath("/workspace/formal-proofs/bendvy-worktrees/scopes45-source-survivor-control")
LEAF_REL = PurePosixPath("experiments/public-scopes/source-survivor-control-v1")
LEAF = WORKTREE / LEAF_REL
HELPER_PATH = "/workspace/formal-proofs/bendvy/experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/capacity-v1/array-transport-v1/matched-feature-v1/scheduled-followup-delivery-v1/verify.py"
EXPECTED = {"normal": (2328, "f146322db06365f4dc4805aff8604a20b119efc92df2debbe9002bd7f9cddeca"), "mutant": (2310, "c93a6c31eb56e50284a24986723fc818cf29ca6b2c913e005df3342abe78b024")}

class VerificationError(Exception):
    pass

def require(ok, message):
    if not ok:
        raise VerificationError(message)

def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()

def parse(data: bytes, label):
    try:
        return json.loads(data)
    except Exception as exc:
        raise VerificationError(f"invalid JSON {label}: {exc}") from exc

def canonical_external(path: str):
    p = PurePosixPath(path)
    require(p.is_absolute() and p.as_posix() == path and all(x not in ("", ".", "..") for x in p.parts), f"noncanonical full sourcePath: {path}")

def repo_root(here: Path):
    root = here.resolve()
    for _ in DELIVERY_REL.parts:
        root = root.parent
    require((root / Path(*DELIVERY_REL.parts)).resolve() == here.resolve(), "delivery moved from its repository path")
    return root

def local_owned(root: Path, rel: str):
    p = PurePosixPath(rel)
    require(not p.is_absolute() and p.as_posix() == rel and p.parts and all(x not in ("", ".", "..") for x in p.parts), f"invalid local ownership path: {rel}")
    base = root.resolve(); target = (base / Path(*p.parts)).resolve()
    try:
        target.relative_to(base)
    except ValueError as exc:
        raise VerificationError(f"local path escapes ownership root: {rel}") from exc
    require(target.is_file(), f"owned file missing: {rel}")
    return target

def verify_local(here: Path):
    here = here.resolve(); root = repo_root(here)
    delivery = parse((here / "DELIVERY.json").read_bytes(), "DELIVERY.json")
    ownership = parse((here / "OWNERSHIP.json").read_bytes(), "OWNERSHIP.json")
    producer = PurePosixPath(ownership.get("producerWorktree", ""))
    require(producer.is_absolute() and producer.as_posix() == ownership.get("producerWorktree") and all(x not in ("", ".", "..") for x in producer.parts), "producer path is not canonical")
    require(delivery.get("producerWorktree") == producer.as_posix(), "delivery/producer root differs")
    require(delivery.get("pathBase") == ownership.get("pathBase") == "repository-root-relative", "ownership path base differs")
    local = ownership.get("ownedPaths"); full = ownership.get("producerOwnedPaths")
    require(isinstance(local, list) and isinstance(full, list) and local == sorted(local) and full == sorted(full) and len(local) == len(full) == ownership.get("count"), "owned path list/count differs")
    mapping = {}
    for path in full:
        canonical_external(path)
        try:
            rel = PurePosixPath(path).relative_to(producer).as_posix()
        except ValueError as exc:
            raise VerificationError(f"owned path outside producer root: {path}") from exc
        require(rel not in ("", ".") and rel not in mapping, f"duplicate owned source suffix: {rel}")
        mapping[rel] = path
    require(sorted(mapping) == local, "local and producer ownership do not map one-to-one")
    require(delivery.get("ownedPaths") == local and delivery.get("producerOwnedPaths") == full, "delivery ownership differs")
    delivery_rel = (DELIVERY_REL / "DELIVERY.json").as_posix()
    require(delivery_rel in local, "delivery metadata is not owned")
    files = delivery.get("files", {})
    require(set(files) == set(local) - {delivery_rel}, "local delivery file selection differs")
    for rel, meta in files.items():
        require(meta.get("sourcePath") == mapping[rel], f"full sourcePath join differs for {rel}")
        raw = local_owned(root, rel).read_bytes()
        require((len(raw), digest(raw)) == (meta.get("bytes"), meta.get("sha256")), f"local file drift: {rel}")
    return delivery, ownership, root

def source_row(rows, path, expected_hash=None):
    canonical_external(path)
    row = rows.get(path)
    require(row is not None, f"exact full sourcePath absent: {path}")
    if expected_hash is not None:
        require(row["sha256"] == expected_hash, f"source hash differs: {path}")
    return row

def load_helper(rows, archive):
    row = source_row(rows, HELPER_PATH)
    raw = archive.read(row["member"])
    require(digest(raw) == row["sha256"], "retained verifier helper hash differs")
    with tempfile.TemporaryDirectory(prefix="component-write-helper-") as td:
        path = Path(td) / "retained_helper.py"; path.write_bytes(raw)
        spec = importlib.util.spec_from_file_location("retained_component_write_helper", path)
        module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
        module.VerificationError = VerificationError
        return module

def verify_source_bridge(rows, archive, result, plans):
    read = lambda path: archive.read(source_row(rows, path)["member"])
    freeze = parse(read(str(LEAF / "SOURCE-FREEZE.json")), "source freeze")
    sources = freeze["sources"]
    require(len(sources) == 80, "source count differs")
    changed = []
    for item in sources:
        a, b = str(WORKTREE / item["path"]), str(WORKTREE / item["mutantPath"])
        source_row(rows, a, item["sha256"]); source_row(rows, b, item["mutantSha256"])
        if read(a) != read(b):
            changed.append(item["path"])
            require(item["path"] == freeze["mutation"]["path"], "unexpected changed source")
            old, new = freeze["mutation"]["before"].encode(), freeze["mutation"]["after"].encode()
            require(read(a).count(old) == 1 and read(a).replace(old,new) == read(b), "mutation is not the single declared expression")
    require(changed == ["src/ecs/lifetime-scope.bend"], "mutation source set differs")
    for variant in EXPECTED:
        path_key, hash_key = ("path", "sha256") if variant == "normal" else ("mutantPath", "mutantSha256")
        expected = {str(WORKTREE / item[path_key]): item[hash_key] for item in sources if item["path"].endswith(".bend")}
        require(len(expected) == 78, "Bend closure size differs")
        for backend in ("js", "native"):
            plan = plans[variant + "-" + backend]
            require(plan["sourceInventory"] == expected and set(plan["importClosure"]) == set(expected), "source closure differs from frozen variant")
            for item in sources:
                require(plan["pins"].get(str(WORKTREE / item[path_key])) == item[hash_key], "full source/sidecar pin differs")
    checks = parse(read(str(LEAF / "SOURCE-CHECKS.json")), "checks")
    require({c["role"]: c["exitCode"] for c in checks["checks"]} == {"normal":1,"mutant":1,"normal-core":0,"mutant-core":0}, "source verdict scopes differ")
    for c in checks["checks"]:
        for stream in ("stdout", "stderr"):
            raw = read(str(LEAF / (c["role"] + "-check." + stream)))
            require(digest(raw) == c[stream + "Sha256"], "source check stream differs")
        if c["role"] in ("normal", "mutant"):
            require(b"5 defs rely on unsafe or foreign code" in read(str(LEAF / (c["role"] + "-check.stderr"))), "foreign diagnostic absent")
    oracle = parse(read(result["oracleFreeze"]), "oracle freeze")
    require(oracle["producerCommit"] == result["producerCommit"], "oracle producer differs")
    for variant in EXPECTED:
        side = oracle[variant]
        path_key, hash_key = ("path", "sha256") if variant == "normal" else ("mutantPath", "mutantSha256")
        expected = {item["path"]: item[hash_key] for item in sources}
        require(side["sourceInventory"] == {p:h for p,h in expected.items() if p.endswith(".bend")}, "oracle Bend source mapping differs")
        for rel,h in expected.items():
            source_row(rows, str(PurePosixPath(side["snapshot"]) / rel), h)

def verify_evidence(here: Path, negative=None):
    delivery, owner, root = verify_local(here)
    result = parse((here / "RESULT.json").read_bytes(), "result")
    manifest = parse((here / "MANIFEST.json").read_bytes(), "manifest")
    status = "PASS_SOURCE_SURVIVOR_CONTROL_DELIVERY"
    require(delivery["status"] == result["status"] == status and result["performanceClaim"] is False, "result status differs")
    for name,key in (("MANIFEST.json","manifest"),("RESULT.json","result"),("EVIDENCE.zip","archive")):
        raw=(here/name).read_bytes(); require((len(raw),digest(raw)) == (delivery[key]["bytes"],delivery[key]["sha256"]), "package hash differs")
    rows = {r["sourcePath"]: r for r in manifest["logicalPaths"]}
    require(len(rows) == len(manifest["logicalPaths"]), "duplicate full source path")
    objects = {o["sha256"]: o for o in manifest["objects"]}
    require(len(objects) == len(manifest["objects"]), "duplicate object")
    with zipfile.ZipFile(here/"EVIDENCE.zip") as archive:
        require(len(archive.namelist()) == len(set(archive.namelist())), "duplicate archive member")
        require(set(archive.namelist()) == {"objects/"+h for h in objects}, "archive membership differs")
        for h,o in objects.items():
            raw=archive.read(o["member"]); require(o["member"] == "objects/"+h and (len(raw),digest(raw)) == (o["bytes"],h), "object differs")
        for p,r in rows.items():
            canonical_external(p); o=objects[r["sha256"]]
            require((r["bytes"],r["member"]) == (o["bytes"],o["member"]), "path/object differs")
        reuse=parse((here/"REUSE.json").read_bytes(),"reuse")
        require(reuse["productionTreeBefore"] == reuse["productionTreeAfter"], "production tree changed")
        require(all(p.startswith(str(LEAF_REL)+"/") for p in reuse["changedPaths"]), "candidate changes production/workload")
        for ref in reuse["references"]:
            source_row(rows,ref["path"],ref["sha256"])
        for rel,h in reuse["scopeModulesUnchanged"].items():
            source_row(rows,str(WORKTREE/rel),h)
        for item in reuse["dependencyDrift"]:
            source_row(rows,str(WORKTREE/item["path"]),item["currentSHA256"])
        helper=load_helper(rows,archive)
        roles={r["name"]:r for r in result["roles"]}
        require(len(roles)==4 and set(roles)=={v+"-"+b for v in EXPECTED for b in ("js","native")}, "role inventory differs")
        verified={n:helper.verify_role(r,rows,manifest,archive) for n,r in roles.items()}
        for name,(plan,receipt) in verified.items():
            variant=name.split("-")[0]; expected=EXPECTED[variant]
            commands = receipt["commands"]
            expected_labels = ["emit","consumer"] if name.endswith("-js") else ["emit","build","consumer"]
            require([c["label"] for c in commands] == expected_labels, "backend stages differ")
            caps = {"emit":30,"build":120,"consumer":5}
            for c in commands:
                require(c["capSeconds"] == caps[c["label"]], "backend cap differs")
            require(commands[0]["argv"][3] == "/home/node/.bend/bin/bend-2.0.35", "non-stock Bend compiler")
            require(plan["pins"]["/home/node/.bend/bin/bend-2.0.35"] == "f77417474ded314ad5d1a68fa3ebbe214c2124bf04d56a59b05bc17be6b0327a", "stock compiler hash differs")
            if name.endswith("-native"):
                require(commands[1]["argv"][3:5] == ["/tmp/bendvy-clang19-diagnostic/clang19","-O3"], "ordinary Native build differs")
            require(receipt["status"] == "COMPLETE_CONSUMER_DEVELOPMENT_PASS", "incomplete backend")
            require((plan["oracleBytes"],plan["oracleSHA256"]) == expected, "oracle identity differs")
            consumer=next(c for c in receipt["commands"] if c["label"]=="consumer")
            require(consumer["stderr"]["bytes"]==0, "nonempty consumer stderr")
            require(receipt["wholeOracleSHA256"] == expected[1], "whole oracle receipt differs")
            helper.compare_gzip(archive,rows[plan["oracle"]],rows[consumer["stdout"]["path"]],*expected,name)
            if variant=="mutant":
                require(receipt["completeNormalBaselineRejected"] is True, "normal rejection absent")
                require((plan["normalOracleBytes"],plan["normalOracleSHA256"]) == EXPECTED["normal"], "normal baseline differs")
                require(gzip.decompress(archive.read(rows[plan["normalOracle"]]["member"])) != archive.read(rows[consumer["stdout"]["path"]]["member"]), "mutant matches normal")
        verify_source_bridge(rows,archive,result,{n:v[0] for n,v in verified.items()})
        js=next(c for c in verified["normal-js"][1]["commands"] if c["label"]=="consumer")
        native=next(c for c in verified["normal-native"][1]["commands"] if c["label"]=="consumer")
        if negative=="wrong-parent-receipt":
            helper.verify_stream(js["stdout"],"consumer.stdout",roles["normal-js"]["streamRoot"],rows,archive,path_override=native["stdout"]["path"])
        elif negative=="wrong-parent-manifest":
            altered=dict(rows);altered.pop(js["stdout"]["path"])
            helper.verify_stream(js["stdout"],"consumer.stdout",roles["normal-js"]["streamRoot"],altered,archive)
    return {"status":status,"roles":4,"bendInputsPerRole":78,"normalBytes":2328,"counterBytes":2310,"performanceClaim":False}

def selftest():
    verify_evidence(HERE)
    for negative in ("wrong-parent-receipt", "wrong-parent-manifest"):
        try:
            verify_evidence(HERE, negative)
        except VerificationError:
            pass
        else:
            raise VerificationError(f"{negative} was accepted")
    _, owner, root = verify_local(HERE)
    with tempfile.TemporaryDirectory(prefix="component-write-relocated-") as td:
        moved = Path(td)
        for rel in owner["ownedPaths"]:
            source = local_owned(root, rel); target = moved / Path(rel)
            target.parent.mkdir(parents=True, exist_ok=True); shutil.copyfile(source, target)
        local = moved / Path(*DELIVERY_REL.parts)
        verify_local(local)
        with (local / "README.md").open("ab") as stream:
            stream.write(b"drift")
        try:
            verify_local(local)
        except VerificationError as exc:
            require("file drift" in str(exc), "relocated drift rejected for another reason")
        else:
            raise VerificationError("relocated file drift was accepted")

def main():
    try:
        if sys.argv[1:] == ["--selftest"]:
            selftest(); print("PASS_SOURCE_SURVIVOR_CONTROL_DELIVERY_SELFTEST")
        elif not sys.argv[1:]:
            print(json.dumps(verify_evidence(HERE), sort_keys=True))
        else:
            raise VerificationError("usage: python3 verify.py [--selftest]")
        return 0
    except (VerificationError, KeyError, OSError, ValueError, zipfile.BadZipFile) as exc:
        print(f"FAIL_SOURCE_SURVIVOR_CONTROL_DELIVERY: {exc}", file=sys.stderr); return 1

if __name__ == '__main__':
    raise SystemExit(main())

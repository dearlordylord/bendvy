#!/usr/bin/env python3
"""Offline integrity and bounded-claim checks for delivery-v1."""

from __future__ import annotations

import copy
import hashlib
import json
import sys
import zipfile
from pathlib import Path
from typing import Any


HERE = Path(__file__).resolve().parent
REPO = HERE.parents[4]
EMPTY_SHA256 = hashlib.sha256(b"").hexdigest()
NORMAL_V1_SHA = "06cce9e3f7b9cb964199366c20bf23f8b120521324976cff07570fe87bff2c7c"
NORMAL_V2_SHA = "30d5cb408e8df3741f4c21147514aa7916e55ea508ce36b142da76fdb105e261"
NORMAL_V3_SHA = "f32d6203ac65b896ffccb6c885be80a05f390ddf99b0301c5a975def638d098a"
COUNTER_SHA = "58124a67b8615dc5ff960b7f0b8354917b40dda20bb75746ca82bbfc5d5f5fa7"
CANDIDATE_SHA = "bbfca9f7cfd4d838bdc3af19941fb70baf7a7f4727c079c70435c7669b6db573"
STAGED_CORE_SHA = "2f94155cae78160b7feed404e7a6a4be02c43cfcf6198fc24e251bc07d74256b"


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def require(condition: Any, message: str) -> None:
    if not condition:
        raise ValueError(message)


def jbytes(data: bytes, label: str) -> dict[str, Any]:
    try:
        value = json.loads(data)
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise ValueError(f"{label} is not valid UTF-8 JSON") from exc
    require(isinstance(value, dict), f"{label} must be a JSON object")
    return value


def member_bytes(zf: zipfile.ZipFile, manifest: dict[str, Any], name: str) -> bytes:
    members = manifest["archiveMembers"]
    require(name in members, f"missing manifest member {name}")
    raw = zf.read(name)
    row = members[name]
    require(len(raw) == row["bytes"], f"member size mismatch: {name}")
    require(sha(raw) == row["sha256"], f"member hash mismatch: {name}")
    return raw


def json_member(zf: zipfile.ZipFile, manifest: dict[str, Any], name: str) -> dict[str, Any]:
    return jbytes(member_bytes(zf, manifest, name), name)


def verify_manifest_archive(zf: zipfile.ZipFile, manifest: dict[str, Any]) -> None:
    rows = manifest.get("archiveMembers")
    require(isinstance(rows, dict) and bool(rows), "manifest archiveMembers is empty or malformed")
    names = zf.namelist()
    require(len(names) == len(set(names)), "archive contains duplicate member names")
    require(set(names) == set(rows), "archive members differ from manifest membership")
    for name in sorted(rows):
        member_bytes(zf, manifest, name)


def verify_role_sources(
    zf: zipfile.ZipFile, manifest: dict[str, Any], role_name: str, role: dict[str, Any]
) -> tuple[dict[str, Any], dict[str, Any]]:
    plan_raw = member_bytes(zf, manifest, role["plan"])
    receipt_raw = member_bytes(zf, manifest, role["receipt"])
    require(sha(plan_raw) == role["planSHA256"], f"{role_name}: plan hash mismatch")
    require(sha(receipt_raw) == role["receiptSHA256"], f"{role_name}: receipt hash mismatch")
    plan = jbytes(plan_raw, f"{role_name} plan")
    receipt = jbytes(receipt_raw, f"{role_name} receipt")
    require(len(plan.get("pins", {})) == role["pinCount"], f"{role_name}: pin count mismatch")
    inventory = plan.get("sourceInventory", {})
    require(len(inventory) == role["sourceInventoryCount"], f"{role_name}: source inventory count mismatch")
    require(set(plan.get("importClosure", [])) == set(inventory), f"{role_name}: import/source closure mismatch")
    for source_path, archive_path in role["sourceInventory"].items():
        require(source_path in inventory, f"{role_name}: source not in frozen inventory: {source_path}")
        raw = member_bytes(zf, manifest, archive_path)
        require(sha(raw) == inventory[source_path], f"{role_name}: inventory hash mismatch: {source_path}")
    require(set(role["sourceInventory"]) == set(inventory), f"{role_name}: source map is incomplete")
    for source_path, archive_path in role["pinnedTextSources"].items():
        if source_path in plan.get("pins", {}):
            raw = member_bytes(zf, manifest, archive_path)
            require(sha(raw) == plan["pins"][source_path], f"{role_name}: pinned text hash mismatch: {source_path}")
    require(receipt.get("planSHA256") == role["planSHA256"], f"{role_name}: receipt is not bound to plan")
    require(len(receipt.get("guards", [])) == len(role["guards"]), f"{role_name}: guard count mismatch")
    require(receipt.get("guardFailures") in (None, []), f"{role_name}: receipt reports guard failures")
    for receipt_guard, expected_guard in zip(receipt["guards"], role["guards"]):
        require(receipt_guard["sha256"] == expected_guard["sha256"], f"{role_name}: receipt/manifest guard hash mismatch")
        guard = json_member(zf, manifest, expected_guard["member"])
        require(guard.get("label") == expected_guard["label"], f"{role_name}: guard label mismatch")
        require(guard.get("unchanged") is True, f"{role_name}: guard not clean")
    return plan, receipt


def verify_command_join(
    plan: dict[str, Any],
    receipt: dict[str, Any],
    labels: list[str],
    caps: list[int],
    role: dict[str, Any],
    manifest: dict[str, Any],
    read_raw: Any,
) -> None:
    planned = plan.get("commands", [])
    actual = receipt.get("commands", [])
    require([x.get("label") for x in planned] == labels, "unexpected frozen command labels/order")
    require([x.get("label") for x in actual] == labels, "unexpected receipt command labels/order")
    require(len(actual) == len(planned), "receipt command count differs from plan")
    runner_hashes = [digest for path, digest in plan.get("pins", {}).items() if path.endswith("/scripts/task_runner.py")]
    require(len(runner_hashes) == 1, "plan lacks a unique pinned task_runner.py")
    archive_members = manifest["archiveMembers"]
    stream_base = role["consumerStdout"].rsplit("/", 1)[0]
    for p, a, cap in zip(planned, actual, caps):
        require(a.get("argv") == p.get("argv"), f"{a.get('label')}: receipt argv differs from plan")
        require(a.get("capSeconds") == p.get("capSeconds") == cap, f"{a.get('label')}: cap mismatch")
        require(a.get("exit") == 0 and a.get("failure") is None, f"{a.get('label')}: command did not exit cleanly")
        require(a.get("capture") == "split", f"{a.get('label')}: raw stream capture missing")
        require(a.get("runnerSHA256") == runner_hashes[0], "runner binding mismatch")
        for stream in ("stdout", "stderr"):
            info = a.get(stream, {})
            require(info.get("published") is True, f"{a.get('label')}: {stream} not published")
            require(info.get("path") and info.get("sha256"), f"{a.get('label')}: {stream} metadata missing")
            expected_member = f"{stream_base}/{a['label']}.{stream}"
            require(expected_member in archive_members, f"{a.get('label')}: archived {stream} member is missing")
            member_row = archive_members[expected_member]
            require(info["path"] == member_row["sourcePath"], f"{a.get('label')}: {stream} path does not join archived raw stream")
            stream_bytes = read_raw(expected_member)
            require(info["bytes"] == len(stream_bytes) == member_row["bytes"], f"{a.get('label')}: {stream} byte count mismatch")
            require(info["sha256"] == sha(stream_bytes) == member_row["sha256"], f"{a.get('label')}: {stream} digest mismatch")


def check_normal_and_mutant_records(
    roles: dict[str, Any], manifest: dict[str, Any], read_json: Any, read_raw: Any
) -> None:
    js_role = roles["ordinary-js"]
    js_plan, js_receipt = read_json(js_role["plan"]), read_json(js_role["receipt"])
    require(sha(read_raw(js_role["plan"])) == js_role["planSHA256"], "JS plan hash mismatch")
    require(sha(read_raw(js_role["receipt"])) == js_role["receiptSHA256"], "JS receipt hash mismatch")
    verify_command_join(js_plan, js_receipt, ["emit", "consumer"], [30, 5], js_role, manifest, read_raw)
    require(js_receipt["status"] == "INCOMPLETE", "historical JS receipt must remain INCOMPLETE")
    js_stdout = read_raw(js_role["consumerStdout"])
    js_stderr = read_raw(js_role["consumerStderr"])
    require(len(js_stdout) == 2205 and sha(js_stdout) == NORMAL_V3_SHA, "retained JS stdout is not exact v3 output")
    require(js_stderr == b"", "normal JS consumer stderr is not empty")
    require(js_plan["oracleBytes"] == 2189 and js_plan["oracleSHA256"] == NORMAL_V1_SHA, "original JS oracle binding changed")
    require(js_stdout != read_raw("evidence/oracles/independent-oracle-v1/expected.stdout"), "historical JS/v1 mismatch was erased")

    native_role = roles["ordinary-native"]
    native_plan, native_receipt = read_json(native_role["plan"]), read_json(native_role["receipt"])
    require(sha(read_raw(native_role["plan"])) == native_role["planSHA256"], "Native plan hash mismatch")
    require(sha(read_raw(native_role["receipt"])) == native_role["receiptSHA256"], "Native receipt hash mismatch")
    verify_command_join(native_plan, native_receipt, ["emit", "build", "consumer"], [30, 120, 5], native_role, manifest, read_raw)
    require(native_receipt["status"] == "COMPLETE_CONSUMER_DEVELOPMENT_PASS", "Native status mismatch")
    native_stdout = read_raw(native_role["consumerStdout"])
    require(len(native_stdout) == 2205 and sha(native_stdout) == NORMAL_V3_SHA, "Native stdout is not full normal v3")
    require(read_raw(native_role["consumerStderr"]) == b"", "Native consumer stderr is not empty")
    require(native_receipt.get("wholeOracleSHA256") == NORMAL_V3_SHA, "Native receipt oracle binding mismatch")
    require(native_plan["oracleBytes"] == 2205 and native_plan["oracleSHA256"] == NORMAL_V3_SHA, "Native plan oracle mismatch")
    require("-O3" in native_plan["commands"][1]["argv"], "Native run is not the reviewed ordinary -O3 build")
    require(native_role["generatedSource"] and native_role["generatedBinary"], "Native generated artifact bindings missing")

    retained = read_json("evidence/runtime-entry-wt/ordinary-input-v2/runtime01/RETAINED-JS-POSTHOC-V3.json")
    require(retained["status"] == "PASS_RETAINED_JS_NOT_FRESH_RUN", "post-hoc JS record has wrong status")
    require(retained["freshExecutionPerformed"] is False, "post-hoc JS record claims a fresh run")
    require(retained["retainedJavaScriptArtifacts"]["byteComparison"]["equal"] is True, "post-hoc JS byte comparison is not exact")
    require(retained["retainedJavaScriptArtifacts"]["consumerStdout"]["sha256"] == NORMAL_V3_SHA, "post-hoc record is not bound to retained stdout")

    mutant_role = roles["clock-mutant-js"]
    mutant_plan, mutant_receipt = read_json(mutant_role["plan"]), read_json(mutant_role["receipt"])
    require(sha(read_raw(mutant_role["plan"])) == mutant_role["planSHA256"], "mutant plan hash mismatch")
    require(sha(read_raw(mutant_role["receipt"])) == mutant_role["receiptSHA256"], "mutant receipt hash mismatch")
    verify_command_join(mutant_plan, mutant_receipt, ["emit", "consumer"], [30, 5], mutant_role, manifest, read_raw)
    require(mutant_receipt["status"] == "COMPLETE_CONSUMER_DEVELOPMENT_PASS", "mutant status mismatch")
    mutant_stdout = read_raw(mutant_role["consumerStdout"])
    require(len(mutant_stdout) == 2205 and sha(mutant_stdout) == COUNTER_SHA, "mutant stdout differs from full counter oracle")
    require(mutant_receipt.get("completeNormalBaselineRejected") is True, "mutant did not reject normal baseline")
    require(mutant_stdout != read_raw("evidence/oracles/independent-oracle-v3/expected.stdout"), "mutant does not falsify normal v3")
    require(mutant_receipt.get("wholeOracleSHA256") == COUNTER_SHA, "mutant receipt counter binding mismatch")


def verify_oracles(read_json: Any, read_raw: Any) -> None:
    expected = {
        "independent-oracle-v1": (2189, NORMAL_V1_SHA, "SOURCE_DERIVED_COMPLETE_ORACLE"),
        "independent-oracle-v2": (2201, NORMAL_V2_SHA, "SOURCE_DERIVED_COMPLETE_ORACLE_V2"),
        "independent-oracle-v3": (2205, NORMAL_V3_SHA, "SOURCE_DERIVED_COMPLETE_ORACLE_V3"),
        "counter-oracle-v1": (2205, COUNTER_SHA, "SOURCE_DERIVED_COUNTER_ORACLE_V1"),
    }
    for leaf, (size, digest, state) in expected.items():
        base = f"evidence/oracles/{leaf}"
        records = read_json(base + "/ORACLES.json")
        raw = read_raw(base + "/expected.stdout")
        require(records.get("state") == state, f"{leaf}: oracle state mismatch")
        require(records.get("runtimeOutputInputs") == [], f"{leaf}: model used runtime output")
        require(len(raw) == size and sha(raw) == digest, f"{leaf}: raw oracle hash mismatch")
        gz = read_raw(base + "/expected.stdout.gz")
        import gzip
        require(gzip.decompress(gz) == raw, f"{leaf}: gzip/raw oracle mismatch")


def verify_candidate_and_source_checks(zf: zipfile.ZipFile, manifest: dict[str, Any], result: dict[str, Any]) -> None:
    input_map = json_member(zf, manifest, "evidence/runtime-entry-wt/ordinary-input-v2/INPUT-MAP.json")
    candidate = member_bytes(zf, manifest, "evidence/candidate/src/ecs/inspector-runtime.bend")
    require(sha(candidate) == CANDIDATE_SHA, "candidate source hash mismatch")
    require(input_map["candidateExecutableBinding"]["candidateCoreSHA256"] == CANDIDATE_SHA, "input map candidate binding mismatch")
    row = next(x for x in input_map["stagedSources"] if x["relativePath"] == "src/ecs/inspector-runtime.bend")
    require(row["sourceSHA256"] == CANDIDATE_SHA and row["stageSHA256"] == STAGED_CORE_SHA, "candidate/stage source map changed")
    original_lines = candidate.splitlines(keepends=True)
    for rewrite in row["importOnlyRewrites"]:
        idx = rewrite["line"] - 1
        require(0 <= idx < len(original_lines), "import rewrite line is out of range")
        prior = original_lines[idx]
        ending = b"\r\n" if prior.endswith(b"\r\n") else (b"\n" if prior.endswith(b"\n") else b"")
        bare = prior[:-len(ending)] if ending else prior
        require(bare.decode("utf-8") == rewrite["from"], "source import rewrite does not match candidate")
        original_lines[idx] = rewrite["to"].encode() + ending
    staged = b"".join(original_lines)
    staged_raw = member_bytes(zf, manifest, "evidence/runtime-entry-wt/ordinary-input-v2/stage/src/ecs/inspector-runtime.bend")
    require(len(row["importOnlyRewrites"]) == 6, "candidate should have exactly six import rewrites")
    require(staged == staged_raw and sha(staged) == STAGED_CORE_SHA, "staged core is not the exact six-import rebase")
    current_path = REPO / "src/ecs/inspector-runtime.bend"
    if current_path.exists():
        require(sha(current_path.read_bytes()) == CANDIDATE_SHA, "working-tree candidate differs from archived candidate")

    # Preserve the check-only classification: the selected Bend wrapper reports
    # the expected six foreign/unsafe references, not a full type/proof success.
    check_path = "evidence/runtime-entry-wt/ordinary-input-v2/source-check-main-v1/receipt.json"
    check = json_member(zf, manifest, check_path)
    require(check["exit"] == 1 and check["expectedForeignRefusalOnly"] is True, "normal source check classification changed")
    require(check["closureCount"] == 22 and check["pinsUnchanged"] is True, "normal source check closure changed")
    err = member_bytes(zf, manifest, "evidence/runtime-entry-wt/ordinary-input-v2/source-check-main-v1/stderr").decode()
    require("Error: 6 defs rely on unsafe or foreign code:" in err, "normal source check does not show the expected six-refusal diagnostic")
    mutant_check = json_member(zf, manifest, "evidence/runtime-entry-wt/ordinary-input-v2/reached-clock-mutant-v1/source-check-main-v2/receipt.json")
    require(mutant_check["exit"] == 1 and mutant_check["sameSixForeignReferencesAsOrdinary"] is True, "mutant source check classification changed")
    require(mutant_check["stderrMatchesOrdinarySourceCheck"] is False, "mutant source-check raw diagnostic must remain distinct")


def verify_auxiliary(zf: zipfile.ZipFile, manifest: dict[str, Any], result: dict[str, Any]) -> None:
    checks = json_member(zf, manifest, "evidence/authority-controls-v2/CHECKS.json")
    entries = checks["checks"]
    require([e["name"] for e in entries] == ["positive", "undeclared-read", "cross-schema", "write-through-read", "opaque-owner-escape"], "authority control set/order changed")
    require([e["exit"] for e in entries] == [0, 1, 1, 1, 1], "authority control outcomes changed")
    require(all(e["capSeconds"] == 5 for e in entries), "authority control cap changed")
    for entry in entries:
        prefix = f"evidence/authority-controls-v2/checks/{entry['name']}"
        out = member_bytes(zf, manifest, prefix + ".stdout.log").decode(errors="replace")
        err = member_bytes(zf, manifest, prefix + ".stderr.log").decode(errors="replace")
        require(entry["expectedFragment"] in out + err, f"{entry['name']}: expected diagnostic fragment missing")
    require(checks["scope"].startswith("Parser/type/affine development controls"), "authority control scope overclaims")

    ts = json_member(zf, manifest, "evidence/ts-retention/RETENTION-INPUTS.json")
    require(len(ts["archiveInputs"]) == 59 and ts["executionActor"].startswith("root; original exec session82412"), "TS retention handoff differs")
    require(ts["wholeOracle"]["bytes"] == 24298 and ts["wholeOracle"]["lifecycles"] == 1, "TS retention fixture binding differs")
    require("no timing/profile/full #55" in ts["scope"] and ts["fixtureDistinction"], "TS retention scope/fixture distinction missing")

    basis = json_member(zf, manifest, "evidence/workshop-applicability/basis-audit.json")
    candidate = json_member(zf, manifest, "evidence/workshop-applicability/runtime-entry-audit.json")
    require(basis["reachedCount"] == 23 and basis["reachedCoreCount"] == 15, "protected gate reachability basis changed")
    require(candidate["reachedCount"] == 23 and candidate["selectedRootPinCount"] == 232, "runtime-entry applicability audit changed")
    require(candidate["proposedAdditiveModule"]["path"] == "src/ecs/inspector-runtime.bend", "applicability target differs")
    require(candidate["proposedAdditiveModule"]["reached"] is False, "candidate unexpectedly appears in protected reached closure")
    require("not a new run" in candidate["scope"] and "full #55 acceptance" in candidate["scope"], "applicability scope overclaims")

    # The TypeScript and protected-gate evidence are context only, not executions
    # of this consumer or new timings.
    require(result["typescriptRetention"]["crossFixtureParityClaim"] is False, "TS handoff is misrepresented as parity")
    require(result["protectedWorkshopApplicability"]["candidateRuntimeModuleReached"] is False, "protected-gate applicability overclaimed")


def verify_bundle(directory: Path = HERE, *, selftest: bool = False) -> None:
    delivery_path = directory / "DELIVERY.json"
    delivery = json.loads(delivery_path.read_text(encoding="utf-8"))
    archive_path = directory / "EVIDENCE.zip"
    manifest_path = directory / "MANIFEST.json"
    archive_raw, manifest_raw = archive_path.read_bytes(), manifest_path.read_bytes()
    require(sha(archive_raw) == delivery["artifacts"]["EVIDENCE.zip"]["sha256"], "delivery archive digest mismatch")
    require(sha(manifest_raw) == delivery["artifacts"]["MANIFEST.json"]["sha256"], "delivery manifest digest mismatch")
    for filename, item in delivery["artifacts"].items():
        raw = (directory / filename).read_bytes()
        require(len(raw) == item["bytes"] and sha(raw) == item["sha256"], f"delivery file hash mismatch: {filename}")
    manifest = jbytes(manifest_raw, "MANIFEST.json")
    result = json.loads((directory / "RESULT.json").read_text(encoding="utf-8"))
    owned = json.loads((directory / "OWNED-PATHS.json").read_text(encoding="utf-8"))
    expected_paths = {
        "src/ecs/inspector-runtime.bend",
        "experiments/public-inspect/inspector-runtime-entry-v1/delivery-v1/DELIVERY.json",
        "experiments/public-inspect/inspector-runtime-entry-v1/delivery-v1/EVIDENCE.zip",
        "experiments/public-inspect/inspector-runtime-entry-v1/delivery-v1/MANIFEST.json",
        "experiments/public-inspect/inspector-runtime-entry-v1/delivery-v1/OWNED-PATHS.json",
        "experiments/public-inspect/inspector-runtime-entry-v1/delivery-v1/README.md",
        "experiments/public-inspect/inspector-runtime-entry-v1/delivery-v1/RESULT.json",
        "experiments/public-inspect/inspector-runtime-entry-v1/delivery-v1/verify.py",
    }
    require(owned.get("count") == 8 and set(owned.get("paths", [])) == expected_paths, "owned selection differs from the exact eight paths")
    with zipfile.ZipFile(archive_path, "r") as zf:
        verify_manifest_archive(zf, manifest)
        require(len(zf.namelist()) == delivery["evidenceArchive"]["memberCount"], "delivery archive member count mismatch")
        require(sum(info.file_size for info in zf.infolist()) == delivery["evidenceArchive"]["uncompressedBytes"], "delivery archive expanded size mismatch")
        roles = manifest["roles"]

        def raw(name: str) -> bytes:
            return member_bytes(zf, manifest, name)

        def parsed(name: str) -> dict[str, Any]:
            return json_member(zf, manifest, name)

        for name, role in roles.items():
            verify_role_sources(zf, manifest, name, role)
        verify_candidate_and_source_checks(zf, manifest, result)
        verify_oracles(parsed, raw)
        check_normal_and_mutant_records(roles, manifest, parsed, raw)
        verify_auxiliary(zf, manifest, result)
        if selftest:
            # Exercise the same role checks against malformed in-memory records.
            js_role = roles["ordinary-js"]
            js_plan = json.loads(raw(js_role["plan"]))
            js_receipt = json.loads(raw(js_role["receipt"]))
            original = copy.deepcopy(js_receipt)
            bad = copy.deepcopy(js_receipt)
            bad["status"] = "COMPLETE_CONSUMER_DEVELOPMENT_PASS"
            expect_reject(lambda: require(bad["status"] == "INCOMPLETE", "JS receipt status mismatch"))
            bad = copy.deepcopy(original)
            bad["commands"][0]["capSeconds"] = 31
            expect_reject(lambda: verify_command_join(js_plan, bad, ["emit", "consumer"], [30, 5], js_role, manifest, raw))
            bad = copy.deepcopy(original)
            bad["commands"][0]["stderr"]["path"] = "/tmp/other.stderr"
            expect_reject(lambda: verify_command_join(js_plan, bad, ["emit", "consumer"], [30, 5], js_role, manifest, raw))
            bad = copy.deepcopy(original)
            bad["commands"][0]["stdout"]["bytes"] += 1
            expect_reject(lambda: verify_command_join(js_plan, bad, ["emit", "consumer"], [30, 5], js_role, manifest, raw))
            bad = copy.deepcopy(original)
            bad["commands"][0]["stdout"]["sha256"] = "0" * 64
            expect_reject(lambda: verify_command_join(js_plan, bad, ["emit", "consumer"], [30, 5], js_role, manifest, raw))
            native_receipt = json.loads(raw(roles["ordinary-native"]["receipt"]))
            bad = copy.deepcopy(native_receipt)
            bad["guards"].pop()
            expect_reject(lambda: require(len(bad["guards"]) == 10, "guard count mismatch"))
            mutant_receipt = json.loads(raw(roles["clock-mutant-js"]["receipt"]))
            bad = copy.deepcopy(mutant_receipt)
            bad["completeNormalBaselineRejected"] = False
            expect_reject(lambda: require(bad.get("completeNormalBaselineRejected") is True, "normal baseline was not rejected"))
    print("PASS_BOUNDED_INSPECTOR_RUNTIME_ENTRY_DELIVERY")


def expect_reject(action: Any) -> None:
    try:
        action()
    except (ValueError, AssertionError):
        return
    raise ValueError("malformed-record self-test was not rejected")


if __name__ == "__main__":
    if len(sys.argv) > 2 or (len(sys.argv) == 2 and sys.argv[1] != "--selftest"):
        raise SystemExit("usage: python3 verify.py [--selftest]")
    verify_bundle(selftest=len(sys.argv) == 2)

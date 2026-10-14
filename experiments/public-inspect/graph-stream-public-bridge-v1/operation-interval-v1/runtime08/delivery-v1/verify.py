#!/usr/bin/env python3
"""Verify the retained #55 runtime08 source and consumer packet."""

from __future__ import annotations

import gzip
import hashlib
import json
import pathlib
import sys
import zipfile


HERE = pathlib.Path(__file__).resolve().parent


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def read_json(data: bytes):
    return json.loads(data.decode("utf-8"))


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def main() -> int:
    portable = HERE / "PORTABLE.zip"
    manifest_path = HERE / "MANIFEST.json"
    delivery_path = HERE / "DELIVERY.json"
    manifest_bytes = manifest_path.read_bytes()
    delivery = read_json(delivery_path.read_bytes())
    manifest = read_json(manifest_bytes)

    require(delivery["format"] == "inspector55-runtime08-delivery-v1", "delivery format")
    require(delivery["manifestSHA256"] == sha256(manifest_bytes), "manifest hash")
    require(delivery["verifierSHA256"] == sha256((HERE / "verify.py").read_bytes()), "verifier hash")
    require(delivery["readmeSHA256"] == sha256((HERE / "README.md").read_bytes()), "README hash")
    ownership_bytes = (HERE / "OWNED-PATHS.json").read_bytes()
    require(delivery["ownershipSHA256"] == sha256(ownership_bytes), "ownership manifest hash")
    ownership = read_json(ownership_bytes)
    require(delivery["ownedPathCount"] == ownership["count"] == len(ownership["paths"]), "owned path count")
    archived_only = delivery.get("archiveOnlySourceCopies", [])
    require(len(archived_only) == 1, "archive-only source copy count")
    archived_copy = archived_only[0]
    require(archived_copy["repositoryPath"] not in ownership["paths"], "archive-only source is not a standalone owned path")
    portable_bytes = portable.read_bytes()
    require(delivery["portableSHA256"] == sha256(portable_bytes), "portable archive hash")
    require(delivery["portableBytes"] == len(portable_bytes), "portable archive size")
    require(manifest["format"] == "inspector55-runtime08-portable-manifest-v1", "manifest format")

    entries = manifest["members"]
    require(manifest["memberCount"] == len(entries), "manifest member count")
    expected = {entry["archivePath"]: entry for entry in entries}
    require(len(expected) == len(entries), "duplicate archive member")
    with zipfile.ZipFile(portable, "r") as archive:
        actual_names = set(archive.namelist())
        require(actual_names == set(expected), "archive membership")
        objects = {}
        for name, entry in expected.items():
            data = archive.read(name)
            require(len(data) == entry["bytes"], f"member size: {name}")
            require(sha256(data) == entry["sha256"], f"member hash: {name}")
            objects[name] = data

    def obj(name: str) -> bytes:
        require(name in objects, f"missing member: {name}")
        return objects[name]

    base = "evidence/runtime08/"
    oracle_prefix = "evidence/independent-oracle-v4/"
    oracle_raw = obj(oracle_prefix + "expected-bend.stdout")
    oracle_gzip = obj(oracle_prefix + "expected-bend.stdout.gz")
    require(gzip.decompress(oracle_gzip) == oracle_raw, "oracle gzip reconstruction")
    oracle_sha = sha256(oracle_raw)
    oracle_index = read_json(obj(oracle_prefix + "ORACLES.json"))
    require(oracle_index["sourceOnly"] is True and oracle_index["noRuntimeInputs"] is True, "oracle independence declaration")
    require(oracle_index["artifacts"][0]["sha256"] == oracle_sha, "oracle index hash")
    require(len(oracle_raw.splitlines()) == 136, "oracle interval count")

    source_map = read_json(obj(base + "SOURCE-COPY-MAP.json"))
    rows = source_map["rows"]
    require(len(rows) == 83 and source_map["originalClosureCount"] == 83, "source closure count")
    require(len({row["stageRelativePath"] for row in rows}) == 83, "source identity uniqueness")
    require(len(source_map["privateSemanticBodyChanges"]) == 3, "private semantic delta count")
    require(len(source_map["foreignImportEdges"]) == 26, "foreign import edge count")
    require(len(source_map["foreignResources"]) == 2, "foreign resource count")
    stage_prefix = base + "source-stage/"
    archived_row = next((row for row in rows if row["stageRelativePath"] == archived_copy["stageRelativePath"]), None)
    require(archived_row is not None, "archive-only source map row")
    expected_archive_path = stage_prefix + archived_row["stageRelativePath"]
    require(archived_copy["archivePath"] == expected_archive_path, "archive-only source member path")
    archived_bytes = obj(archived_copy["archivePath"])
    require(sha256(archived_bytes) == archived_copy["sha256"] == archived_row["stageSHA256"] == archived_row["canonicalSourceSHA256"], "archive-only source reconstruction SHA")
    require(archived_row["reconstructionMatchesContentSource"] is True, "archive-only source reconstruction map")
    for row in rows:
        staged = obj(stage_prefix + row["stageRelativePath"])
        require(sha256(staged) == row["stageSHA256"], f"staged source: {row['stageRelativePath']}")
    for resource in source_map["foreignResources"]:
        staged = obj(stage_prefix + resource["stageRelativePath"])
        require(sha256(staged) == resource["stageSHA256"] == resource["sourceSHA256"], "foreign resource bytes")

    for delta in source_map["privateSemanticBodyChanges"]:
        filename = pathlib.PurePosixPath(delta["canonicalSource"]).name
        candidate = obj("candidate-core/src/ecs/" + filename)
        staged = obj(stage_prefix + "src/ecs/" + filename)
        row = next(row for row in rows if row["canonicalSource"] == delta["canonicalSource"])
        require(sha256(candidate) == delta["privateCandidateSHA256"] == row["contentSourceSHA256"], f"candidate source: {filename}")
        require(sha256(staged) == row["stageSHA256"], f"candidate staged source: {filename}")

    protected = read_json(obj(base + "protected-workshop-applicability.json"))
    require(delivery["protectedWorkshopApplicability"]["sha256"] == sha256(obj(base + "protected-workshop-applicability.json")), "protected #28 audit hash")
    require(protected["status"] == "EXACT_PROTECTED_WORKSHOP_APPLICABILITY_FOR_THREE_UNREACHED_MODULES_NOT_NEW_TIMING", "protected #28 audit classification")
    require(protected["acceptedIntegrationCommit"] == "9a39b2d9e0aaf527c6b380380893f7ee79a023a4", "protected #28 accepted commit")
    require(protected["reachedCount"] == 23 and protected["reachedCoreCount"] == 15, "protected #28 reached closure")
    require(protected["currentRootReachedMismatches"] == 0, "protected #28 reached source matches")
    require(protected["currentRootPinCheck"]["count"] == 232 and protected["currentRootPinCheck"]["mismatches"] == 0, "protected #28 root pins")
    require(all(tool["matches"] for tool in protected["selectedToolChecks"]), "protected #28 tool pins")
    require(protected["originalGate"]["status"] == "NO_CONFIRMED_REGRESSION", "protected #28 result")
    require(protected["originalGate"]["pairsPerBackend"] == 20 and protected["originalGate"]["warmups"] == 2 and protected["originalGate"]["completeOutputs"] == 110, "protected #28 cohort")
    require(protected["originalGate"]["candidateProcessMediansMs"] == {"TS": 358.8111685, "JS": 146.875776, "Native": 33.2926415}, "protected #28 recorded medians")
    protected_deltas = protected["threeModuleDelta"]
    require(len(protected_deltas) == 3 and all(item["reached"] is False for item in protected_deltas), "protected #28 candidate modules are unreached")
    require({item["path"] for item in protected_deltas} == {delta["canonicalSource"].removeprefix("/workspace/formal-proofs/bendvy/") for delta in source_map["privateSemanticBodyChanges"]}, "protected #28 candidate path join")
    require(all(source["currentRootMatches"] for source in protected["reachedSources"]), "protected #28 reached-source byte matches")
    for delta, module in zip(source_map["privateSemanticBodyChanges"], sorted(protected_deltas, key=lambda item: item["path"])):
        require(module["candidateSHA256"] == delta["privateCandidateSHA256"], f"protected #28 candidate hash: {module['path']}")
        require(module["currentRootSHA256"] == delta["currentMasterSHA256"] == module["acceptedSnapshotSHA256"], f"protected #28 accepted source hash: {module['path']}")

    check = read_json(obj(base + "source-check-v2/receipt.json"))
    require(len(check["checks"]) == 2, "source check count")
    adapter, full_main = check["checks"]
    require(adapter["label"] == "staged-adapter" and adapter["exit"] == 0, "adapter source check")
    require(full_main["label"] == "staged-main" and full_main["exit"] == 1, "full-main check classification")
    for check_step in check["checks"]:
        for channel in ("stdout", "stderr"):
            ref = check_step[channel]
            name = pathlib.PurePosixPath(ref["path"]).name
            data = obj(base + "source-check-v2/" + name)
            require(len(data) == ref["bytes"] and sha256(data) == ref["sha256"], f"source-check {check_step['label']} {channel}")
    main_stderr = obj(base + "source-check-v2/staged-main.stderr")
    require(b"65 defs rely on unsafe or foreign code" in main_stderr, "expected FFI refusal")

    telemetry_text = []
    for role, expected_caps, expected_labels, guard_count in (
        ("js", [30, 5], ["emit", "consumer"], 7),
        ("native", [30, 120, 5], ["emit", "build", "consumer"], 10),
    ):
        role_prefix = base + role + "/"
        plan_bytes = obj(role_prefix + "plan.json")
        plan = read_json(plan_bytes)
        receipt_bytes = obj(role_prefix + "receipt.json")
        receipt = read_json(receipt_bytes)
        require(plan["role"] == role, f"{role} plan role")
        require(sha256(plan_bytes) == receipt["planSHA256"], f"{role} plan/receipt join")
        require(len(plan["pins"]) == 239, f"{role} plan pins")
        require(len(plan["sourceInventory"]) == 83 and len(plan["importClosure"]) == 83, f"{role} frozen closure count")
        require(plan["sourceStageBinding"]["stagedModules"] == 83, f"{role} staged modules")
        require(plan["sourceStageBinding"]["semanticBodyDeltaCount"] == 3, f"{role} plan body delta")
        require(plan["sourceStageBinding"]["mapSHA256"] == sha256(obj(base + "SOURCE-COPY-MAP.json")), f"{role} source map binding")
        require(plan["normalOracleBytes"] == len(oracle_raw), f"{role} oracle byte count")
        require(plan["normalOracleSHA256"] == oracle_sha, f"{role} oracle hash")
        require(plan["telemetryScope"].find("not an acceptance threshold or performance result") >= 0, f"{role} telemetry scope")
        require(plan["collectorBinding"]["collector"]["sha256"] == "4b5cd2a87e2f0c7b383252dff8ebb5d78b2be94691d3bc6ffef0c343a4e55e2d", f"{role} collector pin")
        require(plan["collectorBinding"]["strictTelemetryValidator"]["sha256"] == "7143e0849e2f527debde9350fbaa8c3fc3d68f1953084f23d785b1c1b595982b", f"{role} guard pin")
        require(receipt["status"] == "COMPLETE_CONSUMER_DEVELOPMENT_PASS", f"{role} status")
        require(receipt["timingQualification"] == "UNQUALIFIED_OPERATION_TO_RESULT_HANDOFF", f"{role} timing scope")
        require(receipt["wholeOracleSHA256"] == oracle_sha, f"{role} full-oracle receipt")
        commands = receipt["commands"]
        planned_commands = plan["commands"]
        require([command["label"] for command in commands] == expected_labels, f"{role} command order")
        require([command["label"] for command in planned_commands] == expected_labels, f"{role} planned command order")
        require([command["capSeconds"] for command in commands] == expected_caps, f"{role} command caps")
        require([command["capSeconds"] for command in planned_commands] == expected_caps, f"{role} planned command caps")
        require([command["argv"] for command in commands] == [command["argv"] for command in planned_commands], f"{role} exact command argv")
        require(all(command["exit"] == 0 and command["failure"] is None for command in commands), f"{role} command results")
        for command in commands:
            for channel in ("stdout", "stderr"):
                ref = command[channel]
                relative = pathlib.PurePosixPath(ref["path"]).name
                raw = obj(role_prefix + relative)
                require(ref["published"] is True, f"{role} {command['label']} {channel} publication")
                require(len(raw) == ref["bytes"] and sha256(raw) == ref["sha256"], f"{role} {command['label']} {channel}")
        guard_refs = receipt["guards"]
        require(len(guard_refs) == guard_count, f"{role} guard count")
        expected_guard_names = {"emit-pre.guard.json", "emit-acquired.guard.json", "emit-post.guard.json", "consumer-pre.guard.json", "consumer-acquired.guard.json", "consumer-post.guard.json", "final.guard.json"}
        if role == "native":
            expected_guard_names |= {"build-pre.guard.json", "build-acquired.guard.json", "build-post.guard.json"}
        require({pathlib.PurePosixPath(item["path"]).name for item in guard_refs} == expected_guard_names, f"{role} guard set")
        for guard_ref in guard_refs:
            name = pathlib.PurePosixPath(guard_ref["path"]).name
            guard_bytes = obj(role_prefix + name)
            require(sha256(guard_bytes) == guard_ref["sha256"], f"{role} guard receipt join: {name}")
            guard = read_json(guard_bytes)
            require(guard["unchanged"] is True, f"{role} guard result: {name}")
            for pin, pin_hash in plan["pins"].items():
                require(guard["actualPins"].get(pin) == pin_hash, f"{role} guard pin: {name} {pin}")

        stdout = obj(role_prefix + "consumer.stdout")
        stderr = obj(role_prefix + "consumer.stderr")
        require(stdout == oracle_raw and sha256(stdout) == oracle_sha, f"{role} complete stdout oracle")
        require(len(stdout.splitlines()) == 136, f"{role} complete output lines")
        telemetry = read_json(stderr)
        require(stderr.endswith(b"\n") and len(stderr.splitlines()) == 1, f"{role} telemetry framing")
        require(telemetry == receipt["consumerTelemetry"], f"{role} telemetry receipt")
        policy = plan["consumerStderrPolicy"]
        require(policy["kind"] == "interval-telemetry-v1", f"{role} telemetry policy kind")
        require(policy["elapsedNs"] == "decimal-string", f"{role} telemetry policy elapsed field")
        require(telemetry["bytes"] == policy["bytes"] and telemetry["digest"] == policy["digest"] and telemetry["intervals"] == policy["intervals"], f"{role} telemetry policy values")
        require(telemetry["elapsedNs"].isdigit(), f"{role} elapsed telemetry encoding")
        fnv = 2166136261
        for byte in stdout:
            fnv = ((fnv ^ byte) * 16777619) & 0xFFFFFFFF
        require(telemetry["bytes"] == len(stdout) and telemetry["digest"] == fnv and telemetry["intervals"] == 136, f"{role} telemetry/output join")
        generated_name = "scenario.js" if role == "js" else "scenario.c"
        generated = obj(role_prefix + generated_name)
        require(sha256(generated) == receipt["emitArtifactSHA256"], f"{role} generated artifact")
        if role == "native":
            native = obj(role_prefix + "scenario.native")
            require(sha256(native) == receipt["buildArtifactSHA256"], "native binary artifact")
        telemetry_text.append(f"{role}: {stderr.decode('utf-8').strip()}")

    print("PASS_RETAINED_RUNTIME08_JS_NATIVE_ORACLE_GUARDS_SOURCE_MAP")
    print("scope: finite N=1 JS and Native consumer outputs; operation-to-result-handoff telemetry is unqualified; no TS run, comparative performance, or production-adoption claim")
    for line in telemetry_text:
        print(line)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (KeyError, OSError, ValueError, json.JSONDecodeError, zipfile.BadZipFile) as error:
        print(f"FAIL: {error}", file=sys.stderr)
        raise SystemExit(1)

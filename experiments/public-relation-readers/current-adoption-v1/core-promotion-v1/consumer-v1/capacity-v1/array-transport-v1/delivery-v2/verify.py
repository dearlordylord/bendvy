#!/usr/bin/env python3
"""Portable, read-only verification for the bounded #43 array-transport packet."""
from __future__ import annotations

import copy
import gzip
import hashlib
import io
import json
import shutil
import sys
import tempfile
import zipfile
from pathlib import Path
from pathlib import PurePosixPath


HERE = Path(__file__).resolve().parent
DELIVERY_RELATIVE_PATH = PurePosixPath(
    "experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/"
    "consumer-v1/capacity-v1/array-transport-v1/delivery-v2"
)
EXPECTED_JS_GUARDS = [
    "emit-pre", "emit-acquired", "emit-post", "consumer-pre",
    "consumer-acquired", "consumer-post", "final",
]
EXPECTED_NATIVE_GUARDS = [
    "emit-pre", "emit-acquired", "emit-post", "build-pre",
    "build-acquired", "build-post", "consumer-pre",
    "consumer-acquired", "consumer-post", "final",
]


class VerificationError(Exception):
    pass


def require(condition: bool, message: str) -> None:
    if not condition:
        raise VerificationError(message)


def digest_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def git_blob_sha1(data: bytes) -> str:
    return hashlib.sha1(b"blob " + str(len(data)).encode("ascii") + b"\0" + data).hexdigest()


def hash_stream(stream) -> tuple[int, str]:
    h = hashlib.sha256()
    size = 0
    while True:
        block = stream.read(1024 * 1024)
        if not block:
            break
        size += len(block)
        h.update(block)
    return size, h.hexdigest()


def read_json_bytes(data: bytes, label: str):
    try:
        return json.loads(data)
    except Exception as exc:
        raise VerificationError(f"invalid JSON in {label}: {exc}") from exc


def local_repository_root(here: Path) -> Path:
    """Resolve this packet's checkout root from its fixed repository-relative location."""
    here = here.resolve()
    root = here
    for _ in DELIVERY_RELATIVE_PATH.parts:
        root = root.parent
    expected = root / Path(*DELIVERY_RELATIVE_PATH.parts)
    require(expected.resolve() == here,
            "delivery directory is not at its repository-relative owned location")
    return root


def resolve_local_owned_path(repository_root: Path, relative_path: str) -> Path:
    """Resolve a repository-relative path while rejecting traversal and symlink escape."""
    logical = PurePosixPath(relative_path)
    require(not logical.is_absolute() and logical.parts and
            all(part not in ("", ".", "..") for part in logical.parts) and
            logical.as_posix() == relative_path,
            f"owned path is not a canonical repository-relative path: {relative_path}")
    root = repository_root.resolve()
    candidate = root.joinpath(*logical.parts)
    resolved = candidate.resolve()
    try:
        resolved.relative_to(root)
    except ValueError as exc:
        raise VerificationError(f"owned path escapes the local repository root: {relative_path}") from exc
    require(resolved.is_file(), f"missing local owned file: {relative_path}")
    return resolved


def verify_owned_selection(here: Path) -> tuple[dict, dict, dict[str, str], Path]:
    """Join producer-owned absolute paths to same-relative local checkout paths."""
    here = here.resolve()
    repository_root = local_repository_root(here)
    delivery = read_json_bytes((here / "DELIVERY.json").read_bytes(), "DELIVERY.json")
    ownership = read_json_bytes((here / "OWNERSHIP.json").read_bytes(), "OWNERSHIP.json")

    producer_root = PurePosixPath(ownership.get("worktree", ""))
    require(producer_root.is_absolute() and
            producer_root.as_posix() == ownership.get("worktree") and
            all(part not in ("", ".", "..") for part in producer_root.parts),
            "producer worktree root is not a canonical absolute path")
    require(delivery.get("producerWorktree") == producer_root.as_posix(),
            "delivery/ownership producer root mismatch")
    require(delivery.get("pathBase") == ownership.get("pathBase") == "repository-root-relative",
            "owned-path base is not the local repository root")

    producer_paths = ownership.get("producerOwnedPaths")
    local_paths = ownership.get("ownedPaths")
    require(isinstance(producer_paths, list) and isinstance(local_paths, list) and
            len(producer_paths) == len(local_paths) == ownership.get("count"),
            "ownership path lists/count are inconsistent")
    require(local_paths == sorted(local_paths) and len(set(local_paths)) == len(local_paths),
            "local owned paths are not unique canonical sorted paths")

    source_by_local: dict[str, str] = {}
    for producer_path in producer_paths:
        producer_logical = PurePosixPath(producer_path)
        require(producer_logical.is_absolute() and
                producer_logical.as_posix() == producer_path and
                all(part not in ("", ".", "..") for part in producer_logical.parts),
                f"producer owned path is not canonical absolute: {producer_path}")
        try:
            relative = producer_logical.relative_to(producer_root)
        except ValueError as exc:
            raise VerificationError(f"producer owned path is outside its declared root: {producer_path}") from exc
        relative_text = relative.as_posix()
        require(relative_text not in ("", ".") and
                all(part not in ("", ".", "..") for part in relative.parts),
                f"producer owned path has invalid relative suffix: {producer_path}")
        require(relative_text not in source_by_local,
                f"duplicate producer-relative owned path: {relative_text}")
        source_by_local[relative_text] = producer_logical.as_posix()

    require(sorted(source_by_local) == local_paths,
            "producer paths do not map one-to-one to local repository-relative ownership")
    require(delivery.get("ownedPaths") == local_paths and
            delivery.get("producerOwnedPaths") == producer_paths,
            "delivery/ownership path mapping mismatch")

    delivery_relative = DELIVERY_RELATIVE_PATH.as_posix() + "/DELIVERY.json"
    require(delivery_relative in local_paths, "DELIVERY.json is absent from local ownership")
    files = delivery.get("files", {})
    require(set(files) == set(local_paths) - {delivery_relative},
            "delivery hashes do not cover the exact local owned selection minus DELIVERY.json")
    for relative_path, metadata in files.items():
        resolve_local_owned_path(repository_root, relative_path)
        require(metadata.get("sourcePath") == source_by_local[relative_path],
                f"producer source path differs from exact local relocation: {relative_path}")
        local_file = resolve_local_owned_path(repository_root, relative_path)
        with local_file.open("rb") as src:
            size, digest = hash_stream(src)
        require(size == metadata.get("bytes") and digest == metadata.get("sha256"),
                f"delivery metadata mismatch for local file: {relative_path}")
    return delivery, ownership, source_by_local, repository_root


def verify_command_stream(command: dict, stream_name: str, role_dir: str,
                          logical_rows: dict, archive: zipfile.ZipFile) -> None:
    stream = command[stream_name]
    expected_path = str(Path(role_dir) / f"{command['label']}.{stream_name}")
    require(stream.get("path") == expected_path,
            f"{command['label']} {stream_name}: unexpected full path")
    require(stream.get("published") is True,
            f"{command['label']} {stream_name}: stream was not published")
    row = logical_rows.get(expected_path)
    require(row is not None, f"{command['label']} {stream_name}: missing archive mapping")
    require(row["bytes"] == stream.get("bytes"),
            f"{command['label']} {stream_name}: receipt byte count differs from manifest")
    require(row["sha256"] == stream.get("sha256"),
            f"{command['label']} {stream_name}: receipt digest differs from manifest")
    with archive.open(row["member"], "r") as src:
        size, digest = hash_stream(src)
    require(size == stream["bytes"] and digest == stream["sha256"],
            f"{command['label']} {stream_name}: archived raw stream mismatch")


def compare_gzip_member(archive: zipfile.ZipFile, compressed_member: str,
                       raw_member: str, expected_bytes: int,
                       expected_sha: str) -> None:
    total = 0
    h = hashlib.sha256()
    with archive.open(raw_member, "r") as raw, archive.open(compressed_member, "r") as packed:
        with gzip.GzipFile(fileobj=packed, mode="rb") as oracle:
            while True:
                expected = oracle.read(1024 * 1024)
                actual = raw.read(len(expected) or 1)
                require(actual == expected, "consumer stdout differs from decompressed independent oracle")
                if not expected:
                    break
                total += len(expected)
                h.update(expected)
            require(raw.read(1) == b"", "consumer stdout has trailing bytes")
    require(total == expected_bytes, "independent oracle byte count mismatch")
    require(h.hexdigest() == expected_sha, "independent oracle raw digest mismatch")


def hash_gzip_member(archive: zipfile.ZipFile, compressed_member: str) -> tuple[int, str]:
    h = hashlib.sha256()
    size = 0
    with archive.open(compressed_member, "r") as packed:
        with gzip.GzipFile(fileobj=packed, mode="rb") as uncompressed:
            size, digest = hash_stream(uncompressed)
            return size, digest


def _verify_role(role_key: str, role: dict, delivery: dict, manifest: dict,
                 logical_rows: dict, archive: zipfile.ZipFile,
                 negative_mode: str | None = None) -> tuple[dict, dict]:
    plan_path = role["plan"]
    receipt_path = role["receipt"]
    plan_row = logical_rows.get(plan_path)
    receipt_row = logical_rows.get(receipt_path)
    require(plan_row is not None and receipt_row is not None,
            f"{role_key}: missing plan or receipt archive mapping")
    require(plan_row["sha256"] == role["planSHA256"], f"{role_key}: plan hash mismatch")
    require(receipt_row["sha256"] == role["receiptSHA256"], f"{role_key}: receipt hash mismatch")
    plan = read_json_bytes(archive.read(plan_row["member"]), f"{role_key} plan")
    receipt = read_json_bytes(archive.read(receipt_row["member"]), f"{role_key} receipt")
    require(digest_bytes(archive.read(plan_row["member"])) == role["planSHA256"],
            f"{role_key}: archived plan digest mismatch")
    require(digest_bytes(archive.read(receipt_row["member"])) == role["receiptSHA256"],
            f"{role_key}: archived receipt digest mismatch")
    require(receipt.get("planSHA256") == role["planSHA256"], f"{role_key}: receipt is not bound to plan")
    require(receipt.get("status") == "COMPLETE_CONSUMER_DEVELOPMENT_PASS",
            f"{role_key}: current role is not a complete consumer pass")
    require(role.get("freshRun") is True and role.get("receiptStatus") == receipt["status"],
            f"{role_key}: result/receipt status binding mismatch")

    inventory = plan.get("sourceInventory", {})
    closure = plan.get("importClosure", [])
    require(len(inventory) == 41 and set(inventory) == set(closure),
            f"{role_key}: source inventory/import closure mismatch")
    for path, expected in inventory.items():
        row = logical_rows.get(path)
        require(row is not None and row["sha256"] == expected,
                f"{role_key}: source closure member mismatch: {path}")

    external = {item["path"]: item["sha256"] for item in manifest["externalToolPins"]}
    tool_paths = set(plan.get("tools", {}).values())
    for path, expected in plan.get("pins", {}).items():
        if path in tool_paths:
            require(external.get(path) == expected, f"{role_key}: external tool pin mismatch: {path}")
        else:
            row = logical_rows.get(path)
            require(row is not None and row["sha256"] == expected,
                    f"{role_key}: pinned source/resource missing or changed: {path}")

    expected_labels = ["emit", "consumer"] if role_key == "js" else ["emit", "build", "consumer"]
    expected_caps = {"emit": 30, "build": 120, "consumer": 5}
    planned = plan.get("commands", [])
    commands = receipt.get("commands", [])
    require([c.get("label") for c in planned] == expected_labels,
            f"{role_key}: unexpected planned command order")
    require([c.get("label") for c in commands] == expected_labels,
            f"{role_key}: unexpected receipt command order")
    role_dir = str(Path(plan_path).parent)
    for pc, rc in zip(planned, commands):
        label = pc["label"]
        require(rc.get("argv") == pc.get("argv"), f"{role_key}/{label}: argv differs from frozen plan")
        require(rc.get("capSeconds") == pc.get("capSeconds") == expected_caps[label],
                f"{role_key}/{label}: cap mismatch")
        require(rc.get("exit") == 0 and rc.get("failure") is None,
                f"{role_key}/{label}: command was not successful")
        require(rc.get("capture") == "split", f"{role_key}/{label}: stream capture policy differs")
        for stream_name in ("stdout", "stderr"):
            command_copy = rc
            if negative_mode == f"wrong-parent-{role_key}-{label}-{stream_name}":
                command_copy = copy.deepcopy(rc)
                # Swap only the absolute parent, keeping the identical basename.
                other = "native" if role_key == "js" else "js"
                other_role = delivery["roles"][other]
                other_dir = str(Path(other_role["plan"]).parent)
                command_copy[stream_name]["path"] = str(Path(other_dir) / Path(rc[stream_name]["path"]).name)
            if negative_mode == f"wrong-hash-{role_key}-{label}-{stream_name}":
                command_copy = copy.deepcopy(rc)
                command_copy[stream_name]["sha256"] = "0" * 64
            verify_command_stream(command_copy, stream_name, role_dir, logical_rows, archive)
        require(rc["stderr"]["bytes"] == 0 and rc["stderr"]["sha256"] == digest_bytes(b""),
                f"{role_key}/{label}: stderr should be empty")

    expected_guards = EXPECTED_JS_GUARDS if role_key == "js" else EXPECTED_NATIVE_GUARDS
    guard_rows = receipt.get("guards", [])
    require(len(guard_rows) == len(expected_guards), f"{role_key}: guard count mismatch")
    actual_labels = []
    for guard in guard_rows:
        expected_path = str(Path(role_dir) / f"{guard['path'].split('/')[-1]}")
        require(guard["path"] == expected_path, f"{role_key}: guard full path mismatch")
        row = logical_rows.get(expected_path)
        require(row is not None and row["sha256"] == guard.get("sha256"),
                f"{role_key}: guard archive mapping mismatch")
        data = read_json_bytes(archive.read(row["member"]), f"{role_key} guard")
        actual_labels.append(data.get("label"))
        require(data.get("unchanged") is True, f"{role_key}: guard not unchanged")
        actual_pins = data.get("actualPins", {})
        for path, expected in plan.get("pins", {}).items():
            require(actual_pins.get(path) == expected,
                    f"{role_key}: guard does not retain pin {path}")
    require(actual_labels == expected_guards, f"{role_key}: guard order mismatch")

    oracle_path = plan["oracle"]
    oracle_row = logical_rows.get(oracle_path)
    require(oracle_row is not None, f"{role_key}: compressed oracle source missing")
    require(plan["oracleBytes"] == 252206150, f"{role_key}: unexpected full oracle size")
    consumer = commands[-1]
    out_path = consumer["stdout"]["path"]
    out_row = logical_rows.get(out_path)
    require(out_row is not None, f"{role_key}: consumer stdout not archived")
    require(receipt.get("wholeOracleSHA256") == plan["oracleSHA256"],
            f"{role_key}: receipt whole-oracle digest mismatch")
    compare_gzip_member(archive, oracle_row["member"], out_row["member"],
                       plan["oracleBytes"], plan["oracleSHA256"])

    generated = plan["generated"]
    generated_row = logical_rows.get(generated)
    require(generated_row is not None and generated_row["sha256"] == receipt.get("emitArtifactSHA256"),
            f"{role_key}: emitted artifact is not joined to receipt")
    emit_argv = planned[0]["argv"]
    require(generated in emit_argv, f"{role_key}: emit argv does not name generated artifact")
    if role_key == "native":
        native = plan["native"]
        native_row = logical_rows.get(native)
        require(native_row is not None and native_row["sha256"] == receipt.get("buildArtifactSHA256"),
                "native: built artifact is not joined to receipt")
        require(native in planned[1]["argv"], "native: build argv does not name executable artifact")
        require(native in planned[2]["argv"], "native: consumer argv does not execute artifact")
    return plan, receipt


def verify_packet(negative_mode: str | None = None,
                  delivery_dir: Path | None = None) -> dict:
    here = (delivery_dir or HERE).resolve()
    delivery, ownership, _source_by_local, repository_root = verify_owned_selection(here)
    manifest = json.loads((here / "MANIFEST.json").read_text())
    result = json.loads((here / "RESULT.json").read_text())
    archive_path = here / "EVIDENCE.zip"
    files = delivery["files"]
    require(delivery.get("status") == "BOUNDED_FULLCAPACITY_ARRAY_TRANSPORT_V2_DELIVERY",
            "unexpected delivery status")
    require(delivery.get("backendRuns") == 0 and delivery.get("noPerformanceClaim") is True,
            "delivery overstates backend or performance scope")
    require(result.get("status") == "BOUNDED_FULLCAPACITY_JS_NATIVE_DEVELOPMENT_PASS",
            "unexpected result status")
    verifier_meta = next((meta for name, meta in files.items()
                          if Path(name).name == "verify.py"), None)
    verifier_path = resolve_local_owned_path(repository_root,
                                             str(DELIVERY_RELATIVE_PATH / "verify.py"))
    require(verifier_meta and digest_bytes(verifier_path.read_bytes()) == verifier_meta["sha256"],
            "verifier self-hash mismatch")
    require(ownership["ownedPaths"] == delivery["ownedPaths"], "owned path lists differ")
    require(ownership["count"] == len(ownership["ownedPaths"]), "ownership count mismatch")
    require(delivery["ownedPaths"] == sorted(delivery["ownedPaths"]), "owned paths are not canonical sorted")
    delivery_path = DELIVERY_RELATIVE_PATH.as_posix() + "/DELIVERY.json"
    require(delivery_path in delivery["ownedPaths"], "DELIVERY.json is absent from ownership")

    with archive_path.open("rb") as src:
        zip_size, zip_sha = hash_stream(src)
    archive_meta = next((meta for name, meta in files.items()
                         if Path(name).name == "EVIDENCE.zip"), None)
    require(archive_meta is not None and zip_size == archive_meta["bytes"] and zip_sha == archive_meta["sha256"],
            "archive metadata mismatch")
    logical_rows = {row["logicalPath"]: row for row in manifest["logicalPaths"]}
    require(len(logical_rows) == len(manifest["logicalPaths"]), "duplicate logical path in manifest")
    objects = {item["sha256"]: item for item in manifest["objects"]}
    require(len(objects) == len(manifest["objects"]), "duplicate archive object digest")
    expected_members = {item["member"] for item in manifest["objects"]}
    with zipfile.ZipFile(archive_path, "r") as archive:
        names = archive.namelist()
        require(len(names) == len(set(names)), "duplicate ZIP member")
        require(set(names) == expected_members, "ZIP object set differs from manifest")
        for item in manifest["objects"]:
            require(item["member"] == f"objects/{item['sha256']}",
                    f"noncanonical content-addressed member: {item['member']}")
            with archive.open(item["member"], "r") as src:
                size, digest = hash_stream(src)
            require(size == item["bytes"] and digest == item["sha256"],
                    f"archive object mismatch: {item['member']}")
        for row in manifest["logicalPaths"]:
            obj = objects.get(row["sha256"])
            require(obj is not None and obj["member"] == row["member"] and obj["bytes"] == row["bytes"],
                    f"logical path object join mismatch: {row['logicalPath']}")

        js_plan, js_receipt = _verify_role("js", result["roles"]["js"], result,
                                           manifest, logical_rows, archive, negative_mode)
        native_plan, native_receipt = _verify_role("native", result["roles"]["native"], result,
                                                   manifest, logical_rows, archive, negative_mode)
        require(js_plan["oracleSHA256"] == native_plan["oracleSHA256"], "JS/Native oracle identity differs")

        for source_key in ("candidate",):
            source = result["source"][source_key]
            row = logical_rows.get(source)
            require(row is not None and row["sha256"] == result["source"]["sha256"],
                    "candidate source is not joined to archived bytes")
        for map_key in ("sourceIdentityMap", "losslessMap", "sourceDiff"):
            item = result["source"][map_key]
            row = logical_rows.get(item["path"])
            require(row is not None and row["sha256"] == item["sha256"],
                    f"source mapping artifact is not archived: {map_key}")
        require(result["source"]["sourceIdentityMap"]["entries"] == 41,
                "source identity map count is not 41")

        # Historical Native refusal is retained as an incomplete predecessor, not relabeled.
        hist_native = result["history"]
        old_plan_path = next(p for p in logical_rows if p.endswith("runtime-native-capacity-v1/plan.json"))
        old_receipt_path = str(Path(old_plan_path).parent / "receipt.json")
        old_plan = read_json_bytes(archive.read(logical_rows[old_plan_path]["member"]), "v1 Native plan")
        old_receipt = read_json_bytes(archive.read(logical_rows[old_receipt_path]["member"]), "v1 Native receipt")
        require(old_receipt["status"] == "INCOMPLETE", "v1 Native arity failure was relabeled")
        require(old_plan["commands"][0]["label"] == "emit" and len(old_receipt["commands"]) == 1,
                "v1 Native history command shape changed")
        old_err = logical_rows[str(Path(old_plan_path).parent / "emit.stderr")]
        require(old_err["bytes"] == 25, "v1 Native refusal stderr size changed")
        with archive.open(old_err["member"], "r") as f:
            require(f.read() == b"Error: an arity over 247\n", "v1 Native refusal diagnostic changed")
        require(old_receipt["planSHA256"] == hist_native["v1NativePlanSHA256"],
                "v1 Native receipt/plan join mismatch")
        require(digest_bytes(archive.read(logical_rows[old_plan_path]["member"])) ==
                hist_native["v1NativePlanSHA256"] and
                digest_bytes(archive.read(logical_rows[old_receipt_path]["member"])) ==
                hist_native["v1NativeReceiptSHA256"],
                "v1 Native archived role bytes differ from retained history metadata")

        old_js_plan_path = next(p for p in logical_rows if p.endswith("runtime-js-capacity-v1/plan.json"))
        old_js_receipt_path = str(Path(old_js_plan_path).parent / "receipt.json")
        old_js_plan = read_json_bytes(archive.read(logical_rows[old_js_plan_path]["member"]), "v1 JS plan")
        old_js_receipt = read_json_bytes(archive.read(logical_rows[old_js_receipt_path]["member"]), "v1 JS receipt")
        require(old_js_receipt["status"] == "COMPLETE_CONSUMER_DEVELOPMENT_PASS" and
                old_js_receipt["planSHA256"] == hist_native["v1JsPlanSHA256"] and
                digest_bytes(archive.read(logical_rows[old_js_plan_path]["member"])) ==
                hist_native["v1JsPlanSHA256"] and
                digest_bytes(archive.read(logical_rows[old_js_receipt_path]["member"])) ==
                hist_native["v1JsReceiptSHA256"],
                "historical v1 JS pass/plan join mismatch")
        old_js_oracle = logical_rows.get(old_js_plan["oracle"])
        old_js_stdout_path = old_js_receipt["commands"][-1]["stdout"]["path"]
        old_js_stdout = logical_rows.get(old_js_stdout_path)
        require(old_js_oracle is not None and old_js_stdout is not None,
                "historical v1 JS oracle or output is absent")
        compare_gzip_member(archive, old_js_oracle["member"], old_js_stdout["member"],
                            old_js_plan["oracleBytes"], old_js_plan["oracleSHA256"])

        # Independent source oracle and the lossless inverse are archived and checked.
        v2_oracle_path = next(p for p in logical_rows if p.endswith("independent-oracle-v2/ORACLE.json"))
        v2_oracle = read_json_bytes(archive.read(logical_rows[v2_oracle_path]["member"]), "v2 ORACLE.json")
        require(v2_oracle["outputBytes"] == 252206150 and v2_oracle["outputSHA256"] == js_plan["oracleSHA256"],
                "source oracle metadata differs from backend plans")
        require(v2_oracle["noRuntimeOutputInput"] is True, "v2 oracle is not source-only")
        oracle_gzip_path = str(Path(v2_oracle_path).parent / Path(v2_oracle["outputPath"]).name)
        oracle_gzip_row = logical_rows.get(oracle_gzip_path)
        require(oracle_gzip_row is not None and
                oracle_gzip_row["sha256"] == v2_oracle["compressedSHA256"] and
                oracle_gzip_row["bytes"] == v2_oracle["compressedBytes"],
                "source-derived oracle gzip is not joined to archive")
        basis_path = str(Path(v2_oracle_path).parent / "SOURCE-BASIS.json")
        basis_row = logical_rows.get(basis_path)
        require(basis_row is not None and basis_row["sha256"] == v2_oracle["sourceBasisSHA256"],
                "source-only oracle basis hash mismatch")
        require(v2_oracle["transportSourceSHA256"] == result["source"]["sha256"],
                "oracle is bound to another transport source")
        inv_path = str(Path(v2_oracle_path).parent / "INVERSE-RESULT.json")
        inv = read_json_bytes(archive.read(logical_rows[inv_path]["member"]), "v2 inverse result")
        require(inv["inverse"] is True and inv["outputBytes"] == v2_oracle["inputBytes"] and
                inv["outputSHA256"] == v2_oracle["inputSHA256"], "source inverse does not recover predecessor wire")
        predecessor = result["oracle"]["predecessorSourceWire"]
        predecessor_row = logical_rows.get(predecessor["path"])
        require(predecessor_row is not None and predecessor_row["bytes"] == predecessor["gzipBytes"] and
                predecessor_row["sha256"] == predecessor["gzipSHA256"],
                "predecessor source wire is not joined to archive")
        inverse_size, inverse_sha = hash_gzip_member(archive, predecessor_row["member"])
        require(inverse_size == inv["outputBytes"] == predecessor["rawBytes"] and
                inverse_sha == inv["outputSHA256"] == predecessor["rawSHA256"],
                "retained predecessor wire differs from the source-derived inverse result")

        # Reused #42 packet: bind its committed metadata and carried packet bytes.
        reuse = manifest["externalReuse"]
        require(reuse["commit"] == result["reusedForeignOperation"]["integratedCommit"],
                "#42 reuse commit does not match result provenance")
        require(result["reusedForeignOperation"]["reuseScope"].startswith(
                    "Discharges only the concrete independently-created same-schema foreign-operation"),
                "#42 reused-evidence scope was broadened")
        for name in ("DELIVERY.json", "EVIDENCE.zip", "FINAL-REVIEW.md", "MANIFEST.json",
                     "OWNERSHIP.json", "README.md", "RESULT.json", "VERIFIER-CONTROLS.json", "verify.py"):
            logical = f"/workspace/formal-proofs/bendvy/{reuse['path']}/{name}"
            row = logical_rows.get(logical)
            require(row is not None, f"reused #42 packet member missing: {name}")
            expected_blob = reuse["gitBlobSha1"].get(name)
            require(expected_blob, f"reused #42 commit blob missing: {name}")
            with archive.open(row["member"], "r") as src:
                data = src.read()
            require(git_blob_sha1(data) == expected_blob,
                    f"reused #42 bytes do not match integrated commit blob: {name}")
        io_delivery_path = f"/workspace/formal-proofs/bendvy/{reuse['path']}/DELIVERY.json"
        io_delivery = read_json_bytes(archive.read(logical_rows[io_delivery_path]["member"]), "#42 DELIVERY")
        require(io_delivery["status"] == "BOUNDED_IO_RELATION_AUTHORITY_DELIVERY",
                "#42 reused packet status changed")
        for filename, sha in io_delivery["files"].items():
            logical = f"/workspace/formal-proofs/bendvy/{reuse['path']}/{filename}"
            row = logical_rows.get(logical)
            require(row is not None and row["sha256"] == sha,
                    f"reused #42 delivery hash mismatch: {filename}")
        review_logical = f"/workspace/formal-proofs/bendvy/{reuse['path']}/FINAL-REVIEW.md"
        require(logical_rows[review_logical]["sha256"] ==
                result["reusedForeignOperation"]["packetFinalReviewSha256"],
                "#42 final review hash differs from bounded source result")

        io_evidence_path = f"/workspace/formal-proofs/bendvy/{reuse['path']}/EVIDENCE.zip"
        io_manifest_path = f"/workspace/formal-proofs/bendvy/{reuse['path']}/MANIFEST.json"
        io_result_path = f"/workspace/formal-proofs/bendvy/{reuse['path']}/RESULT.json"
        io_zip_data = archive.read(logical_rows[io_evidence_path]["member"])
        io_manifest = read_json_bytes(archive.read(logical_rows[io_manifest_path]["member"]), "#42 evidence manifest")
        io_result = read_json_bytes(archive.read(logical_rows[io_result_path]["member"]), "#42 result")
        native_scope = result["reusedForeignOperation"]["qualifiedNativeRole"]
        io_native = next(role for role in io_result["roles"] if role["name"] == "native")
        require(io_native["plan"] == native_scope["planPath"] and
                io_native["planSHA256"] == native_scope["planSHA256"] and
                io_native["receipt"] == native_scope["receiptPath"] and
                io_native["receiptSHA256"] == native_scope["receiptSHA256"],
                "#42 qualified Native role differs from packet result")
        with zipfile.ZipFile(io.BytesIO(io_zip_data), "r") as io_archive:
            io_names = set(io_archive.namelist())
            require(len(io_names) == len(io_archive.namelist()), "#42 evidence ZIP has duplicate objects")
            native_plan_path = native_scope["planPath"]
            native_receipt_path = native_scope["receiptPath"]
            io_native_plan = None
            io_native_receipt = None
            for source_path, expected in ((native_plan_path, native_scope["planSHA256"]),
                                          (native_receipt_path, native_scope["receiptSHA256"])):
                member = io_manifest["pathHashToMember"].get(source_path, {}).get(expected)
                require(member in io_names, f"#42 native plan/receipt absent from archive: {source_path}")
                body = io_archive.read(member)
                require(hashlib.sha256(body).hexdigest() == expected,
                        f"#42 native plan/receipt hash mismatch: {source_path}")
                if source_path == native_plan_path:
                    io_native_plan = read_json_bytes(body, "#42 native plan")
                else:
                    io_native_receipt = read_json_bytes(body, "#42 native receipt")
            require(io_native_plan is not None and io_native_receipt is not None,
                    "#42 Native plan/receipt could not be read")
            require(io_native_plan["sourceInventory"] == native_scope["sourceInventory"] and
                    len(io_native_plan["sourceInventory"]) == native_scope["sourceCount"],
                    "#42 Native plan source closure differs from recorded reuse scope")
            require(io_native_receipt["planSHA256"] == native_scope["planSHA256"] and
                    io_native_receipt["status"] == "COMPLETE_CONSUMER_DEVELOPMENT_PASS" and
                    io_native_receipt["wholeOracleSHA256"] == io_result["wholeOutputSHA256"] and
                    io_result["wholeOutputBytes"] == 18546,
                    "#42 Native receipt/result completion binding mismatch")
            io_stdout = io_native_receipt["commands"][-1]["stdout"]
            io_stdout_member = io_manifest["pathHashToMember"].get(io_stdout["path"], {}).get(io_stdout["sha256"])
            require(io_stdout_member in io_names and io_stdout["bytes"] == io_result["wholeOutputBytes"] and
                    io_stdout["sha256"] == io_result["wholeOutputSHA256"],
                    "#42 Native complete stdout is not bound to receipt/result")
            io_oracle_path = io_native_plan["oracle"]
            io_oracle_sha = io_native_plan["pins"][io_oracle_path]
            io_oracle_member = io_manifest["pathHashToMember"].get(io_oracle_path, {}).get(io_oracle_sha)
            require(io_oracle_member in io_names,
                    "#42 source-derived full oracle is not in the archived execution closure")
            compare_gzip_member(io_archive, io_oracle_member, io_stdout_member,
                                io_native_plan["oracleBytes"], io_native_plan["oracleSHA256"])
            for source_path, expected in native_scope["sourceInventory"].items():
                member = io_manifest["pathHashToMember"].get(source_path, {}).get(expected)
                require(member in io_names, f"#42 reached source absent from archive: {source_path}")
                metadata = io_manifest["members"].get(member)
                require(metadata is not None and metadata["sha256"] == expected,
                        f"#42 reached source manifest hash mismatch: {source_path}")
                body = io_archive.read(member)
                require(hashlib.sha256(body).hexdigest() == expected,
                        f"#42 reached source body mismatch: {source_path}")

            def source_text(suffix: str) -> str:
                matches = [(path, sha) for path, sha in native_scope["sourceInventory"].items()
                           if path.endswith(suffix)]
                require(len(matches) == 1, f"#42 expected one source for {suffix}")
                path, sha = matches[0]
                member = io_manifest["pathHashToMember"][path][sha]
                return io_archive.read(member).decode("utf-8")

            consumer_text = source_text("/independent-io-authority-v1/consumer.bend")
            require(consumer_text.count("WI.create(") == 2 and
                    all(token in consumer_text for token in
                        ("ForeignSource{}", "ForeignTarget{}", "ForeignClear{}", "C.write(")),
                    "#42 reached consumer does not retain both actual creations and foreign operations")
            composition_text = source_text("/mutation-composition-v1/consumer.bend")
            require("C.writer_registered(" in consumer_text and "Sy.run_tracked(" in composition_text,
                    "#42 registered writer/run path is not in the reached source closure")
            operations_text = source_text("/mutation-composition-v1/operations.bend")
            provider_text = source_text("/src/ecs/relation-providers.bend")
            commands_text = source_text("/src/ecs/relation-commands.bend")
            require("P.invoke_write(" in operations_text and
                    "A.queue_relate(" in provider_text and "A.queue_unrelate(" in provider_text and
                    "queue_namespaced(" in commands_text and "MissingEntity{}" in commands_text,
                    "#42 reached queue/provider source route differs from reported boundary")

    return {"status": "PASS_BOUNDED_FULLCAPACITY_ARRAY_TRANSPORT_V2",
            "logicalPaths": len(logical_rows), "archiveObjects": len(objects),
            "jsBytes": result["roles"]["js"]["stdoutBytes"],
            "nativeBytes": result["roles"]["native"]["stdoutBytes"],
            "scope": "bounded consumer evidence; full #43 acceptance remains open"}


def selftest() -> None:
    verify_packet()
    # Both role streams share the basename consumer.stdout. Swapping the full
    # parent must fail even though these two successful outputs have equal bytes.
    try:
        verify_packet("wrong-parent-js-consumer-stdout")
    except VerificationError:
        pass
    else:
        raise VerificationError("wrong-parent/same-basename stream mutation was accepted")
    try:
        verify_packet("wrong-hash-native-emit-stdout")
    except VerificationError:
        pass
    else:
        raise VerificationError("altered stream digest mutation was accepted")

    # Copy the selected files into a different checkout root. The positive
    # proves the producer's absolute paths are provenance only; the verifier
    # resolves the exact same repository-relative paths in this local copy.
    source_delivery, source_ownership, _source_map, source_root = verify_owned_selection(HERE)
    with tempfile.TemporaryDirectory(prefix="array-transport-relocation-") as temporary:
        relocated_root = Path(temporary)
        for relative_path in source_ownership["ownedPaths"]:
            original = resolve_local_owned_path(source_root, relative_path)
            relocated = relocated_root.joinpath(*PurePosixPath(relative_path).parts)
            relocated.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(original, relocated)
        relocated_here = relocated_root.joinpath(*DELIVERY_RELATIVE_PATH.parts)
        verify_owned_selection(relocated_here)

        readme_rel = DELIVERY_RELATIVE_PATH.as_posix() + "/README.md"
        producer_readme = source_delivery["files"][readme_rel]
        original_producer_readme = Path(producer_readme["sourcePath"])
        if original_producer_readme.is_file():
            with original_producer_readme.open("rb") as src:
                size, digest = hash_stream(src)
            require(size == producer_readme["bytes"] and digest == producer_readme["sha256"],
                    "producer README changed before relocated-copy negative control")

        relocated_readme = resolve_local_owned_path(relocated_root, readme_rel)
        with relocated_readme.open("ab") as dst:
            dst.write(b"local drift")
        try:
            verify_owned_selection(relocated_here)
        except VerificationError as exc:
            require("delivery metadata mismatch for local file" in str(exc),
                    "relocated changed-local-file control failed for an unrelated reason")
        else:
            raise VerificationError("changed local owned file was accepted via producer path")

        try:
            resolve_local_owned_path(relocated_root, "../outside-owned-root")
        except VerificationError:
            pass
        else:
            raise VerificationError("outside-root owned path was accepted")


def main() -> int:
    try:
        if sys.argv[1:] == ["--selftest"]:
            selftest()
            print("PASS_BOUNDED_FULLCAPACITY_ARRAY_TRANSPORT_V2_SELFTEST")
        elif not sys.argv[1:]:
            print(json.dumps(verify_packet(), sort_keys=True))
        else:
            raise VerificationError("usage: python3 verify.py [--selftest]")
        return 0
    except (VerificationError, KeyError, OSError, ValueError, zipfile.BadZipFile) as exc:
        print(f"FAIL_BOUNDED_FULLCAPACITY_ARRAY_TRANSPORT_V2: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())

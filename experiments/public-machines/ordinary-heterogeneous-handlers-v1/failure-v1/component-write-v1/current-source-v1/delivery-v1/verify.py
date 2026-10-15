#!/usr/bin/env python3
"""Offline verifier for the bounded current-source component-write delivery."""
from __future__ import annotations
import gzip, hashlib, importlib.util, json, shutil, sys, tempfile, zipfile
from pathlib import Path, PurePosixPath

HERE = Path(__file__).resolve().parent
DELIVERY_REL = PurePosixPath("experiments/public-machines/ordinary-heterogeneous-handlers-v1/failure-v1/component-write-v1/current-source-v1/delivery-v1")
WORKTREE = PurePosixPath("/workspace/formal-proofs/bendvy-worktrees/handlers49-component-write-current")
LEAF_REL = PurePosixPath("experiments/public-machines/ordinary-heterogeneous-handlers-v1/failure-v1/component-write-v1/current-source-v1")
LEAF = WORKTREE / LEAF_REL
HELPER_PATH = "/workspace/formal-proofs/bendvy/experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/capacity-v1/array-transport-v1/matched-feature-v1/scheduled-followup-delivery-v1/verify.py"
EXPECTED = (24422, "dfa63c0ed3b258d70c6622b4befd51a6ed1f1b319e718cf96f68b080fc2ff66d")

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
    binding = result["sourceFreeze"]
    freeze_row = source_row(rows, binding["path"], binding["sha256"])
    freeze = parse(archive.read(freeze_row["member"]), "producer source freeze")
    entry = (LEAF_REL / "main.bend").as_posix()
    require(freeze.get("entry") == entry and binding.get("entry") == entry, "producer freeze entry differs")
    sources = freeze.get("sources", [])
    require(len(sources) == binding.get("sourceCount") == 29, "producer source count differs")
    expected = {str(WORKTREE / item["path"]): item["sha256"] for item in sources}
    for item in sources:
        row = source_row(rows, str(WORKTREE / item["path"]), item["sha256"])
        require(row["bytes"] == item["bytes"], f"producer source size differs: {item['path']}")
    for name in ("component-write-js", "component-write-native"):
        plan = plans[name]
        require(plan.get("sourceInventory") == expected, f"{name} source inventory differs from producer freeze")
        require(set(plan.get("importClosure", [])) == set(expected), f"{name} literal closure differs from producer freeze")

    diff = binding["adaptationDiff"]
    diff_row = source_row(rows, diff["path"], diff["sha256"])
    require(diff_row["bytes"] == diff["bytes"] and diff_row["bytes"] > 0, "adaptation diff binding differs")

    checks_binding = binding["check"]
    checks_row = source_row(rows, checks_binding["path"], checks_binding["sha256"])
    checks = parse(archive.read(checks_row["member"]), "source-check record")
    require(checks.get("exitCode") == 0 and checks.get("sourcePassed") is True and checks.get("runtimeExecuted") is False, "source-check record does not pass or claims runtime")
    require(checks.get("stdoutSHA256") and checks.get("stderrSHA256"), "source-check stream hashes absent")
    for label in ("stdout", "stderr"):
        path = str(LEAF / f"check01.{label}")
        row = source_row(rows, path)
        raw = archive.read(row["member"])
        require((len(raw), digest(raw)) == (row["bytes"], row["sha256"]), f"source-check {label} stream differs")
        require(digest(raw) == checks[f"{label}SHA256"], f"source-check {label} hash differs from record")
        if label == "stdout":
            require(b"ALL PROOFS CHECK" in raw, "successful source check lacks checker receipt")

    oracle = result["independentOracle"]
    oracle_freeze_row = source_row(rows, oracle["sourceFreezePath"], oracle["sourceFreezeSHA256"])
    oracle_freeze = parse(archive.read(oracle_freeze_row["member"]), "independent oracle source freeze")
    require(oracle_freeze.get("producerCommit") == result.get("producerCommit", "")[:9], "oracle source freeze is not bound to this producer")
    oracle_sources = oracle_freeze.get("sourceInventory", {})
    producer_sources = {item["path"]: item["sha256"] for item in sources}
    require(oracle_sources == producer_sources and len(oracle_sources) == 29, "independent oracle source inventory differs")
    snapshot = PurePosixPath(oracle_freeze["snapshot"])
    for rel, h in oracle_sources.items():
        source_row(rows, str(snapshot / rel), h)
    expected_path = oracle["expectedGzipPath"]
    expected_row = source_row(rows, expected_path, oracle["expectedGzipSHA256"])
    raw_path = str(PurePosixPath(expected_path).with_name("expected.stdout"))
    raw_row = source_row(rows, raw_path)
    current_expected = archive.read(raw_row["member"])
    packed_expected = gzip.decompress(archive.read(expected_row["member"]))
    historical_path = oracle["historicalOraclePath"]
    historical_row = source_row(rows, historical_path, oracle["historicalOracleGzipSHA256"])
    require(historical_path in plans["component-write-js"].get("pins", {}), "historical oracle is not pinned by runtime plan")
    require(plans["component-write-js"]["pins"][historical_path] == historical_row["sha256"], "historical oracle runtime pin differs")
    historical = gzip.decompress(archive.read(historical_row["member"]))
    require(current_expected == packed_expected == historical, "source-derived oracle does not match exact historical full output")
    require((len(current_expected), digest(current_expected)) == EXPECTED, "source-derived oracle byte identity differs")
    require((oracle.get("outputBytes"), oracle.get("outputSHA256")) == EXPECTED, "oracle result binding differs")
    return freeze, oracle_freeze

def verify_evidence(here: Path, negative=None):
    delivery, owner, root = verify_local(here)
    result = parse((here / "RESULT.json").read_bytes(), "RESULT.json")
    manifest = parse((here / "MANIFEST.json").read_bytes(), "MANIFEST.json")
    status = "PASS_BOUNDED_CURRENT_COMPONENT_WRITE_DELIVERY"
    require(delivery.get("status") == result.get("status") == status, "delivery status differs")
    require(result.get("fullIssueAcceptance") == "OPEN" and result.get("performanceClaim") is False, "result overstates acceptance or performance")
    for name, key in (("MANIFEST.json", "manifest"), ("RESULT.json", "result"), ("EVIDENCE.zip", "archive")):
        raw = (here / name).read_bytes(); meta = delivery[key]
        require((len(raw), digest(raw)) == (meta["bytes"], meta["sha256"]), f"{name} package hash differs")
    rows_list = manifest.get("logicalPaths", [])
    rows = {row["sourcePath"]: row for row in rows_list}
    require(len(rows) == len(rows_list), "duplicate full sourcePath")
    objects = {item["sha256"]: item for item in manifest.get("objects", [])}
    require(len(objects) == len(manifest.get("objects", [])), "duplicate content-addressed object")
    require(all(item.get("member") == f"objects/{h}" for h, item in objects.items()), "noncanonical archive member")
    with zipfile.ZipFile(here / "EVIDENCE.zip", "r") as archive:
        require(set(archive.namelist()) == {item["member"] for item in objects.values()}, "archive membership differs from manifest")
        for row in rows_list:
            canonical_external(row["sourcePath"])
            obj = objects.get(row["sha256"])
            require(obj is not None and (obj["member"], obj["bytes"]) == (row["member"], row["bytes"]), "logical path/object mapping differs")
        for h, obj in objects.items():
            data = archive.read(obj["member"])
            require((len(data), digest(data)) == (obj["bytes"], h), f"archive object corrupt: {h}")
        helper = load_helper(rows, archive)
        roles = {item["name"]: item for item in result.get("roles", [])}
        expected_names = {"component-write-js", "component-write-native"}
        require(len(roles) == len(result.get("roles", [])) and set(roles) == expected_names, "runtime role inventory differs")
        verified = {name: helper.verify_role(role, rows, manifest, archive) for name, role in roles.items()}
        for name, (plan, receipt) in verified.items():
            require(receipt is not None, f"{name} receipt missing")
            require((plan.get("oracleBytes"), plan.get("oracleSHA256")) == EXPECTED, f"{name} plan oracle differs")
            require(receipt.get("status") == "COMPLETE_CONSUMER_DEVELOPMENT_PASS", f"{name} did not complete")
            consumer = next(command for command in receipt["commands"] if command["label"] == "consumer")
            require((consumer["stdout"]["bytes"], consumer["stdout"]["sha256"]) == EXPECTED, f"{name} output differs")
            require(consumer["stderr"]["bytes"] == 0, f"{name} consumer stderr is nonempty")
            require(receipt.get("wholeOracleSHA256") == EXPECTED[1], f"{name} receipt oracle differs")
            oracle_row = source_row(rows, plan["oracle"])
            helper.compare_gzip(archive, oracle_row, rows[consumer["stdout"]["path"]], EXPECTED[0], EXPECTED[1], name)
        js_plan, js_receipt = verified["component-write-js"]
        native_plan, native_receipt = verified["component-write-native"]
        require(js_plan["sourceInventory"] == native_plan["sourceInventory"], "JS/Native source inventories differ")
        js_consumer = next(c for c in js_receipt["commands"] if c["label"] == "consumer")
        native_consumer = next(c for c in native_receipt["commands"] if c["label"] == "consumer")
        require(js_consumer["stdout"]["sha256"] == native_consumer["stdout"]["sha256"], "JS/Native outputs differ")
        require(PurePosixPath(js_consumer["stdout"]["path"]).name == PurePosixPath(native_consumer["stdout"]["path"]).name, "wrong-parent control precondition differs")
        verify_source_bridge(rows, archive, result, {name: value[0] for name, value in verified.items()})
        if negative == "wrong-parent-receipt":
            helper.verify_stream(js_consumer["stdout"], "consumer.stdout", roles["component-write-js"]["streamRoot"], rows, archive, path_override=native_consumer["stdout"]["path"])
        elif negative == "wrong-parent-manifest":
            altered = dict(rows); altered.pop(js_consumer["stdout"]["path"], None)
            helper.verify_stream(js_consumer["stdout"], "consumer.stdout", roles["component-write-js"]["streamRoot"], altered, archive)
    return {"status": status, "roles": 2, "sourceClosureEntries": 29, "historicalOracleBridge": True, "fullPathNegativeControls": 2, "performanceClaim": False, "fullIssueAcceptance": "OPEN"}

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
            selftest(); print("PASS_BOUNDED_CURRENT_COMPONENT_WRITE_DELIVERY_SELFTEST")
        elif not sys.argv[1:]:
            print(json.dumps(verify_evidence(HERE), sort_keys=True))
        else:
            raise VerificationError("usage: python3 verify.py [--selftest]")
        return 0
    except (VerificationError, KeyError, OSError, ValueError, zipfile.BadZipFile) as exc:
        print(f"FAIL_BOUNDED_CURRENT_COMPONENT_WRITE_DELIVERY: {exc}", file=sys.stderr); return 1

if __name__ == '__main__':
    raise SystemExit(main())

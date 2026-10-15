#!/usr/bin/env python3
"""Offline verifier for the bounded ordinary transition-reader evidence packet."""
from __future__ import annotations
import gzip, hashlib, importlib.util, json, shutil, sys, tempfile, zipfile
from pathlib import Path, PurePosixPath

HERE = Path(__file__).resolve().parent
DELIVERY_REL = PurePosixPath("experiments/public-machines/ordinary-initialization-v1/ordinary-reader-v1/delivery-v1")
WORKTREE = PurePosixPath("/workspace/formal-proofs/bendvy-worktrees/machines48-ordinary-transition-reader")
LEAF_REL = PurePosixPath("experiments/public-machines/ordinary-initialization-v1/ordinary-reader-v1")
LEAF = WORKTREE / LEAF_REL
HELPER_PATH = "/workspace/formal-proofs/bendvy/experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/capacity-v1/array-transport-v1/matched-feature-v1/scheduled-followup-delivery-v1/verify.py"

class VerificationError(Exception): pass
def require(ok, message):
    if not ok: raise VerificationError(message)
def digest(data: bytes) -> str: return hashlib.sha256(data).hexdigest()
def parse(data: bytes, label):
    try: return json.loads(data)
    except Exception as exc: raise VerificationError(f"invalid JSON {label}: {exc}") from exc
def canonical_external(path):
    p=PurePosixPath(path)
    require(p.is_absolute() and p.as_posix()==path and all(x not in ("", ".", "..") for x in p.parts), f"noncanonical full sourcePath: {path}")
def repo_root(here):
    root=here.resolve()
    for _ in DELIVERY_REL.parts: root=root.parent
    require((root/Path(*DELIVERY_REL.parts)).resolve()==here.resolve(), "delivery moved from its repository path")
    return root
def local_owned(root, rel):
    p=PurePosixPath(rel)
    require(not p.is_absolute() and p.as_posix()==rel and p.parts and all(x not in ("", ".", "..") for x in p.parts), f"invalid local ownership path: {rel}")
    base=root.resolve(); target=(base/Path(*p.parts)).resolve()
    try: target.relative_to(base)
    except ValueError as exc: raise VerificationError(f"local path escapes ownership root: {rel}") from exc
    require(target.is_file(), f"owned file missing: {rel}")
    return target
def verify_local(here):
    here=here.resolve(); root=repo_root(here)
    delivery=parse((here/"DELIVERY.json").read_bytes(),"DELIVERY.json")
    ownership=parse((here/"OWNERSHIP.json").read_bytes(),"OWNERSHIP.json")
    producer=PurePosixPath(ownership.get("producerWorktree", ""))
    require(producer.is_absolute() and producer.as_posix()==ownership.get("producerWorktree") and all(x not in ("", ".", "..") for x in producer.parts), "producer path is not canonical")
    require(delivery.get("producerWorktree")==producer.as_posix(), "delivery/producer root differs")
    require(delivery.get("pathBase")==ownership.get("pathBase")=="repository-root-relative", "ownership path base differs")
    local=ownership.get("ownedPaths"); full=ownership.get("producerOwnedPaths")
    require(isinstance(local,list) and isinstance(full,list) and local==sorted(local) and full==sorted(full) and len(local)==len(full)==ownership.get("count"), "owned path list/count differs")
    mapping={}
    for path in full:
        canonical_external(path)
        try: rel=PurePosixPath(path).relative_to(producer).as_posix()
        except ValueError as exc: raise VerificationError(f"owned path outside producer root: {path}") from exc
        require(rel not in ("", ".") and rel not in mapping, f"duplicate owned source suffix: {rel}")
        mapping[rel]=path
    require(sorted(mapping)==local, "local and producer ownership do not map one-to-one")
    require(delivery.get("ownedPaths")==local and delivery.get("producerOwnedPaths")==full, "delivery ownership differs")
    delivery_path=(DELIVERY_REL/"DELIVERY.json").as_posix()
    require(delivery_path in local, "delivery metadata is not owned")
    files=delivery.get("files", {})
    require(set(files)==set(local)-{delivery_path}, "local delivery file selection differs")
    for rel,meta in files.items():
        require(meta.get("sourcePath")==mapping[rel], f"full sourcePath join differs for {rel}")
        raw=local_owned(root,rel).read_bytes()
        require((len(raw),digest(raw))==(meta.get("bytes"),meta.get("sha256")), f"local file drift: {rel}")
    return delivery, ownership, root
def source_row(rows, path, expected_hash=None):
    canonical_external(path); row=rows.get(path)
    require(row is not None, f"exact full sourcePath absent: {path}")
    if expected_hash is not None: require(row["sha256"]==expected_hash, f"source hash differs: {path}")
    return row
def load_helper(rows, archive):
    row=source_row(rows,HELPER_PATH)
    raw=archive.read(row["member"])
    require(digest(raw)==row["sha256"], "retained verifier helper hash differs")
    with tempfile.TemporaryDirectory(prefix="ordinary-reader-helper-") as td:
        path=Path(td)/"retained_helper.py"; path.write_bytes(raw)
        spec=importlib.util.spec_from_file_location("retained_reader_helper",path)
        module=importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
        module.VerificationError=VerificationError
        return module
def verify_freeze(rows, archive, plan, freeze_path, count, entry_path):
    freeze_row=source_row(rows,freeze_path)
    freeze=parse(archive.read(freeze_row["member"]),"source freeze")
    require(freeze.get("entry")==entry_path and len(freeze.get("sources",[]))==count, "producer source freeze entry/count differs")
    expected={str(WORKTREE/item["path"]):item["sha256"] for item in freeze["sources"]}
    require(plan.get("sourceInventory")==expected, "runtime source inventory differs from producer freeze")
    require(set(plan.get("importClosure",[]))==set(expected), "runtime literal closure differs from producer freeze")
    for item in freeze["sources"]:
        row=source_row(rows,str(WORKTREE/item["path"]),item["sha256"])
        require(row["bytes"]==item["bytes"], f"producer source byte count differs: {item['path']}")
    return freeze
def check_recorded_stream(rows, archive, rel, expected):
    path=(LEAF/PurePosixPath(rel)).as_posix(); row=source_row(rows,path)
    raw=archive.read(row["member"])
    require((len(raw),digest(raw))==(expected["bytes"],expected["sha256"]), f"retained source-check stream differs: {rel}")
    return raw
def verify_source_checks(rows, archive):
    checks=parse(archive.read(source_row(rows,(LEAF/"CHECKS.json").as_posix())["member"]),"normal source checks")
    require("Source check passed" in checks["finalResult"], "normal source-check final result is not passing")
    require(any(x["label"]=="main-check02" and x["exitCode"]==0 for x in checks["checks"]), "final main source check is absent")
    for check in checks["checks"]:
        for stream in check["streams"].values(): check_recorded_stream(rows,archive,stream["path"],stream)
    foreign=parse(archive.read(source_row(rows,(LEAF/"FOREIGN-CHECKS.json").as_posix())["member"]),"foreign source checks")
    require(len(foreign["attempts"])==5 and all(x["checkerExitCode"]==1 for x in foreign["attempts"]), "foreign checker history differs")
    require("no source-pass claim" in foreign["result"].lower() or "no source pass claim" in foreign["result"].lower(), "foreign source-check limitation missing")
    for attempt in foreign["attempts"]:
        for stream in attempt["streams"].values(): check_recorded_stream(rows,archive,stream["path"],stream)
    controls=parse(archive.read(source_row(rows,(LEAF/"controls-v1/CHECKS.json").as_posix())["member"]),"type controls")
    expected={"affine-positive.bend":0,"negative-cross-schema.bend":1,"negative-affine-duplicate.bend":1}
    require({x["file"]:x["exitCode"] for x in controls["controls"]}==expected, "type-control results differ")
    for control in controls["controls"]:
        source_row(rows,(LEAF/"controls-v1"/control["file"]).as_posix())
        for label in ("stdout","stderr"):
            path=(LEAF/"controls-v1"/control[label]).as_posix(); row=source_row(rows,path); data=archive.read(row["member"])
            require((len(data),digest(data))==(row["bytes"],row["sha256"]), f"type-control {label} bytes differ")
            if label=="stdout" and control["exitCode"]==0: require(b"ALL PROOFS CHECK" in data, "positive affine source check lacks successful receipt")
            if label=="stderr" and control["exitCode"]!=0: require(bool(data), "negative type control has empty diagnostic")
def verify_role_sources(rows, archive, plans):
    normal=verify_freeze(rows,archive,plans["primary-js"],(LEAF/"SOURCE-FREEZE.json").as_posix(),35,(LEAF_REL/"main.bend").as_posix())
    authority=verify_freeze(rows,archive,plans["authority-js"],(LEAF/"FOREIGN-SOURCE-FREEZE.json").as_posix(),38,(LEAF_REL/"foreign-disposal.bend").as_posix())
    require(all(x["path"].endswith(".bend") for x in authority["sources"]), "foreign Bend closure contains a non-Bend path")
    sidecars=[str(WORKTREE/"src/ecs/world-namespace.c"),str(WORKTREE/"src/ecs/world-namespace.js")]
    authority_plan=plans["authority-js"]
    require(all(p in authority_plan["pins"] for p in sidecars), "foreign WorldIO sidecar pins are incomplete")
    for path in sidecars: source_row(rows,path,authority_plan["pins"][path])
    mutant_role=plans["wrong-reader-disposal-mutant-js"]
    mutant_plan=mutant_role
    freeze_path=next(p for p in mutant_plan["pins"] if p.endswith("/authority-mutant-oracle-v1/source-freeze.json"))
    mutant_freeze=parse(archive.read(source_row(rows,freeze_path)["member"]),"mutant source freeze")
    mutant_inventory={str(PurePosixPath(mutant_freeze["snapshot"])/p):h for p,h in mutant_freeze["sourceInventory"].items()}
    require(mutant_plan["sourceInventory"]==mutant_inventory, "mutant runtime source inventory differs from frozen oracle source")
    base_path=next(p for p in plans["authority-js"]["pins"] if p.endswith("/authority-oracle-v1/source-freeze.json"))
    base_freeze=parse(archive.read(source_row(rows,base_path)["member"]),"normal authority source freeze")
    before=base_freeze["sourceInventory"]; after=mutant_freeze["sourceInventory"]
    changed=[p for p in before if before[p]!=after.get(p)]
    require(set(before)==set(after) and changed==["src/ecs/ordinary-machine-transition-reader.bend"], "mutant is not the single documented disposal mutation")
    normal_body=archive.read(source_row(rows,str(PurePosixPath(base_freeze["snapshot"])/changed[0]),before[changed[0]])["member"]).decode()
    mutant_body=archive.read(source_row(rows,str(PurePosixPath(mutant_freeze["snapshot"])/changed[0]),after[changed[0]])["member"]).decode()
    require("St.dispose(~V,stream,id)" in normal_body and "St.dispose(~V,stream,U32.add(id,1))" in mutant_body, "wrong-reader disposal mutation expression differs")
    return normal,authority
def verify_evidence(here: Path, negative=None):
    delivery, owner, root=verify_local(here)
    result=parse((here/"RESULT.json").read_bytes(),"RESULT.json")
    manifest=parse((here/"MANIFEST.json").read_bytes(),"MANIFEST.json")
    status="PASS_BOUNDED_ORDINARY_TRANSITION_READER_DELIVERY"
    require(delivery.get("status")==result.get("status")==status, "delivery status differs")
    require(result.get("fullIssueAcceptance")=="OPEN" and result.get("performanceClaim") is False, "result overstates acceptance or performance")
    for name,key in (("MANIFEST.json","manifest"),("RESULT.json","result"),("EVIDENCE.zip","archive")):
        raw=(here/name).read_bytes(); meta=delivery[key]
        require((len(raw),digest(raw))==(meta["bytes"],meta["sha256"]), f"{name} package hash differs")
    rows_list=manifest.get("logicalPaths",[]); rows={x["sourcePath"]:x for x in rows_list}
    require(len(rows)==len(rows_list), "duplicate full sourcePath")
    objects={x["sha256"]:x for x in manifest.get("objects",[])}
    require(len(objects)==len(manifest.get("objects",[])), "duplicate content-addressed object")
    require(all(x.get("member")==f"objects/{h}" for h,x in objects.items()), "noncanonical archive member")
    with zipfile.ZipFile(here/"EVIDENCE.zip","r") as archive:
        require(set(archive.namelist())=={x["member"] for x in objects.values()}, "archive membership differs from manifest")
        for row in rows_list:
            canonical_external(row["sourcePath"])
            obj=objects.get(row["sha256"])
            require(obj is not None and (obj["member"],obj["bytes"])==(row["member"],row["bytes"]), "logical path/object mapping differs")
        for h,obj in objects.items():
            raw=archive.read(obj["member"]); require((len(raw),digest(raw))==(obj["bytes"],h), f"archive object corrupt: {h}")
        helper=load_helper(rows,archive)
        roles={x["name"]:x for x in result.get("roles",[])}
        expected_names={"primary-js","primary-native","authority-js","authority-native","wrong-reader-disposal-mutant-js"}
        require(len(roles)==len(result.get("roles",[])) and set(roles)==expected_names, "runtime role inventory differs")
        verified={name:helper.verify_role(role,rows,manifest,archive) for name,role in roles.items()}
        expected={
            "primary-js":(105004,"f0d566ba6fa6c74efc28470d0ec3e406dcdc19ccd894a8b75e1329c6752089d6"),
            "primary-native":(105004,"f0d566ba6fa6c74efc28470d0ec3e406dcdc19ccd894a8b75e1329c6752089d6"),
            "authority-js":(17347,"70fe4679f1cbb93404e85785f476e8e4b359623a1b02ffda7dac83dd0feae2d4"),
            "authority-native":(17347,"70fe4679f1cbb93404e85785f476e8e4b359623a1b02ffda7dac83dd0feae2d4"),
            "wrong-reader-disposal-mutant-js":(17433,"5ec129da26837e8e48bc0f8c6a0f98ea88eece237d452a0318f1d24d8896bef2"),
        }
        for name,meta in expected.items():
            role=roles[name]; plan,receipt=verified[name]
            require((role["outputBytes"],role["outputSHA256"])==meta, f"{name} result metadata differs")
            require((plan["oracleBytes"],plan["oracleSHA256"])==meta, f"{name} plan oracle differs")
            consumer=next(c for c in receipt["commands"] if c["label"]=="consumer")
            helper.compare_gzip(archive,rows[plan["oracle"]],rows[consumer["stdout"]["path"]],meta[0],meta[1],name)
            require(consumer["stderr"]["bytes"]==0, f"{name} consumer stderr is nonempty")
            require(receipt["status"]=="COMPLETE_CONSUMER_DEVELOPMENT_PASS", f"{name} did not complete")
        for left,right in (("primary-js","primary-native"),("authority-js","authority-native")):
            _,lr=verified[left]; _,rr=verified[right]
            lc=next(c for c in lr["commands"] if c["label"]=="consumer"); rc=next(c for c in rr["commands"] if c["label"]=="consumer")
            require(lc["stdout"]["sha256"]==rc["stdout"]["sha256"], f"{left}/{right} outputs differ")
        mutant_plan,mutant_receipt=verified["wrong-reader-disposal-mutant-js"]
        require(mutant_plan["normalOracleSHA256"]==expected["authority-js"][1] and mutant_plan["normalOracleBytes"]==expected["authority-js"][0], "mutant normal baseline binding differs")
        mc=next(c for c in mutant_receipt["commands"] if c["label"]=="consumer")
        try: helper.compare_gzip(archive,rows[mutant_plan["normalOracle"]],rows[mc["stdout"]["path"]],mutant_plan["normalOracleBytes"],mutant_plan["normalOracleSHA256"],"normal authority baseline")
        except VerificationError: pass
        else: raise VerificationError("wrong-reader mutant unexpectedly matches normal authority output")
        normal,authority=verify_role_sources(rows,archive,{n:v[0] for n,v in verified.items()})
        verify_source_checks(rows,archive)
        js=roles["primary-js"]; native=roles["primary-native"]
        jsreceipt=verified["primary-js"][1]; natreceipt=verified["primary-native"][1]
        jsc=next(c for c in jsreceipt["commands"] if c["label"]=="consumer")
        nac=next(c for c in natreceipt["commands"] if c["label"]=="consumer")
        require(PurePosixPath(jsc["stdout"]["path"]).name==PurePosixPath(nac["stdout"]["path"]).name and jsc["stdout"]["sha256"]==nac["stdout"]["sha256"], "wrong-parent test precondition differs")
        if negative=="wrong-parent-receipt": helper.verify_stream(jsc["stdout"],"consumer.stdout",js["streamRoot"],rows,archive,path_override=nac["stdout"]["path"])
        if negative=="wrong-parent-manifest":
            altered=dict(rows); altered.pop(jsc["stdout"]["path"],None)
            helper.verify_stream(jsc["stdout"],"consumer.stdout",js["streamRoot"],altered,archive)
    return {"status":status,"roles":len(roles),"sourceClosureEntries":{"primary":35,"authority":38},"logicalPaths":len(rows),"objects":len(objects),"fullPathNegativeControls":2,"performanceClaim":False,"fullIssueAcceptance":"OPEN"}
def selftest():
    verify_evidence(HERE)
    for mode in ("wrong-parent-receipt","wrong-parent-manifest"):
        try: verify_evidence(HERE,mode)
        except VerificationError: pass
        else: raise VerificationError(f"{mode} negative control was accepted")
    _,owner,root=verify_local(HERE)
    with tempfile.TemporaryDirectory(prefix="ordinary-reader-relocated-") as td:
        moved=Path(td)
        for rel in owner["ownedPaths"]:
            source=local_owned(root,rel); target=moved/Path(rel); target.parent.mkdir(parents=True,exist_ok=True); shutil.copyfile(source,target)
        local=moved/Path(*DELIVERY_REL.parts); verify_local(local)
        readme=moved/Path((DELIVERY_REL/"README.md").as_posix())
        with readme.open("ab") as stream: stream.write(b"drift")
        try: verify_local(local)
        except VerificationError as exc: require("file drift" in str(exc), "relocated drift rejected for another reason")
        else: raise VerificationError("relocated local file drift was accepted")
def main():
    try:
        if sys.argv[1:]==["--selftest"]:
            selftest(); print("PASS_BOUNDED_ORDINARY_TRANSITION_READER_DELIVERY_SELFTEST")
        elif not sys.argv[1:]: print(json.dumps(verify_evidence(HERE),sort_keys=True))
        else: raise VerificationError("usage: python3 verify.py [--selftest]")
        return 0
    except (VerificationError,KeyError,OSError,ValueError,zipfile.BadZipFile) as exc:
        print(f"FAIL_BOUNDED_ORDINARY_TRANSITION_READER_DELIVERY: {exc}",file=sys.stderr); return 1
if __name__=="__main__": raise SystemExit(main())

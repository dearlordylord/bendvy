#!/usr/bin/env python3
"""Offline verifier for the bounded scheduled follow-up and current IO delivery."""
from __future__ import annotations
import gzip, hashlib, json, shutil, sys, tempfile, zipfile
from pathlib import Path, PurePosixPath

HERE = Path(__file__).resolve().parent
DELIVERY_REL = PurePosixPath("experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/capacity-v1/array-transport-v1/matched-feature-v1/scheduled-followup-delivery-v1")
class VerificationError(Exception): pass

def require(ok, message):
    if not ok: raise VerificationError(message)
def digest(data: bytes) -> str: return hashlib.sha256(data).hexdigest()
def parse_json(data: bytes, label: str):
    try: return json.loads(data)
    except Exception as exc: raise VerificationError(f"invalid JSON in {label}: {exc}") from exc
def hash_stream(stream):
    h=hashlib.sha256(); size=0
    while True:
        block=stream.read(1024*1024)
        if not block: break
        size += len(block); h.update(block)
    return size,h.hexdigest()
def canonical_external(path: str):
    p=PurePosixPath(path)
    require(p.is_absolute() and p.as_posix()==path and all(x not in ("", ".", "..") for x in p.parts), f"noncanonical evidence sourcePath: {path}")
def repo_root(here: Path):
    root=here.resolve()
    for _ in DELIVERY_REL.parts: root=root.parent
    require((root/Path(*DELIVERY_REL.parts)).resolve()==here.resolve(), "delivery is not at its fixed repository-relative location")
    return root
def local_owned(root: Path, rel: str):
    p=PurePosixPath(rel)
    require(not p.is_absolute() and p.as_posix()==rel and p.parts and all(x not in ("", ".", "..") for x in p.parts), f"noncanonical local path: {rel}")
    base=root.resolve(); out=(base/Path(*p.parts)).resolve()
    try: out.relative_to(base)
    except ValueError as exc: raise VerificationError(f"local ownership escapes repository: {rel}") from exc
    require(out.is_file(), f"missing local owned file: {rel}")
    return out
def verify_local_selection(here: Path):
    here=here.resolve(); root=repo_root(here)
    delivery=parse_json((here/"DELIVERY.json").read_bytes(),"DELIVERY.json")
    owner=parse_json((here/"OWNERSHIP.json").read_bytes(),"OWNERSHIP.json")
    producer=PurePosixPath(owner.get("producerWorktree",""))
    require(producer.is_absolute() and producer.as_posix()==owner.get("producerWorktree") and all(x not in ("", ".", "..") for x in producer.parts), "producer root is not canonical")
    require(delivery.get("producerWorktree")==producer.as_posix(), "producer root differs")
    require(owner.get("pathBase")==delivery.get("pathBase")=="repository-root-relative", "ownership base differs")
    local_paths=owner.get("ownedPaths"); producer_paths=owner.get("producerOwnedPaths")
    require(isinstance(local_paths,list) and isinstance(producer_paths,list) and local_paths==sorted(local_paths) and producer_paths==sorted(producer_paths) and len(local_paths)==len(producer_paths)==owner.get("count"), "ownership selection/count invalid")
    mapping={}
    for source in producer_paths:
        full=PurePosixPath(source)
        canonical_external(source)
        try: suffix=full.relative_to(producer)
        except ValueError as exc: raise VerificationError(f"owned path outside producer root: {source}") from exc
        rel=suffix.as_posix()
        require(rel not in ("", ".") and rel not in mapping, f"duplicate or empty producer suffix: {source}")
        mapping[rel]=source
    require(sorted(mapping)==local_paths, "producer paths do not map one-to-one to local files")
    require(delivery.get("ownedPaths")==local_paths and delivery.get("producerOwnedPaths")==producer_paths, "delivery/ownership mapping differs")
    delivery_rel=(DELIVERY_REL/"DELIVERY.json").as_posix()
    require(delivery_rel in local_paths, "DELIVERY.json missing from ownership")
    files=delivery.get("files",{})
    require(set(files)==set(local_paths)-{delivery_rel}, "delivery file selection differs from ownership")
    for rel,meta in files.items():
        require(meta.get("sourcePath")==mapping[rel], f"full producer path mapping differs: {rel}")
        path=local_owned(root,rel)
        raw=path.read_bytes()
        require(len(raw)==meta.get("bytes") and digest(raw)==meta.get("sha256"), f"local owned file drift: {rel}")
    return delivery,owner,root

def verify_stream(stream, label, stream_root, rows, archive, path_override=None):
    source=path_override if path_override is not None else stream.get("path")
    require(isinstance(source,str), f"{label}: stream path missing")
    canonical_external(source)
    require(source==str(PurePosixPath(stream_root)/label), f"{label}: full stream path differs from frozen command path")
    require(stream.get("published") is True, f"{label}: stream is unpublished")
    row=rows.get(source)
    require(row is not None, f"{label}: exact full sourcePath absent from manifest")
    require(row["bytes"]==stream.get("bytes") and row["sha256"]==stream.get("sha256"), f"{label}: receipt and manifest differ")
    with archive.open(row["member"],"r") as f: size,h=hash_stream(f)
    require((size,h)==(row["bytes"],row["sha256"]), f"{label}: archive object differs")
def compare_gzip(archive, gzip_row, raw_row, expected_bytes, expected_sha, label):
    h=hashlib.sha256(); size=0
    with archive.open(gzip_row["member"],"r") as packed, archive.open(raw_row["member"],"r") as raw:
        with gzip.GzipFile(fileobj=packed,mode="rb") as expected:
            while True:
                e=expected.read(1024*1024); a=raw.read(len(e) or 1)
                require(a==e,f"{label}: output differs from independent oracle")
                if not e: break
                size+=len(e); h.update(e)
            require(raw.read(1)==b"",f"{label}: output has trailing bytes")
    require((size,h.hexdigest())==(expected_bytes,expected_sha),f"{label}: independent oracle size/hash differs")
def verify_plan_inputs(plan, rows, manifest, role):
    inventory=plan.get("sourceInventory",{})
    require(set(inventory)==set(plan.get("importClosure",[])), f"{role}: source closure/import list differs")
    for path,h in inventory.items():
        row=rows.get(path); require(row is not None and row["sha256"]==h, f"{role}: source inventory input missing/drifted: {path}")
    tools={x["path"]:x["sha256"] for x in manifest.get("externalToolPins",[])}
    roots={x["root"]:x for x in manifest.get("resourceRootInventories",[])}
    for root,items in plan.get("resourceRoots",{}).items():
        canonical=json.dumps(items,sort_keys=True,separators=(",",":")).encode()
        entry=roots.get(root)
        require(entry is not None and entry.get("inventorySHA256")==digest(canonical) and entry.get("fileCount")==len(items), f"{role}: resource root inventory missing/drifted: {root}")
    root_names=tuple(plan.get("resourceRoots",{}))
    for path,h in plan.get("pins",{}).items():
        if path in plan.get("tools",{}).values():
            require(tools.get(path)==h, f"{role}: external tool pin missing/drifted: {path}")
        elif any(path==r or path.startswith(r.rstrip("/")+"/") for r in root_names):
            continue
        else:
            row=rows.get(path); require(row is not None and row["sha256"]==h, f"{role}: pinned input missing/drifted: {path}")
def verify_role(role, rows, manifest, archive):
    plan_row=rows.get(role["planPath"]); require(plan_row is not None and plan_row["sha256"]==role["planSHA256"], f"{role['name']}: plan sourcePath/hash absent")
    plan_raw=archive.read(plan_row["member"]); require(digest(plan_raw)==role["planSHA256"], f"{role['name']}: archived plan hash differs")
    plan=parse_json(plan_raw,f"{role['name']} plan")
    verify_plan_inputs(plan,rows,manifest,role["name"])
    if role["receiptPath"] is None:
        require(role["expectedStatus"]=="NOT_EXECUTED" and role["receiptSHA256"] is None, f"{role['name']}: invalid not-executed role")
        return plan,None
    receipt_row=rows.get(role["receiptPath"]); require(receipt_row is not None and receipt_row["sha256"]==role["receiptSHA256"],f"{role['name']}: receipt path/hash absent")
    raw_receipt=archive.read(receipt_row["member"]); require(digest(raw_receipt)==role["receiptSHA256"],f"{role['name']}: receipt object hash differs")
    receipt=parse_json(raw_receipt,f"{role['name']} receipt")
    require(receipt.get("planSHA256")==role["planSHA256"], f"{role['name']}: receipt does not bind plan")
    require(receipt.get("status")==role["expectedStatus"],f"{role['name']}: receipt status differs")
    planned=plan.get("commands",[]); actual=receipt.get("commands",[])
    require(len(planned)==len(actual),f"{role['name']}: command count differs")
    for pc,ac in zip(planned,actual):
        require(pc.get("label")==ac.get("label") and pc.get("argv")==ac.get("argv") and pc.get("capSeconds")==ac.get("capSeconds"),f"{role['name']}/{ac.get('label')}: command differs from plan")
        require(ac.get("capture")=="split",f"{role['name']}/{ac.get('label')}: capture is not split")
        for field in ("stdout","stderr"):
            verify_stream(ac[field],f"{ac['label']}.{field}",role["streamRoot"],rows,archive)
        if role["kind"]=="pass":
            require(ac.get("exit")==0 and ac.get("failure") is None,f"{role['name']}/{ac['label']}: command did not pass")
    for guard in receipt.get("guards",[]):
        p=guard.get("path"); canonical_external(p)
        require(PurePosixPath(p).parent.as_posix()==role["streamRoot"],f"{role['name']}: guard parent differs")
        row=rows.get(p); require(row is not None and row["sha256"]==guard.get("sha256"),f"{role['name']}: guard full-path join differs")
        data=parse_json(archive.read(row["member"]),f"{role['name']} guard")
        require(data.get("unchanged") is True,f"{role['name']}: guard reports drift")
        for path,h in plan.get("pins",{}).items():
            require(data.get("actualPins",{}).get(path)==h,f"{role['name']}: guard missing exact pin {path}")
    return plan,receipt

def verify_evidence(here: Path, negative=None):
    delivery,owner,root=verify_local_selection(here)
    require(delivery.get("status")=="BOUNDED_SCHEDULED_FOLLOWUP_IO_AND_MUTANT_CONTROLS_DELIVERY", "unexpected packet status")
    result=parse_json((here/"RESULT.json").read_bytes(),"RESULT.json")
    manifest=parse_json((here/"MANIFEST.json").read_bytes(),"MANIFEST.json")
    require(result.get("status")=="PASS_BOUNDED_SCHEDULED_FOLLOWUP_IO_AND_MUTANT_CONTROLS_DELIVERY", "unexpected result status")
    require(result.get("fullIssueAcceptance")=="OPEN" and result.get("performanceClaim") is False, "result overstates acceptance/performance")
    for name,meta in (("MANIFEST.json",delivery["manifest"]),("RESULT.json",delivery["result"]),("EVIDENCE.zip",delivery["archive"])):
        raw=(here/name).read_bytes(); require(len(raw)==meta["bytes"] and digest(raw)==meta["sha256"],f"{name}: delivery hash differs")
    vm=(DELIVERY_REL/"verify.py").as_posix(); require(digest((here/"verify.py").read_bytes())==delivery["files"][vm]["sha256"],"verifier self-hash differs")
    rows={r["sourcePath"]:r for r in manifest["logicalPaths"]}
    require(len(rows)==len(manifest["logicalPaths"]),"duplicate full sourcePath")
    objects={o["sha256"]:o for o in manifest["objects"]}; require(len(objects)==len(manifest["objects"]),"duplicate content object")
    for h,obj in objects.items():
        require(obj.get("member")==f"objects/{h}",f"noncanonical object member: {h}")
    with zipfile.ZipFile(here/"EVIDENCE.zip","r") as archive:
        names=archive.namelist(); require(len(names)==len(set(names)),"duplicate archive object")
        require(set(names)=={o["member"] for o in manifest["objects"]},"archive and object manifest differ")
        for row in manifest["logicalPaths"]:
            canonical_external(row["sourcePath"])
            obj=objects.get(row["sha256"])
            require(obj is not None and obj["member"]==row["member"] and obj["bytes"]==row["bytes"],f"path/object join differs: {row['sourcePath']}")
        for h,obj in objects.items():
            with archive.open(obj["member"],"r") as f: size,actual=hash_stream(f)
            require((size,actual)==(obj["bytes"],h),f"object digest differs: {h}")
        role_map={r["name"]:r for r in result["roles"]}
        verified={name:verify_role(role,rows,manifest,archive) for name,role in role_map.items()}
        expected_names={"primary-js","primary-native","io-js","io-native","mutant-wrong-reader","mutant-premature-publication"}
        require(len(role_map)==len(result["roles"]),"duplicate role name")
        require({r["name"] for r in result["roles"] if r["kind"]=="pass"}==expected_names,"successful backend/control role set differs")
        for name in expected_names:
            plan,receipt=verified[name]
            consumer=next(c for c in receipt["commands"] if c["label"]=="consumer")
            output=rows[consumer["stdout"]["path"]]
            oracle=rows.get(plan["oracle"]); require(oracle is not None,f"{name}: oracle gzip missing")
            require(receipt.get("wholeOracleSHA256")==plan.get("oracleSHA256"),f"{name}: receipt/plan oracle differs")
            compare_gzip(archive,oracle,output,plan["oracleBytes"],plan["oracleSHA256"],name)
        # Mutant outputs must match their independent mutant oracles and reject the complete normal baseline.
        for name in ("mutant-wrong-reader","mutant-premature-publication"):
            plan,receipt=verified[name]
            require(receipt.get("completeNormalBaselineRejected") is True,f"{name}: normal baseline rejection is absent")
            normal=rows.get(plan.get("normalOracle")); require(normal is not None,f"{name}: normal baseline oracle missing")
            consumer=next(c for c in receipt["commands"] if c["label"]=="consumer")
            output=rows[consumer["stdout"]["path"]]
            try:
                compare_gzip(archive,normal,output,plan["normalOracleBytes"],plan["normalOracleSHA256"],f"{name} complete normal baseline")
            except VerificationError:
                pass
            else:
                raise VerificationError(f"{name}: mutant unexpectedly matches complete normal baseline")
        # Historical actual01 is retained as a setup failure; actual02 is the independently rejected missing-fast trace.
        for name,expected_sha,expected_len in (("primary-actual01-js","81c66e550361841320866ba317306294d824e924db322d96dac340548dcb2266",13),("primary-actual02-js","26d7d8d8c488439fde3fcfc407eb269905af380e32f7d0c70ae91a717f3d0509",24765)):
            plan,receipt=verified[name]
            require(receipt.get("status")=="INCOMPLETE",f"{name}: historical mismatch status rewritten")
            cmd=next(c for c in receipt["commands"] if c["label"]=="consumer")
            row=rows[cmd["stdout"]["path"]]
            require((row["bytes"],row["sha256"])==(expected_len,expected_sha),f"{name}: preserved stdout differs")
            if name=="primary-actual01-js":
                with archive.open(row["member"],"r") as f: require(f.read()==b"setup-failed\n","actual01 diagnostic output changed")
            else:
                negative_path=str(PurePosixPath(plan["oracle"]).parent/"successor-repeat-chain-v1/rejected-omitted-fast.stdout")
                neg=rows.get(negative_path); require(neg is not None,f"{name}: source-derived rejected-fast control missing")
                require(archive.read(row["member"])==archive.read(neg["member"]),"actual02 no longer matches independently derived omitted-fast rejection")
        for name in ("primary-actual01-native","primary-actual02-native"):
            require(verified[name][1] is None and role_map[name]["expectedStatus"]=="NOT_EXECUTED",f"{name}: not-executed history changed")
        # Reached exact-path controls: JS and Native streams have the same basename/bytes, but are distinct sources.
        jsrec=verified["primary-js"][1]; nrec=verified["primary-native"][1]
        jsrole=role_map["primary-js"]; jsc=next(c for c in jsrec["commands"] if c["label"]=="consumer"); nc=next(c for c in nrec["commands"] if c["label"]=="consumer")
        require(PurePosixPath(jsc["stdout"]["path"]).name==PurePosixPath(nc["stdout"]["path"]).name and jsc["stdout"]["sha256"]==nc["stdout"]["sha256"],"same-basename negative-control precondition differs")
        if negative=="wrong-parent-receipt":
            verify_stream(jsc["stdout"],"consumer.stdout",jsrole["streamRoot"],rows,archive,path_override=nc["stdout"]["path"])
        elif negative=="wrong-parent-manifest":
            # Retargeting to the other same-basename stream removes the required
            # exact JS sourcePath. Equal bytes cannot replace the missing path row.
            altered=dict(rows); altered.pop(jsc["stdout"]["path"])
            verify_stream(jsc["stdout"],"consumer.stdout",jsrole["streamRoot"],altered,archive)
    return {'status':'PASS_BOUNDED_SCHEDULED_FOLLOWUP_IO_AND_MUTANT_CONTROLS_DELIVERY','logicalPaths':len(rows),'objects':len(objects),'roles':len(role_map),'scope':'four ordinary backend passes, two current-source JS mutant controls, and retained primary failure history; full #43 and performance remain open'}

def selftest():
    verify_evidence(HERE)
    for negative in ("wrong-parent-receipt","wrong-parent-manifest"):
        try: verify_evidence(HERE,negative)
        except VerificationError: pass
        else: raise VerificationError(f"malformed {negative} was accepted")
    _,owner,root=verify_local_selection(HERE)
    with tempfile.TemporaryDirectory(prefix="bendvy43-followup-relocation-") as td:
        moved_root=Path(td)
        for rel in owner["ownedPaths"]:
            src=local_owned(root,rel); dest=moved_root/Path(rel); dest.parent.mkdir(parents=True,exist_ok=True); shutil.copyfile(src,dest)
        moved=moved_root/Path(*DELIVERY_REL.parts)
        verify_local_selection(moved)
        readme=(moved_root/Path((DELIVERY_REL/"README.md").as_posix()))
        with readme.open("ab") as f: f.write(b"local drift")
        try: verify_local_selection(moved)
        except VerificationError as exc: require("local owned file drift" in str(exc),"relocation drift failed for unexpected reason")
        else: raise VerificationError("changed relocated local file was accepted")
        try: local_owned(moved_root,"../outside")
        except VerificationError: pass
        else: raise VerificationError("path outside relocated root accepted")
def main():
    try:
        if sys.argv[1:]==["--selftest"]:
            selftest(); print("PASS_BOUNDED_SCHEDULED_FOLLOWUP_IO_AND_MUTANT_CONTROLS_DELIVERY_SELFTEST")
        elif not sys.argv[1:]: print(json.dumps(verify_evidence(HERE),sort_keys=True))
        else: raise VerificationError("usage: python3 verify.py [--selftest]")
        return 0
    except (VerificationError,KeyError,OSError,ValueError,zipfile.BadZipFile) as exc:
        print(f"FAIL_BOUNDED_SCHEDULED_FOLLOWUP_IO_DELIVERY: {exc}",file=sys.stderr); return 1
if __name__=="__main__": raise SystemExit(main())

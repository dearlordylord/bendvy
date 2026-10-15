#!/usr/bin/env python3
"""Portable verifier for the bounded #43 full-capacity scheduled-consumer packet."""
from __future__ import annotations
import copy, gzip, hashlib, io, json, shutil, sys, tarfile, tempfile, zipfile
from pathlib import Path, PurePosixPath

HERE = Path(__file__).resolve().parent
DELIVERY_REL = PurePosixPath("experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/capacity-v1/array-transport-v1/matched-feature-v1/fullcapacity-delivery-v1")
EMPTY_SHA = hashlib.sha256(b"").hexdigest()

class VerificationError(Exception): pass

def require(ok, message):
    if not ok: raise VerificationError(message)

def digest(data: bytes) -> str: return hashlib.sha256(data).hexdigest()

def hash_stream(stream):
    h=hashlib.sha256(); size=0
    while True:
        block=stream.read(1024*1024)
        if not block: break
        size+=len(block); h.update(block)
    return size,h.hexdigest()

def parse_json(data: bytes, label: str):
    try: return json.loads(data)
    except Exception as exc: raise VerificationError(f"invalid JSON in {label}: {exc}") from exc

def repository_root(here: Path) -> Path:
    root=here.resolve()
    for _ in DELIVERY_REL.parts: root=root.parent
    require((root / Path(*DELIVERY_REL.parts)).resolve()==here.resolve(), "packet is not at its fixed repository-relative location")
    return root

def local_owned(root: Path, relative: str) -> Path:
    logical=PurePosixPath(relative)
    require(not logical.is_absolute() and logical.parts and logical.as_posix()==relative and
            all(x not in ("", ".", "..") for x in logical.parts), f"noncanonical local path: {relative}")
    base=root.resolve(); p=(base / Path(*logical.parts)).resolve()
    try: p.relative_to(base)
    except ValueError as exc: raise VerificationError(f"local owned path escapes repository: {relative}") from exc
    require(p.is_file(), f"missing local owned file: {relative}")
    return p

def verify_local_selection(here: Path):
    here=here.resolve(); root=repository_root(here)
    delivery=parse_json((here/"DELIVERY.json").read_bytes(),"DELIVERY.json")
    owner=parse_json((here/"OWNERSHIP.json").read_bytes(),"OWNERSHIP.json")
    producer=PurePosixPath(owner.get("producerWorktree",""))
    require(producer.is_absolute() and producer.as_posix()==owner.get("producerWorktree") and
            all(x not in ("", ".", "..") for x in producer.parts), "producer root is not canonical")
    require(delivery.get("producerWorktree")==producer.as_posix(), "producer roots differ")
    require(delivery.get("pathBase")==owner.get("pathBase")=="repository-root-relative", "wrong owned-path base")
    local_paths=owner.get("ownedPaths"); producer_paths=owner.get("producerOwnedPaths")
    require(isinstance(local_paths,list) and isinstance(producer_paths,list) and
            local_paths==sorted(local_paths) and producer_paths==sorted(producer_paths) and
            len(local_paths)==len(producer_paths)==owner.get("count"), "ownership arrays/count mismatch")
    mapping={}
    for p in producer_paths:
        full=PurePosixPath(p)
        require(full.is_absolute() and full.as_posix()==p and all(x not in ("", ".", "..") for x in full.parts),
                f"producer owned path is not canonical: {p}")
        try: suffix=full.relative_to(producer)
        except ValueError as exc: raise VerificationError(f"owned path outside producer root: {p}") from exc
        rel=suffix.as_posix()
        require(rel not in ("", ".") and rel not in mapping, f"duplicate/empty producer suffix: {p}")
        mapping[rel]=p
    require(sorted(mapping)==local_paths, "producer paths do not map one-to-one to local ownership")
    require(delivery.get("ownedPaths")==local_paths and delivery.get("producerOwnedPaths")==producer_paths,
            "delivery/ownership path mapping differs")
    delivery_rel=DELIVERY_REL.as_posix()+"/DELIVERY.json"
    require(delivery_rel in local_paths, "DELIVERY.json absent from ownership")
    files=delivery.get("files",{})
    require(set(files)==set(local_paths)-{delivery_rel}, "delivery file hashes do not match owned selection")
    for rel,meta in files.items():
        require(meta.get("sourcePath")==mapping[rel], f"producer path mapping mismatch: {rel}")
        p=local_owned(root,rel)
        with p.open("rb") as f: size,sha=hash_stream(f)
        require(size==meta.get("bytes") and sha==meta.get("sha256"), f"local owned file drift: {rel}")
    return delivery,owner,root

def canonical_external(path: str):
    p=PurePosixPath(path)
    require(p.is_absolute() and p.as_posix()==path and all(x not in ("", ".", "..") for x in p.parts),
            f"evidence sourcePath is not canonical absolute: {path}")

def verify_stream(stream, label: str, stream_root: str, rows: dict, archive: zipfile.ZipFile, path_override=None, allow_missing_published=False):
    source=path_override if path_override is not None else stream.get("path")
    require(isinstance(source,str), f"{label}: missing stream source path")
    canonical_external(source)
    expected=str(PurePosixPath(stream_root) / f"{label}")
    require(source==expected, f"{label}: full stream path differs from its frozen command path")
    if allow_missing_published:
        require(stream.get("published") in (None, True), f"{label}: stream publication flag is invalid")
    else:
        require(stream.get("published") is True, f"{label}: stream was not published")
    row=rows.get(source)
    require(row is not None, f"{label}: full sourcePath is absent from evidence manifest")
    require(row["bytes"]==stream.get("bytes") and row["sha256"]==stream.get("sha256"),
            f"{label}: receipt bytes/hash differ from exact-path manifest row")
    with archive.open(row["member"],"r") as f: size,sha=hash_stream(f)
    require(size==stream["bytes"] and sha==stream["sha256"], f"{label}: archived raw stream differs from receipt")

def verify_role(role, rows, archive, manifest):
    plan_row=rows.get(role["planPath"]); require(plan_row is not None, f"{role['name']}: plan missing")
    require(plan_row["sha256"]==role["planSHA256"], f"{role['name']}: plan digest differs")
    plan=parse_json(archive.read(plan_row["member"]),f"{role['name']} plan")
    require(digest(archive.read(plan_row["member"]))==role["planSHA256"], f"{role['name']}: archived plan hash differs")
    external_tools={x["path"]:x["sha256"] for x in manifest.get("externalToolPins",[])}
    external_roots={(x["root"],x["inventorySHA256"]) for x in manifest.get("resourceRootInventories",[])}
    source_inventory=plan.get("sourceInventory",{})
    for path,sha in source_inventory.items():
        row=rows.get(path); require(row is not None and row["sha256"]==sha, f"{role['name']}: source closure mismatch: {path}")
    tools=set(plan.get("tools",{}).values())
    roots=plan.get("resourceRoots",{})
    for path,sha in plan.get("pins",{}).items():
        if path in external_tools:
            require(external_tools[path]==sha, f"{role['name']}: external tool pin differs: {path}")
        elif any(path==root or path.startswith(root.rstrip("/")+"/") for root in roots):
            continue
        else:
            row=rows.get(path); require(row is not None and row["sha256"]==sha, f"{role['name']}: pinned input missing/drifted: {path}")
    for root,inventory in roots.items():
        packed=json.dumps(inventory,sort_keys=True,separators=(",",":")).encode()
        require((root,digest(packed)) in external_roots, f"{role['name']}: resource-root inventory digest missing: {root}")

    receipt_path=role.get("receiptPath")
    if receipt_path is None:
        require(role.get("expectedStatus")=="NOT_EXECUTED", f"{role['name']}: plan-only role status is not explicit")
        return plan,None
    receipt_row=rows.get(receipt_path); require(receipt_row is not None, f"{role['name']}: receipt missing")
    require(receipt_row["sha256"]==role["receiptSHA256"], f"{role['name']}: receipt digest differs")
    receipt=parse_json(archive.read(receipt_row["member"]),f"{role['name']} receipt")
    require(digest(archive.read(receipt_row["member"]))==role["receiptSHA256"], f"{role['name']}: archived receipt hash differs")
    if role.get("class")=="stack-diagnostic":
        require(receipt.get("pins",{}).get(role["planPath"])==role["planSHA256"], f"{role['name']}: diagnostic receipt not bound to exact plan")
    else:
        require(receipt.get("planSHA256")==role["planSHA256"], f"{role['name']}: receipt not bound to exact plan")
    require(receipt.get("status")==role["expectedStatus"], f"{role['name']}: status differs from retained result")
    if receipt.get("commands"):
        planned=plan.get("commands",[]); actual=receipt["commands"]
        plan_index=0
        for c in actual:
            label=c["label"]
            if plan_index < len(planned) and label==planned[plan_index].get("label"):
                p=planned[plan_index]; plan_index+=1
                require(c.get("argv")==p.get("argv"), f"{role['name']}/{label}: argv differs from plan")
                require(c.get("capSeconds")==p.get("capSeconds"), f"{role['name']}/{label}: cap differs from plan")
            elif role.get("class") in ("native-diagnostic","ordinary-replay") and label.startswith("library-probe-"):
                argv=c.get("argv",[])
                require(len(argv)==5 and argv[:4]==[plan.get("taskset"),"-c","5",plan.get("ldd")] and argv[4] in set(plan.get("tools",{}).values()), f"{role['name']}/{label}: unexpected diagnostic library probe")
                require(c.get("capSeconds")==5 and c.get("exit")==0 and c.get("failure") is None, f"{role['name']}/{label}: unexpected diagnostic probe result")
            else:
                raise VerificationError(f"{role['name']}/{label}: unexpected command or order")
            require(c.get("capture")=="split", f"{role['name']}/{label}: capture policy differs")
            for name in ("stdout","stderr"):
                stream=c[name]
                # `streamRoot` is the independently retained exact parent. This prevents a
                # same-basename stream from another run from satisfying a hash-only join.
                verify_stream(stream,f"{label}.{name}",role["streamRoot"],rows,archive,allow_missing_published=(role.get("class") in ("native-diagnostic","ordinary-replay")))
        require(plan_index==len(planned), f"{role['name']}: planned commands are missing")
        for guard in receipt.get("guards",[]):
            path=guard.get("path"); canonical_external(path)
            require(PurePosixPath(path).parent.as_posix()==role["streamRoot"], f"{role['name']}: guard parent differs")
            row=rows.get(path); require(row is not None and row["sha256"]==guard.get("sha256"), f"{role['name']}: guard path/hash join failed")
            data=parse_json(archive.read(row["member"]),f"{role['name']} guard")
            require(data.get("unchanged") is True, f"{role['name']}: guard reports drift")
            for path2,sha in plan.get("pins",{}).items():
                require(data.get("actualPins",{}).get(path2)==sha, f"{role['name']}: guard missing pin {path2}")
    else:
        # The stack diagnostics use one top-level command record rather than `commands[]`.
        require(role.get("class")=="stack-diagnostic", f"{role['name']}: unexpected receipt shape")
        for name in ("stdout","stderr"):
            s=receipt[name]; expected=plan[name]
            require(s.get("path")==expected, f"{role['name']}: diagnostic full stream path differs")
            row=rows.get(s["path"]); require(row is not None and row["bytes"]==s["bytes"] and row["sha256"]==s["sha256"], f"{role['name']}: diagnostic stream join failed")
            with archive.open(row["member"],"r") as f: size,sha=hash_stream(f)
            require((size,sha)==(s["bytes"],s["sha256"]), f"{role['name']}: diagnostic raw stream mismatch")
        require(receipt.get("result",{}).get("capture")=="split", f"{role['name']}: diagnostic capture differs")
    return plan,receipt

def compare_gzip(archive, gzip_member, raw_member, expected_bytes, expected_sha):
    h=hashlib.sha256(); size=0
    with archive.open(gzip_member,"r") as packed, archive.open(raw_member,"r") as raw:
        with gzip.GzipFile(fileobj=packed,mode="rb") as oracle:
            while True:
                expected=oracle.read(1024*1024)
                actual=raw.read(len(expected) or 1)
                require(actual==expected,"consumer stdout differs from independent compressed oracle")
                if not expected: break
                size+=len(expected); h.update(expected)
            require(raw.read(1)==b"","consumer stdout has trailing bytes")
    require(size==expected_bytes and h.hexdigest()==expected_sha,"oracle wire size/hash mismatch")

def verify_evidence(here: Path, negative=None):
    delivery,owner,root=verify_local_selection(here)
    require(delivery.get("status")=="BOUNDED_FULLCAPACITY_SCHEDULED_DELIVERY", "unexpected delivery status")
    result=parse_json((here/"RESULT.json").read_bytes(),"RESULT.json")
    manifest=parse_json((here/"MANIFEST.json").read_bytes(),"MANIFEST.json")
    require(result.get("status")=="BOUNDED_FULLCAPACITY_SCHEDULED_JS_AND_RETAINED_NATIVE_ORACLE_PASS", "unexpected result status")
    require(result.get("fullIssueAcceptance")=="OPEN" and result.get("performanceClaim") is False, "result overstates issue/performance scope")
    files=delivery["files"]
    for name,meta in (("MANIFEST.json",delivery["manifest"]),("RESULT.json",delivery["result"]),("EVIDENCE.zip",delivery["archive"])):
        raw=(here/name).read_bytes(); require(len(raw)==meta["bytes"] and digest(raw)==meta["sha256"], f"{name}: delivery hash mismatch")
    vmeta=files.get((DELIVERY_REL/"verify.py").as_posix()); require(vmeta is not None and digest((here/"verify.py").read_bytes())==vmeta["sha256"], "verifier self hash mismatch")
    rows={r["sourcePath"]:r for r in manifest["logicalPaths"]}
    require(len(rows)==len(manifest["logicalPaths"]),"duplicate exact sourcePath in manifest")
    objects={o["sha256"]:o for o in manifest["objects"]}; require(len(objects)==len(manifest["objects"]),"duplicate content object")
    with zipfile.ZipFile(here/"EVIDENCE.zip","r") as archive:
        names=archive.namelist(); require(len(names)==len(set(names)),"duplicate archive member")
        require(set(names)=={o["member"] for o in manifest["objects"]},"archive/manifest object set differs")
        for row in manifest["logicalPaths"]:
            canonical_external(row["sourcePath"])
            obj=objects.get(row["sha256"])
            require(obj is not None and row["member"]==obj["member"] and row["bytes"]==obj["bytes"], f"logical content join failed: {row['sourcePath']}")
        for sha,obj in objects.items():
            require(obj["member"]==f"objects/{sha}","noncanonical object member")
            with archive.open(obj["member"],"r") as f: size,actual=hash_stream(f)
            require(size==obj["bytes"] and actual==sha,f"object digest mismatch: {sha}")
        role_results={}
        for role in result["history"]:
            plan,receipt=verify_role(role,rows,archive,manifest)
            role_results[role["name"]]=(plan,receipt,role)

        def completed_output(role_name):
            plan,receipt,role=role_results[role_name]
            require(receipt is not None and receipt.get("status")=="COMPLETE_CONSUMER_DEVELOPMENT_PASS", f"{role_name} is not an ordinary complete pass")
            cmd=next(c for c in receipt["commands"] if c["label"]=="consumer")
            stream=cmd["stdout"]; row=rows.get(stream["path"]); require(row is not None,"pass stdout absent")
            oracle=rows.get(plan["oracle"]); require(oracle is not None,"source oracle gzip missing")
            require(receipt.get("wholeOracleSHA256")==plan.get("oracleSHA256"), f"{role_name}: plan/receipt oracle differs")
            compare_gzip(archive,oracle["member"],row["member"],plan["oracleBytes"],plan["oracleSHA256"])
            return plan,receipt,row

        # The earlier complete pair used a smaller 31,686,777-byte wire; it is historical.
        for role_name in ("v5-js","v5-native","v7-js","v8-js","v9-js"):
            completed_output(role_name)
        replay_plan,replay_receipt,replay_out=role_results["v9-native-ordinary-replay"]
        require(replay_receipt.get("status")=="ORDINARY_RETAINED_NATIVE_FULL_ORACLE_PASS" and replay_receipt.get("completeOracleMatch") is True, "ordinary replay is not a full-oracle pass")
        replay_cmd=next(c for c in replay_receipt["commands"] if c["label"]=="consumer")
        v9_oracle=rows.get(replay_plan["oracle"]); require(v9_oracle is not None,"replay oracle missing")
        compare_gzip(archive,v9_oracle["member"],rows[replay_cmd["stdout"]["path"]]["member"],replay_plan["oracleBytes"],replay_plan["oracleSHA256"])
        native_path=replay_plan["tools"]["native"]
        require(replay_plan["environment"].get("LD_PRELOAD","")=="", "ordinary replay unexpectedly has LD_PRELOAD")
        require(replay_plan["pins"].get(native_path)==result["ordinaryBackendDisposition"]["nativeReplay"]["binarySHA256"], "replay binary identity mismatch")
        require(rows.get(native_path,{}).get("sha256")==result["ordinaryBackendDisposition"]["nativeReplay"]["binarySHA256"], "replay executable bytes absent or changed")

        # Canonical v9 Native remains a deadline/incomplete result, despite replay/profile evidence.
        _,v9native,_=role_results["v9-native"]
        require(v9native.get("status")=="INCOMPLETE" and v9native["commands"][-1].get("failure")=="child deadline", "canonical Native history was rewritten")
        require(v9native["commands"][-1]["stdout"]["bytes"]==v9native["commands"][-1]["stderr"]["bytes"]==0, "canonical Native timeout streams changed")

        # Profiler result is diagnostic-only and must bind the unchanged replay binary and output.
        profile_plan,profile_receipt,profile_role=role_results["native-pc-sampler-02"]
        profile_analysis_row=rows.get(profile_role["analysisPath"]); require(profile_analysis_row is not None and profile_analysis_row["sha256"]==profile_role["analysisSHA256"],"profile analysis absent or changed")
        analysis=parse_json(archive.read(profile_analysis_row["member"]),"Native PC sampler analysis")
        require(analysis.get("status")=="DIAGNOSTIC_ANALYSIS_ONLY" and analysis.get("binaryUnchanged") is True and analysis.get("completeOracleMatch") is True, "Native profile scope/status mismatch")
        require(profile_receipt.get("status")=="NATIVE_PC_DIAGNOSTIC_COMPLETE" and profile_receipt.get("completeOracleMatch") is True, "profile receipt is not diagnostic oracle match")
        profile_consumer=next(c for c in profile_receipt["commands"] if c["label"]=="consumer")
        compare_gzip(archive,v9_oracle["member"],rows[profile_consumer["stdout"]["path"]]["member"],67573993,"804d5dbf564e859ece28200e92fe147cdad070b4db4a37392526c2fd5262520b")
        require(profile_receipt.get("samplerSHA256")==analysis.get("samplerSHA256"), "PC diagnostic sampler hash differs")
        sampler_path=str(PurePosixPath(profile_role["receiptPath"]).parent/"sampler.so")
        sampler_row=rows.get(sampler_path)
        require(sampler_row is not None and sampler_row["sha256"]==analysis["samplerSHA256"], "PC diagnostic sampler artifact is absent or changed")
        wrapper_path=str(PurePosixPath(profile_role["planPath"]).parent/"run.py")
        wrapper_row=rows.get(wrapper_path)
        require(wrapper_path in profile_plan.get("pins",{}) and wrapper_row is not None and wrapper_row["sha256"]==profile_plan["pins"][wrapper_path], "PC diagnostic launch wrapper is absent or changed")
        wrapper=archive.read(wrapper_row["member"])
        require(b"childEnv['LD_PRELOAD']=str(out/'sampler.so')" in wrapper, "PC diagnostic wrapper does not bind its sampler")

        # Bind the source-only model and all 65 source rows to the exact v9 source closure.
        source=rows.get(result["candidateSource"]["path"]); require(source is not None and source["sha256"]==result["candidateSource"]["sha256"], "v9 consumer source join failed")
        v9plan=role_results["v9-js"][0]
        require(len(v9plan.get("sourceInventory",{}))==65 and len(v9plan.get("importClosure",[]))==65, "v9 source closure count mismatch")
        require(v9plan["sourceInventory"].get("/tmp/bendvy43-fullcapacity-v9-oracle-source01/src/ecs/world.bend")=="4e191783000df87279190cdd5c74d419de88a1bae8d7ebaf0c3ed8600ad80d1a", "v9 protected World source pin differs")
        require(result["oracleSource"]["sourceOnly"] is True and result["oracleSource"]["rawSHA256"]==result["v9Wire"]["sha256"], "independent oracle binding mismatch")

        # Protected #28 source/artifact audit is bounded reuse; inspect its actual archive member.
        reuse=result["protectedWorkshopReuse"]; record=rows.get(reuse["recordSourcePath"])
        require(record is not None and record["sha256"]==reuse["recordSHA256"], "#28 committed reuse record missing")
        record_json=parse_json(archive.read(record["member"]),"#28 source-reuse record")
        require(record_json.get("sourceIdenticalCount")==22 and record_json.get("count")==23, "#28 source comparison scope differs")
        require(record_json.get("artifactIdentity",{}).get("status")=="IDENTICAL", "#28 artifact identity audit is not identical")
        identity_receipt_path="/tmp/bendvy28-pending-artifact-identity01/receipt.json"
        identity_plan_path="/tmp/bendvy28-pending-artifact-identity01/PLAN.json"
        identity_receipt=parse_json(archive.read(rows[identity_receipt_path]["member"]),"#28 identity receipt")
        identity_plan=parse_json(archive.read(rows[identity_plan_path]["member"]),"#28 identity plan")
        require(identity_receipt.get("status")=="IDENTICAL" and identity_receipt.get("planSHA256")==result["protectedWorkshopReuse"].get("planSHA256","729e9bd39790741e7c3399944500741876eddfd894919d084b79bff359b472b6"), "#28 identity files changed")
        for base in ("expected-workshop.js","workshop.js","expected-workshop.c","workshop.c"):
            path=f"/tmp/bendvy28-pending-artifact-identity01/{base}"
            require(path in rows,"#28 identity output missing")
        require(rows["/tmp/bendvy28-pending-artifact-identity01/expected-workshop.js"]["sha256"]==rows["/tmp/bendvy28-pending-artifact-identity01/workshop.js"]["sha256"], "#28 JS output identity differs")
        require(rows["/tmp/bendvy28-pending-artifact-identity01/expected-workshop.c"]["sha256"]==rows["/tmp/bendvy28-pending-artifact-identity01/workshop.c"]["sha256"], "#28 C output identity differs")
        archive_row=rows.get(result["retainedNativeArtifactArchive"]["path"]); require(archive_row is not None and archive_row["sha256"]==result["retainedNativeArtifactArchive"]["sha256"], "#28 evidence archive missing")
        with archive.open(archive_row["member"],"r") as blob:
            tar_bytes=blob.read()
        with tarfile.open(fileobj=io.BytesIO(tar_bytes),mode="r:gz") as tar:
            member=tar.extractfile(result["retainedNativeArtifactArchive"]["qualifiedMember"])
            require(member is not None,"#28 qualified native archive member missing")
            nbytes,nsha=hash_stream(member)
        require(nbytes==result["retainedNativeArtifactArchive"]["qualifiedBinaryBytes"] and nsha==result["retainedNativeArtifactArchive"]["qualifiedBinarySHA256"], "#28 qualified native artifact bytes differ")

        if negative=="wrong-parent-receipt":
            # Both paths have basename `consumer.stdout` and identical wire bytes. A full-path join must reject.
            jsrole=next(x for x in result["history"] if x["name"]=="v9-js")
            plan,receipt,_=role_results["v9-js"]
            cmd=next(c for c in receipt["commands"] if c["label"]=="consumer")
            replay=role_results["v9-native-ordinary-replay"][2]
            other=next(c for c in role_results["v9-native-ordinary-replay"][1]["commands"] if c["label"]=="consumer")
            require(Path(cmd["stdout"]["path"]).name==Path(other["stdout"]["path"]).name and cmd["stdout"]["sha256"]==other["stdout"]["sha256"], "test streams are not identical basename controls")
            verify_stream(cmd["stdout"],"consumer.stdout",jsrole["streamRoot"],rows,archive,path_override=other["stdout"]["path"])
        elif negative=="wrong-parent-manifest":
            jsrole=next(x for x in result["history"] if x["name"]=="v9-js")
            replay=role_results["v9-native-ordinary-replay"][2]
            jsout=next(c for c in role_results["v9-js"][1]["commands"] if c["label"]=="consumer")["stdout"]
            replayout=next(c for c in role_results["v9-native-ordinary-replay"][1]["commands"] if c["label"]=="consumer")["stdout"]
            require(jsout["sha256"]==replayout["sha256"] and Path(jsout["path"]).name==Path(replayout["path"]).name, "same-basename equal-content precondition failed")
            # A manifest row cannot be retargeted to the replay parent to satisfy JS; the JS exact path disappears.
            require(jsout["path"] in rows and replayout["path"] in rows, "same-basename rows missing")
            mutant=dict(rows); mutant[jsout["path"]]=dict(rows[jsout["path"]]); mutant[jsout["path"]]["sourcePath"]=replayout["path"]
            mutant.pop(jsout["path"])
            verify_stream(jsout,"consumer.stdout",jsrole["streamRoot"],mutant,archive)
    return {'status':'PASS_BOUNDED_FULLCAPACITY_SCHEDULED_DELIVERY','logicalPaths':len(rows),'objects':len(objects),'roles':len(result['history']),'jsBytes':67573993,'nativeReplayBytes':67573993,'scope':'bounded selected #43 full-capacity consumer gate; full issue acceptance and comparative performance remain open'}

def selftest():
    result=verify_evidence(HERE)
    for mode in ("wrong-parent-receipt","wrong-parent-manifest"):
        try: verify_evidence(HERE,mode)
        except VerificationError: pass
        else: raise VerificationError(f"malformed {mode} was accepted")
    delivery,owner,root=verify_local_selection(HERE)
    with tempfile.TemporaryDirectory(prefix="bendvy43-relocation-") as td:
        relocated=Path(td)
        for rel in owner["ownedPaths"]:
            src=local_owned(root,rel); dest=relocated/Path(rel); dest.parent.mkdir(parents=True,exist_ok=True); shutil.copyfile(src,dest)
        moved=relocated/Path(*DELIVERY_REL.parts)
        verify_local_selection(moved)
        readme_rel=(DELIVERY_REL/"README.md").as_posix()
        with (relocated/Path(readme_rel)).open("ab") as out: out.write(b"local drift")
        try: verify_local_selection(moved)
        except VerificationError as exc: require("local owned file drift" in str(exc),"relocation drift failed for unrelated reason")
        else: raise VerificationError("changed relocated local file was accepted")
        try: local_owned(relocated,"../outside")
        except VerificationError: pass
        else: raise VerificationError("outside-root local path accepted")

def main():
    try:
        if sys.argv[1:]==["--selftest"]:
            selftest(); print("PASS_BOUNDED_FULLCAPACITY_SCHEDULED_DELIVERY_SELFTEST")
        elif not sys.argv[1:]: print(json.dumps(verify_evidence(HERE),sort_keys=True))
        else: raise VerificationError("usage: python3 verify.py [--selftest]")
        return 0
    except (VerificationError,KeyError,OSError,ValueError,zipfile.BadZipFile,tarfile.TarError) as exc:
        print(f"FAIL_BOUNDED_FULLCAPACITY_SCHEDULED_DELIVERY: {exc}",file=sys.stderr); return 1
if __name__=="__main__": raise SystemExit(main())

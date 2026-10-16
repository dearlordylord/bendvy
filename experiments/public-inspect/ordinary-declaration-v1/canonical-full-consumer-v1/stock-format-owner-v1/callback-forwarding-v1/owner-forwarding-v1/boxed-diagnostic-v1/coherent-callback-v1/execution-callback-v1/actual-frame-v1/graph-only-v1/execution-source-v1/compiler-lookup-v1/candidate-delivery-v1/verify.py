#!/usr/bin/env python3
"""One candidate packet; reuse existing full-path verification primitives."""
import hashlib, json, shutil, sys, tempfile, types, zipfile
from pathlib import Path, PurePosixPath
HERE=Path(__file__).resolve().parent
H=lambda raw:hashlib.sha256(raw).hexdigest()
def load(raw): return json.loads(raw)
def verify():
    meta=load((HERE/"BUILD-META.json").read_bytes())
    manifest=load((HERE/"MANIFEST.json").read_bytes())
    result=load((HERE/"RESULT.json").read_bytes())
    rows={x["sourcePath"]:x for x in manifest["logicalPaths"]}
    assert len(rows)==len(manifest["logicalPaths"])
    with zipfile.ZipFile(HERE/"EVIDENCE.zip") as archive:
        support=rows[meta["helperSourcePath"]]
        code=archive.read(support["member"])
        assert H(code)==meta["helperSHA256"]==support["sha256"]
        v=types.ModuleType("existing_scheduled_delivery_verifier")
        v.__file__=meta["helperSourcePath"]
        exec(compile(code,v.__file__,"exec"),v.__dict__)
        v.DELIVERY_REL=PurePosixPath(meta["deliveryRelative"])
        v.verify_local_selection(HERE)
        assert set(archive.namelist())=={x["member"] for x in manifest["objects"]}
        for x in manifest["objects"]:
            with archive.open(x["member"]) as f: size,h=v.hash_stream(f)
            assert (size,h)==(x["bytes"],x["sha256"])
        for path,x in rows.items():
            v.canonical_external(path)
            assert x["member"]=="objects/"+x["sha256"]
            assert load_manifest_object(x,manifest)
        def body(path):return archive.read(rows[path]["member"])
        assert len(result["source47"])==47
        for path,h in result["source47"].items():assert rows[path]["sha256"]==h
        ordinary=[]; identity=None
        for role in result["roles"]:
            if role["kind"]=="ordinary":
                plan,receipt=v.verify_role(dict(role,kind="pass"),rows,manifest,archive)
                assert receipt["wholeOracleSHA256"]==result["oracle"]["sha256"]
                stdout=receipt["commands"][-1]["stdout"]
                v.compare_gzip(archive,rows[plan["oracle"]],rows[stdout["path"]],5077477,result["oracle"]["sha256"],role["name"])
                for label,key in [("emit","generated"),("build","native")]:
                    artifact=receipt.get(label+"ArtifactSHA256")
                    if artifact: assert rows[plan[key]]["sha256"]==artifact
                ordinary.append((role,plan,receipt))
            else:
                plan=load(body(role["planPath"]));receipt=load(body(role["receiptPath"]))
                assert H(body(role["planPath"]))==role["planSHA256"]==receipt["planSHA256"]
                assert H(body(role["receiptPath"]))==role["receiptSHA256"]
                assert receipt["status"]=="IDENTICAL"
                # Existing identity-helper dialect has no tools/published fields.
                adapted=dict(plan,tools={x["path"]:x["path"] for x in manifest["externalToolPins"]})
                v.verify_plan_inputs(adapted,rows,manifest,role["name"])
                for base,inventory in plan["sourceMembership"].items():
                    for rel,h in inventory.items():assert rows[base+"/"+rel]["sha256"]==h
                assert len(receipt["commands"])==len(plan["commands"])==1
                for planned,actual in zip(plan["commands"],receipt["commands"]):
                    assert all(actual[k]==planned[k] for k in ["label","argv","capSeconds"])
                    assert actual["result"]["exit"]==0 and actual["result"]["failure"] is None
                    assert actual["result"]["capture"]=="split"
                    for field in ["stdout","stderr"]:
                        v.verify_stream(dict(actual[field],published=True),actual["label"]+"."+field,role["streamRoot"],rows,archive)
                a=receipt["artifacts"]["c"];expected=plan["expected"]["c"]["path"]
                assert a["identical"] and a["bytes"]==33749160
                assert rows[a["path"]]["sha256"]==rows[expected]["sha256"]==result["CReuse"]["sha256"]==a["sha256"]
                identity=(role,plan,receipt)
        assert len(ordinary)==2 and identity
        native=next(x for x in ordinary if x[0]["name"]=="lookup-native")
        assert rows[native[1]["entrypoint"]]["sha256"]==result["CReuse"]["sha256"]
        protected=result["protectedNative"];pr=load(body(protected["receiptPath"]))
        assert H(body(protected["receiptPath"]))==protected["receiptSHA256"]
        assert pr["status"]=="COMPLETE_CONSUMER_DEVELOPMENT_PASS" and not protected["regressionQualified"]
        for command in pr["commands"]:
            assert command["exit"]==0 and command["failure"] is None
            for field in ["stdout","stderr"]:
                v.verify_stream(command[field],command["label"]+"."+field,str(PurePosixPath(protected["receiptPath"]).parent),rows,archive)
        stdout=pr["commands"][-1]["stdout"]
        pp=load(body(str(PurePosixPath(protected["receiptPath"]).with_name("plan.json"))))
        assert rows[pp["native"]]["sha256"]==pr["buildArtifactSHA256"]
        assert stdout["bytes"]==231190
        v.compare_gzip(archive,rows[pp["oracle"]],rows[stdout["path"]],231190,pr["wholeOracleSHA256"],"protected-correctness-only")
        # Verify retained actual checker refusals and exact mirrored source bytes.
        controls=[p for p in rows if p.endswith("affected-controls-v1/canonical-v1/CHECKS.json")]
        assert len(controls)==1
        checks=load(body(controls[0]));assert len(checks["checks"])==5
        mirror=str(PurePosixPath(controls[0]).parent/"mirror")
        for rel,source in checks["sourceInventory"].items():
            assert rows[mirror+"/"+rel]["sha256"]==source["sha256"]
        for c in checks["checks"]:
            assert c["exit"]==c["expectedExit"]==1 and c["intendedRefusalMatched"] and c["unchanged"]
            for field in ["stdout","stderr"]:
                x=c["streams"][field];assert (len(body(x["sourcePath"])),H(body(x["sourcePath"])))==(x["bytes"],x["sha256"])
            stderr=body(c["streams"]["stderr"]["sourcePath"]).decode()
            assert all(t in stderr for t in c["expectedDiagnosticTokens"])
        if "--selftest" in sys.argv:
            c=native[2]["commands"][-1];stream=c["stdout"];wrong="/tmp/wrong-parent/"+PurePosixPath(stream["path"]).name
            try:v.verify_stream(stream,c["label"]+".stdout",native[0]["streamRoot"],rows,archive,path_override=wrong)
            except v.VerificationError:pass
            else:raise AssertionError("same-basename wrong-parent accepted")
            with tempfile.TemporaryDirectory(prefix="bendvy54-packet-relocated-") as td:
                target=Path(td)/meta["deliveryRelative"];target.parent.mkdir(parents=True)
                shutil.copytree(HERE,target)
                v.verify_local_selection(target)
                (target/"README.md").write_text("drift")
                try:v.verify_local_selection(target)
                except v.VerificationError:pass
                else:raise AssertionError("local packet drift accepted")
        return len(rows),len(manifest["objects"])
def load_manifest_object(row,manifest):
    return any(x["member"]==row["member"] and x["sha256"]==row["sha256"] and x["bytes"]==row["bytes"] for x in manifest["objects"])
if __name__=="__main__":
    paths,objects=verify();print(f"PASS: {paths} full paths, {objects} objects; full54 correctness, exact C reuse, regression UNQUALIFIED")

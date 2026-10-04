#!/usr/bin/env python3
"""Exact approved all-pairs comparison gate, each Bend invocation limited to five seconds."""
import hashlib, json, os, pathlib, shutil, subprocess, tempfile
ROOT = pathlib.Path(__file__).resolve().parents[2]
HERE = pathlib.Path(__file__).resolve().parent
WRAPPER = ROOT / "experiments/t01/bend-check"
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
source = ROOT / "experiments/p-observe/ARITHMETIC-PROPOSED.bend"
assert sha(source) == "7d4ea7b7c94592c473271cffb8bcd3ec1cb1ff7390f6e1aa5cde9918ad9ce937"
block = source.read_text().split("law u32_comparison_agrees_nat:",1)[1]
assert (HERE/"LAWS.bend").read_text().split("law u32_comparison_agrees_nat:",1)[1] == block
records = []
def run(path, verdict=False, failure=None, kernel_negative=False):
    env = dict(os.environ)
    if kernel_negative: env["BENDTT"] = "/usr/bin/false"
    cmd = [str(WRAPPER),str(path),"--verdict" if verdict else "--check-only"]
    p = subprocess.run(cmd,capture_output=True,text=True,timeout=6,env=env)
    out = p.stdout+p.stderr
    assert p.returncode == (1 if failure or kernel_negative else 0), (cmd,p.returncode,out)
    if failure: assert failure in out, out
    elif kernel_negative: assert "SOME PROOFS FAIL" in out and "formalized BendTT kernel" in out,out
    else: assert "ALL PROOFS CHECK" in out,out
    records.append({"file":path.name,"kernel_requested":verdict,"kernel_negative_control":kernel_negative,"exit":p.returncode,"output":out})
for name in ["structural.bend","PROOF.bend","controls.bend"]:
    for verdict in [False,True]: run(HERE/name,verdict)
run(HERE/"PROOF.bend",True,kernel_negative=True)
with tempfile.TemporaryDirectory(prefix="u32-comparison-") as td:
    mirror=pathlib.Path(td)/"experiments"
    package=mirror/HERE.name
    shutil.copytree(HERE,package)
    bridge=mirror/"t11-replacement/bridge.bend"
    bridge.parent.mkdir()
    original=(ROOT/"experiments/t11-replacement/bridge.bend").read_text()
    needle="U32.is_lt(left,right)"
    assert original.count(needle)==1
    bridge.write_text(original.replace(needle,"U32.is_lt(right,left)"))
    run(bridge)
    run(package/"structural.bend",True)
    run(package/"controls.bend",failure="true_instance")
    run(package/"PROOF.bend",failure="Laws.u32_comparison_agrees_nat")
refs=pathlib.Path("/workspace/formal-proofs/bendvy/.references")
pins={name:subprocess.check_output(["git","-C",str(refs/name),"rev-parse","HEAD"],text=True).strip() for name in ["bevy-ts","bevy","bend2"]}
assert pins == {"bevy-ts":"3040a3b2a3f28fa8554d856f9ccb6bf5433fa334","bevy":"ad678262ce53b5d142fe49ee5e08caff6f00ab60","bend2":"a950fd683c0d76f09794078e6174fe98a1492876"}
evidence={"scope":"exact approved universal u32_comparison_agrees_nat; no other catalogue endpoint", "baseline":"8e149fd", "version":subprocess.check_output(["bend","version"],text=True).strip(), "sources":{p.name:sha(p) for p in HERE.glob("*.bend")}, "frozen":{"proposal":sha(source),"approval":sha(ROOT/"docs/reviews/delegated-owned-law-approval.md"),"bridge":sha(ROOT/"experiments/t11-replacement/bridge.bend"),"compiler":sha(pathlib.Path(shutil.which("bend"))),"Base":sha(pathlib.Path.home()/".bend/bend2/base.bend")}, "reference_commits":pins,"checks":records}
assert evidence["frozen"] == {"proposal":"7d4ea7b7c94592c473271cffb8bcd3ec1cb1ff7390f6e1aa5cde9918ad9ce937","approval":"f4bcbb952c558093aa572c6499ac6763cf85c0faf9ef6a33485b2160eae0b220","bridge":"c20d2d4bac15b3bf4bff7a20a28a140f6f74862081ffff23955cdc6326441f80","compiler":"d4821d04932218216c9dc906223ed0e23dd86726d4357a567fb76ee6c976db4e","Base":"c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661"}
(HERE/"evidence.json").write_text(json.dumps(evidence,indent=2)+"\n")
print("PASS: exact universal comparison, independent kernel, original complete-law witness, compiling reversed comparison mutant and kernel-negative control")

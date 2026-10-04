#!/usr/bin/env python3
"""Partial owned-proof milestone; never claims the full schedule endpoint."""
import hashlib, json, os, pathlib, re, shutil, subprocess, tempfile

ROOT = pathlib.Path(__file__).resolve().parents[2]
HERE = pathlib.Path(__file__).resolve().parent
WRAPPER = ROOT / "experiments/t01/bend-check"
def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()
frozen = json.loads((ROOT / "experiments/p-owned-route/subjects.json").read_text())["canonical_sources"]
frozen["experiments/p-owned-route/PROPOSED.bend"] = "8e400d78b08530ff17295fa32190d0cf93b1f4641816d2710506b64a8ae2940b"
for name, digest in frozen.items(): assert sha(ROOT/name) == digest, name
records = []
def check(path, kernel=False, failure=None, reject_kernel=False):
    env = dict(os.environ)
    if reject_kernel: env["BENDTT"] = "/usr/bin/false"
    cmd = [str(WRAPPER), str(path), "--verdict" if kernel else "--check-only"]
    p = subprocess.run(cmd, capture_output=True, text=True, timeout=6, env=env)
    out = p.stdout+p.stderr
    assert p.returncode == (1 if failure or reject_kernel else 0), (path,p.returncode,out)
    if failure: assert "SOME PROOFS FAIL" in out and failure in out, out
    elif reject_kernel: assert "SOME PROOFS FAIL" in out and "formalized BendTT kernel" in out, out
    else: assert "ALL PROOFS CHECK" in out, out
    records.append({"file":path.name,"kernel":kernel,"kernel_negative":reject_kernel,"exit":p.returncode,"output":out})

positive = ["arrays.bend","point.bend","capture.bend","empty.bend","controls.bend","empty-witness.bend",
    "commands.bend","allocation.bend","barrier.bend","bump.bend","primitive-controls.bend"]
for name in positive:
    check(HERE/name)
    check(HERE/name, kernel=True)
check(HERE/"false-negative.bend",failure="Location: false_fact")
check(HERE/"empty.bend",kernel=True,reject_kernel=True)

closure = {}
def inventory(path):
    path = path.resolve()
    if path in closure: return
    closure[path] = sha(path)
    for target in re.findall(r"^import (\.{1,2}/\S+)",path.read_text(),re.M):
        inventory(path.parent/target)
for name in positive: inventory(HERE/name)
with tempfile.TemporaryDirectory(prefix="owned-empty-mutant-") as tmp:
    mirror = pathlib.Path(tmp)
    for path in closure:
        dest = mirror/path.relative_to(ROOT)
        dest.parent.mkdir(parents=True,exist_ok=True)
        shutil.copyfile(path,dest)
    runtime = mirror/"experiments/t11-replacement/runtime.bend"
    prefix, tick = runtime.read_text().split("def tick(",1)
    assert tick.count("case Nil{}: world") == 1
    runtime.write_text(prefix+"def tick("+tick.replace("case Nil{}: world","case Nil{}: flush(world)"))
    check(runtime)
    target = mirror/HERE.relative_to(ROOT)
    assert sha(target/"empty.bend") == sha(HERE/"empty.bend")
    check(target/"empty-witness.bend",failure="Location: equation")
    check(target/"empty.bend",failure="Location: empty_frame")

compiler = pathlib.Path(shutil.which("bend"))
base = pathlib.Path.home()/".bend/bend2/base.bend"
assert sha(compiler) == "d4821d04932218216c9dc906223ed0e23dd86726d4357a567fb76ee6c976db4e"
assert sha(base) == "c742fae9c49b14f0cc9128429a2c6109364c8a933a142f2c90b9f2e5fd976661"
evidence = {"status":"PARTIAL: full-domain empty schedule, actual-owner/array point helpers, Reserve/Publish/FIFO/Barrier and selected safe Bump cell; full nonempty endpoint remains open",
    "baseline":"8e149fd","version":subprocess.check_output(["bend","version"],text=True).strip(),
    "compiler":sha(compiler),"Base":sha(base),"frozen":frozen,
    "closure":{str(p.relative_to(ROOT)):digest for p,digest in sorted(closure.items())},
    "checker_seconds":5,"checks":records}
(HERE/"evidence.json").write_text(json.dumps(evidence,indent=2)+"\n")
print("PASS partial milestone: exact arbitrary-world empty endpoint, actual owner/point helpers, false/kernel negatives and compiling empty-endpoint mutant; full schedule OPEN")

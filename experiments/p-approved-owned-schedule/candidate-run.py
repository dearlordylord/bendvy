#!/usr/bin/env python3
"""Full owned proof diagnostic on a pinned isolated checker candidate; no adoption."""
import argparse, hashlib, json, pathlib, re, shutil, subprocess, tempfile

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--checker", type=pathlib.Path, default=ROOT / "experiments/p-owned-checker-diagnostic/verify.py")
args = parser.parse_args()
checker = args.checker.resolve()
def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()
pins = json.loads((HERE / "candidate-pins.json").read_text())
assert sha(checker) == pins["checker_runner_sha256"], "candidate runner changed"
assert sha(checker.parent / "pins.json") == pins["checker_pins_sha256"], "candidate toolchain pins changed"
frozen = json.loads((ROOT / "experiments/p-owned-route/subjects.json").read_text())["canonical_sources"]
frozen["experiments/p-owned-route/PROPOSED.bend"] = "8e400d78b08530ff17295fa32190d0cf93b1f4641816d2710506b64a8ae2940b"
for name, digest in frozen.items(): assert sha(ROOT / name) == digest, name
marker = "law owned_runtime_schedule_correspondence:"
assert (HERE / "LAWS.bend").read_text().split(marker,1)[1] == (ROOT / "experiments/p-owned-route/PROPOSED.bend").read_text().split(marker,1)[1]
records = []
def check(path, label, location=None, reject_kernel=False):
    cmd = ["python3", str(checker), str(path)]
    if reject_kernel: cmd.append("--reject-kernel")
    # The pinned checker runner enforces five seconds on its entire checker/kernel
    # process group; this outer bound additionally contains its setup/reporting.
    p = subprocess.run(cmd, capture_output=True, text=True, timeout=8)
    result = json.loads(p.stdout)
    expected = 1 if location or reject_kernel else 0
    assert p.returncode == expected and result["exit"] == expected, (label,p.returncode,result,p.stderr)
    if location:
        assert "Location: " + location in result["stderr"], (label,result)
        assert "CHECK PASS" not in result["stdout"], (label,result)
    elif reject_kernel:
        assert result["controlled_kernel_override"] == "/usr/bin/false", result
        assert "CHECK PASS" in result["stdout"] and "kernel rejection" in result["stderr"], result
        assert "KERNEL PASS" not in result["stdout"], result
    else:
        assert "CHECK PASS" in result["stdout"] and "KERNEL PASS" in result["stdout"], (label,result)
    records.append({"label":label,"subject":path.name,"source_sha256":sha(path),"kernel_negative":reject_kernel,"result":result})

positive = ["PROOF.bend", "full-controls.bend", "full-witness.bend"]
for name in positive: check(HERE/name,"original "+name)
check(HERE/"false-negative.bend","false equality control",location="false_fact")
check(HERE/"PROOF.bend","full proof rejects false kernel",reject_kernel=True)

closure = {}
def inventory(path):
    path = path.resolve()
    if path in closure: return
    closure[path] = sha(path)
    for target in re.findall(r"^import (\.{1,2}/\S+)",path.read_text(),re.M): inventory(path.parent/target)
for name in positive: inventory(HERE/name)
mutations = [
    ("implicit final flush","case Nil{}: world","case Nil{}: flush(world)","pending_equation","tick"),
    ("dropped tail","case Con{s,tail}: tick(tail,limit,step(limit,world,s))","case Con{s,tail}: step(limit,world,s)","tail_equation","continue_tick"),
]
for label, old, new, witness_location, proof_location in mutations:
    with tempfile.TemporaryDirectory(prefix="owned-full-candidate-mutant-") as tmp:
        mirror = pathlib.Path(tmp)
        for path in closure:
            dest = mirror/path.relative_to(ROOT)
            dest.parent.mkdir(parents=True,exist_ok=True)
            shutil.copyfile(path,dest)
        runtime = mirror/"experiments/t11-replacement/runtime.bend"
        prefix, tick = runtime.read_text().split("def tick(",1)
        assert tick.count(old) == 1
        runtime.write_text(prefix+"def tick("+tick.replace(old,new))
        target = mirror/HERE.relative_to(ROOT)
        for path,digest in closure.items():
            if path != ROOT/"experiments/t11-replacement/runtime.bend": assert sha(mirror/path.relative_to(ROOT)) == digest
        check(runtime,label+": actual runtime compiles and kernel accepts")
        check(target/"full-witness.bend",label+": complete original-safe witness fails",location=witness_location)
        check(target/"PROOF.bend",label+": unchanged dedicated endpoint induction fails",location=proof_location)

# Explicit baseline control: candidate results must not masquerade as an installed
# compiler pass. The historical normalization failure must remain recognizable.
p = subprocess.run([str(ROOT/"experiments/t01/bend-check"),str(HERE/"PROOF.bend"),"--check-only"],capture_output=True,text=True,timeout=6)
assert p.returncode == 1 and "machine stack overflowed" in p.stdout+p.stderr, (p.returncode,p.stdout,p.stderr)
baseline = {"exit":p.returncode,"stdout":p.stdout,"stderr":p.stderr}
evidence = {
    "status":"CANDIDATE-ONLY: full exact approved owned theorem and own mutation gates pass; installed compiler fails; adoption and root aggregate acceptance remain separate",
    "checker_seconds":5,"candidate_runner":str(checker),"candidate_pins":pins,
    "toolchain_manifest":json.loads((checker.parent/"pins.json").read_text()),
    "runner_sha256":sha(pathlib.Path(__file__)),"frozen":frozen,
    "closure":{str(p.relative_to(ROOT)):digest for p,digest in sorted(closure.items())},
    "checks":records,"installed_baseline":baseline,
}
(HERE/"candidate-evidence.json").write_text(json.dumps(evidence,indent=2)+"\n")
print("CANDIDATE-ONLY PASS: exact owned endpoint, full controls, unchanged kernel, two own induction mutants; no tooling adoption or root completion claimed")

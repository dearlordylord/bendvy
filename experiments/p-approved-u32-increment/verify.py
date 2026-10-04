#!/usr/bin/env python3
"""Frozen exact approved endpoint, checker/kernel, true-domain own mutant gate."""
import hashlib,json,os,re,shutil,signal,subprocess,tempfile,time
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parent.parent
CHECK=ROOT/'experiments/t01/bend-check'
FROZEN=json.loads((HERE/'subjects.json').read_text())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(path,flag='--check-only',expected=0,env=None):
    cmd=[str(CHECK),str(path),flag]
    started=time.monotonic()
    p=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True,env=env)
    try:output=p.communicate(timeout=6)[0]
    except subprocess.TimeoutExpired:
        os.killpg(p.pid,signal.SIGKILL);p.communicate();raise AssertionError('five-second checker wrapper did not terminate')
    assert p.returncode==expected,(cmd,p.returncode,output)
    if expected==0:assert 'ALL PROOFS CHECK' in output,output
    return {'command':cmd,'exit_code':p.returncode,'wall_seconds':time.monotonic()-started,'output':output}
for name,digest in FROZEN['canonical_sources'].items():assert sha(ROOT/name)==digest,name
assert sha(Path('/home/node/.bend/bin/bend'))==FROZEN['compiler_sha256']
assert sha(Path('/home/node/.bend/bend2/base.bend'))==FROZEN['base_sha256']
original=(ROOT/'experiments/p-observe/ARITHMETIC-PROPOSED.bend').read_text()
assert sha(ROOT/'experiments/p-observe/ARITHMETIC-PROPOSED.bend')==FROZEN['approved_subject_sha256']
expected=original[:original.index('law u32_comparison_agrees_nat:')]
assert (HERE/'LAWS.bend').read_text()==expected
assert re.findall(r'^law (\w+):',(HERE/'LAWS.bend').read_text(),re.M)==['u32_increment_no_wrap']
report={'issue':18,'status':'pending','scope':'exact approved universal u32_increment_no_wrap; no other catalogue law','exact_selection':True,'checker_limit_seconds':5,'frozen':FROZEN,'checks':[]}
for flag in ['--check-only','--verdict']:report['checks'].append(run(HERE/'PROOF.bend',flag))
report['checks'].append(run(HERE/'controls.bend','--verdict'))
env=dict(os.environ);env['BENDTT']='/usr/bin/false'
negative=run(HERE/'PROOF.bend','--verdict',1,env)
assert 'ALL PROOFS CHECK' not in negative['output'];report['kernel_negative']=negative
with tempfile.TemporaryDirectory(prefix='increment-mutant-',dir=HERE) as tmp:
    base=Path(tmp)
    shutil.copytree(ROOT/'experiments/t11-replacement',base/'t11-replacement',ignore=shutil.ignore_patterns('__pycache__'))
    shutil.copytree(ROOT/'experiments/p-owned-arithmetic',base/'p-owned-arithmetic',ignore=shutil.ignore_patterns('__pycache__'))
    package=base/'p-approved-u32-increment';package.mkdir()
    for name in ['LAWS.bend','PROOF.bend','controls.bend']:shutil.copyfile(HERE/name,package/name)
    report['copied_original']=run(package/'PROOF.bend','--verdict')
    witness=package/'witness.bend'
    witness.write_text('import Base\nimport ../t11-replacement/spec.bend as S\nimport ../t11-replacement/bridge.bend as B\n\ndef domain() -> {U32.is_lt(255,4294967295) == True{} : Bool}: {==}\ndef exact_true_instance() -> S.When(U32.is_lt(255,4294967295),{U32.to_nat(B.increment(255)) == 1n+U32.to_nat(255) : Nat}): {==}\n')
    report['original_complete_true_domain_witness']=run(witness,'--verdict')
    target=base/'t11-replacement/bridge.bend';text=target.read_text();old='(value + 1 : U32)';new='(value + 2 : U32)'
    assert text.count(old)==1;target.write_text(text.replace(old,new))
    compiled=run(target)
    # Guard remains true on the mutant; no excluded-domain witness can kill it.
    domain=package/'domain.bend';domain.write_text('import Base\ndef domain() -> {U32.is_lt(255,4294967295) == True{} : Bool}: {==}\n')
    mutant_domain=run(domain,'--verdict')
    failure=run(package/'PROOF.bend',expected=1)
    assert 'Location: L.u32_increment_no_wrap' in failure['output'],failure
    assert 'expected :' in failure['output'] and 'observed :' in failure['output']
    false_instance=run(witness,expected=1)
    assert 'Location: exact_true_instance' in false_instance['output'],false_instance
    report['mutant']={'old':old,'new':new,'compiles':compiled,'true_domain_after_mutation':mutant_domain,'unchanged_exact_endpoint_failure':failure,'complete_exact_instance_failure':false_instance}
report['source_hashes']={p.name:sha(p) for p in HERE.glob('*.bend')}
report['runner_sha256']=sha(HERE/'verify.py')
report['version']=subprocess.check_output(['bend','version'],text=True).strip()
report['status']='PASS: exact universal approved increment theorem, checker/kernel, complete true-domain witness, compiling +2 mutant rejected in its own endpoint'
(HERE/'evidence.json').write_text(json.dumps(report,indent=2)+'\n')
print(report['status'])

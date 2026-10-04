#!/usr/bin/env python3
"""Verified neutral wrapper facts plus a reproducible unresolved MAX residual."""
import hashlib,json,os,signal,subprocess,time
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parent.parent
CHECK=ROOT/'experiments/t01/bend-check'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
frozen=json.loads((HERE/'subjects.json').read_text())
for name,h in frozen['sources'].items():assert sha(ROOT/name)==h,name
assert sha(Path('/home/node/.bend/bin/bend'))==frozen['compiler_sha256']
assert sha(Path('/home/node/.bend/bend2/base.bend'))==frozen['base_sha256']
def run(file,flag='--check-only',failure=None,env=None):
    cmd=[str(CHECK),str(HERE/file),flag];start=time.monotonic()
    p=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True,env=env)
    try:out=p.communicate(timeout=6)[0]
    except subprocess.TimeoutExpired:
        os.killpg(p.pid,signal.SIGKILL);p.communicate();raise AssertionError('five-second wrapper did not finish')
    assert p.returncode==(1 if failure else 0),(cmd,p.returncode,out)
    assert (failure or 'ALL PROOFS CHECK') in out,out
    return {'command':cmd,'exit':p.returncode,'wall_seconds':time.monotonic()-start,'output':out}
checks=[run('bridge.bend'),run('bridge.bend','--verdict'),run('controls.bend','--verdict'),run('false.bend',failure='Location: wrong_describe_result')]
residuals=[run('declaration.bend',failure='1 TODO found'),run('found-neutral.bend',failure='machine stack overflowed')]
env=dict(os.environ);env['BENDTT']='/usr/bin/false'
negative=run('bridge.bend','--verdict',failure='SOME PROOFS FAIL',env=env)
assert 'ALL PROOFS CHECK' not in negative['output']
report={'status':'PARTIAL: neutral wrapper bridges verified; exact Overflow row guard still unresolved','issue':18,'baseline':'dc273b8','checker_limit_seconds':5,'frozen':frozen,'checks':checks,'residuals':residuals,'kernel_negative':negative,'source_hashes':{p.name:sha(p) for p in HERE.glob('*.bend')},'runner_sha256':sha(HERE/'verify.py')}
(HERE/'evidence.json').write_text(json.dumps(report,indent=2)+'\n');print(report['status'])

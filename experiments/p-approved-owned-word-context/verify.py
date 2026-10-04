#!/usr/bin/env python3
"""Frozen contextual caller links; each checker/kernel uses the five-second wrapper."""
import hashlib,json,os,signal,subprocess,time
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parent.parent
CHECK=ROOT/'experiments/t01/bend-check'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
frozen=json.loads((HERE/'subjects.json').read_text())
for name,value in frozen['sources'].items():assert sha(ROOT/name)==value,name
assert sha(Path('/home/node/.bend/bin/bend'))==frozen['compiler_sha256']
assert sha(Path('/home/node/.bend/bend2/base.bend'))==frozen['base_sha256']
def run(name,flag='--check-only',bad=None,env=None):
    cmd=[str(CHECK),str(HERE/name),flag];started=time.monotonic()
    p=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True,env=env)
    try:out=p.communicate(timeout=6)[0]
    except subprocess.TimeoutExpired:
        os.killpg(p.pid,signal.SIGKILL);p.communicate();raise AssertionError('checker wrapper failed its five-second deadline')
    assert p.returncode==(1 if bad else 0),(cmd,p.returncode,out)
    if bad:assert bad in out,out
    else:assert 'ALL PROOFS CHECK' in out,out
    return {'command':cmd,'exit':p.returncode,'wall_seconds':time.monotonic()-started,'output':out}
checks=[run('helpers.bend'),run('helpers.bend','--verdict'),run('controls.bend','--verdict'),run('false.bend',bad='Location: invalid_reserve_premise'),run('false-bump.bend',bad='Location: invalid_bump_result')]
env=dict(os.environ);env['BENDTT']='/usr/bin/false'
p=subprocess.run([str(CHECK),str(HERE/'helpers.bend'),'--verdict'],env=env,capture_output=True,text=True,timeout=6)
assert p.returncode==1 and 'ALL PROOFS CHECK' not in p.stdout+p.stderr
report={'status':'PASS: contextual equality, Reserve bound and Bump guard/increment links; checker/kernel and exact negative controls','governing_issue':18,'baseline':'6c4c36a','checker_limit_seconds':5,'frozen':frozen,'version':subprocess.check_output(['bend','version'],text=True).strip(),'checks':checks,'kernel_negative':{'exit':p.returncode,'output':p.stdout+p.stderr},'source_hashes':{x.name:sha(x) for x in HERE.glob('*.bend')},'runner_sha256':sha(HERE/'verify.py')}
(HERE/'evidence.json').write_text(json.dumps(report,indent=2)+'\n');print(report['status'])

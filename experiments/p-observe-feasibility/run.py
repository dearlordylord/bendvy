#!/usr/bin/env python3
"""Bounded checker/kernel feasibility; no ECS theorem is declared proved."""
import hashlib,json,pathlib,shutil,subprocess,time
HERE=pathlib.Path(__file__).resolve().parent
ROOT=HERE.parents[1]
REFERENCE_ROOT=pathlib.Path('/workspace/formal-proofs/bendvy/.references')
def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def invoke(args):
    start=time.monotonic()
    result=subprocess.run(args,cwd=ROOT,text=True,capture_output=True,timeout=5)
    return {'command':args,'exit_code':result.returncode,'stdout':result.stdout,'stderr':result.stderr,'elapsed_seconds':round(time.monotonic()-start,6)}
cases=[('reflexive.bend',True,'ALL PROOFS CHECK'),('erased-match-negative.bend',False,'a live scrutinee'),('false-negative.bend',False,'expected : 0n'),('erased-projection-match-negative.bend',False,'a live scrutinee'),('empty-schedule-attempt.bend',False,'expected : S.When'),('barrier-schedule-attempt.bend',False,'expected : S.When')]
rows=[]
for name,positive,diagnostic in cases:
    item=invoke(['bend',str(HERE/name),'--verdict'])
    item['name']=name
    assert (item['exit_code']==0)==positive,item
    assert diagnostic in item['stdout']+item['stderr'],item
    rows.append(item)
for name,positive in [('erasure-control.bend',True),('erasure-negative.bend',False)]:
    item=invoke(['bend',str(ROOT/'experiments/t11-replacement'/name),'--verdict'])
    item['name']='prior-'+name
    assert (item['exit_code']==0)==positive,item
    output=item['stdout']+item['stderr']
    if positive:
        assert 'ALL PROOFS CHECK' in output,item
    else:
        assert 'SOME PROOFS FAIL' in output,item
        assert 'expected : -world' in output and 'observed : world' in output,item
        assert 'Location: bad' in output,item
    rows.append(item)
manifest=json.loads((REFERENCE_ROOT/'sources.json').read_text())
references={}
for name,source in manifest['sources'].items():
    head=invoke(['git','-C',str(REFERENCE_ROOT/name),'rev-parse','HEAD'])['stdout'].strip()
    assert head==source['commit']
    references[name]=head
files={str(p.relative_to(ROOT)):sha(p) for p in sorted(HERE.glob('*')) if p.suffix in ['.bend','.py']}
files.update({str(p.relative_to(ROOT)):sha(p) for p in sorted((ROOT/'experiments/t11-replacement').glob('*.bend'))})
base=pathlib.Path.home()/'.bend/bend2/base.bend'
record={'version':invoke(['bend','version'])['stdout'].strip(),'binary_sha256':sha(pathlib.Path(shutil.which('bend')).resolve()),'base_sha256':sha(base),'references':references,'source_sha256':files,'cases':rows,'all_expected_results_observed':True,'ecs_theorems_proved':0,'limits':'Each subprocess has a five-second timeout. No dependency added. Failure of these attempts is not a proof of impossibility.'}
(HERE/'evidence.json').write_text(json.dumps(record,indent=2)+'\n')
print('PASS: eight expected checker/kernel outcomes; zero ECS theorems proved.')

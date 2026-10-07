#!/usr/bin/env python3
"""Exact source-bound public affine Local gate; stdlib only."""
import argparse,hashlib,json,os,pathlib,shutil,subprocess,tempfile,time,statistics

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
from task_runner import run as _run_command

ROOT=pathlib.Path(__file__).resolve().parents[2]
HERE=pathlib.Path(__file__).resolve().parent
ORIGINAL_ROOT=ROOT
ORIGINAL_HERE=HERE
parser=argparse.ArgumentParser()
parser.add_argument('--output',type=pathlib.Path)
parser.add_argument('--timing',action='store_true',help='Collect five raw equivalent-work process timings per backend')
args=parser.parse_args()
OUT=(args.output or ORIGINAL_ROOT/'.artifacts'/('public-local-'+str(time.time_ns()))).resolve()
OUT.mkdir(parents=True,exist_ok=False)
# Freeze the exact imported source closure before any checker/backend process.
frozen=tempfile.TemporaryDirectory(prefix='bendvy-local-closure-')
ROOT=pathlib.Path(frozen.name)
(ROOT/'src').mkdir()
shutil.copytree(ORIGINAL_ROOT/'src/ecs',ROOT/'src/ecs')
HERE=ROOT/'experiments/public-local-owner'
shutil.copytree(ORIGINAL_HERE,HERE,ignore=shutil.ignore_patterns('evidence','__pycache__'))
env=dict(os.environ,BENDVY_CLANG19_ROOT='/tmp/bendvy-clang19-diagnostic/root')
receipt={'status':'INCOMPLETE','commands':[],'sourceHashes':{},'timings':[],'timingRequested':args.timing}
def save():
    (OUT/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def inventory(path):return {str(p.relative_to(path)):sha(p) for p in sorted(path.rglob('*')) if p.is_file()}
def run(cmd,limit,name,expected=0):
    start=time.perf_counter()
    p=_run_command([str(x) for x in cmd],cwd=ROOT,env=env,text=True,capture_output=True,timeout=limit)
    elapsed=time.perf_counter()-start
    (OUT/(name+'.stdout')).write_text(p.stdout)
    (OUT/(name+'.stderr')).write_text(p.stderr)
    receipt['commands'].append({'command':[str(x) for x in cmd],'limit':limit,'exit':p.returncode,'elapsed':elapsed,'stdout':name+'.stdout','stderr':name+'.stderr'})
    save()
    assert p.returncode==expected,(name,p.stdout,p.stderr)
    return p.stdout,elapsed
for path in sorted(list((ROOT/'src/ecs').glob('*.bend'))+[p for p in HERE.iterdir() if p.suffix in {'.bend','.py','.mjs','.txt'}]):
    receipt['sourceHashes'][str(path.relative_to(ROOT))]=sha(path)
manifest=ORIGINAL_ROOT/'.references/sources.json'
receipt['manifestHash']=sha(manifest)
pins=json.loads(manifest.read_text())['sources']
receipt['referenceHeads']={}
for name in ['bevy-ts','bevy','bend2']:
    path=ORIGINAL_ROOT/'.references'/name
    head,_=run(['git','-C',path,'rev-parse','HEAD'],5,'reference-head-'+name)
    assert head.strip()==pins[name]['commit'],(name,head,pins[name])
    dirty,_=run(['git','-C',path,'status','--porcelain','--untracked-files=no'],5,'reference-clean-'+name)
    assert not dirty.strip(),(name,dirty)
    receipt['referenceHeads'][name]=head.strip()
reference_tree=ORIGINAL_ROOT/'.references/bevy-ts/packages/core/src'
receipt['referenceSourceHashes']=inventory(reference_tree)
receipt['toolVersions']={}
for name,cmd in [('Bend',['bend','version']),('Node',['node','--version']),('Clang',['/tmp/bendvy-clang19-diagnostic/clang19','--version'])]:
    stdout,_=run(cmd,5,'version-'+name)
    receipt['toolVersions'][name]=stdout.strip()
reference,_=run(['node',HERE/'reference.mjs'],5,'reference')
expected=reference.splitlines();assert len(expected)==19
assert reference== (HERE/'expected.txt').read_text(),'TS adapter differs from frozen complete observations'
run(['bend',HERE/'main.bend','--check-only'],5,'checker')
with tempfile.TemporaryDirectory(prefix='bendvy-locals-') as td:
    td=pathlib.Path(td)
    run(['bend',HERE/'main.bend','-o',td/'main.js'],30,'emit-js')
    run(['bend',HERE/'main.bend','-o',td/'main.c'],30,'emit-c')
    run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',td/'main.c','-o',td/'main.native','-pthread','-lm'],120,'build-native')
    for backend,cmd in {'JS':['node',td/'main.js'],'Native':[td/'main.native']}.items():
        actual,_=run(cmd,5,backend+'-full')
        assert actual.splitlines()==expected
    if args.timing:
        for suffix in ['js','c']:
            run(['bend',HERE/'main.bend','-o',td/('timing.'+suffix)],30,'timing-emit-'+suffix)
        run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',td/'timing.c','-o',td/'timing.native','-pthread','-lm'],120,'timing-build-native')
    if args.timing:
        programs={'TS':['node',HERE/'reference.mjs'],'JS':['node',td/'timing.js'],'Native':[td/'timing.native']}
        for backend,cmd in programs.items():
            for i in range(5):
                actual,elapsed=run(cmd,5,backend+'-'+str(i))
                want=expected
                assert actual.splitlines()==want,(backend,actual,want)
                receipt['timings'].append({'backend':backend,'sample':i,'elapsed':elapsed})
    diagnostics={
      'owner':['- expected : instance','- observed : instance (consumed more than once)','Location: duplicate'],
      'undeclared':['- expected : L.Cell<S.Owner>','- observed : H','Location: undeclared'],
      'schema':['- expected : L.Instance<Other, Unit, U32, Unit, S.Owner, S.Args, Unit, S.Output, other_runner>','- observed : L.Instance<S.Schema, Unit, U32, Unit, S.Owner, S.Args, Unit, S.Output, S.runner>','Location: cross_schema'],
      'runner':['- expected : L.Instance<S.Schema, Unit, U32, Unit, S.Owner, S.Args, Unit, S.Output, other_runner>','- observed : L.Instance<S.Schema, Unit, U32, Unit, S.Owner, S.Args, Unit, S.Output, S.runner>','Location: change_runner']}
    for name,needles in diagnostics.items():
        actual,_=run(['bend',HERE/('negative-'+name+'.bend')],5,'negative-'+name,1)
        actual += (OUT/('negative-'+name+'.stderr')).read_text()
        assert 'SOME PROOFS FAIL' in actual and '- message  :' not in actual,(name,actual)
        assert all(needle in actual for needle in needles),(name,actual)
    mutant=td/'mutant';(mutant/'src').mkdir(parents=True)
    shutil.copytree(ROOT/'src/ecs',mutant/'src/ecs')
    shutil.copytree(HERE,mutant/'experiments/public-local-owner',ignore=shutil.ignore_patterns('evidence','__pycache__'))
    p=mutant/'src/ecs/local.bend';s=p.read_text()
    old='Bool.and(U32.is_eq(namespace,actual),W.registration_list_matches(registrations,id,name,access))'
    new='W.registration_list_matches(registrations,id,name,access)'
    assert old in s;p.write_text(s.replace(old,new))
    m=mutant/'experiments/public-local-owner/main.bend'
    run(['bend',m,'--check-only'],5,'mutant-checker')
    run(['bend',m,'-o',td/'mutant.js'],30,'mutant-emit')
    run(['bend',m,'-o',td/'mutant.c'],30,'mutant-c-emit')
    run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',td/'mutant.c','-o',td/'mutant.native','-pthread','-lm'],120,'mutant-native-build')
    receipt['mutantSourceHash']=sha(p)
    receipt['mutantDetected']={}
    for backend,cmd in {'JS':['node',td/'mutant.js'],'Native':[td/'mutant.native']}.items():
        actual,_=run(cmd,5,'mutant-run-'+backend)
        assert actual.splitlines()!=expected
        assert 'FOREIGN_RUN_BUG' in actual,actual
        receipt['mutantDetected'][backend]=True

receipt['timingScope']='Whole child process, startup/printing included; five raw samples of equivalent main workload, not product qualification. Actual Local adapter policy, full-array snapshots, World transaction rollback, owner recovery and disposal are included.'
receipt['medians']={b:statistics.median(x['elapsed'] for x in receipt['timings'] if x['backend']==b) for b in ['TS','JS','Native']} if args.timing else {}
current_sources={str(p.relative_to(ORIGINAL_ROOT)):sha(p) for p in sorted(list((ORIGINAL_ROOT/'src/ecs').glob('*.bend'))+[p for p in ORIGINAL_HERE.iterdir() if p.suffix in {'.bend','.py','.mjs','.txt'}])}
assert current_sources==receipt['sourceHashes'],'Executable source/inventory drift during run'
assert sha(manifest)==receipt['manifestHash'],'Manifest drift during run'
assert inventory(reference_tree)==receipt['referenceSourceHashes'],'Reference source drift during run'
for name,head in receipt['referenceHeads'].items():
    actual,_=run(['git','-C',ORIGINAL_ROOT/'.references'/name,'rev-parse','HEAD'],5,'reference-head-final-'+name)
    assert actual.strip()==head,'Reference HEAD drift during run'
receipt['finalSourceGuards']='PASS'
receipt['status']='PASS'
(OUT/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
print(json.dumps({'status':receipt['status'],'medians':receipt['medians'],'mutantDetected':receipt['mutantDetected'],'output':str(OUT)}))

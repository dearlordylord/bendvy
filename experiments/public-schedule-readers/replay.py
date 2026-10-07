#!/usr/bin/env python3
"""Guard every original schedule-reader consumer command; original files remain byte-identical."""
import argparse,ast,gzip,hashlib,importlib.util,json,os,pathlib,sys
ROOT=pathlib.Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--cpu',type=int,choices=[5,10],default=10);a=p.parse_args();OUT=a.output.resolve();assert not OUT.exists()
sys.path.insert(0,str(ROOT/'benchmarks/parity-features'));import supervise
spec=importlib.util.spec_from_file_location('flat_tools',ROOT/'benchmarks/parity-features/tool-pins.py');tools=importlib.util.module_from_spec(spec);spec.loader.exec_module(tools)
sha=lambda path:hashlib.sha256(pathlib.Path(path).read_bytes()).hexdigest()
source=ROOT/'experiments/public-schedule-readers/run.py'
files=set((ROOT/'src/ecs').glob('*.bend'))|{x for x in source.parent.iterdir() if x.is_file()}|{pathlib.Path(__file__).resolve(),ROOT/'.references/sources.json',ROOT/'benchmarks/parity-features/supervise.py',ROOT/'benchmarks/parity-features/tool-pins.py',ROOT/'experiments/s-prep/fivehour-connected-gates/supervisor.py'}
PINS={str(x):sha(x) for x in sorted(files)}
def external():return {str(x):sha(x) for x in sorted((ROOT/'.references/bevy-ts/packages/core/src').rglob('*')) if x.is_file()}
EXTERNAL=external()
INSTALLED=tools.snapshot();artifacts={};commands=[];ns={'__file__':str(source),'__name__':'__main__','OUT':OUT}
def guard():
 assert all(sha(x)==h for x,h in PINS.items()),'live subject drift'
 assert external()==EXTERNAL,'reference inventory or bytes drift'
 assert all(sha(x)==h for x,h in artifacts.items()),'artifact/log drift'
 tools.verify(INSTALLED)


def staged_subjects():
 return {str(x):sha(x) for x in OUT.rglob('*') if x.is_file() and x.suffix in {'.bend','.py','.mjs'}}
def guarded_run(args,cap,cwd=ROOT,expected=0):
 guard();ns['guard']();args=list(map(str,args))
 if args[:2]==['timeout','5']:
  assert cap==6;args=args[2:];cap=5
 assert cap in [5,30,120]
 before=staged_subjects()
 target=None
 if '-o' in args:
  target=pathlib.Path(args[args.index('-o')+1]);assert not target.exists(),'prospective output exists'
 label='command-'+str(len(commands));logs=[OUT/(label+'.stdout.gz'),OUT/(label+'.stderr')];assert not any(x.exists() for x in logs)
 actual=['taskset','-c',str(a.cpu),*args]
 prior_cwd=os.getcwd();os.chdir(cwd)
 try:q=supervise.execute(actual,cap,dict(os.environ,BENDVY_CLANG19_ROOT='/tmp/bendvy-clang19-diagnostic/root',BEND_NO_TELEMETRY='1'))
 finally:os.chdir(prior_cwd)
 gzip.open(logs[0],'wb').write(q.stdout);logs[1].write_bytes(q.stderr)
 for x in logs:artifacts[str(x)]=sha(x)
 if target is not None:assert target.is_file();artifacts[str(target)]=sha(target)
 commands.append({'command':actual,'cap':cap,'exit':q.returncode,'stagedSubjects':before})
 assert before==staged_subjects(),'staged subject drift during command';guard();ns['guard']()
 ns['receipt']['commands'].append({'args':args,'cap':cap,'exit':q.returncode,'stdout':q.stdout.decode(),'stderr':q.stderr.decode()})
 if expected is not None:assert q.returncode==expected,(args,q.stdout,q.stderr)
 return q
def verify_reference_heads():
 manifest=json.loads((ROOT/'.references/sources.json').read_text())['sources']
 for name,known in manifest.items():
  result=guarded_run(['git','-C',ROOT/'.references'/name,'rev-parse','HEAD'],5)
  assert result.stdout.decode().strip()==known['commit']
# Only replace the orchestration function and fresh output-path assignment.
# All assertions, application transformations, outputs and mutations execute unchanged.
tree=ast.parse(source.read_text());runs=[x for x in tree.body if isinstance(x,ast.FunctionDef) and x.name=='run'];outs=[x for x in tree.body if isinstance(x,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='OUT' for t in x.targets)]
assert len(runs)==len(outs)==1
tree.body=[x for x in tree.body if x not in runs+outs]
index=next(i for i,x in enumerate(tree.body) if isinstance(x,ast.Try));tree.body.insert(index,ast.parse('verify_reference_heads()').body[0]);ast.fix_missing_locations(tree)
ns['run']=guarded_run;ns['verify_reference_heads']=verify_reference_heads
try:
 guard();exec(compile(tree,str(source),'exec'),ns);guard()
finally:
 if OUT.exists():
  receipt=ns.get('receipt',{});receipt.update(sources={str(pathlib.Path(x).relative_to(ROOT)):v for x,v in PINS.items()},external_hashes=EXTERNAL,installedTools=INSTALLED,guardedCommands=commands,guardedArtifacts=artifacts,orchestration='AST replaces run function and fresh OUT assignment, inserts pinned reference-head guard before original try; all original assertions and mutations unchanged',cpu=a.cpu,childEnvironmentFixed={'BEND_NO_TELEMETRY':'1'})
  (OUT/'receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')

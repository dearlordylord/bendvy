"""Finite literal comparison; no law proof or performance measurement."""
import pathlib,hashlib,json,subprocess,tempfile,shutil,re,os,argparse,time

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
import task_runner

HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[2];parser=argparse.ArgumentParser();parser.add_argument('--output',type=pathlib.Path);args=parser.parse_args();OUT=(args.output or ROOT/'.artifacts'/('schedule-readers-laws-'+str(time.time_ns()))).resolve();OUT.mkdir(parents=True,exist_ok=False)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
found=set();pending=list(HERE.glob('*.bend'))
while pending:
 p=pending.pop().resolve()
 if p in found:continue
 found.add(p)
 for name in re.findall(r'^import\s+(\S+)',p.read_text(),re.M):
  if name!='Base':pending.append((p.parent/name).resolve())
found.add(HERE/'run.py');SNAP={str(p.relative_to(ROOT)):sha(p) for p in found};r={'status':'INCOMPLETE','sources':SNAP,'commands':[],'mutants':{}}
def run(stage,expected,label,cmd,cap,exit=0):
 assert all(sha(ROOT/p)==v for p,v in SNAP.items())
 assert all(sha(stage/p)==v for p,v in expected.items())
 q=task_runner.run(['taskset','-c','5']+list(map(str,cmd)),capture_output=True,text=True,timeout=cap,env=dict(os.environ,BENDVY_CLANG19_ROOT='/tmp/bendvy-clang19-diagnostic/root'))
 (OUT/(label+'.stdout')).write_text(q.stdout);(OUT/(label+'.stderr')).write_text(q.stderr);r['commands'].append({'label':label,'command':list(map(str,cmd)),'cap':cap,'exit':q.returncode});assert q.returncode==exit,(label,q.stderr)
 assert all(sha(stage/p)==v for p,v in expected.items());assert all(sha(ROOT/p)==v for p,v in SNAP.items());return q.stdout
try:
 with tempfile.TemporaryDirectory() as tmp:
  stage=pathlib.Path(tmp)
  for p in SNAP:
   dst=stage/p;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/p,dst)
  expected=dict(SNAP);fixture=stage/HERE.relative_to(ROOT)/'falsify.bend';core=stage/'src/ecs/reader-domains.bend';original=core.read_text()
  out=run(stage,expected,'law-draft-check',['bend',fixture.parent/'LAWS.bend','--check-only'],5,1);assert '3 TODOs' in (OUT/'law-draft-check.stderr').read_text()
  variants={'normal':original,
   'inverted-domain':original.replace('choose(~E,is_event(value),value,events,removals)','choose(~E,Bool.not(is_event(value)),value,events,removals)'),
   'reversed-batches':original.replace('case []: List.reverse(&2,Ev.Batch<E>,acc)','case []: acc'),
   'reset-ticks':original.replace('case (items,_): Ev.Batch{tick,items} <> rest','case (items,_): Ev.Batch{0n,items} <> rest')}
  for name,source in variants.items():
   core.write_text(source);expected['src/ecs/reader-domains.bend']=sha(core);r['mutants'][name]={'source':sha(core),'backends':{}}
   run(stage,expected,name+'-check',['bend',fixture,'--check-only'],5)
   for backend in ['JS']:
    target=OUT/(name+('.js' if backend=='JS' else '.c'));run(stage,expected,name+'-emit-'+backend,['bend',fixture,'-o',target],30)
    if backend=='Native':run(stage,expected,name+'-clang',['/tmp/bendvy-clang19-diagnostic/clang19','-O3',target,'-o',OUT/name,'-pthread','-lm'],120)
    observed=run(stage,expected,name+'-run-'+backend,['node',target] if backend=='JS' else [OUT/name],5)
    lines=[x.split('|') for x in observed.strip().splitlines()];assert len(lines)==8 and all(len(x)==3 for x in lines)
    mismatches=[x[0] for x in lines if x[1]!=x[2]]
    targets={'inverted-domain':'stable_partition','reversed-batches':'filtered_batch_order','reset-ticks':'retained_publication_ticks'}
    if name in targets:assert targets[name] in mismatches,(name,mismatches)
    else:assert mismatches==[],(name,mismatches)
    if name!='normal':assert source!=original,name
    r['mutants'][name]['backends'][backend]={'target_literal':targets.get(name),'mismatches':mismatches,'scope':'finite literals only'}
  assert all(sha(ROOT/p)==v for p,v in SNAP.items());r['status']='PASS'
finally:
 (OUT/'receipt.json').write_text(json.dumps(r,indent=2)+'\n')
print(r['status'])

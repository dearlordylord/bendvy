"""Finite literal comparison; no law proof or performance measurement."""
import pathlib,hashlib,json,subprocess,tempfile,shutil,re,os,argparse,time
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[2];parser=argparse.ArgumentParser();parser.add_argument('--output',type=pathlib.Path);args=parser.parse_args();OUT=(args.output or ROOT/'.artifacts'/('nested-provision-laws-'+str(time.time_ns()))).resolve();OUT.mkdir(parents=True,exist_ok=False)
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
 q=subprocess.run(list(map(str,cmd)),capture_output=True,text=True,timeout=cap,env=dict(os.environ,BENDVY_CLANG19_ROOT='/tmp/bendvy-clang19-diagnostic/root'))
 (OUT/(label+'.stdout')).write_text(q.stdout);(OUT/(label+'.stderr')).write_text(q.stderr);r['commands'].append({'label':label,'command':list(map(str,cmd)),'cap':cap,'exit':q.returncode});assert q.returncode==exit,(label,q.stderr)
 assert all(sha(stage/p)==v for p,v in expected.items());assert all(sha(ROOT/p)==v for p,v in SNAP.items());return q.stdout
try:
 with tempfile.TemporaryDirectory() as tmp:
  stage=pathlib.Path(tmp)
  for p in SNAP:
   dst=stage/p;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/p,dst)
  expected=dict(SNAP);fixture=stage/HERE.relative_to(ROOT)/'falsify.bend';core=stage/'src/ecs/schedule-provision.bend';original=core.read_text()
  out=run(stage,expected,'law-draft-check',['bend',fixture.parent/'LAWS.bend','--check-only'],5,1);assert '5 TODOs' in (OUT/'law-draft-check.stderr').read_text()
  variants={'normal':original,'omitted-requirement':original.replace('case Entry{_,needs}: needs','case Entry{_,needs}: []'),'category-equality':original.replace('case _ _: False{}','case _ _: True{}'), 'union-order':original.replace('unique_seen(~S,items,[])','List.reverse(&2,Requirement<S>,unique_seen(~S,items,[]))'), 'flatten-order':original.replace('flatten(~S,left),flatten(~S,right)','flatten(~S,right),flatten(~S,left)'), 'missing-omission':original.replace('case False{}: item <> next','case False{}: next'), 'precheck-bypass':original.replace('missing_requirements(~S,needs,available),schedule,world,needs','[],schedule,world,needs')}
  for name,source in variants.items():
   core.write_text(source);expected['src/ecs/schedule-provision.bend']=sha(core);r['mutants'][name]={'source':sha(core),'backends':{}}
   run(stage,expected,name+'-check',['bend',fixture,'--check-only'],5)
   for backend in ['JS','Native']:
    target=OUT/(name+('.js' if backend=='JS' else '.c'));run(stage,expected,name+'-emit-'+backend,['bend',fixture,'-o',target],30)
    if backend=='Native':run(stage,expected,name+'-clang',['/tmp/bendvy-clang19-diagnostic/clang19','-O3',target,'-o',OUT/name,'-pthread','-lm'],120)
    observed=run(stage,expected,name+'-run-'+backend,['node',target] if backend=='JS' else [OUT/name],5)
    lines=[x.split('|') for x in observed.strip().splitlines()];assert len(lines)==11 and all(len(x)==3 for x in lines)
    mismatches=[x[0] for x in lines if x[1]!=x[2]]
    targets={'omitted-requirement':'requirements','category-equality':'identity-cross','union-order':'union','flatten-order':'flatten','missing-omission':'missing'}
    if name in targets:assert targets[name] in mismatches,(name,mismatches)
    else:assert mismatches==[],(name,mismatches)
    if name!='normal':assert source!=original,name
    r['mutants'][name]['backends'][backend]={'target_literal':targets.get(name),'mismatches':mismatches,'scope':'precheck-bypass intentionally outside pure metadata laws' if name=='precheck-bypass' else 'finite literals'}
  assert all(sha(ROOT/p)==v for p,v in SNAP.items());r['status']='PASS'
finally:
 (OUT/'receipt.json').write_text(json.dumps(r,indent=2)+'\n')
print(r['status'])

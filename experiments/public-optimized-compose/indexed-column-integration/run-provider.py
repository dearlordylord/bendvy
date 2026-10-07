"""Source-current indexed provider, unchanged gameplay; correctness only."""
import argparse,pathlib,subprocess,hashlib,json,os,shutil,tempfile,re
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[2];BASE=HERE.parent;WORK=BASE/'workshop'
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();out=a.output.resolve();out.mkdir(exist_ok=False)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def inventory():return {str(p.relative_to(ROOT)):sha(p) for p in sorted(list((ROOT/'src/ecs').glob('*.bend'))+list(WORK.glob('*.bend'))+[HERE/'indexed-provider-control.bend',HERE/'run-provider.py'])}
r={'scope':'Source-current indexed empty provisioning, unchanged full Workshop and14old/new transaction/access pairs against actual legacy controls; queues/events in specific fixture are count observations, not full closure payload traces; no performance acceptance','sources':inventory(),'commands':[],'status':'INCOMPLETE'}
staged=None; staged_expected=None
def copied_inventory(stage):
 d=stage/'experiments/public-optimized-compose'
 files=list((stage/'src/ecs').glob('*.bend'))+list((d/'workshop').glob('*.bend'))+[d/HERE.name/'indexed-provider-control.bend']
 return {str(p.relative_to(stage)):sha(p) for p in sorted(files)}
def stage_guard(label):
 if staged is not None:
  assert copied_inventory(staged)==staged_expected,'Unapproved copied source drift before '+label
  r.setdefault('stage_guards',[]).append(label)
def run(label,cmd,cap):
 stage_guard(label)
 q=subprocess.run(list(map(str,cmd)),capture_output=True,text=True,timeout=cap,env=dict(os.environ,BENDVY_CLANG19_ROOT='/tmp/bendvy-clang19-diagnostic/root'));(out/(label+'.stdout')).write_text(q.stdout);(out/(label+'.stderr')).write_text(q.stderr);r['commands'].append({'label':label,'command':list(map(str,cmd)),'cap':cap,'exit':q.returncode});assert q.returncode==0,(label,q.stderr);return q.stdout
expected_path=BASE/'evidence/view-fusion/workshop-main-run-JS.stdout';expected=json.loads(expected_path.read_text());r['Workshop_oracle']={'path':str(expected_path.relative_to(ROOT)),'sha256':sha(expected_path),'scope':'Historical complete observations with unchanged normative inputs'}
try:
 with tempfile.TemporaryDirectory(prefix='indexed-provider-') as temp:
  stage=pathlib.Path(temp);shutil.copytree(ROOT/'src/ecs',stage/'src/ecs');d=stage/'experiments/public-optimized-compose';shutil.copytree(WORK,d/'workshop');(d/HERE.name).mkdir();shutil.copy2(HERE/'indexed-provider-control.bend',d/HERE.name/'indexed-provider-control.bend')
  copied_expected={k:v for k,v in r['sources'].items() if k!=str((HERE/'run-provider.py').relative_to(ROOT))}
  assert copied_inventory(stage)==copied_expected,'Stage copy differs from frozen root source snapshot'
  r['initial_stage_copy_guard']='PASS';r['copied_source_snapshot']=copied_expected
  staged=stage;staged_expected=dict(copied_expected)
  schema=d/'workshop/schema.bend';schema_key=str(schema.relative_to(stage));assert sha(schema)==copied_expected[schema_key]
  source_schema=schema.read_text();assert source_schema.count('Col.empty_indexed(~')==5 and 'Col.empty(~' not in source_schema
  r['provisioning']={'source':schema_key,'sha256':sha(schema),'edit':'NONE: all staged inputs initially equal source-current already-indexed root snapshot; only reached capture-restoration mutant changes source later'}
  stage_guard('source-current-staging-ready')
  assert (d/'workshop/owned-main.bend').read_bytes()==(WORK/'owned-main.bend').read_bytes()
  legacy=[];indexed=[]
  for name,source in [('legacy-control',d/'workshop/owned-provider-control.bend'),('indexed-control',d/HERE.name/'indexed-provider-control.bend'),('owned-main',d/'workshop/owned-main.bend')]:
   run(name+'-check',['bend',source,'--check-only'],5);v=[]
   for backend in ['JS','Native']:
    target=out/(name+('.js' if backend=='JS' else '.c'));run(name+'-emit-'+backend,['bend',source,'-o',target],30)
    if backend=='Native':run(name+'-compile',['/tmp/bendvy-clang19-diagnostic/clang19','-O3',target,'-o',out/name,'-pthread','-lm'],120)
    actual=json.loads(run(name+'-run-'+backend,['node',target] if backend=='JS' else [out/name],5));v.append(actual)
    if name=='owned-main':assert actual==expected;assert len(actual['checkpoints'])==23
    else:
     assert len(actual)==28
     for i in range(0,28,2):assert actual[i]==actual[i+1],(name,i,actual[i:i+2])
     assert actual[0][6]==15 and actual[0][-6:]==[5,9,3,7,11,999],actual[0]
   assert v[0]==v[1]
   if name=='legacy-control':legacy=v[0]
   elif name=='indexed-control':indexed=v[0];assert indexed==legacy
  # Reach omission at actual indexed prepared captured restoration on full Workshop.
  captured=stage/'src/ecs/captured-column.bend';captured_key=str(captured.relative_to(stage));assert sha(captured)==copied_expected[captured_key];original=captured.read_text();old='Col.IndexedPreparedState{values,metadata,capacity,id,owner,remaining,past}';new='Col.IndexedPreparedState{values,metadata,capacity,id,None{},remaining,past}';assert original.count(old)==1;captured.write_text(original.replace(old,new));staged_expected[captured_key]=sha(captured);stage_guard('intentional-mutant-ready');r['mutant']={'kind':'drop actual prepared row owner from indexed captured restoration','original_sha256':hashlib.sha256(original.encode()).hexdigest(),'mutant_sha256':sha(captured),'backends':{}}
  source=d/'workshop/owned-main.bend';run('mutant-check',['bend',source,'--check-only'],5)
  for backend in ['JS','Native']:
   target=out/('mutant'+('.js' if backend=='JS' else '.c'));run('mutant-emit-'+backend,['bend',source,'-o',target],30)
   if backend=='Native':run('mutant-compile',['/tmp/bendvy-clang19-diagnostic/clang19','-O3',target,'-o',out/'mutant','-pthread','-lm'],120)
   actual=json.loads(run('mutant-run-'+backend,['node',target] if backend=='JS' else [out/'mutant'],5));assert actual!=expected;r['mutant']['backends'][backend]='DETECTED'
   r['mutant'].setdefault('different_checkpoint_labels',{})[backend]=[x.get('label',x.get('name','record-'+str(i))) for i,(x,y) in enumerate(zip(actual['checkpoints'],expected['checkpoints'])) if x!=y]
  stage_guard('final-before-stage-cleanup')
 assert inventory()==r['sources'];r['status']='PASS';r['provider_pairs']=14;r['complete_Workshop_checkpoints']=23
finally:(out/'receipt.json').write_text(json.dumps(r,indent=2)+'\n')
print(r['status'])

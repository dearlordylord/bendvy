#!/usr/bin/env python3
"""Independent source-pinned persistent Slot command staging controls."""
import argparse,hashlib,json,os,pathlib,re,shutil,signal,subprocess
P=pathlib.Path
p=argparse.ArgumentParser();p.add_argument('--overlay',type=P,required=True);p.add_argument('--output',type=P,required=True);p.add_argument('--cpu',type=int,default=6);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False)
r={'status':'INCOMPLETE','scope':'Actual persistent Main Slot Type staging and finite affine queue controls; not full22, authority proof or performance','commands':[],'subjects':{}}
def sha(b):return hashlib.sha256(b).hexdigest()
def save(): (a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(argv,limit,label,negative=False):
 out=a.output/(label+'.txt');entry={'argv':list(map(str,argv)),'limitSeconds':limit,'log':out.name};r['commands'].append(entry);save()
 env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root'
 with out.open('w') as f:
  proc=subprocess.Popen(['taskset','-c',str(a.cpu),*map(str,argv)],stdout=f,stderr=subprocess.STDOUT,start_new_session=True,env=env)
  try:entry['exit']=proc.wait(timeout=limit)
  except subprocess.TimeoutExpired:os.killpg(proc.pid,signal.SIGKILL);proc.wait();entry['timeout']=True;save();raise
 text=out.read_text();entry['sha256']=sha(out.read_bytes());save()
 assert (entry['exit']!=0 if negative else entry['exit']==0),(entry,text)
 return text
try:
 manifest=json.loads((a.overlay/'overlay.json').read_text())['sources'];assert all(sha((a.overlay/k).read_bytes())==v for k,v in manifest.items());r['sourceManifest']=manifest;r['inputManifestSHA256']=sha((a.overlay/'overlay.json').read_bytes());r['closureSHA256']=sha(json.dumps(manifest,sort_keys=True,separators=(',',':')).encode())
 core=a.overlay/'experiments/s-integrate';copied=a.output/'core';shutil.copytree(core,copied)
 assert len(list(core.glob('*.bend')))==29
 for f in core.glob('*.bend'):
  assert not f.is_symlink()
  for dep in re.findall(r'^import (\./\S+\.bend)',f.read_text(),re.M):assert (f.parent/dep).resolve().is_relative_to(core.resolve())
 r['recipes']={name:sha((P(__file__).parent/name).read_bytes()) for name in ['run.py','fixtures.py']};r['toolchain']={name:{'path':str(path),'sha256':sha(path.read_bytes())} for name,path in [('compiler',P(shutil.which('bend')).resolve()),('Base',P.home()/'.bend/bend2/base.bend'),('privateClangWrapper',P('/tmp/bendvy-clang19-diagnostic/clang19'))]};save()
 run(['bend','version'],5,'version');run(['bend','guide'],5,'guide')
 for schema,raw,view,aux,flag,ledger,mode in [('Motion','Position','PositionView','Velocity','Selected','MotionLedger','MotionMode'),('Health','Vitals','VitalsView','Armor','Tracked','HealthLedger','HealthMode')]:
  slot=f'CP.Prototype{schema}MainSlot';world=f'S.World<T.{schema}Schema,{slot},T.{aux},T.{flag},C.Cache<T.{ledger},T.LedgerView>,T.{mode}>';handle=f'S.Handle<T.{schema}Schema>';command=f'S.Command<{slot},T.{aux},T.{flag}>';tx=f'X.Tx<{world},{handle},{command}>'
  header='import Base\nimport ./types.bend as T\nimport ./storage.bend as S\nimport ./transaction.bend as X\nimport ./cache.bend as C\nimport ./cached-payload.bend as CP\n'
  for kind,owner in [('slot-positive',slot),('raw-negative',f'T.{raw}'),('cache-negative',f'C.Cache<T.{raw},T.{view}>'),('other-slot-negative',f'CP.Prototype'+('Health' if schema=='Motion' else 'Motion')+'MainSlot')]:
   source=copied/f'{schema.lower()}-{kind}.bend';source.write_text(header+f'def stage(owner:{tx},main:{owner}) -> {tx}:\n  X.tx_stage_command({world},{handle},{command},owner,S.InsertMain{{1,main}})\n')
   text=run(['bend',source,'--check-only'],15,source.stem,kind!='slot-positive')
   assert ('ALL PROOFS CHECK' if kind=='slot-positive' else 'SOME PROOFS FAIL') in text
   if kind!='slot-positive':assert 'Location: stage' in text and f'- expected : {slot}\n- observed : {owner.replace(chr(44), chr(44)+chr(32))}\n' in text
   r['subjects'][source.stem]={'status':'PASS','fixtureSHA256':sha(source.read_bytes()),'expectedResult':'checks' if kind=='slot-positive' else 'intended type refusal'};save()
  other='Health' if schema=='Motion' else 'Motion'
  extras={
   'cross-schema-handle-negative':(header+'import ./commands.bend as K\n'+f'def stage(world:{world},handle:S.Handle<T.{other}Schema>,payload:{slot}) -> T.CommandResult<{world},{slot}>:\n  K.insert_main(T.{schema}Schema,{slot},T.{aux},T.{flag},C.Cache<T.{ledger},T.LedgerView>,T.{mode},world,handle,payload)\n',f'expected : S.Handle<T.{schema}Schema>',f'observed : S.Handle<T.{other}Schema>'),
   'affine-duplicate-negative':(header+f'def stage(payload:{slot}) -> {slot} & {slot}:\n  (payload,payload)\n','expected : payload','observed : payload (consumed more than once)')}
  for kind,(fixture,want,got) in extras.items():
   source=copied/f'{schema.lower()}-{kind}.bend';source.write_text(fixture);text=run(['bend',source,'--check-only'],15,source.stem,True)
   assert 'SOME PROOFS FAIL' in text and 'Location: stage' in text and want in text and got in text
   r['subjects'][source.stem]={'status':'PASS','fixtureSHA256':sha(source.read_bytes()),'expectedResult':'intended type refusal','intendedDiagnostic':[want,got]};save()
 # Runtime fixture generated separately, but import graph and actual modules stay unchanged.
 from fixtures import runtime,expected
 for schema in ['Motion','Health']:
  src=runtime(schema);source=copied/(schema.lower()+'-runtime.bend');source.write_text(src)
  text=run(['bend',source,'--check-only'],15,schema+'-runtime-check');assert 'ALL PROOFS CHECK' in text
  for backend in ['JS','Native']:
   dest=copied/(schema.lower()+('-runtime.js' if backend=='JS' else '-runtime.c'));run(['bend',source,'-o',dest],30,schema+backend+'-emit')
   if backend=='Native':run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',dest,'-o',copied/(schema.lower()+'-native'),'-lm','-pthread'],120,schema+'-clang')
   argv=['node',dest] if backend=='JS' else [copied/(schema.lower()+'-native'),'--threads','1','--gpu','off'];observed=run(argv,5,schema+backend+'-run');assert observed==expected(schema),(schema,backend,observed,expected(schema))
   r['subjects'][schema+backend]={'status':'PASS','fixtureSHA256':sha(source.read_bytes()),'outputSHA256':sha(observed.encode()),'expectedSHA256':sha(expected(schema).encode()),'checkpoints':10};save()
 assert all(sha((a.overlay/k).read_bytes())==v for k,v in manifest.items());r['status']='PASS_BOUNDED_SLOT_STAGING';save()
except BaseException as e:r['error']=repr(e);save();raise

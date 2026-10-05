#!/usr/bin/env python3
import pathlib,subprocess,os,signal,json,hashlib,shutil,re,types,ast
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[2];ART=pathlib.Path(os.environ.get('BENDVY_PERSISTENT_ARTIFACT','/tmp/bendvy-persistent-cache-replay'));ART.mkdir(exist_ok=False);CPU=os.environ.get('BENDVY_CPU','5');e={'status':'INCOMPLETE','cases':[],'sources':{},'limits':{'checker':5,'runtime':5,'codegen':30,'clang':120}}
# Reuse the actual fixed reference guards and bounded process wrapper unchanged.
guards=ROOT/'experiments/s-prep/owned-write-query/run.py';tree=ast.parse(guards.read_text());nodes=[n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name in ['run','reference_provenance','wrong_reference_commit_control']];assert len(nodes)==3
exec(compile(ast.Module(body=nodes,type_ignores=[]),str(guards),'exec'),globals());e['guardSourceSHA256']=hashlib.sha256(guards.read_bytes()).hexdigest()
try:
 e['sourceCommit']=run(['git','-C',ROOT,'rev-parse','HEAD']).strip()
 for protected in [HERE/'reference.mjs',guards,*HERE.glob('*.bend'),HERE/'callback-pins.json']:
  pinned=subprocess.check_output(['git','-C',str(ROOT),'show','HEAD:'+protected.relative_to(ROOT).as_posix()],timeout=5);assert protected.read_bytes()==pinned,'Prototype/adapter/guard source differs from tracked revision: '+str(protected)
 manifest=ROOT/'.references/sources.json';pinned_manifest=subprocess.check_output(['git','-C',str(ROOT),'show','HEAD:.references/sources.json'],timeout=5);assert manifest.read_bytes()==pinned_manifest
 pin=json.loads(pinned_manifest)['sources']['bevy-ts']['commit'];ref=pathlib.Path('/workspace/formal-proofs/bendvy/.references/bevy-ts');e.update(reference_provenance(ref,pin));e['referenceNegativeControl']=wrong_reference_commit_control(pin)
 e['runnerSHA256']=hashlib.sha256(pathlib.Path(__file__).read_bytes()).hexdigest();e['referenceAdapterSHA256']=hashlib.sha256((HERE/'reference.mjs').read_bytes()).hexdigest();e['rawRoot']=str(ART.resolve());e['referenceManifestSHA256']=hashlib.sha256(pinned_manifest).hexdigest()
 run(['bend','version']);run(['bend','guide']);overlay=ART/'overlay';run(['python3',ROOT/'experiments/s-perf/overlay.py',overlay]);pkg=overlay/'experiments/s-integrate'
 for p in HERE.glob('*.bend'):shutil.copy2(p,pkg/p.name)
 frozen=subprocess.check_output(['git','-C',str(ROOT),'show','56b72f6:experiments/s-perf/candidate/measurement-bend.bend'],timeout=5);assert (ROOT/'experiments/s-perf/candidate/measurement-bend.bend').read_bytes()==frozen
 source=frozen.decode();copy=(HERE/'callbacks.bend').read_text();pins=json.loads((HERE/'callback-pins.json').read_text())
 for name,pin in pins.items():
  m=re.search(r'^def '+name+r'\(',source,re.M);end=min(x for x in [source.find('\ndef ',m.start()+1),source.find('\ntype ',m.start()+1),len(source)] if x>=0);part=source[m.start():end].rstrip()+'\n';assert part in copy and hashlib.sha256(part.encode()).hexdigest()==pin
 payload=subprocess.check_output(['git','-C',str(ROOT),'show','56b72f6:experiments/s-integrate/payload.bend'],timeout=5);assert (pkg/'payload.bend').read_bytes()==payload;(pkg/'uncached-payload.bend').write_bytes(payload)
 e['originalCallbackSourceSHA256']=hashlib.sha256(frozen).hexdigest();e['actualPayloadSHA256']=hashlib.sha256(payload).hexdigest()
 # The actual accepted finite writer domain is index0-only scalar updates.
 assert payload.count(b'Array.swap(U32,array,0,value)')==4
 for p in [*HERE.glob('*.bend'),pathlib.Path('/home/node/.bend/bin/bend'),pathlib.Path('/home/node/.bend/bend2/base.bend')]:e['sources'][str(p)]=hashlib.sha256(p.read_bytes()).hexdigest()
 def build(label):
  import datetime
  assert datetime.datetime.now(datetime.timezone.utc)<datetime.datetime(2026,10,5,1,48,tzinfo=datetime.timezone.utc),'Assigned new-build cutoff reached'
  entry=pkg/'prototype.bend';assert 'ALL PROOFS CHECK' in run(['taskset','-c',CPU,'bend',entry,'--check-only']);c=ART/(label+'.c');js=ART/(label+'.js');binary=ART/label
  run(['taskset','-c',CPU,'bend',entry,'-o',c],30);run(['taskset','-c',CPU,'bend',entry,'-o',js],30);run(['taskset','-c',CPU,'clang','-O3',c,'-o',binary,'-lm','-pthread'],120)
  native=run(['taskset','-c',CPU,binary,'--threads','1','--gpu','off']);javascript=run(['taskset','-c',CPU,'node',js]);assert native==javascript;(ART/(label+'.txt')).write_text(native);return native
 original=build('original');e['originalOutputSHA256']=hashlib.sha256(original.encode()).hexdigest();assert reference_provenance(ref,e['referenceCommit'])['referenceClosureSHA256']==e['referenceClosureSHA256'];output=run(['node',HERE/'reference.mjs']);(ART/'reference-observed.json').write_text(output);e['referenceOutputSHA256']=hashlib.sha256(output.encode()).hexdigest();reference=json.loads(output)
 def vals(o):
  if isinstance(o,dict):
   if set(o)=={'a','b','c','d'}:return [o[x] for x in ['a','b','c','d']]
   return {k:vals(v) for k,v in o.items()}
  if isinstance(o,list):return [vals(v) for v in o]
  return o
 records={};sums={'motion':[],'health':[]};pings={}
 for line in original.splitlines():
  if ':cached:' in line or ':raw:' in line:
   sch,step,kind,value=line.split(':',3);records[(sch,step,kind)]=json.loads(value)
  elif ':sum:' in line:
   sch,_,value=line.split(':');sums[sch].append(int(value))
  elif ':pings:' in line:
   sch,step,_,value=line.split(':');pings[(sch,step)]=[int(x) for x in value.split(';') if x]
  else:raise AssertionError('Unexpected line '+line)
 for r in reference:
  sch,step=r['schema'],r['step'];cached=records[(sch,step,'cached')];raw=records[(sch,step,'raw')];assert cached==raw
  assert cached['namespace']==7 and cached['next']==2 and cached['mode']==sch.title()+'On';assert len(cached['rows'])==1
  assert [(x['added'],x['changed']) for x in cached['rows']]==[(3,4 if step=='init' else 9)]
  assert cached['pending']==([] if step=='init' else [{'kind':'FlagView','id':1,'flag':{'group':9}}])
  rows=[{k:vals(v) for k,v in row.items() if k not in ['added','changed']} for row in cached['rows']];assert rows==r['rows'];assert vals(cached['ledger'])==r['ledger']
  if step!='init':assert pings[(sch,step)]==r['pings']
 for sch in ['motion','health']:assert sums[sch]==[46,47]
 assert len(records)==12;e['cases'].append({'label':'persistent cached/raw/freshTS fullworld init commit laterfailure','status':'PASS','worldCheckpoints':6,'schemas':2,'actualTicksPerSchema':2,'epochLimits':'Bend identity/added/changed/commandpending checked independently; no TS epoch equality'})
 controls={
 'affine':'def bad(owner:C.Cache<T.Position,T.PositionView>) -> C.Cache<T.Position,T.PositionView> & C.Cache<T.Position,T.PositionView>:\n  (owner,owner)\n',
 'undeclared-token':'def bad(-Owner:Type,set:Owner -> T.VitalsToken -> U32 -> Owner,owner:Owner) -> Owner:\n  set(owner,T.PositionToken{},1)\n',
 'read-write':'def bad(-Owner:Type,owner:Owner) -> Owner:\n  P.position_swap(owner,1)\n'}
 for name,body in controls.items():
  f=pkg/(name+'.bend');f.write_text('import Base\nimport ./types.bend as T\nimport ./cache.bend as C\nimport ./uncached-payload.bend as P\n'+body);out=run(['taskset','-c',CPU,'bend',f,'--check-only'],expected=1);assert 'Location: bad' in out and 'SOME PROOFS FAIL' in out;e['cases'].append({'label':name,'status':'PASS','output':out})
 cache=(pkg/'cache.bend').read_text();cp=(pkg/'persistent-payload.bend').read_text();raw=payload.decode()
 mutants={
 'stale-cache':('cache.bend',cache.replace('patch(cached,value)','cached')),
 'corrupt-raw-cell3':('uncached-payload.bend',raw.replace('(T.Position{array,frame},old)','(T.Position{Array.set(U32,array,3,999),frame},old)').replace('(T.Vitals{array,reserve,class},old)','(T.Vitals{Array.set(U32,array,3,999),reserve,class},old)'))}
 originals={'cache.bend':cache,'persistent-payload.bend':cp,'uncached-payload.bend':raw}
 for name,(file,changed) in mutants.items():
  assert changed!=originals[file];(pkg/file).write_text(changed);observed=build(name);assert observed!=original;e['cases'].append({'label':name,'status':'DETECTED','compilingBothBackends':True});(pkg/file).write_text(originals[file])
 # Excluded-domain actual exported constructor / raw-transform controls.
 counterexamples={
 'forged-public-cache':cp.replace('C.init(T.Position,T.PositionView,P.position_get,raw)','C.Cache{raw,T.PositionView{T.Four{99,11,12,13},7}}'),
 'arbitrary-raw-transform':cp.replace('uncached_done(Raw,View,cached,get(raw))','uncached_done(Raw,View,cached,get(raw))').replace('C.init(T.Position,T.PositionView,P.position_get,raw)','C.init(T.Position,T.PositionView,P.position_get,raw)')}
 # A direct public Cache constructor with raw original head10 and cached99.
 changed=counterexamples['forged-public-cache'];assert changed!=cp;(pkg/'persistent-payload.bend').write_text(changed);observed=build('forged-public-cache');assert observed!=original;e['cases'].append({'label':'forged public Cache unconditional invariant','status':'FALSIFIED_OUTSIDE_DOMAIN','compilingBothBackends':True});(pkg/'persistent-payload.bend').write_text(cp)
 # Mutate actual raw through original swap while deliberately retaining old cache.
 changed=cp.replace('C.swap(T.Position,T.PositionView,P.position_swap,position_patch,owner,value)','arbitrary_raw(owner,value)')
 helper='def arbitrary_raw_done(cached:T.PositionView,result:T.Position & U32) -> C.Cache<T.Position,T.PositionView> & U32:\n  match result:\n    case (raw,old): (C.Cache{raw,cached},old)\ndef arbitrary_raw(owner:C.Cache<T.Position,T.PositionView>,value:U32) -> C.Cache<T.Position,T.PositionView> & U32:\n  match owner:\n    case C.Cache{raw,cached}: arbitrary_raw_done(cached,P.position_swap(raw,value))\n'
 changed=changed.replace('def position_swap(',helper+'def position_swap(',1);assert changed!=cp;(pkg/'persistent-payload.bend').write_text(changed);observed=build('arbitrary-raw-transform');assert observed!=original;e['cases'].append({'label':'arbitrary raw transform unconditional invariant','status':'FALSIFIED_OUTSIDE_DOMAIN','compilingBothBackends':True});(pkg/'persistent-payload.bend').write_text(cp)
 e['status']='PASS_BOUNDED'
except Exception as error:e['error']=repr(error);raise
finally:(ART/'evidence.json').write_text(json.dumps(e,indent=2)+'\n')

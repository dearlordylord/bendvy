#!/usr/bin/env python3
import pathlib,subprocess,os,signal,json,hashlib,shutil,re,types,ast
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[2];ART=pathlib.Path(os.environ.get('BENDVY_CACHE_ARTIFACT','/tmp/bendvy-cache-replay'));ART.mkdir(exist_ok=False);CPU=os.environ.get('BENDVY_CPU','5');e={'status':'INCOMPLETE','cases':[],'sources':{},'limits':{'checker':5,'runtime':5,'codegen':30,'clang':120}}
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
 lines=[x for x in original.splitlines() if x];at=0
 for row in reference:
  sch=row['schema'];assert lines[at]==sch+':sum:'+str(row['sum']);at+=1;assert lines[at]==sch+':inverse:L:102;M:12;L:101;M:11;L:100;M:10;';at+=1;assert lines[at]==sch+':marks:3';at+=1
  context=vals(json.loads(lines[at].split(':',2)[2]));at+=1;assert context['added']==3 and context['changed']==4;assert {k:v for k,v in context.items() if k not in ['added','changed']}==row['context']
  for kind in ['main','ledger']:
   assert lines[at]==sch+':'+kind+'-checks';at+=1
   for expected in row[kind+'Checks']:
    observed=json.loads(lines[at]);at+=1;assert len(observed)==2 and vals(observed[0])==expected and vals(observed[1])==expected,(observed,expected)
  assert vals(json.loads(lines[at].split(':',2)[2]))==row['mainChecks'][-1];at+=1;assert vals(json.loads(lines[at].split(':',2)[2]))==row['ledgerChecks'][-1];at+=1
 assert at==len(lines);e['cases'].append({'label':'actual raw/cached/freshTS aftereachcheckpoint','status':'PASS','checkpoints':24,'schemas':2})
 f=pkg/'negative.bend';f.write_text('import Base\nimport ./types.bend as T\nimport ./cache.bend as C\ndef bad(owner:C.Cache<T.Position,T.PositionView>) -> C.Cache<T.Position,T.PositionView> & C.Cache<T.Position,T.PositionView>:\n  (owner,owner)\n');out=run(['taskset','-c',CPU,'bend',f,'--check-only'],expected=1);assert 'Location: bad' in out and 'consumed more than once' in out;e['cases'].append({'label':'affine raw owner duplication','status':'PASS','output':out})
 cache=(pkg/'cache.bend').read_text();cp=(pkg/'cached-payload.bend').read_text();raw=payload.decode()
 mutants={
 'raw-wrong-slot':('uncached-payload.bend',raw.replace('Array.swap(U32,array,0,value)','Array.swap(U32,array,1,value)')),
 'cache-wrong-head':('cached-payload.bend',cp.replace('T.Four{value,b,c,d}','T.Four{b,value,c,d}')),
 'stale-cache':('cache.bend',cache.replace('patch(cached,value)','cached')),
 'corrupt-raw-cell3':('uncached-payload.bend',raw.replace('(T.Position{array,frame},old)','(T.Position{Array.set(U32,array,3,999),frame},old)').replace('(T.Vitals{array,reserve,class},old)','(T.Vitals{Array.set(U32,array,3,999),reserve,class},old)'))}
 originals={'cache.bend':cache,'cached-payload.bend':cp,'uncached-payload.bend':raw}
 for name,(file,changed) in mutants.items():
  assert changed!=originals[file];(pkg/file).write_text(changed);observed=build(name);assert observed!=original;e['cases'].append({'label':name,'status':'DETECTED','compilingBothBackends':True});(pkg/file).write_text(originals[file])
 e['status']='PASS_BOUNDED'
except Exception as error:e['error']=repr(error);raise
finally:(ART/'evidence.json').write_text(json.dumps(e,indent=2)+'\n')

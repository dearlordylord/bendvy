#!/usr/bin/env python3
"""Fresh closed typed-cursor controllers; protected authored callback and oracle unchanged."""
from pathlib import Path
import argparse,json,hashlib,gzip,re,shutil,subprocess,os,signal,importlib.util,sys
H=Path(__file__).resolve().parent;ROOT=Path('/workspace/formal-proofs/bendvy');p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--first-only',action='store_true');a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{5});os.environ['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root';base=Path('/tmp/bendvy-slot-host-v1');sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();m=json.loads((base/'overlay.json').read_text());pins=m['sources'];digest=hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest();assert digest=='4baad4960575cda216576e8b90593fbd7ed7dcd44cfa86836b8d87dd5af71f5c'
parentbase=Path('/tmp/bendvy-private-id-query-descending-v1');parentpins=json.loads((parentbase/'overlay.json').read_text())['sources'];assert len(parentpins)==len(pins)==29
expected={'audited-invoker.bend','structural-invoker.bend','host.bend','systems.bend'};changed=set()
for name in pins:
 before=(parentbase/name).read_bytes();after=(base/name).read_bytes();assert sha(parentbase/name)==parentpins[name]
 if before!=after:changed.add(Path(name).name);assert after.startswith(before), 'Nonappend source change'
assert changed==expected
for n,h in pins.items():assert sha(base/n)==h
cache=json.loads((base/'cache-specialization.json').read_text());assert cache==m['cacheSpecialization'] and cache['runtimeClosure']==pins and cache['specializedClosure']==pins and cache['runtimeClosureSHA256']==digest and cache['specializedClosureSHA256']==digest
r={'status':'INCOMPLETE','scope':'Fresh Slot Host source29 typed-cursor row Tx controls; not original Host dispatch or complete full22','source29Pins':pins,'sourceClosure':digest,'commands':[],'programs':[]};outputs={}
def load(n,path):
 sp=importlib.util.spec_from_file_location(n,path);x=importlib.util.module_from_spec(sp);sp.loader.exec_module(x);return x
sys.path.insert(0,str(ROOT/'experiments/s-prep/fivehour-connected-gates'))
PC=load('local_provider',ROOT/'experiments/s-prep/source-paired-journal/local-provider-controls.py');I=load('protected_oracle',ROOT/'experiments/s-prep/owned-write-query-integration/controls-run.py');SUP=load('suppressed_oracle',ROOT/'experiments/s-prep/fivehour-connected-gates/suppressed-owner.py');r['oraclePins']={str(p):sha(p) for p in [ROOT/'experiments/s-prep/owned-write-query-integration/controls-run.py',ROOT/'experiments/s-prep/fivehour-connected-gates/suppressed-owner.py']}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def run(argv,cap,label):
 argv=list(map(str,argv));x=subprocess.Popen(argv,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True)
 try:out=x.communicate(timeout=cap)[0]
 except subprocess.TimeoutExpired:os.killpg(x.pid,signal.SIGKILL);out=x.communicate()[0];r['commands'].append({'argv':argv,'capSeconds':cap,'status':'TIMEOUT','exit':x.returncode});save();raise
 f=a.output/(label+'.stdout');f.write_text(out);r['commands'].append({'argv':argv,'capSeconds':cap,'exit':x.returncode,'outputSHA256':sha(f)});save();assert x.returncode==0,out[-3000:];return out
try:
 for suppressed in [False,True]:
  for getter in ['cached','raw']:
   for lane,cap,main,view,aux,flag,mode in [('motion','Motion','Position','PositionView','Velocity','Selected','MotionMode'),('health','Health','Vitals','VitalsView','Armor','Tracked','HealthMode')]:
    name=('suppressed-' if suppressed else '')+getter+'-'+lane;folder=a.output/name;folder.mkdir();core=folder/'core';shutil.copytree(base/'experiments/s-integrate',core);callback=PC.extract_callbacks(core);r['callbackPinReceipt']=callback
    text=gzip.decompress((ROOT/'experiments/s-prep/source-paired-journal/templates'/('cache-tx-'+lane+'-controls.bend.gz')).read_bytes()).decode();original=text;text=text.replace('import Base\n','import Base\nimport ./query.bend as Q\n',1)
    slot='P.Prototype'+cap+'MainSlot';rawop='position' if lane=='motion' else 'vitals';text=text.replace('CC.Cache<T.'+main+',T.'+view+'>',slot).replace('P.'+rawop+'_new','P.prototype_slot_'+rawop+'_new').replace('P.'+rawop+'_get','P.prototype_slot_'+rawop+'_get')
    for n in re.findall(r'^def ('+lane+r'_\w+)\(', (core/'transaction-dispatch-adapters.bend').read_text(),re.M):text=re.sub(r'\bA\.'+n+r'\b','A.prototype_packed_'+n,text)
    # Fixture adapter calls the actual cursor fold with the incoming selected Handle namespace and ID.
    w=f'S.World<T.{cap}Schema,{slot},T.{aux},T.{flag},CC.Cache<T.{cap}Ledger,T.LedgerView>,T.{mode}>';c=f'S.Command<{slot},T.{aux},T.{flag}>';tx=f'X.Tx<{w},S.Handle<T.{cap}Schema>,{c}>';family='prototype_cursor_flatfold_'+lane
    wrapper=f'''def actual_row(~client:@-Owner:Type -> @-get:(Owner -> T.{main}Token -> Owner & T.Access<T.{view}>) -> @-set:(Owner -> T.{main}Token -> U32 -> Owner) -> @-ledger:(Owner -> T.{cap}LedgerToken -> Owner & Maybe<&2,T.LedgerView>) -> @-setledger:(Owner -> T.{cap}LedgerToken -> U32 -> Owner) -> Owner -> Owner & U32,owner:{tx}) -> {tx} & U32:
  match owner:
    case X.Tx{{world,S.Handle{{+namespace,+id}},undo,commands,pings,marks}}: X.prototype_flat_pair_unpack(~T.{cap}Schema,~{w},~{c},HA.{family}(~client,Q.PrototypeIdCursor{{namespace,[id]}},X.prototype_flat_pack(~T.{cap}Schema,~{w},~{c},X.Tx{{world,S.Handle{{namespace,id}},undo,commands,pings,marks}}),0))
'''
    text=text.replace('def '+lane+'_pair(',wrapper+'def '+lane+'_pair(').replace('HA.prototype_flatjournal_'+lane+'_row(~M.'+lane+'_body,','actual_row(~M.'+lane+'_body,')
    if getter=='raw':
     shutil.copyfile(ROOT/'experiments/s-prep/fivehour-connected-gates/original-raw-observer.bend',core/'original-raw-observer.bend');(core/'slot-raw-observer.bend').write_bytes((H/'slot-raw-observer.bend').read_bytes());text=text.replace('import Base\n','import Base\nimport ./original-raw-observer.bend as ORG\nimport ./slot-raw-observer.bend as SLOTORG\n',1).replace('P.prototype_slot_'+rawop+'_get','SLOTORG.'+rawop+'_get')
     for op in ['motion_ledger','health_ledger']:text=text.replace('P.'+op+'_get','ORG.'+op+'_get')
    if suppressed:
     f=core/'held-adapter.bend';s=f.read_text();s=(H/'suppress.py').read_text() if False else s
     # Exact private setter-local suppression preserves old raw AND cached a, journals and marks.
     prefix='prototype_packed_row_' if lane=='motion' else 'prototype_packed_prototype_journalledger_health_';done=prefix+('set_done' if lane=='motion' else 'set_fused_done')
     b=re.search(r'^def '+done+r'\(.*?(?=\ndef |\Z)',s,re.M|re.S)[0];new=b.replace('cachedframe:U32,','cachedframe:U32,priora:U32,') if lane=='motion' else b.replace('cachedclass:U32,','cachedclass:U32,priora:U32,');array='coordinates' if lane=='motion' else 'levels';new=new.replace('Array.set(U32,'+array+',0,value)',array).replace('rawframe,value,b','rawframe,priora,b').replace('rawclass,value,b','rawclass,priora,b');assert new!=b;s=s.replace(b,new,1)
     b=re.search(r'^def '+prefix+r'set\(.*?(?=\ndef |\Z)',s,re.M|re.S)[0];new=b.replace('rawframe,_,b','rawframe,priora,b').replace('rawclass,_,b','rawclass,priora,b').replace('cachedframe,ledger_raw','cachedframe,ledger_raw')
     if lane=='motion':new=new.replace('handle,undo,marks,value,Array.get','handle,undo,marks,value,Array.get') # priora is positioned after cachedframe in done signature.
     if lane=='motion':new=new.replace('cachedframe,ledger_raw,ledger_cached,handle,undo,marks,value,Array.get','cachedframe,priora,ledger_raw,ledger_cached,handle,undo,marks,value,Array.get')
     else:new=new.replace('cachedclass,value,Array.get','cachedclass,priora,value,Array.get')
     assert new!=b;s=s.replace(b,new,1);f.write_text(s)
    fixture=core/('cache-tx-'+lane+'-controls.bend');fixture.write_text(text);r['programs'].append({'label':name,'schema':lane,'getter':getter,'suppressed':suppressed,'sourceRoot':str(core),'source29Pins':{n:sha(core/Path(n).name) for n in pins},'fixturePath':str(fixture),'fixtureSHA256':sha(fixture),'extraPins':{p.name:sha(p) for p in core.glob('*.bend') if p.name not in [Path(n).name for n in pins]},'originalTemplateSHA256':hashlib.sha256(original.encode()).hexdigest(),'status':'INCOMPLETE'});rec=r['programs'][-1];save()
    run(['bend',fixture,'--check-only'],15,name+'-check');run(['bend',fixture,'-o',folder/'subject.js'],30,name+'-js-emit');run(['bend',fixture,'-o',folder/'subject.c'],30,name+'-c-emit');run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',folder/'subject.c','-pthread','-lm','-o',folder/'subject.native'],120,name+'-clang')
    js=run(['node',folder/'subject.js'],5,name+'-js-run');native=run([folder/'subject.native','--threads','1','--gpu','off'],5,name+'-native-run');jl=[json.loads(x) for x in js.splitlines()];nl=[json.loads(x) for x in native.splitlines()];assert len(jl)==72 and jl==nl;outputs[name]=jl;rec.update(status='BOTH_BACKENDS_72_FULL_RECORDS_EQUAL',generatedPins={n:sha(folder/n) for n in ['subject.js','subject.c','subject.native']});save()
    if a.first_only:r['status']='FIRST_ACTUAL_SUBJECT_72_RECORDS_BOTH_BACKENDS_PASS';save();raise SystemExit(0)
 # Protected independent oracle over exact original interleaving, no expectation rewrite.
 for suppressed in [False,True]:
  merged=[]
  for getter in ['cached','raw']:
   combined=[]
   for scenario in range(9):
    for lane in ['motion','health']:combined.extend(outputs[('suppressed-' if suppressed else '')+getter+'-'+lane][scenario*8:scenario*8+8])
   if not suppressed:I.independent(combined);assert not I.differences(combined);baseline=combined
   else:assert combined==SUP.expected_noop(outputs['baseline-combined']) and combined!=outputs['baseline-combined']
   merged.append(combined)
  assert merged[0]==merged[1]
  if not suppressed:outputs['baseline-combined']=merged[0]
 r['status']='FRESH_ACTUAL_TYPED_CURSOR_TX_AND_SUPPRESSED_576_PER_BACKEND_PASS';save()
except BaseException as e:
 if not isinstance(e,SystemExit):r.update(status='FAIL',error=repr(e));save()
 raise

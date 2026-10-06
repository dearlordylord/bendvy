#!/usr/bin/env python3
"""Original sixteen factory/world subjects, actual Slot/cursor transport only."""
from pathlib import Path
import argparse,json,hashlib,re,shutil,subprocess,signal,os,sys,importlib.util
H=Path(__file__).resolve().parent;ROOT=Path('/workspace/formal-proofs/bendvy');G=ROOT/'experiments/s-prep/fivehour-connected-gates';sys.path.insert(0,str(G));import provider_controls as PC
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);p.add_argument('--first-only',action='store_true');a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{9});os.environ['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def load(n,p):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
W=load('protected_world',G/'static-world-run.py');S=load('protected_slice',G/'materialize-controls.py');base=Path('/tmp/bendvy-slot-host-v1');m=json.loads((base/'overlay.json').read_text());pins=m['sources'];digest=hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest();assert digest=='4baad4960575cda216576e8b90593fbd7ed7dcd44cfa86836b8d87dd5af71f5c' and all(sha(base/n)==h for n,h in pins.items());c=json.loads((base/'cache-specialization.json').read_text());assert c==m['cacheSpecialization'] and c['runtimeClosure']==c['specializedClosure']==pins and c['runtimeClosureSHA256']==c['specializedClosureSHA256']==digest
original=PC.definitions((base/'experiments/s-integrate/measurement-bend.bend').read_text());point=PC.definitions((G/'tx-controls.bend').read_text());template=(G/'static-world-controls.bend').read_text();r={'status':'INCOMPLETE','scope':'Fresh original factory/two-live-local-ID worlds, private Slot cursor static callback and unchanged original point callback; original literal full-field oracle unchanged','sourcePins':pins,'sourceClosure':digest,'fixtureSHA256':sha(G/'static-world-controls.bend'),'oracleSHA256':sha(G/'static-world-run.py'),'recipeSHA256':sha(Path(__file__)),'cases':[]}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
for observer in ['cached','raw']:
 for client in ['static','original-point']:
  for lane,cap,main,view,aux,flag,mode in [('motion','Motion','Position','PositionView','Velocity','Selected','MotionMode'),('health','Health','Vitals','VitalsView','Armor','Tracked','HealthMode')]:
   d=a.output/(observer+'-'+client+'-'+lane);d.mkdir();core=d/'core';shutil.copytree(base/'experiments/s-integrate',core);text=template
   if client=='original-point':
    (core/'gate-original-callbacks.bend').write_text('import Base\nimport ./types.bend as T\n'+''.join(original[n] for n in PC.CALLBACK_NAMES));text=text.replace('import ./prototype-static-client.bend as M','import ./gate-original-callbacks.bend as M')
    for x in ['motion','health']:text=text.replace('HA.'+x+'_row(~M.'+x+'_body,',x+'_body(')
    at=text.index('def quad(');text=text[:at]+point['motion_body']+point['health_body']+text[at:]
   for x,ca,ma,vi,au,fl,mo,op in [('motion','Motion','Position','PositionView','Velocity','Selected','MotionMode','position'),('health','Health','Vitals','VitalsView','Armor','Tracked','HealthMode','vitals')]:
    slot='P.Prototype'+ca+'MainSlot';text=text.replace('CC.Cache<T.'+ma+',T.'+vi+'>',slot).replace('P.'+op+'_get','P.prototype_slot_'+op+'_get')
    for n in re.findall(r'^def ('+x+r'_\w+)\(', (core/'raw-boundaries.bend').read_text(),re.M):
     if 'def prototype_packed_'+n+'(' in (core/'raw-boundaries.bend').read_text():text=re.sub(r'\bRB\.'+n+r'\b','RB.prototype_packed_'+n,text)
    for n in re.findall(r'^def ('+x+r'_\w+)\(', (core/'transaction-dispatch-adapters.bend').read_text(),re.M):text=re.sub(r'\bA\.'+n+r'\b','A.prototype_packed_'+n,text)
    w=f'S.World<T.{ca}Schema,{slot},T.{au},T.{fl},CC.Cache<T.{ca}Ledger,T.LedgerView>,T.{mo}>';co=f'S.Command<{slot},T.{au},T.{fl}>';tx=f'X.Tx<{w},S.Handle<T.{ca}Schema>,{co}>'
    if client=='static':
     wrapper=f'''def actual_{x}_row(~client:@-Owner:Type -> @-get:(Owner -> T.{ma}Token -> Owner & T.Access<T.{vi}>) -> @-set:(Owner -> T.{ma}Token -> U32 -> Owner) -> @-ledger:(Owner -> T.{ca}LedgerToken -> Owner & Maybe<&2,T.LedgerView>) -> @-setledger:(Owner -> T.{ca}LedgerToken -> U32 -> Owner) -> Owner -> Owner & U32,owner:{tx}) -> {tx} & U32:
  match owner:
    case X.Tx{{world,S.Handle{{+namespace,+id}},undo,commands,pings,marks}}: X.prototype_flat_pair_unpack(~T.{ca}Schema,~{w},~{co},HA.prototype_cursor_flatfold_{x}(~client,IQ.PrototypeIdCursor{{namespace,[id]}},X.prototype_flat_pack(~T.{ca}Schema,~{w},~{co},X.Tx{{world,S.Handle{{namespace,id}},undo,commands,pings,marks}}),0))
'''
     text=text.replace('def quad(',wrapper+'def quad(',1).replace('HA.'+x+'_row(~M.'+x+'_body,','actual_'+x+'_row(~M.'+x+'_body,')
   text=text.replace('import Base\n','import Base\nimport ./query.bend as IQ\n',1)
   if observer=='raw':
    shutil.copyfile(ROOT/'experiments/s-prep/source-slot-host-tx-controls/slot-raw-observer.bend',core/'slot-raw-observer.bend');shutil.copyfile(G/'original-raw-observer.bend',core/'original-raw-observer.bend');text=text.replace('import Base\n','import Base\nimport ./slot-raw-observer.bend as SLOTORG\nimport ./original-raw-observer.bend as ORG\n',1)
    for op in ['position','vitals']:text=text.replace('P.prototype_slot_'+op+'_get','SLOTORG.'+op+'_get')
    for op in ['motion_ledger','health_ledger']:text=text.replace('P.'+op+'_get','ORG.'+op+'_get')
   other='health' if lane=='motion' else 'motion';text=text.replace('    '+other+'_start(True{})\n','').replace('    '+other+'_start(False{})\n','');text,retained,removed=S.reachable_fixture(text,'main');entry=core/'static-world-controls.bend';entry.write_text(text);case={'schema':lane,'observer':observer,'client':client,'status':'INCOMPLETE','fixturePins':{p.name:sha(p) for p in core.glob('*.bend') if p.name not in {Path(n).name for n in pins}},'retained':retained,'commands':[]};r['cases'].append(case);save()
   def run(argv,limit,label):
    argv=list(map(str,argv));x=subprocess.Popen(argv,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True)
    try:o=x.communicate(timeout=limit)[0]
    except subprocess.TimeoutExpired:os.killpg(x.pid,signal.SIGKILL);o=x.communicate()[0];(d/(label+'.txt')).write_text(o);case['commands'].append({'argv':argv,'cap':limit,'status':'TIMEOUT'});save();raise
    (d/(label+'.txt')).write_text(o);case['commands'].append({'argv':argv,'cap':limit,'exit':x.returncode});save();assert x.returncode==0,o;return o
   try:
    out=run(['bend',entry,'--check-only'],15,'check');assert 'ALL PROOFS CHECK' in out;run(['bend',entry,'-o',d/'subject.js'],30,'js-emit');run(['bend',entry,'-o',d/'subject.c'],30,'c-emit');run(['/tmp/bendvy-clang19-diagnostic/clang19','-O3',d/'subject.c','-pthread','-lm','-o',d/'subject.native'],120,'clang');wanted=[record for foreign in [True,False] for ns in [1,2] for record in [{'command':'MissingEntity'},W.expected(lane,ns,foreign)]];outputs=[]
    for backend,cmd in [('JS',['node',d/'subject.js']),('Native',[d/'subject.native','--threads','1','--gpu','off'])]:
     raw=run(cmd,5,backend.lower()+'-run');rows=[json.loads(x) for x in raw.splitlines()];assert rows==wanted,{'actual':rows,'expected':wanted};outputs.append(rows)
    assert outputs[0]==outputs[1];case.update(status='BOTH_BACKENDS_EIGHT_FULL_RECORDS_PASS',generatedPins={n:sha(d/n) for n in ['subject.js','subject.c','subject.native']})
   except Exception as e:case.update(status='FAIL_OR_LIMIT',error=repr(e));r['status']='PARTIAL_OR_FAILED';save();raise
   save()
   if a.first_only:r['status']='FIRST_ACTUAL_SLOT_FACTORY_SUBJECT_PASS';save();raise SystemExit(0)
assert len(r['cases'])==8 and all(x['status']=='BOTH_BACKENDS_EIGHT_FULL_RECORDS_PASS' for x in r['cases']);r['status']='FRESH_ACTUAL_SLOT_FACTORY_WORLD16_FULL_FIELDS_PASS';save()

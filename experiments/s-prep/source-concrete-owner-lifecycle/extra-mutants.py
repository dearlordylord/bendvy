#!/usr/bin/env python3
"""Direct flat finish/publication, literal foreign/repeated/dead/high stamp controls."""
import argparse,pathlib,json,hashlib,os,importlib.util,re,sys,shutil,gzip
sys.path.insert(0,"/workspace/formal-proofs/bendvy/experiments/s-prep/fivehour-connected-gates")
p=argparse.ArgumentParser();p.add_argument('--retain-views',action='store_true');p.add_argument('--selection',choices=['Required','Present','Absent','Optional'],default='Required');p.add_argument('--ragged-main',action='store_true');p.add_argument('--alias-main',action='store_true');p.add_argument('--expect-mismatch',action='store_true');p.add_argument('--force-recovery',action='store_true');p.add_argument('--scenario',choices=['one','two','no-ledger','missing'],default='one');p.add_argument('--overlay',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--mutation',choices=['drop-pair-undo','drop-pending','drop-detached','reverse-order','drop-recovered','wrong-old','drop-context']);p.add_argument('--observer',choices=['cached','raw'],default='cached');p.add_argument('--pattern',choices=['pair','main-only','ledger-only','ledger-main','main-ledger-main'],default='pair');a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{8});here=pathlib.Path('/workspace/formal-proofs/bendvy/experiments/s-prep/source-packed-paired-finish-controls')
# Reuse only bounded process/build helpers; no expected oracle is imported.
spec=importlib.util.spec_from_file_location('bounded','/workspace/formal-proofs/bendvy/experiments/t05/run.py');B=importlib.util.module_from_spec(spec);spec.loader.exec_module(B)
import subprocess,signal
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'status':'INCOMPLETE','CPU':8,'sourcePins':json.loads((a.overlay/'overlay.json').read_text())['sources'],'commands':[],'cases':[]}
shutil.copy2(pathlib.Path(__file__),a.output/'executed-recipe.py')
r['scope']='Actual handoff enumeration and rank2 fixture callback; eight original/candidate pre/post records, no inherited acceptance';r['recipeSHA256']=sha(pathlib.Path(__file__));r['retainedViews']=a.retain_views;r['selection']=a.selection;r['raggedMainWitness']=a.ragged_main;r['aliasedMainWitness']=a.alias_main;r['expectedDivergence']=a.expect_mismatch;r['forcedRecoveryConcreteAdapter']=a.force_recovery;r['scenario']=a.scenario;r['pattern']=a.pattern;r['observer']=a.observer
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def command(argv,expected=0,timeout=5):
 argv=list(map(str,argv));env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root'
 if '--check-only' in argv:argv[0]='bend';timeout=15
 if argv[0]=='clang':argv[0]='/tmp/bendvy-clang19-diagnostic/clang19'
 inputs={x:sha(pathlib.Path(x)) for x in argv if pathlib.Path(x).is_file()}
 exe=pathlib.Path(shutil.which(argv[0]) or argv[0]);inputs[str(exe)]=sha(exe)
 c=subprocess.Popen(argv,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True,env=env);timed=False
 try:out=c.communicate(timeout=timeout)[0]
 except subprocess.TimeoutExpired:timed=True;os.killpg(c.pid,signal.SIGKILL);out=c.communicate()[0]
 rec={'argv':argv,'inputFileSHA256':inputs,'outputSHA256':hashlib.sha256(out.encode()).hexdigest(),'limitSeconds':timeout,'exit':c.returncode,'timeout':timed,'output':out};r['commands'].append(rec);save();assert c.returncode==expected and not timed,rec;return out
B.command=command
try:
 assert not a.retain_views or (a.scenario in ['one','two'] and a.selection!='Absent' and not a.alias_main and not a.ragged_main),'Retained-view literal oracle binds one visited row'
 assert a.selection!='Absent' or a.scenario=='one','Absent literal oracle currently one live flagged row'
 empty=a.scenario=='missing' or a.selection=='Absent'
 assert not a.ragged_main or a.scenario=='two','Ragged witness binds two-row oracle'
 assert not (a.alias_main and a.ragged_main)
 assert not a.alias_main or a.scenario=='two','Aliased-array witness binds two-row literal oracle'
 assert not a.force_recovery or a.scenario=='no-ledger','Forced recovery binds absent-ledger literal oracle'
 assert a.scenario!='two' or a.pattern=='pair','Two-row literal oracle currently binds pair writes only'
 boundOverlay=a.overlay;boundManifests={n:sha(a.overlay/n) for n in ['overlay.json','cache-specialization.json']}
 originalPins=r['sourcePins'];assert len(originalPins)==29,'Candidate must bind complete source29'
 for rel,h in originalPins.items():assert sha(a.overlay/rel)==h
 baseline=pathlib.Path('/tmp/bendvy-slot-host-v1')
 baselinePins=json.loads((baseline/'overlay.json').read_text())['sources']
 assert hashlib.sha256(json.dumps(baselinePins,sort_keys=True,separators=(',',':')).encode()).hexdigest()=='4baad4960575cda216576e8b90593fbd7ed7dcd44cfa86836b8d87dd5af71f5c'
 manifest=json.loads((a.overlay/'overlay.json').read_text());cache=json.loads((a.overlay/'cache-specialization.json').read_text())
 digest=hashlib.sha256(json.dumps(originalPins,sort_keys=True,separators=(',',':')).encode()).hexdigest()
 assert manifest['cacheSpecialization']==cache and cache['runtimeClosure']==cache['specializedClosure']==originalPins
 assert cache['runtimeClosureSHA256']==cache['specializedClosureSHA256']==digest
 assert digest=='a4672d110446195e3ac92911c6f41166b62025811df8816878356d0eafd08a55','Concrete frozen closure drift'
 r['candidateClosureSHA256']=digest
 assert set(originalPins)==set(baselinePins)
 for rel,h in baselinePins.items():
  assert sha(baseline/rel)==h
  old=(baseline/rel).read_bytes();new=(a.overlay/rel).read_bytes()
  if rel.endswith('/query.bend'):assert new.removeprefix(b'import ./cached-payload.bend as CP\n').startswith(old),'Original generic query changed'
  elif rel.endswith('/held-adapter.bend'):assert new.startswith(old),'Original provider algorithms changed'
  elif not rel.endswith('/measurement-bend.bend'):assert new==old,'Unexpected candidate module change'
 r['baselineSourcePins']=baselinePins
 if a.mutation:
  copy=a.output/'mutant';shutil.copytree(a.overlay,copy);tp=copy/'experiments/s-integrate'/('query.bend' if a.mutation in ['drop-detached','reverse-order','drop-recovered'] else 'held-adapter.bend' if a.mutation in ['drop-pending','wrong-old','drop-context'] else 'transaction.bend');body=tp.read_text()
  before='case PrototypeFlatPair{space,id,main_old,ledger_old,tail}: prototype_flat_unwind(~Schema,~W,~restore_main,~restore_ledger,tail,restore_main(restore_ledger(world,ledger_old),S.Handle{space,id},main_old))'
  after='case PrototypeFlatPair{_,_,_,_,tail}: prototype_flat_unwind(~Schema,~W,~restore_main,~restore_ledger,tail,world)'
  if a.mutation=='wrong-old':
   for cap in ['Motion','Health']:
    before='prototype_pending_main(~T.'+cap+'Schema,space,id,old,undo)'
    assert body.count(before)==1;body=body.replace(before,'prototype_pending_main(~T.'+cap+'Schema,space,id,value,undo)')
  if a.mutation=='drop-context':
   for lname in ['motion','health']:
    before='case (columns,ids): prototype_cursor_flatfold_'+lname+'_loop(~client,ns,ids,PrototypeFlatFold{ns,next,columns,aux,metadata,capacity,depth,high,pending,ledger,mode,selected,undo,commands,pings,marks,total})'
    assert body.count(before)==1;body=body.replace(before,before.replace('commands,pings,marks','commands,[],marks'))
  if a.mutation=='drop-pending':
   before='case PrototypePendingUndo{True{},space,id,old,tail}: X.PrototypeFlatMain{space,id,old,tail}'
   after='case PrototypePendingUndo{True{},_,_,_,tail}: tail'
  if a.mutation in ['drop-detached','reverse-order','drop-recovered']:
   for lname,cap in [('motion','Motion'),('health','Health')]:
    state='PrototypeConcrete'+cap+'HandoffState';rows='PrototypeConcrete'+cap+'HandoffRows';con='Concrete'+cap+'HandoffCon';nil='Concrete'+cap+'HandoffNil';helper='prototype_control_'+lname+'_reverse'
    if a.mutation=='drop-detached':
     before='case Tuple{main,Some{owner}}: '+state+'{main,aux,live,flags,added,changed,'+con+'{id,owner,values}}'
     after='case Tuple{main,Some{_}}: '+state+'{main,aux,live,flags,added,changed,values}'
    elif a.mutation=='drop-recovered':
     before='prototype_concrete_'+lname+'_handoff_recover_go(rest,Array.set(Maybe<CP.Prototype'+cap+'MainSlot>,columns,U32.sub(id,1),Some{owner}),id <> ids)'
     after='prototype_concrete_'+lname+'_handoff_recover_go(rest,columns,id <> ids)'
    else:
     before='case '+state+'{main,aux,live,flags,added,changed,values}: (S.Rows{main,aux,S.MetadataColumns{live,flags,added,changed},capacity,depth,high},values)'
     after=before[:-7]+helper+'(values,'+nil+'{}))'
     definition='\ndef '+helper+'(values:'+rows+',result:'+rows+') -> '+rows+':\n  match values:\n    case '+nil+'{}: result\n    case '+con+'{id,owner,rest}: '+helper+'(rest,'+con+'{id,owner,result})\n'
     body=body.replace('def prototype_concrete_'+lname+'_handoff_finish_forward(',definition+'def prototype_concrete_'+lname+'_handoff_finish_forward(',1)
    assert body.count(before)==1,(lname,before);body=body.replace(before,after)
  elif a.mutation not in ['wrong-old','drop-context']:
   assert body.count(before)==1;body=body.replace(before,after)
  tp.write_text(body);a.overlay=copy
  if a.mutation in ['drop-pending','wrong-old']:
   ref=copy/'experiments/s-integrate/reference-held-adapter.bend';ref.write_bytes((boundOverlay/'experiments/s-integrate/held-adapter.bend').read_bytes())
   r['referenceExtra']={'path':str(ref),'SHA256':sha(ref),'scope':'Unmodified original HA consumers with same nominal dependency imports'}
  r['mutation']={'name':a.mutation,'site':{'wrong-old':'actual concrete row setter true-old journal capture','drop-context':'actual handoff recovery returned pings','drop-pending':'actual pending Main flush'}.get(a.mutation,'actual named mutation body; see archived source'),'sourceSHA256':sha(tp)}
 for lane,cap,main,view,aux,flag,mode in [('motion','Motion','Position','PositionView','Velocity','Selected','MotionMode'),('health','Health','Vitals','VitalsView','Armor','Tracked','HealthMode')]:
  archived=here/'templates'/('cache-tx-'+lane+'-controls.bend.gz');text=gzip.decompress(archived.read_bytes()).decode();r['cases'].append({'archivedFixture':str(archived),'SHA256':sha(archived)});text=text[:text.index('def main()')]
  text=re.sub(r'^import \./(\S+) as ',lambda m:'import '+str(a.overlay/'experiments/s-integrate'/m[1])+' as ',text,flags=re.M)
  w=f'S.World<T.{cap}Schema,CC.Cache<T.{main},T.{view}>,T.{aux},T.{flag},CC.Cache<T.{cap}Ledger,T.LedgerView>,T.{mode}>';c=f'S.Command<CC.Cache<T.{main},T.{view}>,T.{aux},T.{flag}>';tx=f'X.Tx<{w},S.Handle<T.{cap}Schema>,{c}>'
  args=f'~{tx},~A.{lane}_read_main,~A.{lane}_set_main0,~A.{lane}_read_ledger,~A.{lane}_set_ledger0'
  pack=f'X.prototype_flat_pack(~T.{cap}Schema,~{w},~{c},owner)'
  unpack=f'X.prototype_flat_pair_unpack(~T.{cap}Schema,~{w},~{c},'
  text+=f'''
def fixture_body(~Owner:Type,~get:Owner -> T.{main}Token -> Owner & T.Access<T.{view}>,~set:Owner -> T.{main}Token -> U32 -> Owner,~ledger:Owner -> T.{cap}LedgerToken -> Owner & Maybe<&2,T.LedgerView>,~setledger:Owner -> T.{cap}LedgerToken -> U32 -> Owner,owner:Owner) -> Owner & U32:
  (setledger(setledger(set(owner,T.{main}Token{{}},30),T.{cap}LedgerToken{{}},200),T.{cap}LedgerToken{{}},300),55)
def selected(handle:S.Handle<T.{cap}Schema>,owner:{tx}) -> {tx}:
  match owner:
    case X.Tx{{world,_,undo,commands,pings,marks}}: X.Tx{{world,handle,undo,commands,pings,marks}}
def reference_added(total:U32,result:{tx} & U32) -> {tx} & U32:
  match result:
    case (owner,value): (owner,U32.add(total,value))
def reference_second(result:{tx} & U32) -> {tx} & U32:
  match result:
    case (owner,total): reference_added(total,fixture_body({args},selected(S.Handle{{8,1}},owner)))
def reference(owner:{tx}) -> {tx} & U32:
  fixture_body({args},selected(S.Handle{{7,1}},owner))
def actual(owner:{tx}) -> {tx} & U32:
  {unpack}HA.prototype_flatfold_{lane}(~fixture_body,[S.Handle{{7,1}}],{pack},0))
def transformed_done(owner:{tx}) -> {tx} & U32:
  match owner:
    case X.Tx{{world,_,_,_,_,_}}: (X.Tx{{world,S.Handle{{7,2}},[X.MainInverse{{S.Handle{{7,1}},10}},X.LedgerInverse{{100}},X.LedgerInverse{{77}}],[S.Despawn{{1}},S.RemoveFlag{{2}}],[66,55],[S.Handle{{8,1}},S.Handle{{7,1}},S.Handle{{7,2}},S.Handle{{7,1}}]}},24)
def transformed(owner:{tx}) -> {tx} & U32:
  transformed_done(A.{lane}_set_ledger0(A.{lane}_set_main0(owner,T.{main}Token{{}},40),T.{cap}LedgerToken{{}},400))
def transport_actual(owner:{tx}) -> {tx} & U32:
  {unpack}HA.prototype_flatfold_{lane}_finish(HA.prototype_flatfold_{lane}_fallback(transformed(owner),0)))
def original_finish(fail:Bool,owner:{tx}) -> IO(Unit):
  match fail:
    case False{{}}: {lane}_post(X.storage_commit(T.{cap}Schema,CC.Cache<T.{main},T.{view}>,T.{aux},T.{flag},CC.Cache<T.{cap}Ledger,T.LedgerView>,T.{mode},X.tx_finish_success({w},S.Handle<T.{cap}Schema>,{c},owner),9))
    case True{{}}: {lane}_post(X.storage_commit(T.{cap}Schema,CC.Cache<T.{main},T.{view}>,T.{aux},T.{flag},CC.Cache<T.{cap}Ledger,T.LedgerView>,T.{mode},A.{lane}_finish_failure(owner),9))
def direct_finish(fail:Bool,result:X.PrototypeFlatTx<T.{cap}Schema,{w},{c}> & U32) -> IO(Unit):
  match fail result:
    case False{{}} Tuple{{owner,_}}: {lane}_post(X.prototype_flat_storage_commit(~T.{cap}Schema,~CC.Cache<T.{main},T.{view}>,~T.{aux},~T.{flag},~CC.Cache<T.{cap}Ledger,T.LedgerView>,~T.{mode},X.prototype_flat_finish_success(~T.{cap}Schema,~{w},~{c},owner),9))
    case True{{}} Tuple{{owner,_}}: {lane}_post(X.prototype_flat_storage_commit(~T.{cap}Schema,~CC.Cache<T.{main},T.{view}>,~T.{aux},~T.{flag},~CC.Cache<T.{cap}Ledger,T.LedgerView>,~T.{mode},X.prototype_flat_finish_failure(~T.{cap}Schema,~{w},~{c},~A.{lane}_world_restore,~A.{lane}_world_ledger_restore,owner),9))
def pair(+fail:Bool,kind:U32) -> IO(Unit):
  match kind:
    case 0:
      do IO<Unit>:
        original : {tx} <- {lane}_pre(reference({lane}_owner(0)))
        original_finish(fail,original)
        direct_finish(fail,HA.prototype_flatfold_{lane}(~fixture_body,[S.Handle{{7,1}}],X.prototype_flat_pack(~T.{cap}Schema,~{w},~{c},{lane}_owner(0)),0))
    case _: IO.print("unexpected-fixture-kind")
def main() -> IO(Unit):
  do IO<Unit>:
    pair(False{{}},0)
    pair(True{{}},0)
'''
  if a.retain_views:
   prior=f'def fixture_body(~Owner:Type,~get:Owner -> T.{main}Token -> Owner & T.Access<T.{view}>,~set:Owner -> T.{main}Token -> U32 -> Owner,~ledger:Owner -> T.{cap}LedgerToken -> Owner & Maybe<&2,T.LedgerView>,~setledger:Owner -> T.{cap}LedgerToken -> U32 -> Owner,owner:Owner) -> Owner & U32:\n  (setledger(setledger(set(owner,T.{main}Token{{}},30),T.{cap}LedgerToken{{}},200),T.{cap}LedgerToken{{}},300),55)'
   mainmeta='_' if lane=='motion' else '_,_'
   updated=f'''def retained_value(~Owner:Type,owner:Owner,valid:Bool) -> Owner & U32:\n  match valid:\n    case True{{}}: (owner,55)\n    case False{{}}: (owner,999)\ndef retained_sum(~Owner:Type,owner:Owner,+sum:U32) -> Owner & U32:\n  retained_value(~Owner,owner,Bool.or(U32.is_eq(sum,110),U32.is_eq(sum,1200)))\ndef retained_finish(~Owner:Type,main:T.{view},oldledger:T.LedgerView,owner:Owner) -> Owner & U32:\n  match main oldledger:\n    case T.{view}{{T.Four{{a,_,_,_}},{mainmeta}}} T.LedgerView{{T.Four{{b,_,_,_}},_}}: retained_sum(~Owner,owner,U32.add(a,b))\ndef retained_ledger(~Owner:Type,~set:Owner -> T.{main}Token -> U32 -> Owner,~setledger:Owner -> T.{cap}LedgerToken -> U32 -> Owner,oldmain:T.{view},result:Owner & Maybe<&2,T.LedgerView>) -> Owner & U32:\n  match result:\n    case (owner,Some{{oldledger}}): retained_finish(~Owner,oldmain,oldledger,setledger(setledger(set(owner,T.{main}Token{{}},30),T.{cap}LedgerToken{{}},200),T.{cap}LedgerToken{{}},300))\n    case (owner,None{{}}): (owner,999)\ndef retained_main(~Owner:Type,~set:Owner -> T.{main}Token -> U32 -> Owner,~ledger:Owner -> T.{cap}LedgerToken -> Owner & Maybe<&2,T.LedgerView>,~setledger:Owner -> T.{cap}LedgerToken -> U32 -> Owner,result:Owner & T.Access<T.{view}>) -> Owner & U32:\n  match result:\n    case (owner,T.Found{{oldmain}}): retained_ledger(~Owner,~set,~setledger,oldmain,ledger(owner,T.{cap}LedgerToken{{}}))\n    case (owner,_): (owner,998)\ndef fixture_body(~Owner:Type,~get:Owner -> T.{main}Token -> Owner & T.Access<T.{view}>,~set:Owner -> T.{main}Token -> U32 -> Owner,~ledger:Owner -> T.{cap}LedgerToken -> Owner & Maybe<&2,T.LedgerView>,~setledger:Owner -> T.{cap}LedgerToken -> U32 -> Owner,owner:Owner) -> Owner & U32:\n  retained_main(~Owner,~set,~ledger,~setledger,get(owner,T.{main}Token{{}}))'''
   assert text.count(prior)==1;text=text.replace(prior,updated)
  if a.pattern!='pair':
   original='(setledger(setledger(set(owner,T.'+main+'Token{},30),T.'+cap+'LedgerToken{},200),T.'+cap+'LedgerToken{},300),55)'
   variants={'main-only':'set(owner,T.'+main+'Token{},30)','ledger-only':'setledger(owner,T.'+cap+'LedgerToken{},300)','ledger-main':'set(setledger(owner,T.'+cap+'LedgerToken{},300),T.'+main+'Token{},30)','main-ledger-main':'set(setledger(set(owner,T.'+main+'Token{},20),T.'+cap+'LedgerToken{},300),T.'+main+'Token{},30)'}
   assert text.count(original)==1;text=text.replace(original,'('+variants[a.pattern]+',55)')
  if lane=='health':
   text=text.replace('HA.prototype_flatfold_health(~fixture_body,','HA.prototype_journalledger_health(~fixture_body,')
   oldroute='HA.prototype_flatfold_health_finish(HA.prototype_flatfold_health_fallback(transformed(owner),0))'
   newroute='HA.prototype_journalledger_health_finish(HA.prototype_journalledger_health_unpack(HA.prototype_flatfold_health_converted(transformed(owner)),0))'
   assert text.count(oldroute)==1;text=text.replace(oldroute,newroute)
  # Observe actual candidate before finish while retaining exact flat journal shape.
  flat=f'X.PrototypeFlatTx<T.{cap}Schema,{w},{c}>'
  helper=f'''\ndef candidate_pre_done(undo:X.PrototypeFlatInverse<T.{cap}Schema>,marks:X.PrototypeFlatMark<T.{cap}Schema>,owner:{tx}) -> {flat}:\n  match owner:\n    case X.Tx{{world,selected,_,commands,pings,_}}: X.PrototypeFlatTx{{world,selected,undo,commands,pings,marks}}\ndef candidate_pre(result:{flat} & U32) -> IO({flat} & U32):\n  match result:\n    case (X.PrototypeFlatTx{{world,selected,+undo,commands,pings,+marks}},+total):\n      do IO<{flat} & U32>:\n        observed : {tx} <- {lane}_pre((X.Tx{{world,selected,X.prototype_flat_inverse_unpack(~T.{cap}Schema,undo),commands,pings,X.prototype_flat_mark_unpack(~T.{cap}Schema,marks)}},total))\n        return (candidate_pre_done(undo,marks,observed),total)\n'''
  text=text.replace('def pair(+fail:',helper+'\ndef pair(+fail:')
  original=f'        direct_finish(fail,HA.prototype_flatfold_{lane}(~fixture_body,[S.Handle{{7,1}}],X.prototype_flat_pack(~T.{cap}Schema,~{w},~{c},{lane}_owner(0)),0))'
  if lane=='health':original=original.replace('HA.prototype_flatfold_health','HA.prototype_journalledger_health')
  call=original[original.index('HA.'): -1]
  replacement=f'        candidate : {flat} & U32 <- candidate_pre({call})\n        direct_finish(fail,candidate)'
  assert text.count(original)==1;text=text.replace(original,replacement)
  # Change only actual fold registration to candidate whole-owner query handoff.
  if True:
   before=f'HA.prototype_flatfold_motion(~fixture_body,[S.Handle{{7,1}}],' if lane=='motion' else f'HA.prototype_journalledger_health(~fixture_body,[S.Handle{{7,1}}],'
   after=f'HA.prototype_handoff_flatfold_{lane}(~fixture_body,Q.Required{{}},'
   assert text.count(before)==2,text.count(before)
   text=text.replace(before,after)
  text='import '+str(a.overlay/'experiments/s-integrate/query.bend')+' as Q\n'+text
  if a.scenario=='two':
   text=text.replace(f'{lane}_owner(0)',f'{lane}_owner(8)')
   text=text.replace('reference_second(result:', 'reference_second_unused(result:')
   old=f'  fixture_body({args},selected(S.Handle{{7,1}},owner))'
   new=f'  reference_two(fixture_body({args},selected(S.Handle{{7,1}},owner)))'
   assert text.count(old)==1;text=text.replace(old,new)
   text+=f'\ndef reference_two(result:{tx} & U32) -> {tx} & U32:\n  match result:\n    case (owner,total): reference_added(total,fixture_body({args},selected(S.Handle{{7,2}},owner)))\n'
   # Helpers must precede callers in the Bend source.
   fragment=text[text.rindex('\ndef reference_two'):];text=text[:text.rindex('\ndef reference_two')]
   text=text.replace('def reference(owner:',fragment+'\ndef reference(owner:')
  if a.scenario=='no-ledger':text=text.replace(f'{lane}_owner(0)',f'{lane}_owner(5)')
  if a.force_recovery:
   batch=f'Q.PrototypeConcrete{cap}HandoffBatch<T.{aux},T.{flag},CC.Cache<T.{cap}Ledger,T.LedgerView>,T.{mode}>'
   forced=f'''\ndef recovery_world(batch:{batch}) -> {batch}:\n  match batch:\n    case Q.PrototypeConcrete{cap}HandoffBatch{{S.World{{ns,next,rows,pending,_,mode}},owners}}: Q.PrototypeConcrete{cap}HandoffBatch{{S.World{{ns,next,rows,pending,None{{}},mode}},owners}}\ndef recovery_entry(owner:{flat}) -> {flat} & U32:\n  match owner:\n    case X.PrototypeFlatTx{{world,selected,undo,commands,pings,marks}}: HA.prototype_handoff_{lane}_ready(~fixture_body,selected,undo,commands,pings,marks,0,recovery_world(Q.prototype_concrete_{lane}_handoff_each(T.{aux},T.{flag},CC.Cache<T.{cap}Ledger,T.LedgerView>,T.{mode},Q.Required{{}},world)))\n'''
   text=text.replace('def candidate_pre_done(',forced+'\ndef candidate_pre_done(')
   before=f'HA.prototype_handoff_flatfold_{lane}(~fixture_body,Q.Required{{}},X.prototype_flat_pack(~T.{cap}Schema,~{w},~{c},{lane}_owner(5)),0)'
   after=f'recovery_entry(X.prototype_flat_pack(~T.{cap}Schema,~{w},~{c},{lane}_owner(0)))'
   assert text.count(before)==1;text=text.replace(before,after)
  if a.alias_main or a.ragged_main:
   # Exact fixture AST fragment retained as ordinary text; use a balanced known prefix.
   start=text.index(f'S.Rows{{ANode{{ALeaf{{{lane}_main(scenario)}}')+len('S.Rows{')
   end=text.index('},ANode{ALeaf{Some{T.'+aux,start)+1
   replacement=f'ANode{{ANode{{ALeaf{{None{{}}}},ALeaf{{None{{}}}}}},ALeaf{{{lane}_main(scenario)}}}}' if a.ragged_main else f'ALeaf{{{lane}_main(scenario)}}'
   text=text[:start]+replacement+text[end:]
   if a.ragged_main:
    start=text.index('S.MetadataColumns{',text.index(f'def {lane}_owner('));end=text.index('},2,1n,case_high(scenario)',start)+len('},2,1n,case_high(scenario)')
    text=text[:start]+f'S.MetadataColumns{{ANode{{ANode{{ALeaf{{False{{}}}},ALeaf{{False{{}}}}}},ANode{{ALeaf{{True{{}}}},ALeaf{{True{{}}}}}}}},[None{{}}:Maybe<&2,T.{flag}>^2n],[3:U32^2n],[4:U32^2n]}},4,2n,4'+text[end:]
  if a.scenario=='missing':text=text.replace(f'{lane}_owner(0)',f'{lane}_owner(4)')
  # Execute the original cursor enumeration+consumer as reference, not a supplied-ID proxy.
  legacy=f'''def legacy_next(selected:S.Handle<T.{cap}Schema>,undo:List<&2,X.Inverse<S.Handle<T.{cap}Schema>>>,commands:List<{c}>,pings:List<&2,U32>,marks:List<&2,S.Handle<T.{cap}Schema>>,result:{w} & Q.PrototypeIdCursor<T.{cap}Schema>) -> {tx} & U32:\n  match result:\n    case (world,cursor): X.prototype_flat_pair_unpack(~T.{cap}Schema,~{w},~{c},HA.prototype_cursor_flatfold_{lane}(~fixture_body,cursor,X.prototype_flat_pack(~T.{cap}Schema,~{w},~{c},X.Tx{{world,selected,undo,commands,pings,marks}}),0))\ndef reference(owner:{tx}) -> {tx} & U32:\n  match owner:\n    case X.Tx{{world,selected,undo,commands,pings,marks}}: legacy_next(selected,undo,commands,pings,marks,Q.prototype_cursor_each(~T.{cap}Schema,~CC.Cache<T.{main},T.{view}>,~T.{aux},~T.{flag},~CC.Cache<T.{cap}Ledger,T.LedgerView>,~T.{mode},Q.Required{{}},world))\n'''
  text=re.sub(r'^def reference\(owner:.*?(?=^def )',lambda _:legacy,text,flags=re.M|re.S,count=1)
  if a.mutation in ['drop-pending','wrong-old']:
   text='import '+str(a.overlay/'experiments/s-integrate/reference-held-adapter.bend')+' as HB\n'+text
   text=text.replace(f'HA.prototype_cursor_flatfold_{lane}(~fixture_body,cursor,',f'HB.prototype_cursor_flatfold_{lane}(~fixture_body,cursor,')
  # Adapt the concrete fixture only; both actual and independent generic reference own Slot World.
  text=text.replace('CC.Cache<T.'+main+',T.'+view+'>','P.Prototype'+cap+'MainSlot')
  text=text.replace('P.'+('position' if lane=='motion' else 'vitals')+'_new','P.prototype_slot_'+('position' if lane=='motion' else 'vitals')+'_new')
  text=text.replace('P.'+('position' if lane=='motion' else 'vitals')+'_get','P.prototype_slot_'+('position' if lane=='motion' else 'vitals')+'_get')
  text=re.sub(r'A\.'+lane+r'_(\w+)',lambda m:'A.prototype_packed_'+lane+'_'+m[1],text)
  text=text.replace('HA.prototype_flatfold_motion','HA.prototype_packed_prototype_flatfold_motion').replace('HA.prototype_journalledger_health','HA.prototype_packed_prototype_journalledger_health')
  if a.observer=='raw':
   slot='P.Prototype'+cap+'MainSlot';getname='fixture_raw_slot'
   metas=['rawframe','ca','cb','cc','cd','cachedframe'] if lane=='motion' else ['rawreserve','rawclass','ca','cb','cc','cd','cachedreserve','cachedclass']
   meta_fields=','.join(x+':U32' for x in metas);shape=','.join('+'+x if x.startswith('raw') else x for x in metas)
   view_meta='rawframe' if lane=='motion' else 'rawreserve,rawclass'
   extra='\ntype FixtureSlotMeta is Data:\n  FixtureSlotMeta{'+meta_fields+'}\n'
   extra+='def fixture_raw_slot(owner:'+slot+') -> '+slot+' & T.'+view+':\n  match owner:\n    case '+slot+'{array,'+','.join(metas)+'}: fixture_raw_0(FixtureSlotMeta{'+','.join(metas)+'},Array.get(U32,array,0))\n'
   for i,rawname in enumerate(['a','b','c']):
    prev=['a','b','c'][:i];args=''.join(','+x+':U32' for x in prev);vals=','.join(['meta']+prev+[rawname])
    extra+='def fixture_raw_'+str(i)+'(meta:FixtureSlotMeta'+args+',result:Array<U32> & U32) -> '+slot+' & T.'+view+':\n  match result:\n    case Tuple{array,'+rawname+'}: fixture_raw_'+str(i+1)+'('+vals+',Array.get(U32,array,'+str(i+1)+'))\n'
   extra+='def fixture_raw_3(meta:FixtureSlotMeta,a:U32,b:U32,c:U32,result:Array<U32> & U32) -> '+slot+' & T.'+view+':\n  match meta result:\n    case FixtureSlotMeta{'+shape+'} Tuple{array,d}: ('+slot+'{array,'+','.join(metas)+'},T.'+view+'{T.Four{a,b,c,d},'+view_meta+'})\n'
   pieces=re.split(r'(?=^def )',extra,flags=re.M);extra=pieces[0]+''.join(reversed(pieces[1:]))
   text=text.replace('P.prototype_slot_'+('position' if lane=='motion' else 'vitals')+'_get',getname)
  text=text.replace('Q.Required{}','Q.'+a.selection+'{}')
  sl=importlib.util.spec_from_file_location('slice_fixture','/workspace/formal-proofs/bendvy/experiments/s-prep/fivehour-connected-gates/materialize-controls.py');sm=importlib.util.module_from_spec(sl);sl.loader.exec_module(sm);text,_,_=sm.reachable_fixture(text,'main');text=re.sub(r'^import .* as M\n','',text,flags=re.M)
  if a.observer=='raw':
   first=text.index('def ');text=text[:first]+extra+text[first:]
  folder=a.output/lane;folder.mkdir();src=folder/'fallback.bend';src.write_text(text)
  for program in B.build(src,folder):
   out=B.execute(program);(folder/(program.name+'.jsonl')).write_text(out+'\n');records=[json.loads(x) for x in out.splitlines()];assert len(records)==8
   mismatches=[]
   for i in range(2):
    oldpre,oldpost,newpre,newpost=records[4*i:4*i+4]
    if oldpre!=newpre or oldpost!=newpost:mismatches.append({'case':i,'originalPre':oldpre,'candidatePre':newpre,'originalPost':oldpost,'candidatePost':newpost})
    kind=0;fail=i%2
    assert oldpre['value']==(0 if empty else 110 if a.scenario=='two' else 55 if kind==0 else 24)
    assert oldpre['selected']==({'namespace':7,'id':4 if a.ragged_main else 2 if a.scenario=='two' else 1} if kind==0 else {'namespace':7,'id':2})
    assert oldpre['pings']==([12,11] if kind==0 else [66,55])
    assert oldpre['commands']==([{'kind':'RemoveFlagView','id':1},{'kind':'DespawnView','id':2}] if kind==0 else [{'kind':'DespawnView','id':1},{'kind':'RemoveFlagView','id':2}])
    wanted_marks=([{'namespace':7,'id':2}] if empty or a.pattern=='ledger-only' else [{'namespace':7,'id':4},{'namespace':7,'id':3},{'namespace':7,'id':2}] if a.ragged_main else [{'namespace':7,'id':2},{'namespace':7,'id':1},{'namespace':7,'id':2}] if a.scenario=='two' else [{'namespace':7,'id':1},{'namespace':7,'id':1},{'namespace':7,'id':2}] if a.pattern=='main-ledger-main' else [{'namespace':7,'id':1},{'namespace':7,'id':2}])
    assert oldpre['marks']==wanted_marks
    assert oldpre['undo']==('L:77;' if empty else 'M7/1:10;L:77;' if a.scenario=='no-ledger' else ('L:200;L:300;M7/4:30;L:200;L:100;M7/3:10;L:77;' if a.ragged_main else 'L:200;L:300;M7/2:30;L:200;L:100;M7/1:10;L:77;' if a.alias_main else 'L:200;L:300;M7/2:900;L:200;L:100;M7/1:10;L:77;') if a.scenario=='two' else {'pair':'L:200;L:100;M7/1:10;L:77;','main-only':'M7/1:10;L:77;','ledger-only':'L:100;L:77;','ledger-main':'M7/1:10;L:100;L:77;','main-ledger-main':'M7/1:20;L:100;M7/1:10;L:77;'}[a.pattern] if kind==0 else 'M7/1:10;L:100;L:77;'),oldpre
    coords='coordinates' if lane=='motion' else 'levels'
    if a.scenario=='missing':assert oldpre['world']['rows'][0]['main'] is None and oldpost['world']['rows'][0]['main'] is None
    else:assert oldpre['world']['rows'][0]['main'][coords]['a']==(10 if empty else (10 if a.pattern=='ledger-only' else 30) if kind==0 else 40)
    if a.scenario=='no-ledger':assert oldpre['world']['ledger'] is None and oldpost['world']['ledger'] is None
    else:assert oldpre['world']['ledger']['totals']['a']==(100 if empty else (100 if a.pattern=='main-only' else 300) if kind==0 else 400)
    if a.scenario!='missing':assert oldpost['world']['rows'][0]['main'][coords]['a']==(10 if fail or empty else (10 if a.pattern=='ledger-only' else 30) if kind==0 else 40)
    if a.scenario!='no-ledger':assert oldpost['world']['ledger']['totals']['a']==(77 if fail else 100 if empty else (100 if a.pattern=='main-only' else 300) if kind==0 else 400)
    assert oldpost['world']['rows'][0]['changed']==(4 if fail or empty or a.pattern=='ledger-only' else 9)
    assert oldpost['pings']==([] if fail else [11,12] if kind==0 else [55,66])
    assert oldpost['world']['pending']==([] if fail else [{'kind':'DespawnView','id':2},{'kind':'RemoveFlagView','id':1}] if kind==0 else [{'kind':'RemoveFlagView','id':2},{'kind':'DespawnView','id':1}])
   if a.expect_mismatch:assert len(mismatches)==2,mismatches
   elif a.mutation:assert len(mismatches)==(2 if a.mutation in ['drop-detached','reverse-order','drop-recovered','drop-pending','wrong-old','drop-context'] else 1),mismatches
   else:assert not mismatches,mismatches
   r['cases'].append({'schema':lane,'backend':'JS' if program.suffix=='.js' else 'Native','status':'DETECTED_EXECUTABLE_DIVERGENCE' if a.expect_mismatch else 'DETECTED_COMPILING_COUNTEREXAMPLE' if a.mutation else 'PASS','records':8,'sourceSHA256':sha(src),'programSHA256':sha(program),'mismatches':mismatches})
 for name,h in originalPins.items():assert sha(boundOverlay/name)==h,'Post-run original candidate source drift'
 for name,h in baselinePins.items():assert sha(baseline/name)==h,'Post-run baseline source drift'
 for name,h in boundManifests.items():assert sha(boundOverlay/name)==h,'Post-run candidate manifest drift'
 assert sha(pathlib.Path(__file__))==r['recipeSHA256'],'Post-run recipe drift'
 r['status']='COMPILING_CONCRETE_'+a.mutation.upper().replace('-','_')+'_COUNTEREXAMPLE_BOTH' if a.mutation in ['wrong-old','drop-context'] else 'ACTUAL_ALIASED_ARRAY_HANDOFF_DIVERGENCE_BOTH' if a.expect_mismatch else ('ACTUAL_HANDOFF_'+a.mutation.upper().replace('-','_')+'_COMPILING_COUNTEREXAMPLE_BOTH' if a.mutation in ['drop-detached','reverse-order','drop-recovered'] else 'COMPILING_DIRECT_PENDING_FLUSH_OMISSION_DETECTED_BOTH' if a.mutation=='drop-pending' else 'COMPILING_DIRECT_PAIR_UNWIND_OMISSION_DETECTED_BOTH') if a.mutation else 'ACTUAL_HANDOFF_ENUMERATION_PRE_POST_ROLLBACK_BOTH_PASS'
except Exception as e:r.update(status='FAIL',error=repr(e));raise
finally:save()

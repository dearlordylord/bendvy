#!/usr/bin/env python3
"""Direct flat finish/publication, literal foreign/repeated/dead/high stamp controls."""
import argparse,pathlib,json,hashlib,os,importlib.util,re,sys,shutil,gzip
sys.path.insert(0,"/workspace/formal-proofs/bendvy/experiments/s-prep/fivehour-connected-gates")
p=argparse.ArgumentParser();p.add_argument('--overlay',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--mutation',choices=['drop-pair-undo','drop-pending']);p.add_argument('--pattern',choices=['pair','main-only','ledger-only','ledger-main','main-ledger-main'],default='pair');a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{8});here=pathlib.Path(__file__).resolve().parent
# Reuse only bounded process/build helpers; no expected oracle is imported.
spec=importlib.util.spec_from_file_location('bounded','/workspace/formal-proofs/bendvy/experiments/t05/run.py');B=importlib.util.module_from_spec(spec);spec.loader.exec_module(B)
import subprocess,signal
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'status':'INCOMPLETE','CPU':8,'sourcePins':json.loads((a.overlay/'overlay.json').read_text())['sources'],'commands':[],'cases':[]}
r['recipeSHA256']=sha(pathlib.Path(__file__));r['pattern']=a.pattern
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def command(argv,expected=0,timeout=5):
 argv=list(map(str,argv));env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root'
 if '--check-only' in argv:argv[0]='bend';timeout=15
 if argv[0]=='clang':argv[0]='/tmp/bendvy-clang19-diagnostic/clang19'
 c=subprocess.Popen(argv,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True,env=env);timed=False
 try:out=c.communicate(timeout=timeout)[0]
 except subprocess.TimeoutExpired:timed=True;os.killpg(c.pid,signal.SIGKILL);out=c.communicate()[0]
 rec={'argv':argv,'limitSeconds':timeout,'exit':c.returncode,'timeout':timed,'output':out};r['commands'].append(rec);save();assert c.returncode==expected and not timed,rec;return out
B.command=command
try:
 originalPins=r['sourcePins']
 for rel,h in originalPins.items():assert sha(a.overlay/rel)==h
 if a.mutation:
  copy=a.output/'mutant';shutil.copytree(a.overlay,copy);tp=copy/'experiments/s-integrate'/('held-adapter.bend' if a.mutation=='drop-pending' else 'transaction.bend');body=tp.read_text()
  before='case PrototypeFlatPair{space,id,main_old,ledger_old,tail}: prototype_flat_unwind(~Schema,~W,~restore_main,~restore_ledger,tail,restore_main(restore_ledger(world,ledger_old),S.Handle{space,id},main_old))'
  after='case PrototypeFlatPair{_,_,_,_,tail}: prototype_flat_unwind(~Schema,~W,~restore_main,~restore_ledger,tail,world)'
  if a.mutation=='drop-pending':
   before='case PrototypePendingUndo{True{},space,id,old,tail}: X.PrototypeFlatMain{space,id,old,tail}'
   after='case PrototypePendingUndo{True{},_,_,_,tail}: tail'
  assert body.count(before)==1;tp.write_text(body.replace(before,after));a.overlay=copy
  r['mutation']={'name':a.mutation,'site':'actual prototype_pending_flush' if a.mutation=='drop-pending' else 'actual prototype_flat_unwind Pair branch','sourceSHA256':sha(tp)}
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
    case _:
      do IO<Unit>:
        original : {tx} <- {lane}_pre(transformed({lane}_owner(0)))
        original_finish(fail,original)
        candidate : {tx} <- {lane}_pre(transport_actual({lane}_owner(0)))
        {lane}_finish(fail,candidate)
def main() -> IO(Unit):
  do IO<Unit>:
    pair(False{{}},0)
    pair(True{{}},0)
'''
  if a.pattern!='pair':
   original='(setledger(setledger(set(owner,T.'+main+'Token{},30),T.'+cap+'LedgerToken{},200),T.'+cap+'LedgerToken{},300),55)'
   variants={'main-only':'set(owner,T.'+main+'Token{},30)','ledger-only':'setledger(owner,T.'+cap+'LedgerToken{},300)','ledger-main':'set(setledger(owner,T.'+cap+'LedgerToken{},300),T.'+main+'Token{},30)','main-ledger-main':'set(setledger(set(owner,T.'+main+'Token{},20),T.'+cap+'LedgerToken{},300),T.'+main+'Token{},30)'}
   assert text.count(original)==1;text=text.replace(original,'('+variants[a.pattern]+',55)')
  if lane=='health':
   text=text.replace('HA.prototype_flatfold_health(~fixture_body,','HA.prototype_journalledger_health(~fixture_body,')
   oldroute='HA.prototype_flatfold_health_finish(HA.prototype_flatfold_health_fallback(transformed(owner),0))'
   newroute='HA.prototype_journalledger_health_finish(HA.prototype_journalledger_health_unpack(HA.prototype_flatfold_health_converted(transformed(owner)),0))'
   assert text.count(oldroute)==1;text=text.replace(oldroute,newroute)
  sl=importlib.util.spec_from_file_location('slice_fixture','/workspace/formal-proofs/bendvy/experiments/s-prep/fivehour-connected-gates/materialize-controls.py');sm=importlib.util.module_from_spec(sl);sl.loader.exec_module(sm);text,_,_=sm.reachable_fixture(text,'main');text=re.sub(r'^import .* as M\n','',text,flags=re.M)
  folder=a.output/lane;folder.mkdir();src=folder/'fallback.bend';src.write_text(text)
  for program in B.build(src,folder):
   out=B.execute(program);(folder/(program.name+'.jsonl')).write_text(out+'\n');records=[json.loads(x) for x in out.splitlines()];assert len(records)==6
   mismatches=[]
   for i in range(2):
    oldpre,oldpost,newpost=records[3*i:3*i+3];newpre=oldpre
    if oldpre!=newpre or oldpost!=newpost:mismatches.append({'case':i,'originalPre':oldpre,'candidatePre':newpre,'originalPost':oldpost,'candidatePost':newpost})
    kind=0;fail=i%2
    assert oldpre['value']==(55 if kind==0 else 24)
    assert oldpre['selected']==({'namespace':7,'id':1} if kind==0 else {'namespace':7,'id':2})
    assert oldpre['pings']==([12,11] if kind==0 else [66,55])
    assert oldpre['commands']==([{'kind':'RemoveFlagView','id':1},{'kind':'DespawnView','id':2}] if kind==0 else [{'kind':'DespawnView','id':1},{'kind':'RemoveFlagView','id':2}])
    assert oldpre['marks']==(([{'namespace':7,'id':2}] if a.pattern=='ledger-only' else [{'namespace':7,'id':1},{'namespace':7,'id':1},{'namespace':7,'id':2}] if a.pattern=='main-ledger-main' else [{'namespace':7,'id':1},{'namespace':7,'id':2}]) if kind==0 else [{'namespace':8,'id':1},{'namespace':7,'id':1},{'namespace':7,'id':2},{'namespace':7,'id':1}])
    assert oldpre['undo']==({'pair':'L:200;L:100;M7/1:10;L:77;','main-only':'M7/1:10;L:77;','ledger-only':'L:100;L:77;','ledger-main':'M7/1:10;L:100;L:77;','main-ledger-main':'M7/1:20;L:100;M7/1:10;L:77;'}[a.pattern] if kind==0 else 'M7/1:10;L:100;L:77;'),oldpre
    coords='coordinates' if lane=='motion' else 'levels';assert oldpre['world']['rows'][0]['main'][coords]['a']==((10 if a.pattern=='ledger-only' else 30) if kind==0 else 40)
    assert oldpre['world']['ledger']['totals']['a']==((100 if a.pattern=='main-only' else 300) if kind==0 else 400)
    assert oldpost['world']['rows'][0]['main'][coords]['a']==(10 if fail else (10 if a.pattern=='ledger-only' else 30) if kind==0 else 40)
    assert oldpost['world']['ledger']['totals']['a']==(77 if fail else (100 if a.pattern=='main-only' else 300) if kind==0 else 400)
    assert oldpost['world']['rows'][0]['changed']==(4 if fail or a.pattern=='ledger-only' else 9)
    assert oldpost['pings']==([] if fail else [11,12] if kind==0 else [55,66])
    assert oldpost['world']['pending']==([] if fail else [{'kind':'DespawnView','id':2},{'kind':'RemoveFlagView','id':1}] if kind==0 else [{'kind':'RemoveFlagView','id':2},{'kind':'DespawnView','id':1}])
   if a.mutation:assert len(mismatches)==1,mismatches
   else:assert not mismatches,mismatches
   r['cases'].append({'schema':lane,'backend':'JS' if program.suffix=='.js' else 'Native','status':'DETECTED_COMPILING_COUNTEREXAMPLE' if a.mutation else 'PASS','records':6,'sourceSHA256':sha(src),'programSHA256':sha(program),'mismatches':mismatches})
 r['status']=('COMPILING_DIRECT_PENDING_FLUSH_OMISSION_DETECTED_BOTH' if a.mutation=='drop-pending' else 'COMPILING_DIRECT_PAIR_UNWIND_OMISSION_DETECTED_BOTH') if a.mutation else 'DIRECT_FLAT_PAIR_FINISH_ROLLBACK_PUBLICATION_BOTH_PASS'
except Exception as e:r.update(status='FAIL',error=repr(e));raise
finally:save()

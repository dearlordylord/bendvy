#!/usr/bin/env python3
"""Direct flat finish/publication, literal foreign/repeated/dead/high stamp controls."""
import argparse,pathlib,json,hashlib,os,importlib.util,re,sys
sys.path.insert(0,"/workspace/formal-proofs/bendvy/experiments/s-prep/fivehour-connected-gates")
p=argparse.ArgumentParser();p.add_argument('--overlay',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{8});here=pathlib.Path(__file__).resolve().parent
# Reuse only bounded process/build helpers; no expected oracle is imported.
spec=importlib.util.spec_from_file_location('bounded','/workspace/formal-proofs/bendvy/experiments/t05/run.py');B=importlib.util.module_from_spec(spec);spec.loader.exec_module(B)
import subprocess,signal
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'status':'INCOMPLETE','CPU':8,'sourcePins':json.loads((a.overlay/'overlay.json').read_text())['sources'],'commands':[],'cases':[]}
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
 for lane,cap,main,aux,flag,mode in [('motion','Motion','Position','Velocity','Selected','MotionMode'),('health','Health','Vitals','Armor','Tracked','HealthMode')]:
  archived=pathlib.Path('/tmp/bendvy-flat-journal-tx-v4-adapted/actual/cached/core')/('cache-tx-'+lane+'-controls.bend');text=archived.read_text();r['cases'].append({'archivedFixture':str(archived),'SHA256':sha(archived)});text=text[:text.index('def main()')]
  text=re.sub(r'^import \./(\S+) as ',lambda m:'import '+str(a.overlay/'experiments/s-integrate'/m[1])+' as ',text,flags=re.M)
  # gate-callbacks is a control fixture, not a candidate module.
  text=text.replace('import '+str(a.overlay/'experiments/s-integrate/gate-callbacks.bend')+' as M','import '+str(archived.parent/'gate-callbacks.bend')+' as M')
  w=f'S.World<T.{cap}Schema,CC.Cache<T.{main},T.{main}View>,T.{aux},T.{flag},CC.Cache<T.{cap}Ledger,T.LedgerView>,T.{mode}>'
  c=f'S.Command<CC.Cache<T.{main},T.{main}View>,T.{aux},T.{flag}>'
  legacy='[S.Handle{8,1}]';flat='X.PrototypeFlatMark{8,1,X.PrototypeFlatMarksEnd{}}'
  mixed=[(8,1),(7,1),(7,1),(7,2),(7,0),(7,3)]
  mixedlegacy='['+','.join('S.Handle{%d,%d}'%x for x in mixed)+']';mixedflat='X.PrototypeFlatMarksEnd{}'
  for ns,id in reversed(mixed):mixedflat='X.PrototypeFlatMark{%d,%d,%s}'%(ns,id,mixedflat)
  text+=f'''\ndef incoming_marks(kind:U32) -> List<&2,S.Handle<T.{cap}Schema>>:
  match kind:
    case 0: {legacy}
    case _: {mixedlegacy}
def incoming_flatmarks(kind:U32) -> X.PrototypeFlatMark<T.{cap}Schema>:
  match kind:
    case 0: {flat}
    case _: {mixedflat}
def direct(+kind:U32,private:Bool,owner:X.Tx<{w},S.Handle<T.{cap}Schema>,{c}>) -> IO(Unit):
  match private owner:
    case False{{}} X.Tx{{world,selected,_,commands,pings,_}}: {lane}_post(X.storage_commit(T.{cap}Schema,CC.Cache<T.{main},T.{main}View>,T.{aux},T.{flag},CC.Cache<T.{cap}Ledger,T.LedgerView>,T.{mode},X.tx_finish_success({w},S.Handle<T.{cap}Schema>,{c},X.Tx{{world,selected,[],commands,pings,incoming_marks(kind)}}),9))
    case True{{}} X.Tx{{world,selected,_,commands,pings,_}}: {lane}_post(X.prototype_flat_storage_commit(~T.{cap}Schema,~CC.Cache<T.{main},T.{main}View>,~T.{aux},~T.{flag},~CC.Cache<T.{cap}Ledger,T.LedgerView>,~T.{mode},X.prototype_flat_finish_success(~T.{cap}Schema,~{w},~{c},X.PrototypeFlatTx{{world,selected,X.PrototypeFlatEnd{{}},commands,pings,incoming_flatmarks(kind)}}),9))
def main() -> IO(Unit):
  do IO<Unit>:
'''
  cases=[(0,8,[4,6]),(1,0,[9]),(1,7,[9]),(1,8,[9,9])]
  for kind,scenario,_ in cases:
   for private in ('False','True'):text+=f'    direct({kind},{private}{{}},{lane}_owner({scenario}))\n'
  sl=importlib.util.spec_from_file_location('slice_fixture','/workspace/formal-proofs/bendvy/experiments/s-prep/fivehour-connected-gates/materialize-controls.py');sm=importlib.util.module_from_spec(sl);sl.loader.exec_module(sm);text,_,_=sm.reachable_fixture(text,'main');text=re.sub(r'^import .* as M\n','',text,flags=re.M)
  folder=a.output/lane;folder.mkdir();src=folder/'direct.bend';src.write_text(text)
  for program in B.build(src,folder):
   out=B.execute(program);(folder/(program.name+'.jsonl')).write_text(out+'\n');records=[json.loads(x) for x in out.splitlines()];assert len(records)==8
   for i,(kind,scenario,changed) in enumerate(cases):
    old,new=records[2*i:2*i+2];assert old==new,(old,new);assert [x['changed'] for x in new['world']['rows']]==changed,(scenario,new);assert new['pings']==[11,12];assert new['world']['pending']==[{'kind':'DespawnView','id':2},{'kind':'RemoveFlagView','id':1}],new
   r['cases'].append({'schema':lane,'backend':'JS' if program.suffix=='.js' else 'Native','status':'PASS','records':8,'sourceSHA256':sha(src),'programSHA256':sha(program),'literalChanged':[[4,6],[9],[9],[9,9]],'literalPings':[11,12],'literalPendingReverseChronological':['Despawn2','RemoveFlag1']})
 r['status']='DIRECT_FLAT_FINISH_PUBLICATION_FOREIGN_REPEATED_DEAD_HIGH_MARKS_BOTH_PASS'
except Exception as e:r.update(status='FAIL',error=repr(e));raise
finally:save()

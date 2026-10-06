#!/usr/bin/env python3
"""Literal observation of a Bundle produced by actual Q; no malformed Bundle input."""
import pathlib,argparse,json,hashlib,os,importlib.util,subprocess,signal,shutil
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir();os.sched_setaffinity(0,{8})
root=pathlib.Path('/tmp/bendvy-slot-host-motion-id-buffer-direct-v1');pins=json.loads((root/'overlay.json').read_text())['sources'];sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();closure=hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest();assert closure=='84b808cee2c1a657569888229241dd95ae59f314025512c20159d951f4a1db2c'
for f,h in pins.items():assert sha(root/f)==h
r={'recipeSHA256':sha(pathlib.Path(__file__)),'status':'INCOMPLETE','sourceClosureSHA256':closure,'sourcePins':pins,'commands':[],'cases':[]};shutil.copy2(__file__,a.output/'executed-recipe.py')
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
def command(argv,expected=0,timeout=5):
 argv=list(map(str,argv));env=os.environ.copy();env['BENDVY_CLANG19_ROOT']='/tmp/bendvy-clang19-diagnostic/root'
 if '--check-only' in argv:argv[0]='bend';timeout=15
 if argv[0]=='clang':argv[0]='/tmp/bendvy-clang19-diagnostic/clang19'
 inp={x:sha(pathlib.Path(x)) for x in argv if pathlib.Path(x).is_file()};proc=subprocess.Popen(argv,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True,env=env);timed=False
 try:out=proc.communicate(timeout=timeout)[0]
 except subprocess.TimeoutExpired:timed=True;os.killpg(proc.pid,signal.SIGKILL);out=proc.communicate()[0]
 r['commands'].append({'argv':argv,'inputSHA256':inp,'limitSeconds':timeout,'exit':proc.returncode,'timeout':timed,'output':out,'outputSHA256':hashlib.sha256(out.encode()).hexdigest()});save();assert proc.returncode==expected and not timed;return out
spec=importlib.util.spec_from_file_location('B','/workspace/formal-proofs/bendvy/experiments/t05/run.py');B=importlib.util.module_from_spec(spec);spec.loader.exec_module(B);B.command=command
fixture=pathlib.Path('/tmp/bendvy-split-id-two-v12/motion/fallback.bend');r['inputFixtureSHA256']=sha(fixture);text=fixture.read_text();text=text[:text.index('type MotionInspect')];text=text.replace('/tmp/bendvy-slot-host-motion-id-buffer-v12',str(root))
w='S.World<T.MotionSchema,P.PrototypeMotionMainSlot,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>'
text+='''
def row_rest(owner:P.PrototypeMotionMainSlot,a:U32,result:Q.PrototypeSplitMotionHandoffRows & List<&2,U32>) -> Q.PrototypeSplitMotionHandoffRows & List<&2,U32>:
  match result:
    case (rest,values): (Q.SplitMotionHandoffCon{owner,rest},a <> values)
def row_tail_done(rest:Q.PrototypeSplitMotionHandoffRows,result:P.PrototypeMotionMainSlot & T.PositionView) -> Q.PrototypeSplitMotionHandoffRows & List<&2,U32>:
  match result:
    case (owner,T.PositionView{T.Four{a,_,_,_},_}): (Q.SplitMotionHandoffCon{owner,rest},[a])
def row_tail(rows:Q.PrototypeSplitMotionHandoffRows) -> Q.PrototypeSplitMotionHandoffRows & List<&2,U32>:
  match rows:
    case Q.SplitMotionHandoffNil{}: (Q.SplitMotionHandoffNil{},[])
    case Q.SplitMotionHandoffCon{owner,rest}: row_tail_done(rest,P.prototype_slot_position_get(owner))
def row_done(rest:Q.PrototypeSplitMotionHandoffRows,result:P.PrototypeMotionMainSlot & T.PositionView) -> Q.PrototypeSplitMotionHandoffRows & List<&2,U32>:
  match result:
    case (owner,T.PositionView{T.Four{a,_,_,_},_}): row_rest(owner,a,row_tail(rest))
def row_probe(rows:Q.PrototypeSplitMotionHandoffRows) -> Q.PrototypeSplitMotionHandoffRows & List<&2,U32>:
  match rows:
    case Q.SplitMotionHandoffNil{}: (Q.SplitMotionHandoffNil{},[])
    case Q.SplitMotionHandoffCon{owner,rest}: row_done(rest,P.prototype_slot_position_get(owner))
'''
text+='''
def stored1(rows:Q.PrototypeSplitMotionHandoffRows,+count:U32,values:List<&2,U32>,first:U32,result:Array<U32> & U32) -> IO(Unit):
  match result:
    case (buffer,second): IO.print("{\\"count\\":" ++ U32.show(count) ++ ",\\"stored\\":[" ++ U32.show(first) ++ "," ++ U32.show(second) ++ "],\\"owners\\":" ++ R.render_list(U32,U32.show,values) ++ "}")
def stored0(rows:Q.PrototypeSplitMotionHandoffRows,count:U32,values:List<&2,U32>,result:Array<U32> & U32) -> IO(Unit):
  match result:
    case (buffer,first): stored1(rows,count,values,first,Array.get(U32,buffer,1))
def observed(buffer:Array<U32>,count:U32,result:Q.PrototypeSplitMotionHandoffRows & List<&2,U32>) -> IO(Unit):
  match result:
    case (rows,values): stored0(rows,count,values,Array.get(U32,buffer,0))
def batch_probe(batch:Q.PrototypeSplitMotionHandoffBatch<T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>) -> IO(Unit):
  match batch:
    case Q.PrototypeSplitMotionHandoffBatch{_,Q.PrototypeSplitMotionHandoffBundle{rows,buffer,count}}: observed(buffer,count,row_probe(rows))
'''
text+=f'''\ndef subject_owner(selection:Q.Selection,owner:X.Tx<{w},S.Handle<T.MotionSchema>,S.Command<P.PrototypeMotionMainSlot,T.Velocity,T.Selected>>) -> IO(Unit):\n  match owner:\n    case X.Tx{{world,_,_,_,_,_}}: batch_probe(Q.prototype_split_motion_handoff_each(T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,Array.new(U32,1n,0),selection,world))\ndef subject(scenario:U32,selection:Q.Selection) -> IO(Unit):\n  subject_owner(selection,motion_owner(scenario))\ndef main() -> IO(Unit):\n  do IO<Unit>:\n    subject(0,Q.Absent{{}})\n    subject(0,Q.Required{{}})\n    subject(8,Q.Required{{}})\n    return Unit{{}}\n'''
try:
 src=a.output/'bundle.bend';src.write_text(text)
 for exe in B.build(src,a.output):
  out=B.execute(exe);records=[json.loads(s) for s in out.splitlines()];assert records==[{'count':0,'stored':[0,0],'owners':[]},{'count':1,'stored':[1,0],'owners':[10]},{'count':2,'stored':[2,1],'owners':[10,900]}],records;r['cases'].append({'backend':'JS' if exe.suffix=='.js' else 'Native','records':records,'sourceSHA256':sha(src),'executableSHA256':sha(exe)})
 for f,h in pins.items():assert sha(root/f)==h
 assert sha(pathlib.Path(__file__))==r['recipeSHA256'];assert sha(fixture)==r['inputFixtureSHA256'];r['status']='ACTUAL_PRODUCED_BUNDLE_LITERAL_BOTH_PASS'
except Exception as e:r.update(status='FAIL',error=repr(e));raise
finally:save()

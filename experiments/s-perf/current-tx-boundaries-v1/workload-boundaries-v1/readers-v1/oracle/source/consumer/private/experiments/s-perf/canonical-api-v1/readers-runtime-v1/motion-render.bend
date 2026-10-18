import Base
import motion-report-doc.bend as Doc
import motion.bend as F
import types.bend as T
import events.bend as E
import motion-domain.bend as D
import motion-reader.bend as Reader
import motion-reader-observe.bend as RO
import motion-observe.bend as O
import motion-family.bend as Family
import motion-systems.bend as S
import motion-program.bend as P
import motion-registration.bend as Registration
import ../../../public-audit61/app-a-current-carrier-v1/owner-observer.bend as Dump
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/local.bend as Local
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/schedule.bend as Sch
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/world.bend as W
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/event-notice-runtime.bend as Mixed
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/ordinary-reader-system.bend as Ordinary

def doc_tx_fact(value:D.TxFacts) -> Doc.Doc:
  match value:
    case D.TxFacts{operation,undo,commands,events,trace,world}:Doc.concat([Doc.text("operation=" ++ U32.show(operation) ++ ";undo=" ++ Nat.show(undo) ++ ";commands=" ++ Nat.show(commands) ++ ";events=" ++ List.show(&2,E.event_type(),O.event,events) ++ ";traceEnabled=" ++ Bool.show(trace) ++ ";world={"),world,Doc.text("}")])
def tx_fact(value:D.TxFacts) -> String:Doc.flatten(doc_tx_fact(value))
def maybe_handle(value:Maybe<&2,W.Handle<T.MotionSchema>>) -> String:
  match value:
    case None{}:"None"
    case Some{value}:"Some(" ++ O.handle(value) ++ ")"
def doc_measured_fact(value:D.MeasuredFacts) -> Doc.Doc:
  match value:
    case D.MeasuredFacts{fact,_,_}:doc_tx_fact(fact)
def doc_frame(value:D.Frame) -> Doc.Doc:
  match value:
    case D.Frame{count,iteration,transient,reservations,facts}:Doc.join(Doc.text("count=" ++ U32.show(count) ++ ";iteration=" ++ U32.show(iteration) ++ ";transient=" ++ maybe_handle(transient) ++ ";reservations=" ++ List.show(&2,W.Reservation<T.MotionSchema>,O.reservation,reservations) ++ ";activeTransactions="),Doc.show(~D.MeasuredFacts,~doc_measured_fact,facts))
def frame(value:D.Frame) -> String:Doc.flatten(doc_frame(value))
def doc_maybe_frame(value:Maybe<&2,D.Frame>) -> Doc.Doc:
  match value:
    case None{}:Doc.text("None")
    case Some{value}:Doc.concat([Doc.text("Some("),doc_frame(value),Doc.text(")")])
def maybe_frame(value:Maybe<&2,D.Frame>) -> String:Doc.flatten(doc_maybe_frame(value))
def doc_local_call(value:S.LocalCall) -> Doc.Doc:
  match value:
    case S.LocalCall{id,operation,status,returned}:Doc.join(Doc.text("id=" ++ U32.show(id) ++ ";operation=" ++ U32.show(operation) ++ ";status=" ++ U32.show(status) ++ ";output="),doc_maybe_frame(returned))
def local_call(value:S.LocalCall) -> String:Doc.flatten(doc_local_call(value))
def doc_maybe_read(value:Maybe<&2,Reader.Read>) -> Doc.Doc:
  match value:
    case None{}:Doc.text("None")
    case Some{value}:Doc.concat([Doc.text("Some("),RO.doc_read(value),Doc.text(")")])
def maybe_read(value:Maybe<&2,Reader.Read>) -> String:Doc.flatten(doc_maybe_read(value))
def doc_read_call(value:S.ReadCall) -> Doc.Doc:
  match value:
    case S.ReadCall{+id,status,tick,output,before,after,_}:Doc.concat([Doc.text("Read{id=" ++ U32.show(id) ++ ";tick=" ++ Nat.show(tick) ++ ";before={"),before,Doc.text("};output="),doc_maybe_read(output),Doc.text("};ReadDone{id=" ++ U32.show(id) ++ ";status=" ++ U32.show(status) ++ ";after={"),after,Doc.text("}}")])
def read_call(value:S.ReadCall) -> String:Doc.flatten(doc_read_call(value))
def local_join(+ns:U32,+id:U32,+name:String,+access:List<&2,String>,observed:Array<U32> & String) -> S.Instance() & String:
  match observed:
    case (capture,text):(Local.Instance{ns,id,name,access,capture},"namespace=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";access=" ++ List.show(&2,String,x=>x,access) ++ ";capture=" ++ text)
def local(value:S.Instance()) -> S.Instance() & String:
  match value:
    case Local.Instance{ns,id,name,access,capture}:local_join(ns,id,name,access,Dump.u32_array(capture))
def ids(value:S.IDs) -> String:
  match value:
    case S.IDs{spawn,update,dispose,fast,slow}:"spawn=" ++ U32.show(spawn) ++ ";update=" ++ U32.show(update) ++ ";dispose=" ++ U32.show(dispose) ++ ";fast=" ++ U32.show(fast) ++ ";slow=" ++ U32.show(slow)
def owners_join(+tick:Nat,+args:D.Frame,+phase:U32,+id:S.IDs,+locals:List<&2,S.LocalCall>,+reads:List<&2,S.ReadCall>,spawn:S.Instance() & String,update:S.Instance() & String,dispose:S.Instance() & String,fast:Reader.Provider() & String,slow:Reader.Provider() & String,meta:Mixed.State<T.MotionSchema,E.Publication,Family.Family,Unit> & String) -> S.Owners & String:
  (spawn,ss)=spawn
  (update,su)=update
  (dispose,sd)=dispose
  (fast,sf)=fast
  (slow,sl)=slow
  (meta,sm)=meta
  (S.Owners{spawn,update,dispose,fast,slow,meta,tick,args,phase,id,locals,reads},"ids={" ++ ids(id) ++ "};tick=" ++ Nat.show(tick) ++ ";phase=" ++ U32.show(phase) ++ ";frame={" ++ frame(args) ++ "};spawn={" ++ ss ++ "};update={" ++ su ++ "};dispose={" ++ sd ++ "};fast={" ++ sf ++ "};slow={" ++ sl ++ "};runtimeMeta={" ++ sm ++ "};localCalls=" ++ List.show(&2,S.LocalCall,local_call,locals) ++ ";readerCalls=" ++ List.show(&2,S.ReadCall,read_call,reads))
def owners(value:S.Owners) -> S.Owners & String:
  match value:
    case S.Owners{spawn,update,dispose,fast,slow,meta,tick,args,phase,id,locals,reads}:owners_join(tick,args,phase,id,locals,reads,local(spawn),local(update),local(dispose),RO.provider(fast),RO.provider(slow),RO.meta(meta))
def status_text(value:P.Status) -> String:
  match value:
    case P.Complete{}:"Complete"
    case P.BodyFailed{}:"BodyFailed"
    case P.Refused{}:"Refused"
    case P.Invalid{}:"Invalid"
def step(value:Sch.Step) -> String:
  match value:
    case Sch.System{id,condition}:"System(" ++ U32.show(id) ++ "," ++ U32.show(condition) ++ ")"
    case Sch.Phase{name}:"Phase(" ++ name ++ ")"
    case Sch.Barrier{}:"Barrier"
def observation(value:Sch.Observation) -> String:
  match value:
    case Sch.Entered{name}:"Entered(" ++ name ++ ")"
    case Sch.Ran{id}:"Ran(" ++ U32.show(id) ++ ")"
    case Sch.Skipped{id}:"Skipped(" ++ U32.show(id) ++ ")"
    case Sch.Applied{}:"Applied"
def observations(value:Maybe<&2,List<&2,Sch.Observation>>) -> String:
  match value:
    case None{}:"None"
    case Some{values}:"Some(" ++ List.show(&2,Sch.Observation,observation,values) ++ ")"
def log(value:P.Log) -> String:
  match value:
    case P.Log{name,steps,result,values}:"Log{" ++ name ++ ";steps=" ++ List.show(&2,Sch.Step,step,steps) ++ ";status=" ++ status_text(result) ++ ";observations=" ++ observations(values) ++ "}"
def state_join(+namespace:U32,+logs:List<&2,P.Log>,+status:P.Status,world:F.World() & String,owner:S.Owners & String) -> P.View & String:
  (world,sw)=world
  (owner,so)=owner
  (P.View{world,owner,namespace,logs,status},"namespace=" ++ U32.show(namespace) ++ ";status=" ++ status_text(status) ++ ";world={" ++ sw ++ "};owners={" ++ so ++ "};schedules=" ++ List.show(&2,P.Log,log,logs))
def view(value:P.View) -> P.View & String:
  match value:
    case P.View{world,owner,namespace,logs,status}:state_join(namespace,logs,status,O.world(world),owners(owner))

def state(value:P.State) -> P.State & String:P.inspect(~String,~view,value)

import Base
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import schema-families.bend as D
import runtime-owners.bend as Owners
import fixture.bend as Fixture
import phase-driver.bend as P
import execution.bend as Capture
import check-execution.bend as C
import retry-driver.bend as R
import writer.bend as Writer
import check-schedules.bend as G
import world-observer.bend as Dump
import format.bend as Format
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
type Carry<S:Data> is Type:
  Carry{factory:W.Factory,phase:P.State<S>,writer:Writer.Holder<S>,retry:I.Instance<S>,retryBoundaries:List<&2,R.Boundary<S>>,checks:List<&2,Bool>,output:List<&2,String>,gates:G.Holder<S>}
def factory_view(value:W.Factory) -> W.Factory & String:
  match value:
    case W.Factory{+next}:(W.Factory{next},U32.show(next))
def instance_join(~S:Data,head:I.Instance<S> & String,rest:List<I.Instance<S>> & List<&2,String>) -> List<I.Instance<S>> & List<&2,String>:
  (instance,text)=head
  (instances,texts)=rest
  (instance <> instances,text <> texts)
def instance_list(~S:Data,values:List<I.Instance<S>>) -> List<I.Instance<S>> & List<&2,String>:
  match values:
    case []:([],[])
    case instance <> rest:instance_join(~S,Dump.instance(~S,instance),instance_list(~S,rest))
def query_boundary(value:P.Boundary) -> String:
  match value:
    case P.Boundary{before,after,instanceBefore,instanceAfter}:"clock=" ++ U32.show(before) ++ "->" ++ U32.show(after) ++ ";instance=" ++ P.instance_text(instanceBefore) ++ "->" ++ P.instance_text(instanceAfter)
def retry_boundary(~S:Data,value:R.Boundary<S>) -> String:
  match value:
    case R.Boundary{before,after,instanceBefore,instanceAfter,record,failed}:"clock=" ++ U32.show(before) ++ "->" ++ U32.show(after) ++ ";instance=" ++ P.instance_text(instanceBefore) ++ "->" ++ P.instance_text(instanceAfter) ++ ";failed=" ++ Bool.show(failed) ++ ";rows=" ++ Capture.render(~S,record)
def snapshot_final(~S:Data,label:String,+records:List<&2,Capture.Record<S>>,+boundaries:List<&2,P.Boundary>,+errors:String,+retryBoundaries:List<&2,R.Boundary<S>>,+checks:List<&2,Bool>,output:List<&2,String>,targets:List<&2,W.Handle<S>>,world:Writer.World(~S),writer:Writer.Holder<S>,factory:W.Factory,physical:String,writerText:String,factoryText:String,observedInstances:List<I.Instance<S>> & List<&2,String>,observedRetry:I.Instance<S> & String,observedGates:G.Holder<S> & String) -> Carry<S>:
  (instances,texts)=observedInstances
  (retry,retryText)=observedRetry
  (gates,gatesText)=observedGates
  (Carry{factory,P.State{world,targets,instances,records,boundaries,errors},writer,retry,retryBoundaries,checks,List.append(&2,String,output,[label ++ "|factory=" ++ factoryText ++ "|physical=" ++ physical ++ "|writer=" ++ writerText ++ "|instances=" ++ Format.list(~String,x=>x,texts) ++ "|retry=" ++ retryText ++ "|queries=" ++ Format.list(~Capture.Record<S>,~Capture.render(~S),records) ++ "|queryBoundaries=" ++ Format.list(~P.Boundary,~query_boundary,boundaries) ++ "|checks=" ++ Format.list(~Bool,~Bool.show,checks) ++ "|retryBoundaries=" ++ Format.list(~R.Boundary<S>,~retry_boundary(~S),retryBoundaries) ++ "|errors=" ++ errors ++ "|noops=" ++ gatesText]),gates} : Carry<S>)
def snapshot_join(~S:Data,label:String,records:List<&2,Capture.Record<S>>,boundaries:List<&2,P.Boundary>,errors:String,retryBoundaries:List<&2,R.Boundary<S>>,checks:List<&2,Bool>,output:List<&2,String>,targets:List<&2,W.Handle<S>>,instances:List<I.Instance<S>>,retry:I.Instance<S>,observedWorld:Writer.World(~S) & String,observedWriter:Writer.Holder<S> & String,observedFactory:W.Factory & String,gates:G.Holder<S>) -> Carry<S>:
  (world,physical)=observedWorld
  (writer,writerText)=observedWriter
  (factory,factoryText)=observedFactory
  snapshot_final(~S,label,records,boundaries,errors,retryBoundaries,checks,output,targets,world,writer,factory,physical,writerText,factoryText,instance_list(~S,instances),Dump.instance(~S,retry),G.observe(~S,gates))
def snapshot(~S:Data,label:String,value:Carry<S>) -> Carry<S>:
  match value:
    case Carry{factory,P.State{world,targets,instances,records,boundaries,errors},writer,retry,retryBoundaries,checks,output,gates}:snapshot_join(~S,label,records,boundaries,errors,retryBoundaries,checks,output,targets,instances,retry,Dump.world(~S,world),Writer.observe(~S,writer),factory_view(factory),gates)
def check_kinds() -> List<&2,C.CheckKind>:
  [C.CheckEmpty{},C.CheckOptionalFour{},C.CheckRequiredPair{},C.CheckFiveAlias{},C.CheckWithWithout{},C.CheckMultipleWith{},C.CheckMultipleWithout{},C.CheckRepeated{},C.CheckContradictory{}]
def checked_phase(~S:Data,factory:W.Factory,writer:Writer.Holder<S>,retry:I.Instance<S>,retryBoundaries:List<&2,R.Boundary<S>>,output:List<&2,String>,targets:List<&2,W.Handle<S>>,instances:List<I.Instance<S>>,records:List<&2,Capture.Record<S>>,boundaries:List<&2,P.Boundary>,errors:String,result:G.Batch<S>) -> Carry<S>:
  match result:
    case G.Batch{world,gates,checks}:
      Carry{factory,P.State{world,targets,instances,records,boundaries,errors},writer,retry,retryBoundaries,checks,output,gates}
def ran_phase(~S:Data,~guard:G.World(~S) -> U32 -> G.World(~S) & Bool,~dispatch:G.ScheduleOwners<S> -> G.World(~S) -> U32 -> G.ScheduleOwners<S> & Sys.Outcome<G.World(~S),Unit,Unit>,factory:W.Factory,writer:Writer.Holder<S>,retry:I.Instance<S>,retryBoundaries:List<&2,R.Boundary<S>>,output:List<&2,String>,phase:P.State<S>,gates:G.Holder<S>) -> Carry<S>:
  match phase:
    case P.State{world,+targets,instances,+records,boundaries,errors}:checked_phase(~S,factory,writer,retry,retryBoundaries,output,targets,instances,records,boundaries,errors,G.run(~S,~guard,~dispatch,targets,check_kinds(),Capture.render_list(~S,records),world,gates))
def round(~S:Data,~guard:G.World(~S) -> U32 -> G.World(~S) & Bool,~dispatch:G.ScheduleOwners<S> -> G.World(~S) -> U32 -> G.ScheduleOwners<S> & Sys.Outcome<G.World(~S),Unit,Unit>,label:String,value:Carry<S>) -> Carry<S>:
  match value:
    case Carry{factory,phase,writer,retry,retryBoundaries,_,output,gates}:ran_phase(~S,~guard,~dispatch,factory,writer,retry,retryBoundaries,output,P.run(~S,phase),gates)
def observation(value:Sch.Observation) -> String:
  match value:
    case Sch.Entered{name}:"Entered{" ++ name ++ "}"
    case Sch.Ran{id}:"Ran{" ++ U32.show(id) ++ "}"
    case Sch.Skipped{id}:"Skipped{" ++ U32.show(id) ++ "}"
    case Sch.Applied{}:"Applied{}"
def scheduled(~S:Data,label:String,factory:W.Factory,targets:List<&2,W.Handle<S>>,instances:List<I.Instance<S>>,records:List<&2,Capture.Record<S>>,boundaries:List<&2,P.Boundary>,errors:String,retry:I.Instance<S>,retryBoundaries:List<&2,R.Boundary<S>>,checks:List<&2,Bool>,output:List<&2,String>,result:Writer.Outcome<S>,gates:G.Holder<S>) -> Carry<S>:
  match result:
    case Writer.Outcome{world,writer,observations,status}:snapshot(~S,label,Carry{factory,P.State{world,targets,instances,records,boundaries,errors},writer,retry,retryBoundaries,checks,List.append(&2,String,output,["schedule=" ++ status ++ "|observations=" ++ Format.list(~Sch.Observation,~observation,observations)]),gates})
def schedule(~S:Data,label:String,value:Carry<S>) -> Carry<S>:
  match value:
    case Carry{factory,P.State{world,targets,instances,records,boundaries,errors},writer,retry,retryBoundaries,checks,output,gates}:scheduled(~S,label,factory,targets,instances,records,boundaries,errors,retry,retryBoundaries,checks,output,Writer.run(~S,world,writer),gates)
def retried(~S:Data,label:String,factory:W.Factory,writer:Writer.Holder<S>,instances:List<I.Instance<S>>,records:List<&2,Capture.Record<S>>,boundaries:List<&2,P.Boundary>,errors:String,checks:List<&2,Bool>,output:List<&2,String>,result:R.Retry<S>,gates:G.Holder<S>) -> Carry<S>:
  match result:
    case R.Retry{world,retry,targets,retryBoundaries}:Carry{factory,P.State{world,targets,instances,records,boundaries,errors},writer,retry,retryBoundaries,checks,output,gates}
def retry(~S:Data,label:String,fail:Bool,value:Carry<S>) -> Carry<S>:
  match value:
    case Carry{factory,P.State{world,targets,instances,records,boundaries,errors},writer,retry,retryBoundaries,checks,output,gates}:retried(~S,label,factory,writer,instances,records,boundaries,errors,checks,output,R.step(~S,fail,R.Retry{world,retry,targets,retryBoundaries}),gates)
def pending(~S:Data,world:Writer.World(~S)) -> Writer.World(~S):
  match world:
    case W.World{namespace,next,high,live,capacity,depth,store,resource,events,pending,registrations,nextSystem,clock}:W.World{namespace,next,high,live,capacity,depth,store,resource,events,pending,registrations,nextSystem,(clock + 100 : U32)}
def gates_started(~S:Data,factory:W.Factory,targets:List<&2,W.Handle<S>>,errors:String,writer:Writer.Holder<S>,result:G.Started<S>) -> Maybe<&1,Carry<S>>:
  match result:
    case G.Started{world,gates}:Some{snapshot(~S,"registered",Carry{factory,P.State{world,targets,P.fresh(~S,14n),[],[],errors},writer,I.Fresh{},[],[],[],gates})}
    case G.Rejected{_}:None{}
def started(~S:Data,factory:W.Factory,targets:List<&2,W.Handle<S>>,errors:String,result:Writer.Started<S>) -> Maybe<&1,Carry<S>>:
  match result:
    case Writer.Started{world,writer}:gates_started(~S,factory,targets,errors,writer,G.start(~S,world))
    case Writer.Rejected{_}:None{}
def fixture(~S:Data,factory:W.Factory,value:Fixture.Fixture<S>) -> Maybe<&1,Carry<S>>:
  match value:
    case Fixture.Fixture{world,targets,errors}:started(~S,factory,targets,errors,Writer.start(~S,W.enqueue(~S,~D.Store<S>,~Owners.Resource(~S),~U32,world,pending(~S))))
def built(~S:Data,value:Fixture.Built<S>) -> Maybe<&1,Carry<S>>:
  match value:
    case Fixture.Built{factory,value}:fixture(~S,factory,value)
    case Fixture.BuildRefused{_,_}:None{}
type Action is Data:
  Round{label:String}
  Retry{label:String,fail:Bool}
  Schedule{label:String}
def actions() -> List<&2,Action>:
  [Round{"bootstrap"},Round{"repeat"},Retry{"retry-failed",True{}},Retry{"retry-success",False{}},Retry{"retry-repeat",False{}},Schedule{"writer-first"},Round{"changed"},Round{"changed-repeat"},Schedule{"writer-second"},Round{"changed-again"}]
def action(~S:Data,~guard:G.World(~S) -> U32 -> G.World(~S) & Bool,~dispatch:G.ScheduleOwners<S> -> G.World(~S) -> U32 -> G.ScheduleOwners<S> & Sys.Outcome<G.World(~S),Unit,Unit>,step:Action,value:Carry<S>) -> Carry<S>:
  match step:
    case Round{label}:round(~S,~guard,~dispatch,label,value)
    case Retry{label,fail}:retry(~S,label,fail,value)
    case Schedule{label}:schedule(~S,label,value)
type Completed is Data:
  Plain{label:String}
  WriterDone{label:String,status:String,observations:List<&2,Sch.Observation>}
type Operation<S:Data> is Type:
  Operation{value:Carry<S>,completed:Completed}
def writer_operation(~S:Data,label:String,factory:W.Factory,targets:List<&2,W.Handle<S>>,instances:List<I.Instance<S>>,records:List<&2,Capture.Record<S>>,boundaries:List<&2,P.Boundary>,errors:String,retry:I.Instance<S>,retryBoundaries:List<&2,R.Boundary<S>>,checks:List<&2,Bool>,output:List<&2,String>,result:Writer.Outcome<S>,gates:G.Holder<S>) -> Operation<S>:
  match result:
    case Writer.Outcome{world,writer,observations,status}:Operation{Carry{factory,P.State{world,targets,instances,records,boundaries,errors},writer,retry,retryBoundaries,checks,output,gates},WriterDone{label,status,observations}}
def writer_step(~S:Data,label:String,value:Carry<S>) -> Operation<S>:
  match value:
    case Carry{factory,P.State{world,targets,instances,records,boundaries,errors},writer,retry,retryBoundaries,checks,output,gates}:writer_operation(~S,label,factory,targets,instances,records,boundaries,errors,retry,retryBoundaries,checks,output,Writer.run(~S,world,writer),gates)
def operation(~S:Data,~guard:G.World(~S) -> U32 -> G.World(~S) & Bool,~dispatch:G.ScheduleOwners<S> -> G.World(~S) -> U32 -> G.ScheduleOwners<S> & Sys.Outcome<G.World(~S),Unit,Unit>,step:Action,value:Carry<S>) -> Operation<S>:
  match step:
    case Round{+label}:Operation{round(~S,~guard,~dispatch,label,value),Plain{label}}
    case Retry{+label,fail}:Operation{retry(~S,label,fail,value),Plain{label}}
    case Schedule{label}:writer_step(~S,label,value)
def observed_writer(~S:Data,label:String,status:String,observations:List<&2,Sch.Observation>,value:Carry<S>) -> Carry<S>:
  match value:
    case Carry{factory,phase,writer,retry,retryBoundaries,checks,output,gates}:snapshot(~S,label,Carry{factory,phase,writer,retry,retryBoundaries,checks,List.append(&2,String,output,["schedule=" ++ status ++ "|observations=" ++ Format.list(~Sch.Observation,~observation,observations)]),gates})
def observed(~S:Data,result:Operation<S>) -> Carry<S>:
  match result:
    case Operation{value,Plain{label}}:snapshot(~S,label,value)
    case Operation{value,WriterDone{label,status,observations}}:observed_writer(~S,label,status,observations,value)
def sequence(~S:Data,~guard:G.World(~S) -> U32 -> G.World(~S) & Bool,~dispatch:G.ScheduleOwners<S> -> G.World(~S) -> U32 -> G.ScheduleOwners<S> & Sys.Outcome<G.World(~S),Unit,Unit>,steps:List<&2,Action>,value:Carry<S>) -> Carry<S>:
  match steps:
    case []:value
    case step <> rest:sequence(~S,~guard,~dispatch,rest,observed(~S,operation(~S,~guard,~dispatch,step,value)))
def complete(~S:Data,~guard:G.World(~S) -> U32 -> G.World(~S) & Bool,~dispatch:G.ScheduleOwners<S> -> G.World(~S) -> U32 -> G.ScheduleOwners<S> & Sys.Outcome<G.World(~S),Unit,Unit>,value:Maybe<&1,Carry<S>>) -> Maybe<&1,Carry<S>>:
  match value:
    case None{}:None{}
    case Some{value}:Some{sequence(~S,~guard,~dispatch,actions(),value)}
def detached(~S:Data,value:Maybe<&1,Carry<S>>) -> String:
  match value:
    case None{}:"REGISTER_REFUSED"
    case Some{Carry{_,_,_,_,_,_,output,gates}}:Format.list(~String,x=>x,output)
def main() -> String:
  "Workshop=" ++ detached(~D.Workshop,complete(~D.Workshop,~G.workshop_condition,~G.workshop_dispatch,built(~D.Workshop,Fixture.workshop()))) ++ "|Garden=" ++ detached(~D.Garden,complete(~D.Garden,~G.garden_condition,~G.garden_dispatch,built(~D.Garden,Fixture.garden())))

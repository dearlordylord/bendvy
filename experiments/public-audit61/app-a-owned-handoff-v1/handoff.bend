import Base
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/captured-schedule-composition.bend as Comp
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
import bundle.bend as B
import resources.bend as R
import recovery.bend as Recovery
import events.bend as Events
import systems.bend as Systems
import capture-observe.bend as Captures
import handoff-observe.bend as Observe
import owner-observer.bend as Dump
import inspect.bend as Inspect
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-recovery-system.bend as Recover
import /workspace/formal-proofs/bendvy/src/ecs/recoverable-component.bend as RC
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/lifecycle.bend as Life
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/owned-event-family-reader-query.bend as Read
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-owned-event-family-publisher.bend as Pub
import /workspace/formal-proofs/bendvy/src/ecs/captured-schedule.bend as Run
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-condition-composition.bend as Cond
import /workspace/formal-proofs/bendvy/src/ecs/captured-schedule-condition.bend as Guard
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Component
type Host is Type:
  Host{runtime:Events.Runtime(),handle:W.Handle<B.AuditWorkshop>,schedule:Systems.Schedule(),recovery:Recovery.Owned(),publisher:Events.PublisherRegistry(),reader:Events.ReaderOwner(),registry:Events.ReaderRegistry(),scratch:Array<U32>,records:Recovery.Recovery(),output:Maybe<&1,Array<U32>>,returned:List<Array<U32>>,loose:Maybe<&1,Array<U32>>,history:List<&2,String>,readings:List<&2,U32>,values:List<&2,U32>,lagged:Bool,status:String,text:String}
  Stopped{world:B.World(R.Resources()),text:String}
def identity(value:String) -> String:value
def array_cons(head:Array<U32> & String,tail:List<Array<U32>> & List<&2,String>) -> List<Array<U32>> & List<&2,String>:
  (head,text)=head
  (tail,texts)=tail
  (head <> tail,text <> texts)
def array_rows(values:List<Array<U32>>) -> List<Array<U32>> & List<&2,String>:
  match values:
    case []:([],[])
    case head <> tail:array_cons(Dump.u32_array(head),array_rows(tail))
def arrays_join(result:List<Array<U32>> & List<&2,String>) -> List<Array<U32>> & String:
  (values,texts)=result
  (values,List.show(&2,String,identity,texts))
def arrays(values:List<Array<U32>>) -> List<Array<U32>> & String:
  arrays_join(array_rows(values))
def target(handle:W.Handle<B.AuditWorkshop>) -> String:
  match handle:
    case W.Handle{ns,id}:U32.show(ns) ++ ":" ++ U32.show(id)
def observed(label:String,runtimeObserved:Events.Runtime() & String,+handle:W.Handle<B.AuditWorkshop>,scheduleObserved:Systems.Schedule() & String,recoveryObserved:Recovery.Owned() & String,publisherObserved:Events.PublisherRegistry() & String,readerObserved:Events.ReaderOwner() & String,registryObserved:Events.ReaderRegistry() & String,scratchObserved:Array<U32> & String,recordsObserved:Recovery.Recovery() & String,outputObserved:Maybe<&1,Array<U32>> & String,returnedObserved:List<Array<U32>> & String,looseObserved:Maybe<&1,Array<U32>> & String,+history:List<&2,String>,+readings:List<&2,U32>,+values:List<&2,U32>,+lagged:Bool,+status:String,+text:String) -> Host:
  (runtime,runtimeText)=runtimeObserved
  (schedule,scheduleText)=scheduleObserved
  (recovery,recoveryText)=recoveryObserved
  (publisher,publisherText)=publisherObserved
  (reader,readerText)=readerObserved
  (registry,registryText)=registryObserved
  (scratch,scratchText)=scratchObserved
  (records,recordsText)=recordsObserved
  (output,outputText)=outputObserved
  (returned,returnedText)=returnedObserved
  (loose,looseText)=looseObserved
  Host{runtime,handle,schedule,recovery,publisher,reader,registry,scratch,records,output,returned,loose,history,readings,values,lagged,status,text ++ label ++ "|target=" ++ target(handle) ++ "|runtime=" ++ runtimeText ++ "|schedule=" ++ scheduleText ++ "|recovery=" ++ recoveryText ++ "|publisher=" ++ publisherText ++ "|reader=" ++ readerText ++ "|registry=" ++ registryText ++ "|scratch=" ++ scratchText ++ "|records=" ++ recordsText ++ "|output=" ++ outputText ++ "|returned=" ++ returnedText ++ "|loose=" ++ looseText ++ "|history=" ++ List.show(&2,String,identity,history) ++ "|readings=" ++ List.show(&2,U32,U32.show,readings) ++ "|values=" ++ List.show(&2,U32,U32.show,values) ++ "|lagged=" ++ Bool.show(lagged) ++ "|status=" ++ status ++ "\n"}
def snapshot(label:String,state:Host) -> Host:
  match state:
    case Host{runtime,handle,schedule,recovery,publisher,reader,registry,scratch,records,output,returned,loose,history,readings,values,lagged,status,text}:observed(label,Observe.runtime(runtime),handle,Captures.observe(schedule),Observe.recovery(recovery),Observe.publisher(publisher),Observe.reader(reader),Observe.registry(registry),Dump.u32_array(scratch),Observe.records(records),Dump.optional(~Array<U32>,~Dump.u32_array,output),arrays(returned),Dump.optional(~Array<U32>,~Dump.u32_array,loose),history,readings,values,lagged,status,text)
    case Stopped{world,text}:Stopped{world,text}
type RecoveryReply is Type:
  Recovered{owner:Recovery.Owned(),outcome:T.Outcome<Unit>,output:Maybe<&1,Array<U32>>,records:Recovery.Recovery()}
  Refused{owner:Recovery.Owned(),args:Recovery.Args}
  TransportFailed{}
def recovery_reply(result:Recovery.Run()) -> B.World(R.Resources()) & RecoveryReply:
  match result:
    case Recover.Completed{world,owner,outcome,output,records}:(world,Recovered{owner,outcome,output,records})
    case Recover.RegistrationRejected{world,owner,args}:(world,Refused{owner,args})
    case Recover.TransportFailed{world}:(world,TransportFailed{})
def outcome_text(value:T.Outcome<Unit>) -> String:
  match value:
    case T.Success{}:"Success"
    case T.Failure{Unit{}}:"Failure"
def stopped_observed(label:String,text:String,result:Events.Runtime() & String) -> Host:
  match result:
    case (Route.Runtime{world,family,tick},view):Stopped{world,text ++ label ++ "|" ++ view ++ "\n"}
def stopped_runtime(label:String,text:String,runtime:Events.Runtime()) -> Host:
  stopped_observed(label,text,Observe.runtime(runtime))
def recovered(label:String,handle:W.Handle<B.AuditWorkshop>,schedule:Systems.Schedule(),publisher:Events.PublisherRegistry(),reader:Events.ReaderOwner(),registry:Events.ReaderRegistry(),scratch:Array<U32>,returned:List<Array<U32>>,history:List<&2,String>,readings:List<&2,U32>,values:List<&2,U32>,lagged:Bool,text:String,result:Events.Runtime() & RecoveryReply) -> Host:
  match result:
    case (runtime,Recovered{recovery,outcome,output,records}):snapshot(label,Host{runtime,handle,schedule,recovery,publisher,reader,registry,scratch,records,output,returned,None{},history,readings,values,lagged,outcome_text(outcome),text})
    case (runtime,Refused{recovery,Recovery.Args{target,incoming,fail}}):snapshot(label ++ ":Refused",Host{runtime,handle,schedule,recovery,publisher,reader,registry,scratch,[],None{},returned,Some{incoming},history,readings,values,lagged,"Refused",text})
    case (runtime,TransportFailed{}):stopped_runtime(label ++ ":TransportFailed",text,runtime)
def recover(label:String,fail:Bool,state:Host) -> Host:
  match state:
    case Host{runtime,+handle,schedule,recovery,publisher,reader,registry,scratch,records,output,returned,Some{incoming},history,readings,values,lagged,status,text}:recovered(label,handle,schedule,publisher,reader,registry,scratch,returned,history,readings,values,lagged,text,Events.with_world(~RecoveryReply,w => recovery_reply(Recovery.run(recovery,w,Recovery.Args{handle,incoming,fail})),runtime))
    case Host{runtime,handle,schedule,recovery,publisher,reader,registry,scratch,records,output,returned,None{},history,readings,values,lagged,status,text}:snapshot(label ++ ":missing-incoming",Host{runtime,handle,schedule,recovery,publisher,reader,registry,scratch,records,output,returned,None{},history,readings,values,lagged,status,text})
    case Stopped{world,text}:Stopped{world,text}
def withdraw(label:String,state:Host) -> Host:
  match state:
    case Host{runtime,handle,schedule,recovery,publisher,reader,registry,scratch,RC.Record{+recordHandle,+stamp,Some{incoming}} <> tail,output,returned,None{},history,readings,values,lagged,status,text}:snapshot(label,Host{runtime,handle,schedule,recovery,publisher,reader,registry,scratch,tail,output,returned,Some{incoming},List.append(&2,String,history,[target(recordHandle) ++ ":" ++ Dump.stamp(stamp)]),readings,values,lagged,status,text})
    case state:snapshot(label ++ ":no-owned-record",state)
type PublishReply is Type:
  Published{publisher:Events.PublisherRegistry(),outcome:T.Outcome<Unit>,returned:List<Array<U32>>}
  PublishRefused{publisher:Events.PublisherRegistry(),incoming:Array<U32>}
  PublishTransportFailed{publisher:Events.PublisherRegistry()}
def publish_reply(result:Events.PublishResult()) -> B.World(R.Resources()) & PublishReply:
  match result:
    case Sys.Completed{publisher,Sys.Succeeded{world,Pub.Reply{outcome,Unit{},returned}}}:(world,Published{publisher,outcome,returned})
    case Sys.RegistrationRejected{publisher,world,incoming}:(world,PublishRefused{publisher,incoming})
    case Sys.Completed{publisher,Sys.Failed{world,Unit{}}}:(world,PublishTransportFailed{publisher})
def published(label:String,handle:W.Handle<B.AuditWorkshop>,schedule:Systems.Schedule(),recovery:Recovery.Owned(),reader:Events.ReaderOwner(),registry:Events.ReaderRegistry(),scratch:Array<U32>,records:Recovery.Recovery(),output:Maybe<&1,Array<U32>>,history:List<&2,String>,readings:List<&2,U32>,values:List<&2,U32>,lagged:Bool,text:String,result:Events.Runtime() & PublishReply) -> Host:
  match result:
    case (runtime,Published{publisher,outcome,returned}):snapshot(label,Host{runtime,handle,schedule,recovery,publisher,reader,registry,scratch,records,output,returned,None{},history,readings,values,lagged,"publication:" ++ outcome_text(outcome),text})
    case (runtime,PublishRefused{publisher,incoming}):snapshot(label,Host{runtime,handle,schedule,recovery,publisher,reader,registry,scratch,records,output,[],Some{incoming},history,readings,values,lagged,"publication:Refused",text})
    case (runtime,PublishTransportFailed{publisher}):snapshot(label,Host{runtime,handle,schedule,recovery,publisher,reader,registry,scratch,records,output,[],None{},history,readings,values,lagged,"publication:TransportFailed",text})
def publish(label:String,state:Host) -> Host:
  match state:
    case Host{runtime,handle,schedule,recovery,publisher,reader,registry,scratch,records,output,returned,Some{incoming},history,readings,values,lagged,status,text}:published(label,handle,schedule,recovery,reader,registry,scratch,records,output,history,readings,values,lagged,text,Events.with_world(~PublishReply,w => publish_reply(Events.publish(publisher,w,incoming)),runtime))
    case Host{runtime,handle,schedule,recovery,publisher,reader,registry,scratch,records,output,returned,None{},history,readings,values,lagged,status,text}:snapshot(label ++ ":missing-payload",Host{runtime,handle,schedule,recovery,publisher,reader,registry,scratch,records,output,returned,None{},history,readings,values,lagged,status,text})
    case Stopped{world,text}:Stopped{world,text}
def world_error(error:W.WorldError) -> String:
  R.world_error(error)
def query_error(error:Q.Error<Unit>) -> String:
  match error:
    case Q.UserError{Unit{}}:"UserError"
    case Q.AccessError{error}:"AccessError:" ++ world_error(error)
def read_outcome(value:T.Outcome<Read.Error<Unit>>) -> String:
  match value:
    case T.Success{}:"Success"
    case T.Failure{Read.MissingPayload{}}:"MissingPayload"
    case T.Failure{Read.ProjectError{Unit{}}}:"ProjectError"
    case T.Failure{Read.QueryError{error}}:query_error(error)
def readings_data(values:List<&1,U32>) -> List<&2,U32>:
  match values:
    case []:[]
    case head <> tail:head <> readings_data(tail)
def read_returned(label:String,handle:W.Handle<B.AuditWorkshop>,schedule:Systems.Schedule(),recovery:Recovery.Owned(),publisher:Events.PublisherRegistry(),records:Recovery.Recovery(),output:Maybe<&1,Array<U32>>,returned:List<Array<U32>>,loose:Maybe<&1,Array<U32>>,history:List<&2,String>,text:String,result:Events.ReadResult()) -> Host:
  match result:
    case Route.Ran{runtime,reader,registry,Ev.Succeeded{Read.Reply{outcome,scratch,readings,values,lagged}}}:snapshot(label,Host{runtime,handle,schedule,recovery,publisher,reader,registry,scratch,records,output,returned,loose,history,readings_data(readings),values,lagged,"reader:" ++ read_outcome(outcome),text})
    case Route.Ran{runtime,reader,registry,Ev.Rejected{(scratch,cursor)}}:snapshot(label,Host{runtime,handle,schedule,recovery,publisher,reader,registry,scratch,records,output,returned,loose,history,[],[],False{},"reader:Rejected:cursor=" ++ U32.show(cursor),text})
    case Route.Ran{runtime,reader,registry,Ev.Failed{Unit{}}}:stopped_runtime(label ++ ":reader-transport-failed",text,runtime)
def read(label:String,state:Host) -> Host:
  match state:
    case Host{runtime,handle,schedule,recovery,publisher,reader,registry,scratch,records,output,returned,loose,history,readings,values,lagged,status,text}:read_returned(label,handle,schedule,recovery,publisher,records,output,returned,loose,history,text,Events.read(runtime,reader,registry,scratch))
    case Stopped{world,text}:Stopped{world,text}
def observation(value:Sch.Observation) -> String:
  match value:
    case Sch.Entered{name}:"phase:" ++ name
    case Sch.Ran{id}:"ran:" ++ U32.show(id)
    case Sch.Skipped{id}:"skipped:" ++ U32.show(id)
    case Sch.Applied{}:"barrier"
def schedule_error(value:Cond.Error<Systems.Error()>) -> String:
  match value:
    case Cond.ConditionUnavailable{}:"ConditionUnavailable"
    case Cond.ConditionRegistrationRejected{}:"ConditionRegistrationRejected"
    case Cond.SystemError{Comp.LeftError{Comp.LeftError{error}}}:query_error(error)
    case Cond.SystemError{Comp.LeftError{Comp.RightError{Unit{}}}}:"ResourceError"
    case Cond.SystemError{Comp.RightError{Unit{}}}:"FieldError"
type ScheduleReply is Type:
  ScheduleReply{schedule:Systems.Schedule(),status:String}
def schedule_reply(result:Run.Run<B.World(R.Resources()),Systems.Schedule(),B.AuditWorkshop,Cond.Error<Systems.Error()>>) -> B.World(R.Resources()) & ScheduleReply:
  match result:
    case Run.Finished{world,schedule,logs}:(world,ScheduleReply{schedule,"Finished:" ++ List.show(&2,Sch.Observation,observation,logs)})
    case Run.Failed{world,schedule,error,logs}:(world,ScheduleReply{schedule,"Failed:" ++ schedule_error(error) ++ ":" ++ List.show(&2,Sch.Observation,observation,logs)})
    case Run.Refused{world,schedule,logs}:(world,ScheduleReply{schedule,"Refused:" ++ List.show(&2,Sch.Observation,observation,logs)})
    case Run.Missing{world,schedule,needs}:(world,ScheduleReply{schedule,"Missing:" ++ List.show(&2,SP.Requirement<B.AuditWorkshop>,Captures.requirement,needs)})
def scheduled(label:String,handle:W.Handle<B.AuditWorkshop>,recovery:Recovery.Owned(),publisher:Events.PublisherRegistry(),reader:Events.ReaderOwner(),registry:Events.ReaderRegistry(),scratch:Array<U32>,records:Recovery.Recovery(),output:Maybe<&1,Array<U32>>,returned:List<Array<U32>>,loose:Maybe<&1,Array<U32>>,history:List<&2,String>,readings:List<&2,U32>,values:List<&2,U32>,lagged:Bool,text:String,result:Events.Runtime() & ScheduleReply) -> Host:
  match result:
    case (runtime,ScheduleReply{schedule,status}):snapshot(label,Host{runtime,handle,schedule,recovery,publisher,reader,registry,scratch,records,output,returned,loose,history,readings,values,lagged,status,text})
def run(label:String,state:Host) -> Host:
  match state:
    case Host{runtime,handle,schedule,recovery,publisher,reader,registry,scratch,records,output,returned,loose,history,readings,values,lagged,status,text}:scheduled(label,handle,recovery,publisher,reader,registry,scratch,records,output,returned,loose,history,readings,values,lagged,text,Events.with_world(~ScheduleReply,w => schedule_reply(Systems.run(schedule,w)),runtime))
    case Stopped{world,text}:Stopped{world,text}
def allow(label:String,value:Bool,state:Host) -> Host:
  match state:
    case Host{runtime,handle,schedule,recovery,publisher,reader,registry,scratch,records,output,returned,loose,history,readings,values,lagged,status,text}:snapshot(label,Host{runtime,handle,Systems.allow(schedule,value),recovery,publisher,reader,registry,scratch,records,output,returned,loose,history,readings,values,lagged,status,text})
    case Stopped{world,text}:Stopped{world,text}
def list(values:List<&2,U32>) -> String:
  List.show(&2,U32,U32.show,values)
def access(~V:Data,~show:V -> String,value:Component.Access<V>) -> String:
  match value:
    case Component.Found{value}:"Found(" ++ show(value) ++ ")"
    case Component.ComponentAbsent{}:"ComponentAbsent"
    case Component.MissingEntity{}:"MissingEntity"
def value(~V:Data,~show:V -> String,value:I.Value<V>) -> String:
  match value:
    case I.Value{found,added,changed}:access(~V,~show,found) ++ ":added=" ++ Bool.show(added) ++ ":changed=" ++ Bool.show(changed)
def views(views:Inspect.Views) -> String:
  match views:
    case Inspect.Views{cursor,arrays,scalar,counter}:"cursor=" ++ U32.show(cursor) ++ ";arrays=" ++ value(~List<&2,U32>,~list,arrays) ++ ";scalar=" ++ value(~U32,~U32.show,scalar) ++ ";counter=" ++ list(counter)
def inspected(label:String,handle:W.Handle<B.AuditWorkshop>,schedule:Systems.Schedule(),recovery:Recovery.Owned(),publisher:Events.PublisherRegistry(),reader:Events.ReaderOwner(),registry:Events.ReaderRegistry(),scratch:Array<U32>,records:Recovery.Recovery(),output:Maybe<&1,Array<U32>>,returned:List<Array<U32>>,loose:Maybe<&1,Array<U32>>,history:List<&2,String>,readings:List<&2,U32>,values:List<&2,U32>,lagged:Bool,text:String,result:Events.Runtime() & Inspect.Views) -> Host:
  match result:
    case (runtime,selected):snapshot(label,Host{runtime,handle,schedule,recovery,publisher,reader,registry,scratch,records,output,returned,loose,history,readings,values,lagged,"inspector:" ++ views(selected),text})
def inspect(label:String,state:Host) -> Host:
  match state:
    case Host{runtime,+handle,schedule,recovery,publisher,reader,registry,scratch,records,output,returned,loose,history,readings,values,lagged,status,text}:inspected(label,handle,schedule,recovery,publisher,reader,registry,scratch,records,output,returned,loose,history,readings,values,lagged,text,Events.with_world(~Inspect.Views,w => Inspect.snapshot(w,handle),runtime))
    case Stopped{world,text}:Stopped{world,text}
def finish(state:Host) -> String:
  match state:
    case Host{runtime,handle,schedule,recovery,publisher,reader,registry,scratch,records,output,returned,loose,history,readings,values,lagged,status,text}:text
    case Stopped{world,text}:text
# The caller-created replacement travels through actual recovery records and
# becomes installed on retry. Publication receives the displaced original.
def sequence(state:Host) -> String:
  finish(inspect("third-repeated-inspect",inspect("third-inspect",run("third-after",allow("third-before",True{},inspect("second-repeated-inspect",inspect("second-inspect",run("second-after",allow("second-before",False{},inspect("first-repeated-inspect",inspect("first-inspect",run("first-after",snapshot("first-before",read("reader-after",snapshot("reader-before",publish("publication-after",withdraw("original-withdrawn",recover("recovery-retry-after",False{},withdraw("replacement-withdrawn",recover("recovery-failed-after",True{},snapshot("handoff-registered",state)))))))))))))))))))))
def reader_defined(handle:W.Handle<B.AuditWorkshop>,schedule:Systems.Schedule(),recovery:Recovery.Owned(),publisher:Events.PublisherRegistry(),text:String,result:Events.Registration()) -> String:
  match result:
    case Route.Registered{runtime,reader,registry}:sequence(Host{runtime,handle,schedule,recovery,publisher,reader,registry,ANode{ALeaf{1},ALeaf{2}},[],None{},[],Some{ANode{ALeaf{70},ALeaf{90}}},[],[],[],False{},"registered",text})
    case Route.RegistrationFailed{runtime}:"reader-registration-failed"
def publisher_defined(handle:W.Handle<B.AuditWorkshop>,schedule:Systems.Schedule(),recovery:Recovery.Owned(),text:String,result:Events.PublisherRegistration()) -> String:
  match result:
    case Sys.Registered{world,publisher}:reader_defined(handle,schedule,recovery,publisher,text,Events.register(Events.setup(world)))
    case Sys.RegistrationFailed{world}:"publisher-registration-failed"
def recovery_defined(handle:W.Handle<B.AuditWorkshop>,schedule:Systems.Schedule(),text:String,result:Recover.Defined<B.World(R.Resources()),Recovery.Owned(),Unit>) -> String:
  match result:
    case Recover.Defined{world,recovery}:publisher_defined(handle,schedule,recovery,text,Events.define_publisher(world))
    case Recover.DefinitionRejected{world,capture}:"recovery-registration-failed"
def start(world:B.World(R.Resources()),handle:W.Handle<B.AuditWorkshop>,schedule:Systems.Schedule(),text:String) -> String:
  recovery_defined(handle,schedule,text,Recovery.define(world))

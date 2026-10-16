import Base
import bundle.bend as B
import resources.bend as R
import component.bend as C
import resource-capture.bend as RC
import systems.bend as Systems
import install.bend as Install
import observe.bend as Observe
import capture-observe.bend as Owners
import inspect.bend as Inspect
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/local.bend as L
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-capture-query.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/captured-schedule.bend as Run
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-condition-composition.bend as Cond
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Component
import capture.bend as Capture

type State is Type:
  State{world:B.World(R.Resources()),handle:W.Handle<B.AuditWorkshop>,schedule:Systems.Schedule(),text:String}
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
def observed(label:String,handle:W.Handle<B.AuditWorkshop>,text:String,world:B.World(R.Resources()) & String,owners:Systems.Schedule() & String) -> State:
  (world,worldText)=world
  (schedule,ownerText)=owners
  State{world,handle,schedule,text ++ label ++ "|world=" ++ worldText ++ "|schedule=" ++ ownerText ++ "\n"}
def snapshot(label:String,state:State) -> State:
  match state:
    case State{world,handle,schedule,text}:observed(label,handle,text,Observe.world(world),Owners.observe(schedule))
def inspected(label:String,handle:W.Handle<B.AuditWorkshop>,schedule:Systems.Schedule(),text:String,result:B.World(R.Resources()) & Inspect.Views) -> State:
  match result:
    case (world,selected):snapshot(label ++ ":selected=" ++ views(selected),State{world,handle,schedule,text})
def inspect(label:String,state:State) -> State:
  match state:
    case State{world,+handle,schedule,text}:inspected(label,handle,schedule,text,Inspect.snapshot(world,handle))
def observation(value:Sch.Observation) -> String:
  match value:
    case Sch.Entered{name}:"phase:" ++ name
    case Sch.Ran{id}:"ran:" ++ U32.show(id)
    case Sch.Skipped{id}:"skipped:" ++ U32.show(id)
    case Sch.Applied{}:"barrier"
def returned(label:String,handle:W.Handle<B.AuditWorkshop>,text:String,result:Run.Run<B.World(R.Resources()),Systems.Schedule(),B.AuditWorkshop,Cond.Error<Systems.Error()>>) -> State:
  match result:
    case Run.Finished{world,schedule,logs}:snapshot(label ++ ":Finished:" ++ List.show(&2,Sch.Observation,observation,logs),State{world,handle,schedule,text})
    case Run.Failed{world,schedule,error,logs}:snapshot(label ++ ":Failed:" ++ List.show(&2,Sch.Observation,observation,logs),State{world,handle,schedule,text})
    case Run.Refused{world,schedule,logs}:snapshot(label ++ ":Refused:" ++ List.show(&2,Sch.Observation,observation,logs),State{world,handle,schedule,text})
    case Run.Missing{world,schedule,missing}:snapshot(label ++ ":Missing",State{world,handle,schedule,text})
def run(label:String,state:State) -> State:
  match state:
    case State{world,handle,schedule,text}:returned(label,handle,text,Systems.run(schedule,world))
def allow(label:String,value:Bool,state:State) -> State:
  match state:
    case State{world,handle,schedule,text}:snapshot(label,State{world,handle,Systems.allow(schedule,value),text})
def finish(state:State) -> String:
  match state:
    case State{world,handle,schedule,text}:text
# A executes, then skips while unbound B updates, then executes again.
# Every owner remains threaded through repeated Inspector observations.
def sequence(state:State) -> String:
  finish(inspect("third-repeated-inspect",inspect("third-inspect",run("third-after",allow("third-before",True{},inspect("second-repeated-inspect",inspect("second-inspect",run("second-after",allow("second-before",False{},inspect("first-repeated-inspect",inspect("first-inspect",run("first-after",snapshot("first-before",state)))))))))))))
def field_defined(handle:W.Handle<B.AuditWorkshop>,text:String,query:C.Owned(),resource:RC.Instance(),result:Field.Defined<B.AuditWorkshop,B.World(R.Resources()),Systems.FieldRegistry(),Field.clauses(~B.AuditWorkshop,~Systems.Tx(),~R.Ops(Systems.Tx()),R.declaration())>) -> String:
  match result:
    case Field.Defined{world,field}:sequence(snapshot("registered",State{world,handle,Systems.bind(query,resource,field),text}))
    case Field.Rejected{world}:text ++ "field-registration-rejected"
def resource_defined(handle:W.Handle<B.AuditWorkshop>,text:String,query:C.Owned(),result:L.Registered<B.AuditWorkshop,B.Store,R.Resources(),U32,Array<U32>,Unit,Unit,Unit,RC.runner()>) -> String:
  match result:
    case L.Registered{world,resource}:field_defined(handle,text,query,resource,Field.define(~B.AuditWorkshop,~B.Store,~R.Resources(),~U32,~R.Ops,~Unit,~Unit,~Unit,~R.declaration(),~R.body,world,"CounterTransaction"))
    case L.RegistrationRejected{world,capture}:text ++ "resource-registration-rejected"
def query_defined(handle:W.Handle<B.AuditWorkshop>,text:String,result:O.Registration<B.World(R.Resources()),C.Owned(),Capture.QueryPack>) -> String:
  match result:
    case O.Registered{world,query}:resource_defined(handle,text,query,RC.define(world))
    case O.Rejected{world,capture}:text ++ "query-registration-rejected"
def flushed(handle:W.Handle<B.AuditWorkshop>,text:String,result:B.World(R.Resources()) & String) -> String:
  match result:
    case (world,worldText):query_defined(handle,text ++ "explicit-flush|world=" ++ worldText ++ "\n",C.define(world))
def prepared(handle:W.Handle<B.AuditWorkshop>,text:String,result:B.World(R.Resources()) & String) -> String:
  match result:
    case (world,worldText):flushed(handle,text ++ "bundle-committed-before-flush|world=" ++ worldText ++ "\n",Observe.world(W.barrier(~B.AuditWorkshop,~B.Store,~R.Resources(),~U32,world)))
def seeded(text:String,result:Install.Seeded) -> String:
  match result:
    case Install.Seeded{world,handle}:prepared(handle,text,Observe.world(world))
    case Install.SeedRejected{world,payloads,raw}:text ++ "bundle-rejected"
def initial(result:B.World(R.Resources()) & String) -> String:
  match result:
    case (world,text):seeded("created|world=" ++ text ++ "\n",Install.seed(world))
def created(result:W.Creation<B.AuditWorkshop,B.Store,R.Resources(),U32>) -> String:
  match result:
    case W.Created{factory,world}:initial(Observe.world(world))
    case W.CreateRejected{factory,resource}:"creation-rejected"
def main() -> String:
  created(W.create(~B.AuditWorkshop,~B.Store,~R.Resources(),~U32,~B.empty,W.factory(),R.initial()))

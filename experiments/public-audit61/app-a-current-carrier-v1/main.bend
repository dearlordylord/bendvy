import Base
import handoff.bend as Handoff
import bundle.bend as B
import resources.bend as R
import component.bend as C
import resource-capture.bend as RC
import systems.bend as Systems
import install.bend as Install
import observe.bend as Observe
import capture-observe.bend as Owners
import inspect.bend as Inspect
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/local.bend as L
import ../../../src/ecs/ordinary-capture-query.bend as O
import ../../../src/ecs/ordinary-resource-field-system.bend as Field
import ../../../src/ecs/captured-schedule.bend as Run
import ../../../src/ecs/ordinary-condition-composition.bend as Cond
import ../../../src/ecs/schedule.bend as Sch
import ../../../src/ecs/inspector.bend as I
import ../../../src/ecs/component.bend as Component
import capture.bend as Capture

def field_defined(handle:W.Handle<B.AuditWorkshop>,text:String,query:C.Owned(),resource:RC.Instance(),result:Field.Defined<B.AuditWorkshop,B.World(R.Resources()),Systems.FieldRegistry(),Field.clauses(~B.AuditWorkshop,~Systems.Tx(),~R.Ops(Systems.Tx()),R.declaration())>) -> String:
  match result:
    case Field.Defined{world,field}:Handoff.start(world,handle,Systems.bind(query,resource,field),text)
    case Field.Rejected{world}:text ++ "field-registration-rejected"
def resource_defined(handle:W.Handle<B.AuditWorkshop>,text:String,query:C.Owned(),result:L.Registered<B.AuditWorkshop,B.Store,R.Resources(),Nat,Array<U32>,Unit,Unit,Unit,RC.runner()>) -> String:
  match result:
    case L.Registered{world,resource}:field_defined(handle,text,query,resource,Field.define(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~R.Ops,~Unit,~Unit,~Unit,~R.declaration(),~R.body,world,"CounterTransaction"))
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
    case (world,worldText):flushed(handle,text ++ "bundle-committed-before-flush|world=" ++ worldText ++ "\n",Observe.world(W.barrier(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,world)))
def seeded(text:String,result:Install.Seeded) -> String:
  match result:
    case Install.Seeded{world,handle}:prepared(handle,text,Observe.world(world))
    case Install.SeedRejected{world,payloads,raw}:text ++ "bundle-rejected"
def initial(result:B.World(R.Resources()) & String) -> String:
  match result:
    case (world,text):seeded("created|world=" ++ text ++ "\n",Install.seed(world))
def created(result:W.Creation<B.AuditWorkshop,B.Store,R.Resources(),Nat>) -> String:
  match result:
    case W.Created{factory,world}:initial(Observe.world(world))
    case W.CreateRejected{factory,resource}:"creation-rejected"
def main() -> String:
  created(W.create(~B.AuditWorkshop,~B.Store,~R.Resources(),~Nat,~B.empty,W.factory(),R.initial()))

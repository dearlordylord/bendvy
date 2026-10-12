import Base
import ../alpha/state.bend as F
import ../alpha/bindings.bend as B
import ../alpha/base-application.bend as BaseApp
import ../alpha/application.bend as A
import ../alpha/consumer.bend as C
import ../alpha/event-setup.bend as Events
import ../alpha/dispatch.bend as Dispatch
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-condition-declaration.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-condition-schedule.bend as API
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule.bend as Schedule
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as SchemaApp
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
type Report is Data:Report{factory:U32,before:List<&2,C.Checkpoint>,after:List<&2,C.Checkpoint>,completion:A.Completion}
def swap(first:A.Application,second:A.Application) -> A.Application & A.Application:
  match first second:
    case A.Application{API.Application{Schedule.Application{SchemaApp.Application{schema1,Build.Registered{world1,owners1,recipe1,debug1}},plan1,namespace1,name1,steps1,needs1},program1},family1,tick1} A.Application{API.Application{Schedule.Application{SchemaApp.Application{schema2,Build.Registered{world2,owners2,recipe2,debug2}},plan2,namespace2,name2,steps2,needs2},program2},family2,tick2}:(A.Application{API.Application{Schedule.Application{SchemaApp.Application{schema1,Build.Registered{world2,owners1,recipe1,debug1}},plan1,namespace1,name1,steps1,needs1},program1},family1,tick1},A.Application{API.Application{Schedule.Application{SchemaApp.Application{schema2,Build.Registered{world1,owners2,recipe2,debug2}},plan2,namespace2,name2,steps2,needs2},program2},family2,tick2})
def final(factory:U32,before:List<&2,C.Checkpoint>,completion:A.Completion,first:A.Application & C.Checkpoint,second:A.Application & C.Checkpoint) -> Report:
  match first second:
    case (_,a),(_,b):Report{factory,before,[a,b],completion}
def returned(factory:U32,before:List<&2,C.Checkpoint>,completion:A.Completion,result:A.Application & A.Application) -> Report:
  match result:
    case (first,second):final(factory,before,completion,C.checkpoint(first,True{}),C.checkpoint(second,True{}))
def executed(factory:U32,before:List<&2,C.Checkpoint>,second:A.Application,result:A.Application & A.Completion) -> Report:
  match result:
    case (first,completion):returned(factory,before,completion,swap(first,second))
def swapped(factory:U32,before:List<&2,C.Checkpoint>,result:A.Application & A.Application) -> Report:
  match result:
    case (first,second):executed(factory,before,second,A.run(first))
def observed(factory:U32,first:A.Application & C.Checkpoint,second:A.Application & C.Checkpoint) -> Report:
  match first second:
    case (first,a),(second,b):swapped(factory,[a,b],swap(first,second))
def attached(factory:U32,first:A.Attachment,second:A.Attachment) -> Maybe<&2,Report>:
  match first second:
    case A.Attached{first} A.Attached{second}:Some{observed(factory,C.checkpoint(first,True{}),C.checkpoint(second,True{}))}
    case _ _:None{}
def built(factory:U32,first:BaseApp.Construction,second:BaseApp.Construction) -> Maybe<&2,Report>:
  match first second:
    case BaseApp.Ready{first} BaseApp.Ready{second}:attached(factory,A.attach(BaseApp.publish(first)),A.attach(BaseApp.publish(second)))
    case _ _:None{}
def created_second(first:F.World(),result:W.Creation<F.S,F.Store,F.Resources,F.Events()>) -> Maybe<&2,Report>:
  match result:
    case W.Created{W.Factory{factory},second}:built(factory,BaseApp.construct(W.enqueue(~F.S,~F.Store,~F.Resources,~F.Events(),first,C.barrier)),BaseApp.construct(W.enqueue(~F.S,~F.Store,~F.Resources,~F.Events(),second,C.barrier)))
    case W.CreateRejected{_,_}:None{}
def created_first(result:W.Creation<F.S,F.Store,F.Resources,F.Events()>) -> Maybe<&2,Report>:
  match result:
    case W.Created{factory,first}:created_second(first,W.create(~F.S,~F.Store,~F.Resources,~F.Events(),~F.empty,factory,F.initial_resources()))
    case W.CreateRejected{_,_}:None{}
def run() -> Maybe<&2,Report>:created_first(W.create(~F.S,~F.Store,~F.Resources,~F.Events(),~F.empty,W.factory(),F.initial_resources()))

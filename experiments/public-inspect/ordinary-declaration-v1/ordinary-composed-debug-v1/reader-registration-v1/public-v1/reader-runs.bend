import Base
import state.bend as F
import event-setup.bend as Events
import bindings.bend as Old
import reader-bindings.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-event-family-reader.bend as Reader
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-event-family-runtime.bend as Family
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as SchemaApp
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Fields
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Records
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys

import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
type Delivery<E:Data> is Data:
  Success{reading:Ev.Reading<E>}
  Failure{error:B.ReadError<E>}
  Rejected{args:Bool}
def completion(~E:Data,value:Ev.Completion<B.ReadError<E>,Ev.Reading<E>,Bool>) -> Delivery<E>:
  match value:
    case Ev.Succeeded{reading}:Success{reading}
    case Ev.Failed{error}:Failure{error}
    case Ev.Rejected{args}:Rejected{args}
def owners_first(kept:Old.Owners4() & (B.FirstOwner() & B.SecondOwner()),selected:B.FirstOwner()) -> B.Owners7():
  match kept:
    case (old,(slow,second)):(((old,selected),slow),second)
def returned_first(schema:Schema.Schema<F.S,F.Store,F.Resources>,recipe:Tree.Recipe<F.World(),B.Rows7(),B.observe7()>,debug:Bool,kept:Old.Owners4() & (B.FirstOwner() & B.SecondOwner()),result:Reader.RunResult<F.S,F.Store,F.Resources,F.Events(),F.FirstEvent,Events.State(),Bool,B.ReadError<F.FirstEvent>,Ev.Reading<F.FirstEvent>,Events.take_first,Events.put_first,B.first_runner>) -> B.App7() & Delivery<F.FirstEvent>:
  match result:
    case Reader.Ran{runtime,selected,done}:(Family.Application{schema,runtime,owners_first(kept,selected),recipe,debug},completion(~F.FirstEvent,done))
def selected_first(schema:Schema.Schema<F.S,F.Store,F.Resources>,recipe:Tree.Recipe<F.World(),B.Rows7(),B.observe7()>,debug:Bool,runtime:Events.Runtime(),owners:B.Owners7()) -> B.App7() & Delivery<F.FirstEvent>:
  match owners:
    case (((old,selected),slow),second):returned_first(schema,recipe,debug,(old,(slow,second)),Reader.run(~F.S,~F.Store,~F.Resources,~F.Events(),~F.FirstEvent,~Events.State(),~Bool,~B.ReadError<F.FirstEvent>,~Ev.Reading<F.FirstEvent>,~Events.take_first,~Events.put_first,~B.first_runner,~Events.synchronize,selected,runtime,False{}))
def first(app:B.App7()) -> B.App7() & Delivery<F.FirstEvent>:
  match app:
    case Family.Application{schema,runtime,owners,recipe,debug}:selected_first(schema,recipe,debug,runtime,owners)
def owners_slow(kept:B.Owners5() & B.SecondOwner(),selected:B.FirstOwner()) -> B.Owners7():
  match kept:
    case (old,second):((old,selected),second)
def returned_slow(schema:Schema.Schema<F.S,F.Store,F.Resources>,recipe:Tree.Recipe<F.World(),B.Rows7(),B.observe7()>,debug:Bool,kept:B.Owners5() & B.SecondOwner(),result:Reader.RunResult<F.S,F.Store,F.Resources,F.Events(),F.FirstEvent,Events.State(),Bool,B.ReadError<F.FirstEvent>,Ev.Reading<F.FirstEvent>,Events.take_first,Events.put_first,B.first_runner>) -> B.App7() & Delivery<F.FirstEvent>:
  match result:
    case Reader.Ran{runtime,selected,done}:(Family.Application{schema,runtime,owners_slow(kept,selected),recipe,debug},completion(~F.FirstEvent,done))
def selected_slow(schema:Schema.Schema<F.S,F.Store,F.Resources>,recipe:Tree.Recipe<F.World(),B.Rows7(),B.observe7()>,debug:Bool,runtime:Events.Runtime(),owners:B.Owners7()) -> B.App7() & Delivery<F.FirstEvent>:
  match owners:
    case ((old,selected),second):returned_slow(schema,recipe,debug,(old,second),Reader.run(~F.S,~F.Store,~F.Resources,~F.Events(),~F.FirstEvent,~Events.State(),~Bool,~B.ReadError<F.FirstEvent>,~Ev.Reading<F.FirstEvent>,~Events.take_first,~Events.put_first,~B.first_runner,~Events.synchronize,selected,runtime,False{}))
def slow(app:B.App7()) -> B.App7() & Delivery<F.FirstEvent>:
  match app:
    case Family.Application{schema,runtime,owners,recipe,debug}:selected_slow(schema,recipe,debug,runtime,owners)
def owners_second(kept:B.Owners6(),selected:B.SecondOwner()) -> B.Owners7():
  match kept:
    case old:(old,selected)
def returned_second(schema:Schema.Schema<F.S,F.Store,F.Resources>,recipe:Tree.Recipe<F.World(),B.Rows7(),B.observe7()>,debug:Bool,kept:B.Owners6(),result:Reader.RunResult<F.S,F.Store,F.Resources,F.Events(),F.SecondEvent,Events.State(),Bool,B.ReadError<F.SecondEvent>,Ev.Reading<F.SecondEvent>,Events.take_second,Events.put_second,B.second_runner>) -> B.App7() & Delivery<F.SecondEvent>:
  match result:
    case Reader.Ran{runtime,selected,done}:(Family.Application{schema,runtime,owners_second(kept,selected),recipe,debug},completion(~F.SecondEvent,done))
def selected_second(schema:Schema.Schema<F.S,F.Store,F.Resources>,recipe:Tree.Recipe<F.World(),B.Rows7(),B.observe7()>,debug:Bool,runtime:Events.Runtime(),owners:B.Owners7()) -> B.App7() & Delivery<F.SecondEvent>:
  match owners:
    case (old,selected):returned_second(schema,recipe,debug,old,Reader.run(~F.S,~F.Store,~F.Resources,~F.Events(),~F.SecondEvent,~Events.State(),~Bool,~B.ReadError<F.SecondEvent>,~Ev.Reading<F.SecondEvent>,~Events.take_second,~Events.put_second,~B.second_runner,~Events.synchronize,selected,runtime,False{}))
def second(app:B.App7()) -> B.App7() & Delivery<F.SecondEvent>:
  match app:
    case Family.Application{schema,runtime,owners,recipe,debug}:selected_second(schema,recipe,debug,runtime,owners)

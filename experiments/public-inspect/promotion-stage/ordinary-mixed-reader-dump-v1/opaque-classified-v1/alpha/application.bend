import Base
import ./provision.bend as Provision
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-event-family-dump.bend as DumpApp
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-dump.bend as Dump
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-dump-filter.bend as Filter
import ./state.bend as F
import ./event-setup.bend as Events
import ./bindings.bend as B
import ./descriptor-reader.bend as FailureReader
import ./operations.bend as Operations
import ./physical.bend as Physical
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-event-family-runtime.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as SchemaApp
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Fields
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-event-notice-runtime.bend as NoticeApp
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-event-family-reader.bend as Reader
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route
import /workspace/formal-proofs/bendvy/src/ecs/event-runtime.bend as Ev
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Recipe
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/relation-failure-runtime.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/internal/relation-failures/readings.bend as Read
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
def Application() -> Type:B.App4()
def enabled(value:Application(),flag:Bool) -> Application():App.enabled(~F.S,~F.Store(),~F.Resources(),~F.Events(),~Events.State(),~B.Owners4(),~B.Rows4(),~B.observe4(),~B.fold4(),value,flag)
def snapshot(value:Application()) -> Application() & Maybe<&2,SchemaApp.Description<F.S,B.Rows4()>>:App.snapshot(~F.S,~F.Store(),~F.Resources(),~F.Events(),~Events.State(),~B.Owners4(),~B.Rows4(),~B.observe4(),~B.fold4(),value)
def inventory(value:Application()) -> Application() & Maybe<&2,List<&2,String>>:NoticeApp.inventory(~F.S,~F.Store(),~F.Resources(),~Events.Events(),~Events.Metadata(),~Array<U32>,~Events.inventory(),~B.Owners4(),~B.Rows4(),~B.observe4(),~B.fold4(),value)
def read1_returned(schema:Schema.Schema<F.S,F.Store(),F.Resources()>,held:((Unit & B.Owner2()) & B.Owner3()) & B.Owner4(),recipe:Recipe.Recipe<F.World(),B.Rows4(),B.observe4()>,debug:Bool,result:Reader.RunResult<F.S,F.Store(),F.Resources(),F.Events(),F.FirstEvent,Events.State(),Array<U32>,Unit,(Array<U32> & Ev.Reading<F.FirstEvent>),Events.take_first,Events.put_first,B.first_runner>) -> Application() & Ev.Completion<Unit,(Array<U32> & Ev.Reading<F.FirstEvent>),Array<U32>>:
  match held result:
    case (((base,slow),second),failure) Reader.Ran{runtime,owner,completion}:(App.Application{schema,runtime,((((base,owner),slow),second),failure),recipe,debug},completion)
def read1(value:Application(),args:Array<U32>) -> Application() & Ev.Completion<Unit,(Array<U32> & Ev.Reading<F.FirstEvent>),Array<U32>>:
  match value:
    case App.Application{schema,runtime,((((base,owner),slow),second),failure),recipe,debug}:read1_returned(schema,(((base,slow),second),failure),recipe,debug,Reader.run(~F.S,~F.Store(),~F.Resources(),~F.Events(),~F.FirstEvent,~Events.State(),~Array<U32>,~Unit,~(Array<U32> & Ev.Reading<F.FirstEvent>),~Events.take_first,~Events.put_first,~B.first_runner,~Events.synchronize,owner,runtime,args))
def read2_returned(schema:Schema.Schema<F.S,F.Store(),F.Resources()>,held:((Unit & B.Owner1()) & B.Owner3()) & B.Owner4(),recipe:Recipe.Recipe<F.World(),B.Rows4(),B.observe4()>,debug:Bool,result:Reader.RunResult<F.S,F.Store(),F.Resources(),F.Events(),F.FirstEvent,Events.State(),Array<U32>,Unit,(Array<U32> & Ev.Reading<F.FirstEvent>),Events.take_first,Events.put_first,B.first_runner>) -> Application() & Ev.Completion<Unit,(Array<U32> & Ev.Reading<F.FirstEvent>),Array<U32>>:
  match held result:
    case (((base,first),second),failure) Reader.Ran{runtime,owner,completion}:(App.Application{schema,runtime,((((base,first),owner),second),failure),recipe,debug},completion)
def read2(value:Application(),args:Array<U32>) -> Application() & Ev.Completion<Unit,(Array<U32> & Ev.Reading<F.FirstEvent>),Array<U32>>:
  match value:
    case App.Application{schema,runtime,((((base,first),owner),second),failure),recipe,debug}:read2_returned(schema,(((base,first),second),failure),recipe,debug,Reader.run(~F.S,~F.Store(),~F.Resources(),~F.Events(),~F.FirstEvent,~Events.State(),~Array<U32>,~Unit,~(Array<U32> & Ev.Reading<F.FirstEvent>),~Events.take_first,~Events.put_first,~B.first_runner,~Events.synchronize,owner,runtime,args))
def read3_returned(schema:Schema.Schema<F.S,F.Store(),F.Resources()>,held:((Unit & B.Owner1()) & B.Owner2()) & B.Owner4(),recipe:Recipe.Recipe<F.World(),B.Rows4(),B.observe4()>,debug:Bool,result:Reader.RunResult<F.S,F.Store(),F.Resources(),F.Events(),F.SecondEvent,Events.State(),Array<U32>,Unit,(Array<U32> & Ev.Reading<F.SecondEvent>),Events.take_second,Events.put_second,B.second_runner>) -> Application() & Ev.Completion<Unit,(Array<U32> & Ev.Reading<F.SecondEvent>),Array<U32>>:
  match held result:
    case (((base,first),slow),failure) Reader.Ran{runtime,owner,completion}:(App.Application{schema,runtime,((((base,first),slow),owner),failure),recipe,debug},completion)
def read3(value:Application(),args:Array<U32>) -> Application() & Ev.Completion<Unit,(Array<U32> & Ev.Reading<F.SecondEvent>),Array<U32>>:
  match value:
    case App.Application{schema,runtime,((((base,first),slow),owner),failure),recipe,debug}:read3_returned(schema,(((base,first),slow),failure),recipe,debug,Reader.run(~F.S,~F.Store(),~F.Resources(),~F.Events(),~F.SecondEvent,~Events.State(),~Array<U32>,~Unit,~(Array<U32> & Ev.Reading<F.SecondEvent>),~Events.take_second,~Events.put_second,~B.second_runner,~Events.synchronize,owner,runtime,args))
def failure_returned(schema:Schema.Schema<F.S,F.Store(),F.Resources()>,held:B.Owners3(),recipe:Recipe.Recipe<F.World(),B.Rows4(),B.observe4()>,debug:Bool,result:FailureReader.RunResult<F.S,F.Store(),F.Resources(),Events.Events(),Events.Metadata(),Array<U32>,B.Owner4(),Unit,(Array<U32> & List<&2,Read.KeyReading<F.S,F.Events()>>),Array<U32>>) -> Application() & K.Completion<Unit,(Array<U32> & List<&2,Read.KeyReading<F.S,F.Events()>>),Array<U32>>:
  match result:
    case FailureReader.Ran{runtime,owner,completion}:(App.Application{schema,runtime,(held,owner),recipe,debug},completion)
def read_failure(value:Application(),args:Array<U32>) -> Application() & K.Completion<Unit,(Array<U32> & List<&2,Read.KeyReading<F.S,F.Events()>>),Array<U32>>:
  match value:
    case App.Application{schema,runtime,(held,owner),recipe,debug}:failure_returned(schema,held,recipe,debug,FailureReader.run(~F.S,~F.Store(),~F.Resources(),~Events.Events(),~Array<U32>,~Unit,~(Array<U32> & List<&2,Read.KeyReading<F.S,F.Events()>>),~Operations.runner,~Events.Metadata(),~Array<U32>,~Operations.classify,runtime,owner,args))

def dump(value:Application()) -> Application() & Maybe<&2,Dump.Dump<F.S>>:DumpApp.snapshot(~F.S,~F.Store(),~F.Resources(),~F.Events(),~Events.State(),~B.Owners4(),~B.Rows4(),~B.observe4(),~B.fold4(),~Provision.count(),~Provision.values(),~Provision.resources(),Provision.criteria(),value)

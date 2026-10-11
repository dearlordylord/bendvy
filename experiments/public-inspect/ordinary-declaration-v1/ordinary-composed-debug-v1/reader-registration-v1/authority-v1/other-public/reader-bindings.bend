import Base
import state.bend as F
import event-setup.bend as Events
import bindings.bend as B
import application.bend as Prior
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

type ReadError<E:Data> is Data:ReadError{reading:Ev.Reading<E>}
def read_runner(~E:Data,world:F.World(),input:Ev.Input<E,Bool>) -> Sys.Outcome<F.World(),ReadError<E>,Ev.Reading<E>>:
  match input:
    case Ev.Input{+values,+lagged,False{}}:Sys.Succeeded{world,Ev.Reading{values,lagged}}
    case Ev.Input{values,lagged,True{}}:Sys.Failed{world,ReadError{Ev.Reading{values,lagged}}}
def first_runner(world:F.World(),input:Ev.Input<F.FirstEvent,Bool>) -> Sys.Outcome<F.World(),ReadError<F.FirstEvent>,Ev.Reading<F.FirstEvent>>:read_runner(~F.FirstEvent,world,input)
def second_runner(world:F.World(),input:Ev.Input<F.SecondEvent,Bool>) -> Sys.Outcome<F.World(),ReadError<F.SecondEvent>,Ev.Reading<F.SecondEvent>>:read_runner(~F.SecondEvent,world,input)
def FirstOwner() -> Type:Reader.OwnerType(~F.S,~F.Store,~F.Resources,~F.Events(),~F.FirstEvent,~Events.State(),~Bool,~ReadError<F.FirstEvent>,~Ev.Reading<F.FirstEvent>,~Events.take_first,~Events.put_first,~first_runner)
def SecondOwner() -> Type:Reader.OwnerType(~F.S,~F.Store,~F.Resources,~F.Events(),~F.SecondEvent,~Events.State(),~Bool,~ReadError<F.SecondEvent>,~Ev.Reading<F.SecondEvent>,~Events.take_second,~Events.put_second,~second_runner)
def Owners5() -> Type:B.Owners4() & FirstOwner()
def Rows5() -> Data:DTO.Product<B.Rows4(),Unit>
def observe5() -> F.World() -> F.World() & DTO.Observation<Rows5()>:Tree.observe_pair(~F.World(),~B.Rows4(),~Unit,~B.observe4(),~Reader.observe(~F.S,~F.Store,~F.Resources,~F.Events()))
def fold5() -> Owners5() -> Owners5() & List<&2,Fields.Fields<F.S>>:Records.fold_pair(~F.S,~B.Owners4(),~FirstOwner(),~B.fold4(),~Reader.fields(~F.S,~F.Store,~F.Resources,~F.Events(),~F.FirstEvent,~Route.Reader<F.S,F.FirstEvent,Events.State(),Events.take_first,Events.put_first>,~Bool,~ReadError<F.FirstEvent>,~Ev.Reading<F.FirstEvent>,~first_runner))
def App5() -> Type:Family.Application<F.S,F.Store,F.Resources,F.Events(),Events.State(),Owners5(),Rows5(),observe5(),fold5()>
def install5(~Out:Type,done:App5() -> Out,failed:Prior.Application() -> Out,app:Prior.Application()) -> Out:Reader.install(~F.S,~F.Store,~F.Resources,~F.Events(),~F.FirstEvent,~Events.State(),~Bool,~ReadError<F.FirstEvent>,~Ev.Reading<F.FirstEvent>,~Events.take_first,~Events.put_first,~first_runner,~B.Owners4(),~B.Rows4(),~B.observe4(),~B.fold4(),~Out,done,failed,app,"SharedReader")
def Owners6() -> Type:Owners5() & FirstOwner()
def Rows6() -> Data:DTO.Product<Rows5(),Unit>
def observe6() -> F.World() -> F.World() & DTO.Observation<Rows6()>:Tree.observe_pair(~F.World(),~Rows5(),~Unit,~observe5(),~Reader.observe(~F.S,~F.Store,~F.Resources,~F.Events()))
def fold6() -> Owners6() -> Owners6() & List<&2,Fields.Fields<F.S>>:Records.fold_pair(~F.S,~Owners5(),~FirstOwner(),~fold5(),~Reader.fields(~F.S,~F.Store,~F.Resources,~F.Events(),~F.FirstEvent,~Route.Reader<F.S,F.FirstEvent,Events.State(),Events.take_first,Events.put_first>,~Bool,~ReadError<F.FirstEvent>,~Ev.Reading<F.FirstEvent>,~first_runner))
def App6() -> Type:Family.Application<F.S,F.Store,F.Resources,F.Events(),Events.State(),Owners6(),Rows6(),observe6(),fold6()>
def install6(~Out:Type,done:App6() -> Out,failed:App5() -> Out,app:App5()) -> Out:Reader.install(~F.S,~F.Store,~F.Resources,~F.Events(),~F.FirstEvent,~Events.State(),~Bool,~ReadError<F.FirstEvent>,~Ev.Reading<F.FirstEvent>,~Events.take_first,~Events.put_first,~first_runner,~Owners5(),~Rows5(),~observe5(),~fold5(),~Out,done,failed,app,"SharedReader")
def Owners7() -> Type:Owners6() & SecondOwner()
def Rows7() -> Data:DTO.Product<Rows6(),Unit>
def observe7() -> F.World() -> F.World() & DTO.Observation<Rows7()>:Tree.observe_pair(~F.World(),~Rows6(),~Unit,~observe6(),~Reader.observe(~F.S,~F.Store,~F.Resources,~F.Events()))
def fold7() -> Owners7() -> Owners7() & List<&2,Fields.Fields<F.S>>:Records.fold_pair(~F.S,~Owners6(),~SecondOwner(),~fold6(),~Reader.fields(~F.S,~F.Store,~F.Resources,~F.Events(),~F.SecondEvent,~Route.Reader<F.S,F.SecondEvent,Events.State(),Events.take_second,Events.put_second>,~Bool,~ReadError<F.SecondEvent>,~Ev.Reading<F.SecondEvent>,~second_runner))
def App7() -> Type:Family.Application<F.S,F.Store,F.Resources,F.Events(),Events.State(),Owners7(),Rows7(),observe7(),fold7()>
def install7(~Out:Type,done:App7() -> Out,failed:App6() -> Out,app:App6()) -> Out:Reader.install(~F.S,~F.Store,~F.Resources,~F.Events(),~F.SecondEvent,~Events.State(),~Bool,~ReadError<F.SecondEvent>,~Ev.Reading<F.SecondEvent>,~Events.take_second,~Events.put_second,~second_runner,~Owners6(),~Rows6(),~observe6(),~fold6(),~Out,done,failed,app,"SharedReader")

type ReaderIdentity is Data:ReaderIdentity{namespace:U32,id:U32,registryId:U32}
def first_identity(value:FirstOwner()) -> FirstOwner() & ReaderIdentity:
  match value:
    case Reader.Owner{declaration,Route.Reader{+namespace,+id,+registryId},registry}:(Reader.Owner{declaration,Route.Reader{namespace,id,registryId},registry},ReaderIdentity{namespace,id,registryId})
def second_identity(value:SecondOwner()) -> SecondOwner() & ReaderIdentity:
  match value:
    case Reader.Owner{declaration,Route.Reader{+namespace,+id,+registryId},registry}:(Reader.Owner{declaration,Route.Reader{namespace,id,registryId},registry},ReaderIdentity{namespace,id,registryId})
def identities_second(old:Owners6(),before:List<&2,ReaderIdentity>,result:SecondOwner() & ReaderIdentity) -> Owners7() & List<&2,ReaderIdentity>:
  match result:
    case (second,id):((old,second),List.append(&2,ReaderIdentity,before,[id]))
def identities_slow(old:Owners5(),second:SecondOwner(),before:List<&2,ReaderIdentity>,result:FirstOwner() & ReaderIdentity) -> Owners7() & List<&2,ReaderIdentity>:
  match result:
    case (slow,id):identities_second((old,slow),List.append(&2,ReaderIdentity,before,[id]),second_identity(second))
def identities_first(old:B.Owners4(),slow:FirstOwner(),second:SecondOwner(),result:FirstOwner() & ReaderIdentity) -> Owners7() & List<&2,ReaderIdentity>:
  match result:
    case (first,id):identities_slow((old,first),second,[id],first_identity(slow))
def identities(value:Owners7()) -> Owners7() & List<&2,ReaderIdentity>:
  match value:
    case (((old,first),slow),second):identities_first(old,slow,second,first_identity(first))

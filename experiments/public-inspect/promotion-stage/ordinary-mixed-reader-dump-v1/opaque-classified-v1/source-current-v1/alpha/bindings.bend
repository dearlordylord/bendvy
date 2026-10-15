import Base
import ./provision.bend as Provision
import ../../../../../../../src/ecs/internal/relation-failures/readings.bend as Read
import ../../../../../../../src/ecs/ordinary-app-relation-failure-reader.bend as FailureReader
import ./operations.bend as Operations
import ../../../../../../../src/ecs/relation-failure-runtime.bend as K
import ../../../../../../../src/ecs/event-family-routing.bend as Route
import ../../../../../../../src/ecs/ordinary-app-registration-fields.bend as Fields
import ./state.bend as F
import ./event-setup.bend as Events
import ../../../../../../../src/ecs/ordinary-app-event-family-reader.bend as Reader
import ../../../../../../../src/ecs/ordinary-app-event-family-runtime.bend as App
import ../../../../../../../src/ecs/ordinary-app-records.bend as Records
import ../../../../../../../src/ecs/ordinary-app-recipe.bend as Recipe
import ../../../../../../../src/ecs/ordinary-app-observation-data.bend as DTO
import ../../../../../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../../../../../src/ecs/ordinary-app-relation.bend as Relation
import ../../../../../../../src/ecs/event-runtime.bend as Ev
import ../../../../../../../src/ecs/system.bend as Sys
import ../../../../../../../src/ecs/world.bend as W
import ../../../../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../../../../src/ecs/ordinary-app-schema.bend as SchemaApp
import ../../../../../../../src/ecs/ordinary-app-event-notice-runtime.bend as NoticeApp
def first_runner(world:F.World(),input:Ev.Input<F.FirstEvent,Array<U32>>) -> Sys.Outcome<F.World(),Unit,(Array<U32> & Ev.Reading<F.FirstEvent>)>:
  match input:
    case Ev.Input{values,lagged,args}:Sys.Succeeded{world,(args,Ev.Reading{values,lagged})}
def second_runner(world:F.World(),input:Ev.Input<F.SecondEvent,Array<U32>>) -> Sys.Outcome<F.World(),Unit,(Array<U32> & Ev.Reading<F.SecondEvent>)>:
  match input:
    case Ev.Input{values,lagged,args}:Sys.Succeeded{world,(args,Ev.Reading{values,lagged})}
def Rows0() -> Data:Relation.ObservedRows(~F.S,~Unit)
def Owners0() -> Type:Unit
def observe0() -> F.World() -> F.World() & DTO.Observation<Rows0()>:Recipe.observe_pair(~F.World(),~Unit,~Relation.View<F.S>,~Build.empty_observe(~F.World()),~Relation.observe(~F.S,~F.Components(),~F.Resources(),~F.Publications(),~F.parent(),~Relation.builtin_row(~F.S)))
def fold0() -> Unit -> Unit & List<&2,Fields.Fields<F.S>>:Records.empty(~F.S)
def App0() -> Type:App.Application<F.S,F.Store(),F.Resources(),F.Events(),Events.State(),Owners0(),Rows0(),observe0(),fold0()>
def initial(world:F.World()) -> App0():NoticeApp.start(~F.S,~F.Store(),~F.Resources(),~Events.Events(),~Events.Domains(),~Events.Metadata(),~Array<U32>,~Events.make(),~Events.sync(),~Events.frame(),~Events.retain(),~Events.inventory(),~Owners0(),~Rows0(),~observe0(),~fold0(),Events.provision(),ANode{ALeaf{31},ALeaf{32}},2n,SchemaApp.attached(~F.S,~F.Store(),~F.Resources(),~F.Events(),~Owners0(),~Rows0(),~observe0(),~fold0(),Provision.schema(),Relation.install(~F.S,~F.Components(),~F.Resources(),~F.Publications(),~F.parent(),~Unit,~Unit,~Build.empty_observe(~F.World()),~Records.empty(~F.S),Build.empty(~F.S,~F.World(),world))))
def Owner1() -> Type:Reader.OwnerType(~F.S,~F.Store(),~F.Resources(),~F.Events(),~F.FirstEvent,~Events.State(),~Array<U32>,~Unit,~(Array<U32> & Ev.Reading<F.FirstEvent>),~Events.take_first,~Events.put_first,~first_runner)
def Owners1() -> Type:Owners0() & Owner1()
def Rows1() -> Data:DTO.Product<Rows0(),Unit>
def observe1() -> F.World() -> F.World() & DTO.Observation<Rows1()>:Recipe.observe_pair(~F.World(),~Rows0(),~Unit,~observe0(),~Reader.observe(~F.S,~F.Store(),~F.Resources(),~F.Events()))
def fold1() -> Owners1() -> Owners1() & List<&2,Fields.Fields<F.S>>:Records.fold_pair(~F.S,~Owners0(),~Owner1(),~fold0(),~Reader.fields(~F.S,~F.Store(),~F.Resources(),~F.Events(),~F.FirstEvent,~Route.Reader<F.S,F.FirstEvent,Events.State(),Events.take_first,Events.put_first>,~Array<U32>,~Unit,~(Array<U32> & Ev.Reading<F.FirstEvent>),~first_runner))
def App1() -> Type:Reader.Application(~F.S,~F.Store(),~F.Resources(),~F.Events(),~F.FirstEvent,~Events.State(),~Array<U32>,~Unit,~(Array<U32> & Ev.Reading<F.FirstEvent>),~Events.take_first,~Events.put_first,~first_runner,~Owners0(),~Rows0(),~observe0(),~fold0())
def install1(~Out:Type,done:App1() -> Out,failed:App0() -> Out,value:App0()) -> Out:Reader.install(~F.S,~F.Store(),~F.Resources(),~F.Events(),~F.FirstEvent,~Events.State(),~Array<U32>,~Unit,~(Array<U32> & Ev.Reading<F.FirstEvent>),~Events.take_first,~Events.put_first,~first_runner,~Owners0(),~Rows0(),~observe0(),~fold0(),~Out,done,failed,value,"SignalReader")
def Owner2() -> Type:Reader.OwnerType(~F.S,~F.Store(),~F.Resources(),~F.Events(),~F.FirstEvent,~Events.State(),~Array<U32>,~Unit,~(Array<U32> & Ev.Reading<F.FirstEvent>),~Events.take_first,~Events.put_first,~first_runner)
def Owners2() -> Type:Owners1() & Owner2()
def Rows2() -> Data:DTO.Product<Rows1(),Unit>
def observe2() -> F.World() -> F.World() & DTO.Observation<Rows2()>:Recipe.observe_pair(~F.World(),~Rows1(),~Unit,~observe1(),~Reader.observe(~F.S,~F.Store(),~F.Resources(),~F.Events()))
def fold2() -> Owners2() -> Owners2() & List<&2,Fields.Fields<F.S>>:Records.fold_pair(~F.S,~Owners1(),~Owner2(),~fold1(),~Reader.fields(~F.S,~F.Store(),~F.Resources(),~F.Events(),~F.FirstEvent,~Route.Reader<F.S,F.FirstEvent,Events.State(),Events.take_first,Events.put_first>,~Array<U32>,~Unit,~(Array<U32> & Ev.Reading<F.FirstEvent>),~first_runner))
def App2() -> Type:Reader.Application(~F.S,~F.Store(),~F.Resources(),~F.Events(),~F.FirstEvent,~Events.State(),~Array<U32>,~Unit,~(Array<U32> & Ev.Reading<F.FirstEvent>),~Events.take_first,~Events.put_first,~first_runner,~Owners1(),~Rows1(),~observe1(),~fold1())
def install2(~Out:Type,done:App2() -> Out,failed:App1() -> Out,value:App1()) -> Out:Reader.install(~F.S,~F.Store(),~F.Resources(),~F.Events(),~F.FirstEvent,~Events.State(),~Array<U32>,~Unit,~(Array<U32> & Ev.Reading<F.FirstEvent>),~Events.take_first,~Events.put_first,~first_runner,~Owners1(),~Rows1(),~observe1(),~fold1(),~Out,done,failed,value,"SignalReader")
def Owner3() -> Type:Reader.OwnerType(~F.S,~F.Store(),~F.Resources(),~F.Events(),~F.SecondEvent,~Events.State(),~Array<U32>,~Unit,~(Array<U32> & Ev.Reading<F.SecondEvent>),~Events.take_second,~Events.put_second,~second_runner)
def Owners3() -> Type:Owners2() & Owner3()
def Rows3() -> Data:DTO.Product<Rows2(),Unit>
def observe3() -> F.World() -> F.World() & DTO.Observation<Rows3()>:Recipe.observe_pair(~F.World(),~Rows2(),~Unit,~observe2(),~Reader.observe(~F.S,~F.Store(),~F.Resources(),~F.Events()))
def fold3() -> Owners3() -> Owners3() & List<&2,Fields.Fields<F.S>>:Records.fold_pair(~F.S,~Owners2(),~Owner3(),~fold2(),~Reader.fields(~F.S,~F.Store(),~F.Resources(),~F.Events(),~F.SecondEvent,~Route.Reader<F.S,F.SecondEvent,Events.State(),Events.take_second,Events.put_second>,~Array<U32>,~Unit,~(Array<U32> & Ev.Reading<F.SecondEvent>),~second_runner))
def App3() -> Type:Reader.Application(~F.S,~F.Store(),~F.Resources(),~F.Events(),~F.SecondEvent,~Events.State(),~Array<U32>,~Unit,~(Array<U32> & Ev.Reading<F.SecondEvent>),~Events.take_second,~Events.put_second,~second_runner,~Owners2(),~Rows2(),~observe2(),~fold2())
def install3(~Out:Type,done:App3() -> Out,failed:App2() -> Out,value:App2()) -> Out:Reader.install(~F.S,~F.Store(),~F.Resources(),~F.Events(),~F.SecondEvent,~Events.State(),~Array<U32>,~Unit,~(Array<U32> & Ev.Reading<F.SecondEvent>),~Events.take_second,~Events.put_second,~second_runner,~Owners2(),~Rows2(),~observe2(),~fold2(),~Out,done,failed,value,"SignalReader")
def Owner4() -> Type:FailureReader.OwnerType(~F.S,~F.Store(),~F.Resources(),~Events.Events(),~Array<U32>,~Unit,~(Array<U32> & List<&2,Read.KeyReading<F.S,F.Events()>>),~Operations.runner)
def Owners4() -> Type:Owners3() & Owner4()
def Rows4() -> Data:DTO.Product<Rows3(),Unit>
def observe4() -> F.World() -> F.World() & DTO.Observation<Rows4()>:Recipe.observe_pair(~F.World(),~Rows3(),~Unit,~observe3(),~FailureReader.observe(~F.S,~F.Store(),~F.Resources(),~Events.Events()))
def fold4() -> Owners4() -> Owners4() & List<&2,Fields.Fields<F.S>>:Records.fold_pair(~F.S,~Owners3(),~Owner4(),~fold3(),~FailureReader.fields(~F.S,~F.Store(),~F.Resources(),~Events.Events(),~Array<U32>,~Unit,~(Array<U32> & List<&2,Read.KeyReading<F.S,F.Events()>>),~Operations.runner))
def App4() -> Type:App.Application<F.S,F.Store(),F.Resources(),F.Events(),Events.State(),Owners4(),Rows4(),observe4(),fold4()>
def added_failure(schema:Schema.Schema<F.S,F.Store(),F.Resources()>,family:Events.State(),tick:Nat,result:Build.Registered<F.S,F.World(),Owners4(),Rows4(),observe4(),fold4()>) -> App4():
  match result:
    case Build.Registered{world,owners,recipe,debug}:App.Application{schema,Route.Runtime{world,family,tick},owners,recipe,debug}
def installed_failure(~Out:Type,done:App4() -> Out,failed:App3() -> Out,schema:Schema.Schema<F.S,F.Store(),F.Resources()>,owners:Owners3(),recipe:Recipe.Recipe<F.World(),Rows3(),observe3()>,debug:Bool,result:FailureReader.Registration<F.S,F.Store(),F.Resources(),Events.Events(),Events.Metadata(),Array<U32>,Owner4()>) -> Out:
  match result:
    case FailureReader.RegistrationFailed{runtime}:failed(App.Application{schema,runtime,owners,recipe,debug})
    case FailureReader.Registered{Route.Runtime{world,family,tick},owner}:done(added_failure(schema,family,tick,FailureReader.append(~F.S,~F.Store(),~F.Resources(),~Events.Events(),~Array<U32>,~Unit,~(Array<U32> & List<&2,Read.KeyReading<F.S,F.Events()>>),~Operations.runner,~Owners3(),~Rows3(),~observe3(),~fold3(),owner,Build.Registered{world,owners,recipe,debug})))
def install4(~Out:Type,done:App4() -> Out,failed:App3() -> Out,value:App3()) -> Out:
  match value:
    case App.Application{schema,runtime,owners,recipe,debug}:installed_failure(~Out,done,failed,schema,owners,recipe,debug,FailureReader.register(~F.S,~F.Store(),~F.Resources(),~Events.Events(),~Array<U32>,~Unit,~(Array<U32> & List<&2,Read.KeyReading<F.S,F.Events()>>),~Operations.runner,~Events.Metadata(),~Array<U32>,runtime,F.parent(),"ParentFailures"))

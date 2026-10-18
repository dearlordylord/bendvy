import Base
import ../../../../../../../../src/ecs/ordinary-declaration.bend as Identity
import ../../../../../../../../src/ecs/ordinary-app-execution-recipe.bend as Exec
import ../../../../../../../../src/ecs/ordinary-app-run.bend as Entry
import ../../../../../../../../src/ecs/ordinary-app-service-registration.bend as Service
import ../../../../../../../../src/ecs/ordinary-service-declaration.bend as ServiceDecl
import ../../../../../../../../src/ecs/captured-schedule-composition.bend as Choice
import ../../../../../../../../src/ecs/execution-context.bend as Ctx
import ../../../../../../../../src/ecs/ordinary-app-execution.bend as Execution
import ../../../../../../../../src/ecs/schema-fragments.bend as Fragment
import other-schema.bend as S
import ../../../../../../../../examples/scheduled-health/components.bend as D
import ../../../../../../../../examples/scheduled-health/system.bend as Decay
import ../../../../../../../../src/ecs/ordinary-query-observable.bend as Obs
import ../../../../../../../../src/ecs/ordinary-component-binding.bend as Binding
import ../../../../../../../../src/ecs/ordinary-app-component.bend as Component
import ../../../../../../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../../../../../../src/ecs/ordinary-app-records.bend as Leaf
import ../../../../../../../../src/ecs/ordinary-app-recipe.bend as Tree
import ../../../../../../../../src/ecs/ordinary-app-observation.bend as Leaves
import ../../../../../../../../src/ecs/ordinary-app-observation-data.bend as DTO
import ../../../../../../../../src/ecs/ordinary-app-schema.bend as App
import ../../../../../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../../../../../src/ecs/ordinary-app-schedule.bend as Schedule
import ../../../../../../../../src/ecs/ordinary-app-registration-fields.bend as Fields
import ../../../../../../../../src/ecs/ordinary-app-registration-run.bend as Run
import ../../../../../../../../src/ecs/ordinary-system.bend as Ordinary
import ../../../../../../../../src/ecs/inspector-query-projection.bend as P
import ../../../../../../../../src/ecs/inspector-query.bend as IQ
import ../../../../../../../../src/ecs/inspector.bend as I
import ../../../../../../../../src/ecs/compose.bend as Q
import ../../../../../../../../src/ecs/capabilities.bend as Cap
import ../../../../../../../../src/ecs/component.bend as C
import ../../../../../../../../src/ecs/column.bend as Col
import ../../../../../../../../src/ecs/world.bend as W
import ../../../../../../../../src/ecs/system.bend as Sys
import ../../../../../../../../src/ecs/schedule-provision.bend as SP
import ../../../../../../../../src/ecs/schedule.bend as Sch

def Frame() -> Type:Q.Frame<S.Schema,S.Store,S.Resources,Unit>
def HealthId() -> Identity.Declaration<S.Schema,D.Health>:Identity.component(~S.Schema,~D.Health,"health")
def DecayId() -> Identity.Declaration<S.Schema,D.HealthDecay>:Identity.component(~S.Schema,~D.HealthDecay,"decay")
def health_binding() -> Binding.Binding<S.Schema,S.Store,Col.Column<S.Schema,D.HealthDecay>,D.Health,D.Health,S.HealthToken,S.take_health,S.put_health,S.project_health>:
  Binding.bind(~S.Schema,~S.Store,~Col.Column<S.Schema,D.HealthDecay>,~D.Health,~D.Health,~S.HealthToken,~S.take_health,~S.put_health,~S.project_health,HealthId())
def decay_binding() -> Binding.Binding<S.Schema,S.Store,Col.Column<S.Schema,D.Health>,D.HealthDecay,D.HealthDecay,S.HealthDecayToken,S.take_decay,S.put_decay,S.project_decay>:
  Binding.bind(~S.Schema,~S.Store,~Col.Column<S.Schema,D.Health>,~D.HealthDecay,~D.HealthDecay,~S.HealthDecayToken,~S.take_decay,~S.put_decay,~S.project_decay,DecayId())
def Value() -> Data:P.Product<C.Access<D.Health>,C.Access<D.HealthDecay>>
def query() -> Obs.Declaration<S.Schema,Frame(),Decay.PairOps(Frame()),I.Frame<S.Schema,S.Store,S.Resources,Unit>,Value()>:
  Obs.pair(~S.Schema,~Frame(),~Cap.Write<Frame(),D.Health,D.Health>,~Cap.Read<Frame(),D.HealthDecay>,~I.Frame<S.Schema,S.Store,S.Resources,Unit>,~C.Access<D.Health>,~C.Access<D.HealthDecay>,~Obs.write(~S.Schema,~S.Store,~Col.Column<S.Schema,D.HealthDecay>,~D.Health,~D.Health,~S.HealthToken,~S.take_health,~S.put_health,~S.project_health,~S.Resources,~Unit,~health_binding()),~Obs.read(~S.Schema,~S.Store,~Col.Column<S.Schema,D.Health>,~D.HealthDecay,~D.HealthDecay,~S.HealthDecayToken,~S.take_decay,~S.put_decay,~S.project_decay,~S.Resources,~Unit,~decay_binding()))
def render(value:Value()) -> String:
  match value:
    case P.Product{C.Found{D.Health{h}},C.Found{D.HealthDecay{d}}}:F32.show(h) ++ "/" ++ F32.show(d)
    case _:"missing"
def First() -> Type:Component.Application(~S.Schema,~S.Store,~S.Resources,~Unit,~Unit,~Unit,~Build.empty_observe(~S.World()),~Leaf.empty(~S.Schema),~Unit,~Exec.empty_plan(~S.Schema),~Exec.empty_dispatch(~S.World()),~Exec.empty_provide(~S.Schema,~S.World()),~Decay.PairOps,~Unit,~Decay.Error,~D.Health,~Value(),~query(),~Decay.decay_body,~render)
def FirstOwner() -> Type:Component.execution_owners(~S.Schema,~S.Store,~S.Resources,~Unit,~Unit,~Unit,~Build.empty_observe(~S.World()),~Leaf.empty(~S.Schema),~Unit,~Exec.empty_plan(~S.Schema),~Exec.empty_dispatch(~S.World()),~Exec.empty_provide(~S.Schema,~S.World()),~Decay.PairOps,~Unit,~Decay.Error,~D.Health,~Value(),~query(),~Decay.decay_body,~render)
def FirstRows() -> Data:Component.execution_rows(~S.Schema,~S.Store,~S.Resources,~Unit,~Unit,~Unit,~Build.empty_observe(~S.World()),~Leaf.empty(~S.Schema),~Unit,~Exec.empty_plan(~S.Schema),~Exec.empty_dispatch(~S.World()),~Exec.empty_provide(~S.Schema,~S.World()),~Decay.PairOps,~Unit,~Decay.Error,~D.Health,~Value(),~query(),~Decay.decay_body,~render)
def first_observe() -> S.World() -> S.World() & DTO.Observation<FirstRows()>:Component.execution_observe(~S.Schema,~S.Store,~S.Resources,~Unit,~Unit,~Unit,~Build.empty_observe(~S.World()),~Leaf.empty(~S.Schema),~Unit,~Exec.empty_plan(~S.Schema),~Exec.empty_dispatch(~S.World()),~Exec.empty_provide(~S.Schema,~S.World()),~Decay.PairOps,~Unit,~Decay.Error,~D.Health,~Value(),~query(),~Decay.decay_body,~render)
def first_fold() -> FirstOwner() -> FirstOwner() & List<&2,Fields.Fields<S.Schema>>:Component.execution_fold(~S.Schema,~S.Store,~S.Resources,~Unit,~Unit,~Unit,~Build.empty_observe(~S.World()),~Leaf.empty(~S.Schema),~Unit,~Exec.empty_plan(~S.Schema),~Exec.empty_dispatch(~S.World()),~Exec.empty_provide(~S.Schema,~S.World()),~Decay.PairOps,~Unit,~Decay.Error,~D.Health,~Value(),~query(),~Decay.decay_body,~render)
def first_plan() -> FirstOwner() -> FirstOwner() & SP.Plan<S.Schema>:Component.execution_plan(~S.Schema,~S.Store,~S.Resources,~Unit,~Unit,~Unit,~Build.empty_observe(~S.World()),~Leaf.empty(~S.Schema),~Unit,~Exec.empty_plan(~S.Schema),~Exec.empty_dispatch(~S.World()),~Exec.empty_provide(~S.Schema,~S.World()),~Decay.PairOps,~Unit,~Decay.Error,~D.Health,~Value(),~query(),~Decay.decay_body,~render)
def FirstError() -> Data:Choice.Choice<Unit,Component.ExecutionError<Decay.Error>>
def first_dispatch() -> FirstOwner() -> Ctx.Context<S.World()> -> U32 -> FirstOwner() & Sys.Outcome<Ctx.Context<S.World()>,FirstError(),Unit>:Component.execution_dispatch(~S.Schema,~S.Store,~S.Resources,~Unit,~Unit,~Unit,~Build.empty_observe(~S.World()),~Leaf.empty(~S.Schema),~Unit,~Exec.empty_plan(~S.Schema),~Exec.empty_dispatch(~S.World()),~Exec.empty_provide(~S.Schema,~S.World()),~Decay.PairOps,~Unit,~Decay.Error,~D.Health,~Value(),~query(),~Decay.decay_body,~render)
def first_provide() -> S.World() -> S.World() & List<&2,SP.Requirement<S.Schema>>:Component.execution_provide(~S.Schema,~S.Store,~S.Resources,~Unit,~Unit,~Unit,~Build.empty_observe(~S.World()),~Leaf.empty(~S.Schema),~Unit,~Exec.empty_plan(~S.Schema),~Exec.empty_dispatch(~S.World()),~Exec.empty_provide(~S.Schema,~S.World()),~Decay.PairOps,~Unit,~Decay.Error,~D.Health,~Value(),~query(),~Decay.decay_body,~render)
def scan() -> S.World() -> S.World() & List<&2,ServiceDecl.Status<S.Schema>>:ServiceDecl.world_observed(~S.Schema,~S.Store,~S.Resources,~Unit,~Array<U32>,~Unit,~S.take_counter,~S.put_counter,~S.increment,S.counter())
def Registered() -> Type:Service.Executable(~S.Schema,~S.Store,~S.Resources,~Unit,~Array<U32>,~Unit,~S.take_counter,~S.put_counter,~S.increment,~S.counter(),~scan(),~FirstOwner(),~FirstRows(),~first_observe(),~first_fold(),~FirstError(),~first_plan(),~first_dispatch(),~first_provide())
def Owners() -> Type:Service.execution_owners(~S.Schema,~S.Store,~S.Resources,~Unit,~Array<U32>,~Unit,~S.take_counter,~S.put_counter,~S.increment,~S.counter(),~scan(),~FirstOwner(),~FirstRows(),~first_observe(),~first_fold(),~FirstError(),~first_plan(),~first_dispatch(),~first_provide())
def Rows() -> Data:Service.execution_rows(~S.Schema,~S.Store,~S.Resources,~Unit,~Array<U32>,~Unit,~S.take_counter,~S.put_counter,~S.increment,~S.counter(),~scan(),~FirstOwner(),~FirstRows(),~first_observe(),~first_fold(),~FirstError(),~first_plan(),~first_dispatch(),~first_provide())
def Error() -> Data:Choice.Choice<FirstError(),Unit>
def observer() -> S.World() -> S.World() & DTO.Observation<Rows()>:Service.execution_observe(~S.Schema,~S.Store,~S.Resources,~Unit,~Array<U32>,~Unit,~S.take_counter,~S.put_counter,~S.increment,~S.counter(),~scan(),~FirstOwner(),~FirstRows(),~first_observe(),~first_fold(),~FirstError(),~first_plan(),~first_dispatch(),~first_provide())
def folder() -> Owners() -> Owners() & List<&2,Fields.Fields<S.Schema>>:Service.execution_fold(~S.Schema,~S.Store,~S.Resources,~Unit,~Array<U32>,~Unit,~S.take_counter,~S.put_counter,~S.increment,~S.counter(),~scan(),~FirstOwner(),~FirstRows(),~first_observe(),~first_fold(),~FirstError(),~first_plan(),~first_dispatch(),~first_provide())
def plan() -> Owners() -> Owners() & SP.Plan<S.Schema>:Service.composed_plan(~S.Schema,~S.Store,~S.Resources,~Unit,~Array<U32>,~Unit,~S.take_counter,~S.put_counter,~S.increment,~S.counter(),~scan(),~FirstOwner(),~FirstRows(),~first_observe(),~first_fold(),~FirstError(),~first_plan(),~first_dispatch(),~first_provide())
def dispatch() -> Owners() -> Ctx.Context<S.World()> -> U32 -> Owners() & Sys.Outcome<Ctx.Context<S.World()>,Error(),Unit>:Service.execution_dispatch(~S.Schema,~S.Store,~S.Resources,~Unit,~Array<U32>,~Unit,~S.take_counter,~S.put_counter,~S.increment,~S.counter(),~scan(),~FirstOwner(),~FirstRows(),~first_observe(),~first_fold(),~FirstError(),~first_plan(),~first_dispatch(),~first_provide())
def provide() -> S.World() -> S.World() & List<&2,SP.Requirement<S.Schema>>:Service.execution_provide(~S.Schema,~S.Store,~S.Resources,~Unit,~Array<U32>,~Unit,~S.take_counter,~S.put_counter,~S.increment,~S.counter(),~scan(),~FirstOwner(),~FirstRows(),~first_observe(),~first_fold(),~FirstError(),~first_plan(),~first_dispatch(),~first_provide())
def Scheduled() -> Type:Entry.Application<S.Schema,S.Store,S.Resources,Unit,Owners(),Rows(),observer(),folder(),Error(),plan(),dispatch(),provide()>
def run(app:Scheduled()) -> Execution.Run<Scheduled(),S.Schema,Error()>:Entry.run(~S.Schema,~S.Store,~S.Resources,~Unit,~Owners(),~Rows(),~observer(),~folder(),~Error(),~plan(),~dispatch(),~provide(),app)
def snapshot(app:Scheduled()) -> Scheduled() & Maybe<&2,Schedule.Description<S.Schema,Rows()>>:Entry.snapshot(~S.Schema,~S.Store,~S.Resources,~Unit,~Owners(),~Rows(),~observer(),~folder(),~Error(),~plan(),~dispatch(),~provide(),app)
def enabled(app:Scheduled()) -> Scheduled():Entry.enabled(~S.Schema,~S.Store,~S.Resources,~Unit,~Owners(),~Rows(),~observer(),~folder(),~Error(),~plan(),~dispatch(),~provide(),app,True{})
def attach(app:Registered(),barrier:Bool) -> Schedule.Attachment<Registered(),Scheduled()>:Entry.attach(~S.Schema,~S.Store,~S.Resources,~Unit,~Owners(),~Rows(),~observer(),~folder(),~Error(),~plan(),~dispatch(),~provide(),Schema.Schema{List.append(&2,Fragment.Entry<S.Schema>,Schema.entries(~S.Schema,~Col.Column<S.Schema,D.Health>,~Unit,Schema.component(~S.Schema,~D.Health,HealthId())),List.append(&2,Fragment.Entry<S.Schema>,Schema.entries(~S.Schema,~Col.Column<S.Schema,D.HealthDecay>,~Unit,Schema.component(~S.Schema,~D.HealthDecay,DecayId())),[ServiceDecl.entry(~S.Schema,~S.Resources,~Array<U32>,~Unit,~S.take_counter,~S.put_counter,~S.increment,S.counter())]))},app,"Health simulation",barrier)
def replan(app:Scheduled()) -> Schedule.Attachment<Registered(),Scheduled()>:Entry.replan(~S.Schema,~S.Store,~S.Resources,~Unit,~Owners(),~Rows(),~observer(),~folder(),~Error(),~plan(),~dispatch(),~provide(),app,"Health simulation",True{})
def service_added(~Output:Type,done:Registered() -> Output,failed:First() -> Output,app:First()) -> Output:Service.add(~S.Schema,~S.Store,~S.Resources,~Unit,~Array<U32>,~Unit,~S.take_counter,~S.put_counter,~S.increment,~S.counter(),~scan(),~FirstOwner(),~FirstRows(),~first_observe(),~first_fold(),~FirstError(),~first_plan(),~first_dispatch(),~first_provide(),~Output,done,failed,ServiceDecl.single(~S.Schema,~S.Store,~S.Resources,~Unit,~Array<U32>,~Unit,~S.take_counter,~S.put_counter,~S.increment,~S.counter()),"Count service",app)
def component_added(~Output:Type,done:First() -> Output,failed:Exec.Registered<S.Schema,S.World(),Unit,Unit,Build.empty_observe(~S.World()),Leaf.empty(~S.Schema),Unit,Exec.empty_plan(~S.Schema),Exec.empty_dispatch(~S.World()),Exec.empty_provide(~S.Schema,~S.World())> -> Output,world:S.World()) -> Output:Component.add(~S.Schema,~S.Store,~S.Resources,~Unit,~Unit,~Unit,~Build.empty_observe(~S.World()),~Leaf.empty(~S.Schema),~Unit,~Exec.empty_plan(~S.Schema),~Exec.empty_dispatch(~S.World()),~Exec.empty_provide(~S.Schema,~S.World()),~Decay.PairOps,~Unit,~Decay.Error,~D.Health,~Value(),~query(),~Decay.decay_body,~render,~Output,done,failed,Exec.empty(~S.Schema,~S.World(),world),Unit{},"Health decay","decay")
def counter_read(world:S.World(),result:Array<U32> & U32) -> S.World() & String:
  match world:
    case W.World{namespace,allocator,store,_,events,pending,registrations,nextSystemId,clock}:
      match result:
        case (owner,value):(W.World{namespace,allocator,store,S.Resources{ServiceDecl.Ready{owner}},events,pending,registrations,nextSystemId,clock},"service=" ++ U32.show(value))
def counter_world(world:S.World()) -> S.World() & String:
  match world:
    case W.World{namespace,allocator,store,S.Resources{ServiceDecl.Ready{owner}},events,pending,registrations,nextSystemId,clock}:
      counter_read(W.World{namespace,allocator,store,S.Resources{ServiceDecl.Missing{}},events,pending,registrations,nextSystemId,clock},Array.get(U32,owner,0))
    case world:(world,"ERROR: missing counter")
def counter(app:Scheduled()) -> Scheduled() & String:Entry.inspect(~S.Schema,~S.Store,~S.Resources,~Unit,~Owners(),~Rows(),~observer(),~folder(),~Error(),~plan(),~dispatch(),~provide(),~String,~counter_world,app)

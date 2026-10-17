import Base
import failure-body.bend as Failure
import ../../../examples/scheduled-health/application.bend as Original
import ../../../src/ecs/schema-fragments.bend as Fragment
import ../../../examples/scheduled-health/schema.bend as S
import ../../../examples/scheduled-health/components.bend as D
import ../../../examples/scheduled-health/system.bend as Decay
import ../../../src/ecs/ordinary-query-observable.bend as Obs
import ../../../src/ecs/ordinary-component-binding.bend as Binding
import ../../../src/ecs/ordinary-app-component.bend as Component
import ../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../src/ecs/ordinary-app-records.bend as Leaf
import ../../../src/ecs/ordinary-app-recipe.bend as Tree
import ../../../src/ecs/ordinary-app-observation.bend as Leaves
import ../../../src/ecs/ordinary-app-observation-data.bend as DTO
import ../../../src/ecs/ordinary-app-schema.bend as App
import ../../../src/ecs/ordinary-schema.bend as Schema
import ../../../src/ecs/ordinary-app-schedule.bend as Schedule
import ../../../src/ecs/ordinary-app-registration-fields.bend as Fields
import ../../../src/ecs/ordinary-app-registration-run.bend as Run
import ../../../src/ecs/ordinary-system.bend as Ordinary
import ../../../src/ecs/inspector-query-projection.bend as P
import ../../../src/ecs/inspector-query.bend as IQ
import ../../../src/ecs/inspector.bend as I
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/component.bend as C
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/schedule-provision.bend as SP
import ../../../src/ecs/schedule.bend as Sch

def health_binding() -> Binding.Binding<S.Schema,S.Store,Col.Column<S.Schema,D.HealthDecay>,D.Health,D.Health,S.HealthToken,S.take_health,S.put_health,S.project_health>:
  Binding.bind(~S.Schema,~S.Store,~Col.Column<S.Schema,D.HealthDecay>,~D.Health,~D.Health,~S.HealthToken,~S.take_health,~S.put_health,~S.project_health,Decay.HealthId())
def decay_binding() -> Binding.Binding<S.Schema,S.Store,Col.Column<S.Schema,D.Health>,D.HealthDecay,D.HealthDecay,S.HealthDecayToken,S.take_decay,S.put_decay,S.project_decay>:
  Binding.bind(~S.Schema,~S.Store,~Col.Column<S.Schema,D.Health>,~D.HealthDecay,~D.HealthDecay,~S.HealthDecayToken,~S.take_decay,~S.put_decay,~S.project_decay,Decay.DecayId())
def Value() -> Data:P.Product<C.Access<D.Health>,C.Access<D.HealthDecay>>
def query() -> Obs.Declaration<S.Schema,Decay.Frame(),Decay.PairOps(Decay.Frame()),I.Frame<S.Schema,S.Store,Unit,Unit>,Value()>:
  Obs.pair(~S.Schema,~Decay.Frame(),~Cap.Write<Decay.Frame(),D.Health,D.Health>,~Cap.Read<Decay.Frame(),D.HealthDecay>,~I.Frame<S.Schema,S.Store,Unit,Unit>,~C.Access<D.Health>,~C.Access<D.HealthDecay>,~Obs.write(~S.Schema,~S.Store,~Col.Column<S.Schema,D.HealthDecay>,~D.Health,~D.Health,~S.HealthToken,~S.take_health,~S.put_health,~S.project_health,~Unit,~Unit,~health_binding()),~Obs.read(~S.Schema,~S.Store,~Col.Column<S.Schema,D.Health>,~D.HealthDecay,~D.HealthDecay,~S.HealthDecayToken,~S.take_decay,~S.put_decay,~S.project_decay,~Unit,~Unit,~decay_binding()))
def render(value:Value()) -> String:
  match value:
    case P.Product{C.Found{D.Health{h}},C.Found{D.HealthDecay{d}}}:F32.show(h) ++ "/" ++ F32.show(d)
    case _:"missing"
def runner() -> S.World() -> (Unit & U32) -> Sys.Outcome<S.World(),Q.Error<Decay.Error>,List<&2,D.Health>>:Ordinary.observable_runner(~S.Schema,~S.Store,~Unit,~Unit,~Decay.PairOps,~Unit,~Decay.Error,~D.Health,~Value(),~query(),~Failure.body)
def Registry() -> Type:Sys.Registry<S.Schema,S.Store,Unit,Unit,Unit & U32,Q.Error<Decay.Error>,List<&2,D.Health>,runner()>
def Record() -> Type:Leaf.Record<S.Schema,Fields.Token<Registry()>>
def Owners() -> Type:Unit & Record()
def LeafRows() -> Data:DTO.Product<Unit,List<&2,IQ.ProjectedRow<S.Schema,Value()>>>
def Rows() -> Data:DTO.Product<Unit,LeafRows()>
def observer() -> S.World() -> S.World() & DTO.Observation<Rows()>:Tree.observe_pair(~S.World(),~Unit,~LeafRows(),~Build.empty_observe(~S.World()),~Leaves.component_observe(~S.Schema,~S.Store,~Unit,~Unit,~Decay.PairOps,~Value(),~query(),~render))
def folder() -> Owners() -> Owners() & List<&2,Fields.Fields<S.Schema>>:Leaf.fold_pair(~S.Schema,~Unit,~Record(),~Leaf.empty(~S.Schema),~Leaf.observed(~S.Schema,~Fields.Token<Registry()>))
def Registered() -> Type:Build.Registered<S.Schema,S.World(),Owners(),Rows(),observer(),folder()>
def Application() -> Type:App.Application<S.Schema,S.Store,Unit,Unit,Owners(),Rows(),observer(),folder()>
def Scheduled() -> Type:Schedule.Application<S.Schema,S.Store,Unit,Unit,Owners(),Rows(),observer(),folder()>

def schema() -> Schema.Schema<S.Schema,S.Store,Unit>:
  Schema.Schema{List.append(&2,Fragment.Entry<S.Schema>,Schema.entries(~S.Schema,~Col.Column<S.Schema,D.Health>,~Unit,Schema.component(~S.Schema,~D.Health,Decay.HealthId())),Schema.entries(~S.Schema,~Col.Column<S.Schema,D.HealthDecay>,~Unit,Schema.component(~S.Schema,~D.HealthDecay,Decay.DecayId())))}

type Creation is Type:
  Created{app:Application()}
  Refused{world:S.World()}
def created(value:Registered()) -> Creation:Created{App.attached(~S.Schema,~S.Store,~Unit,~Unit,~Owners(),~Rows(),~observer(),~folder(),schema(),value)}
def registration_failed(value:Build.Registered<S.Schema,S.World(),Unit,Unit,Build.empty_observe(~S.World()),Leaf.empty(~S.Schema)>) -> Creation:
  match value:
    case Build.Registered{world,_,_,_}:Refused{world}
def create(world:S.World()) -> Creation:
  Component.register(~S.Schema,~S.Store,~Unit,~Unit,~Unit,~Unit,~Build.empty_observe(~S.World()),~Leaf.empty(~S.Schema),~Decay.PairOps,~Unit,~Decay.Error,~D.Health,~Value(),~query(),~render,~Failure.body,~Creation,created,registration_failed,Build.empty(~S.Schema,~S.World(),world),"Health decay","decay")

def last_record(value:Owners()) -> Unit & Record():value
def identify(record:Record()) -> Record() & U32:
  match record:
    case Leaf.Record{token,Fields.Fields{+ns,+id,+name,+access,+cursor,+slot,+clauses,+kind}}:(Leaf.Record{token,Fields.Fields{ns,id,name,access,cursor,slot,clauses,kind}},id)
def plan(barrier:Bool,id:U32) -> SP.Plan<S.Schema>:
  match barrier:
    case False{}:SP.Entry{Sch.System{id,0},[]}
    case True{}:SP.Sequence{SP.Entry{Sch.Barrier{},[]},SP.Entry{Sch.System{id,0},[]}}
def attach_identified(schema:Schema.Schema<S.Schema,S.Store,Unit>,world:S.World(),recipe:Tree.Recipe<S.World(),Rows(),observer()>,debug:Bool,prior:Unit,barrier:Bool,value:Record() & U32) -> Schedule.Attachment<Application(),Scheduled()>:
  match value:
    case (record,id):Schedule.attach(~S.Schema,~S.Store,~Unit,~Unit,~Owners(),~Rows(),~observer(),~folder(),App.Application{schema,Build.Registered{world,(prior,record),recipe,debug}},"Health simulation",plan(barrier,id))
def attach(barrier:Bool,app:Application()) -> Schedule.Attachment<Application(),Scheduled()>:
  match app:
    case App.Application{schema,Build.Registered{world,(prior,record),recipe,debug}}:attach_identified(schema,world,recipe,debug,prior,barrier,identify(record))
type Error is Data:
  BodyError{error:Q.Error<Decay.Error>}
  RegistrationRejected{}
def dispatched(prior:Unit,value:Run.TransportResult<S.Schema,S.World(),Unit & U32,Q.Error<Decay.Error>,List<&2,D.Health>,Fields.Token<Registry()>>) -> Owners() & Sys.Outcome<S.World(),Error,Unit>:
  match value:
    case Run.Completed{token,fields,Sys.Succeeded{world,_}}:((prior,Leaf.Record{token,fields}),Sys.Succeeded{world,Unit{}})
    case Run.Completed{token,fields,Sys.Failed{world,error}}:((prior,Leaf.Record{token,fields}),Sys.Failed{world,BodyError{error}})
    case Run.RegistrationRejected{token,fields,world,_}:((prior,Leaf.Record{token,fields}),Sys.Failed{world,RegistrationRejected{}})
def cursor(fields:Fields.Fields<S.Schema>) -> U32:
  match fields:
    case Fields.Fields{_,_,_,_,cursor,_,_,_}:cursor
def dispatch(owners:Owners(),world:S.World(),_:U32) -> Owners() & Sys.Outcome<S.World(),Error,Unit>:
  match owners:
    case (prior,Leaf.Record{token,+fields}):dispatched(prior,Run.run(~S.Schema,~S.Store,~Unit,~Unit,~(Unit & U32),~Q.Error<Decay.Error>,~List<&2,D.Health>,~runner(),token,fields,world,(Unit{},cursor(fields))))
def condition(world:S.World(),_:U32) -> S.World() & Bool:(world,True{})
def provision(world:S.World()) -> S.World() & List<&2,SP.Requirement<S.Schema>>:(world,[])
def run(app:Scheduled()) -> Schedule.RunResult<Scheduled(),S.Schema,Error>:Schedule.run(~S.Schema,~S.Store,~Unit,~Unit,~Owners(),~Rows(),~observer(),~folder(),~Error,~dispatch,~condition,~provision,app)

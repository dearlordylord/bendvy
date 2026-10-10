import Base
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-relation.bend as Relation
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule.bend as Scheduled
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Fields
import /workspace/formal-proofs/bendvy/src/ecs/relation-failure-reader.bend as Ord
import ./registered.bend as Registered

def graph_schema(~S:Data,~C:Type,~R:Type,schema:Schema.Schema<S,C,R>) -> Schema.Schema<S,A.Store<S,C>,R>:
  match schema:
    case Schema.Schema{entries}:Schema.Schema{entries}
def Application(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~target:W.Handle<S>) -> Type:
  Scheduled.Application<S,A.Store<S,C>,R,A.Notice<S,E>,Registered.Owner(~S,~C,~R,~E,~declaration,~target),Relation.View<S>,Relation.observe(~S,~C,~R,~E,~declaration,~Relation.builtin_row(~S)),Registered.empty_fold(~S,~C,~R,~E,~declaration,~target)>
def Recipe(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~target:W.Handle<S>) -> Type:
  Tree.Recipe<Relation.World(~S,~C,~R,~E),Relation.View<S>,Relation.observe(~S,~C,~R,~E,~declaration,~Relation.builtin_row(~S))>
def selected_phase(allowed:Bool,current:String,later:String) -> String:
  match allowed:
    case True{}:current
    case False{}:later
def phase_for(steps:List<&2,Sch.Step>,+id:U32,+current:String) -> String:
  match steps:
    case []:current
    case Sch.Phase{name} <> rest:phase_for(rest,id,name)
    case Sch.Barrier{} <> rest:phase_for(rest,id,current)
    case Sch.System{candidate,_} <> rest:
      selected_phase(U32.is_eq(candidate,id),current,phase_for(rest,id,current))
def described(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~target:W.Handle<S>,plan:SP.Plan<S>,namespace:U32,name:String,steps:List<&2,Sch.Step>,needs:List<&2,SP.Requirement<S>>,schema:Schema.Schema<S,A.Store<S,C>,R>,world:Relation.World(~S,~C,~R,~E),recipe:Recipe(~S,~C,~R,~E,~declaration,~target),debug:Bool,description:Scheduled.Description<S,Relation.View<S>>,result:Registered.Owner(~S,~C,~R,~E,~declaration,~target) & DTO.Binding<S>) -> Application(~S,~C,~R,~E,~declaration,~target) & Maybe<&2,Scheduled.Description<S,Relation.View<S>>>:
  match description:
    case Scheduled.Description{App.Description{schemaEntries,DTO.Product{_,observation}},ns,label,planned}:
      match result:
        case (owners,binding):(Scheduled.Application{App.Application{schema,Build.Registered{world,owners,recipe,debug}},plan,namespace,name,steps,needs},Some{Scheduled.Description{App.Description{schemaEntries,DTO.Product{[binding],observation}},ns,label,planned}})
def snapshot_result(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~target:W.Handle<S>,result:Application(~S,~C,~R,~E,~declaration,~target) & Maybe<&2,Scheduled.Description<S,Relation.View<S>>>) -> Application(~S,~C,~R,~E,~declaration,~target) & Maybe<&2,Scheduled.Description<S,Relation.View<S>>>:
  match result:
    case (app,None{}):(app,None{})
    case (Scheduled.Application{App.Application{schema,Build.Registered{world,Sys.Registry{+ns,+id,+label,+access,+cursor},recipe,debug}},plan,namespace,name,+steps,needs},Some{description}):described(~S,~C,~R,~E,~declaration,~target,plan,namespace,name,steps,needs,schema,world,recipe,debug,description,Registered.binding(~S,~C,~R,~E,~declaration,~target,Sys.Registry{ns,id,label,access,cursor},phase_for(steps,id,"")))
def snapshot(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~target:W.Handle<S>,app:Application(~S,~C,~R,~E,~declaration,~target),flag:Bool) -> Application(~S,~C,~R,~E,~declaration,~target) & Maybe<&2,Scheduled.Description<S,Relation.View<S>>>:
  snapshot_result(~S,~C,~R,~E,~declaration,~target,Scheduled.snapshot(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,~Registered.Owner(~S,~C,~R,~E,~declaration,~target),~Relation.View<S>,~Relation.observe(~S,~C,~R,~E,~declaration,~Relation.builtin_row(~S)),~Registered.empty_fold(~S,~C,~R,~E,~declaration,~target),Scheduled.enabled(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,~Registered.Owner(~S,~C,~R,~E,~declaration,~target),~Relation.View<S>,~Relation.observe(~S,~C,~R,~E,~declaration,~Relation.builtin_row(~S)),~Registered.empty_fold(~S,~C,~R,~E,~declaration,~target),app,flag)))
def install(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~target:W.Handle<S>,schema:Schema.Schema<S,C,R>,world:Relation.World(~S,~C,~R,~E),name:String) -> Sys.RegistrationResult<S,A.Store<S,C>,R,A.Notice<S,E>,Unit,Unit,Unit,Registered.reader(~S,~C,~R,~E,~declaration,~target)>:
  Registered.register(~S,~C,~R,~E,~declaration,~target,world,name)
def attach_allowed(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~target:W.Handle<S>,schema:Schema.Schema<S,C,R>,owner:Registered.Owner(~S,~C,~R,~E,~declaration,~target),name:String,plan:SP.Plan<S>,result:Relation.World(~S,~C,~R,~E) & Bool) -> Scheduled.Attachment<App.Application<S,A.Store<S,C>,R,A.Notice<S,E>,Registered.Owner(~S,~C,~R,~E,~declaration,~target),Relation.View<S>,Relation.observe(~S,~C,~R,~E,~declaration,~Relation.builtin_row(~S)),Registered.empty_fold(~S,~C,~R,~E,~declaration,~target)>,Application(~S,~C,~R,~E,~declaration,~target)>:
  match result:
    case (world,allowed):
      match allowed:
        case False{}:Scheduled.Invalid{App.Application{graph_schema(~S,~C,~R,schema),Build.Registered{world,owner,Tree.Recipe{},False{}}}}
        case True{}:Scheduled.attach(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,~Registered.Owner(~S,~C,~R,~E,~declaration,~target),~Relation.View<S>,~Relation.observe(~S,~C,~R,~E,~declaration,~Relation.builtin_row(~S)),~Registered.empty_fold(~S,~C,~R,~E,~declaration,~target),App.Application{graph_schema(~S,~C,~R,schema),Build.Registered{world,owner,Tree.Recipe{},False{}}},name,plan)
def attach_namespace_checked(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~target:W.Handle<S>,schema:Schema.Schema<S,C,R>,name:String,plan:SP.Plan<S>,allowed:Bool,owner:Registered.Owner(~S,~C,~R,~E,~declaration,~target),world:Relation.World(~S,~C,~R,~E)) -> Scheduled.Attachment<App.Application<S,A.Store<S,C>,R,A.Notice<S,E>,Registered.Owner(~S,~C,~R,~E,~declaration,~target),Relation.View<S>,Relation.observe(~S,~C,~R,~E,~declaration,~Relation.builtin_row(~S)),Registered.empty_fold(~S,~C,~R,~E,~declaration,~target)>,Application(~S,~C,~R,~E,~declaration,~target)>:
  match allowed owner:
    case False{} owner:Scheduled.Invalid{App.Application{graph_schema(~S,~C,~R,schema),Build.Registered{world,owner,Tree.Recipe{},False{}}}}
    case True{} Sys.Registry{+namespace,+id,+label,+access,+cursor}:attach_allowed(~S,~C,~R,~E,~declaration,~target,schema,Sys.Registry{namespace,id,label,access,cursor},name,plan,W.registration_matches(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,world,id,label,access))
def attach_namespace(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~target:W.Handle<S>,schema:Schema.Schema<S,C,R>,name:String,plan:SP.Plan<S>,owner:Registered.Owner(~S,~C,~R,~E,~declaration,~target),result:Relation.World(~S,~C,~R,~E) & U32) -> Scheduled.Attachment<App.Application<S,A.Store<S,C>,R,A.Notice<S,E>,Registered.Owner(~S,~C,~R,~E,~declaration,~target),Relation.View<S>,Relation.observe(~S,~C,~R,~E,~declaration,~Relation.builtin_row(~S)),Registered.empty_fold(~S,~C,~R,~E,~declaration,~target)>,Application(~S,~C,~R,~E,~declaration,~target)>:
  match owner:
    case Sys.Registry{+namespace,id,label,access,cursor}:
      match result:
        case (world,actual):attach_namespace_checked(~S,~C,~R,~E,~declaration,~target,schema,name,plan,U32.is_eq(namespace,actual),Sys.Registry{namespace,id,label,access,cursor},world)
def attach(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~target:W.Handle<S>,schema:Schema.Schema<S,C,R>,owner:Registered.Owner(~S,~C,~R,~E,~declaration,~target),world:Relation.World(~S,~C,~R,~E),name:String,plan:SP.Plan<S>) -> Scheduled.Attachment<App.Application<S,A.Store<S,C>,R,A.Notice<S,E>,Registered.Owner(~S,~C,~R,~E,~declaration,~target),Relation.View<S>,Relation.observe(~S,~C,~R,~E,~declaration,~Relation.builtin_row(~S)),Registered.empty_fold(~S,~C,~R,~E,~declaration,~target)>,Application(~S,~C,~R,~E,~declaration,~target)>:
  attach_namespace(~S,~C,~R,~E,~declaration,~target,schema,name,plan,owner,W.namespace(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,world))
def run(~S:Data,~C:Type,~R:Type,~E:Data,~declaration:Ord.Declaration<S>,~target:W.Handle<S>,~condition:Relation.World(~S,~C,~R,~E) -> U32 -> Relation.World(~S,~C,~R,~E) & Bool,~provision:Relation.World(~S,~C,~R,~E) -> Relation.World(~S,~C,~R,~E) & List<&2,SP.Requirement<S>>,app:Application(~S,~C,~R,~E,~declaration,~target)) -> Scheduled.RunResult<Application(~S,~C,~R,~E,~declaration,~target),S,Maybe<&2,Unit>>:
  Scheduled.run(~S,~A.Store<S,C>,~R,~A.Notice<S,E>,~Registered.Owner(~S,~C,~R,~E,~declaration,~target),~Relation.View<S>,~Relation.observe(~S,~C,~R,~E,~declaration,~Relation.builtin_row(~S)),~Registered.empty_fold(~S,~C,~R,~E,~declaration,~target),~Maybe<&2,Unit>,~Registered.dispatch(~S,~C,~R,~E,~declaration,~target),~condition,~provision,app)

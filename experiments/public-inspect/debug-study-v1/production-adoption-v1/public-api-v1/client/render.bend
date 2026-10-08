import Base
import ../candidate/src/ecs/debug-metadata.bend as M
import ../candidate/src/ecs/debug-state-metadata.bend as State
import ../candidate/src/ecs/debug-description.bend as D
import ./render-fixture.bend as R
# Closed ASCII correctness fixture renderer, not published JSON serializer.
def boolean(value:Bool) -> String:
  match value:
    case True{}:"true"
    case False{}:"false"
def storage(value:M.Storage) -> String:
  match value:
    case M.Plain{}:R.quote("plain")
    case M.Constructed{}:R.quote("constructed")
    case M.Transient{}:R.quote("transient")
def component(value:M.Component) -> String:
  match value:
    case M.Component{v_name,v_storage}:String.join(["{\"name\":",R.quote(v_name),",\"storage\":",storage(v_storage),"}"],"")
def components(values:List<&2,M.Component>) -> List<&2,String>:
  match values:
    case []:[]
    case head<>tail:component(head)<>components(tail)
def resource(value:M.Resource) -> String:
  match value:
    case M.Resource{v_name,v_storage,v_present}:String.join(["{\"name\":",R.quote(v_name),",\"storage\":",storage(v_storage),",\"present\":",boolean(v_present),"}"],"")
def resources(values:List<&2,M.Resource>) -> List<&2,String>:
  match values:
    case []:[]
    case head<>tail:resource(head)<>resources(tail)
def event(value:D.DebugEvent) -> String:
  match value:
    case D.DebugEvent{v_name}:String.join(["{\"name\":",R.quote(v_name),"}"],"")
def events(values:List<&2,D.DebugEvent>) -> List<&2,String>:
  match values:
    case []:[]
    case head<>tail:event(head)<>events(tail)
def kind(value:M.RelationKind) -> String:
  match value:
    case M.Hierarchy{}:R.quote("hierarchy")
    case M.GeneralRelation{}:R.quote("relation")
def relation(value:M.Relation) -> String:
  match value:
    case M.Relation{v_name,v_relatedName,v_kind,v_linkedDespawn,v_ordered}:String.join(["{\"name\":",R.quote(v_name),",\"relatedName\":",R.quote(v_relatedName),",\"kind\":",kind(v_kind),",\"linkedDespawn\":",boolean(v_linkedDespawn),",\"ordered\":",boolean(v_ordered),"}"],"")
def relations(values:List<&2,M.Relation>) -> List<&2,String>:
  match values:
    case []:[]
    case head<>tail:relation(head)<>relations(tail)
def state(value:State.Value) -> String:
  match value:
    case State.Text{v_value}:String.join(["{\"kind\":",R.quote("Text"),",\"value\":",R.quote(v_value),"}"],"")
    case State.NumberBits{v_low,v_high,v_spelling}:String.join(["{\"kind\":",R.quote("NumberBits"),",\"low\":",U32.show(v_low),",\"high\":",U32.show(v_high),",\"spelling\":",R.quote(v_spelling),"}"],"")
def states(values:List<&2,State.Value>) -> List<&2,String>:
  match values:
    case []:[]
    case head<>tail:state(head)<>states(tail)
def current(value:Maybe<&2,State.Value>) -> String:
  match value:
    case None{}:String.join(["{\"kind\":",R.quote("None"),"}"],"")
    case Some{v_value}:String.join(["{\"kind\":",R.quote("Some"),",\"value\":",state(v_value),"}"],"")
def machine(value:State.Machine) -> String:
  match value:
    case State.Machine{v_name,v_states,v_current}:String.join(["{\"name\":",R.quote(v_name),",\"states\":",R.array(states(v_states)),",\"current\":",current(v_current),"}"],"")
def machines(values:List<&2,State.Machine>) -> List<&2,String>:
  match values:
    case []:[]
    case head<>tail:machine(head)<>machines(tail)
def service(value:M.Service) -> String:
  match value:
    case M.Service{v_name,v_provided}:String.join(["{\"name\":",R.quote(v_name),",\"provided\":",boolean(v_provided),"}"],"")
def services(values:List<&2,M.Service>) -> List<&2,String>:
  match values:
    case []:[]
    case head<>tail:service(head)<>services(tail)
def access(value:M.Access) -> String:
  match value:
    case M.Access{v_reads,v_writes}:String.join(["{\"reads\":",R.array(R.names(v_reads)),",\"writes\":",R.array(R.names(v_writes)),"}"],"")
def accesss(values:List<&2,M.Access>) -> List<&2,String>:
  match values:
    case []:[]
    case head<>tail:access(head)<>accesss(tail)
def machine_access(value:M.MachineAccess) -> String:
  match value:
    case M.MachineAccess{v_reads,v_next,v_transitions,v_transitionEvents}:String.join(["{\"reads\":",R.array(R.names(v_reads)),",\"next\":",R.array(R.names(v_next)),",\"transitions\":",R.array(R.names(v_transitions)),",\"transitionEvents\":",R.array(R.names(v_transitionEvents)),"}"],"")
def machine_accesss(values:List<&2,M.MachineAccess>) -> List<&2,String>:
  match values:
    case []:[]
    case head<>tail:machine_access(head)<>machine_accesss(tail)
def query(value:M.Query) -> String:
  match value:
    case M.Query{v_slot,v_reads,v_writes,v_optional,v_with,v_without,v_added,v_changed,v_relations}:String.join(["{\"slot\":",R.quote(v_slot),",\"reads\":",R.array(R.names(v_reads)),",\"writes\":",R.array(R.names(v_writes)),",\"optional\":",R.array(R.names(v_optional)),",\"with\":",R.array(R.names(v_with)),",\"without\":",R.array(R.names(v_without)),",\"added\":",R.array(R.names(v_added)),",\"changed\":",R.array(R.names(v_changed)),",\"relations\":",R.array(R.names(v_relations)),"}"],"")
def querys(values:List<&2,M.Query>) -> List<&2,String>:
  match values:
    case []:[]
    case head<>tail:query(head)<>querys(tail)
def system(value:M.System) -> String:
  match value:
    case M.System{v_name,v_placements,v_queries,v_resources,v_events,v_machines,v_removed,v_despawned,v_relationFailures,v_services,v_when}:String.join(["{\"name\":",R.quote(v_name),",\"placements\":",R.array(R.names(v_placements)),",\"queries\":",R.array(querys(v_queries)),",\"resources\":",access(v_resources),",\"events\":",access(v_events),",\"machines\":",machine_access(v_machines),",\"removed\":",R.array(R.names(v_removed)),",\"despawned\":",boolean(v_despawned),",\"relationFailures\":",R.array(R.names(v_relationFailures)),",\"services\":",R.array(R.names(v_services)),",\"when\":",R.array(R.names(v_when)),"}"],"")
def systems(values:List<&2,M.System>) -> List<&2,String>:
  match values:
    case []:[]
    case head<>tail:system(head)<>systems(tail)
def step(value:M.Step) -> String:
  match value:
    case M.Run{v_system}:String.join(["{\"kind\":",R.quote("system"),",\"system\":",R.quote(v_system),"}"],"")
    case M.ApplyDeferred{}:String.join(["{\"kind\":",R.quote("applyDeferred"),"}"],"")
    case M.ApplyStateTransitions{v_schedules}:String.join(["{\"kind\":",R.quote("applyStateTransitions"),",\"schedules\":",R.array(R.names(v_schedules)),"}"],"")
def steps(values:List<&2,M.Step>) -> List<&2,String>:
  match values:
    case []:[]
    case head<>tail:step(head)<>steps(tail)
def schedule(value:M.Schedule) -> String:
  match value:
    case M.Schedule{v_name,v_steps}:String.join(["{\"name\":",R.quote(v_name),",\"steps\":",R.array(steps(v_steps)),"}"],"")
def schedules(values:List<&2,M.Schedule>) -> List<&2,String>:
  match values:
    case []:[]
    case head<>tail:schedule(head)<>schedules(tail)
def lint(value:M.Lint) -> String:
  match value:
    case M.Lint{severity,code,message,subject}:String.join(["{\"severity\":",R.quote(R.severity(severity)),",\"code\":",R.quote(R.code(code)),",\"subject\":",R.quote(subject),",\"message\":",R.quote(message),"}"],"")
def lints(values:List<&2,M.Lint>) -> List<&2,String>:
  match values:
    case []:[]
    case head<>tail:lint(head)<>lints(tail)
def description(value:D.Description) -> String:
  match value:
    case D.Description{v_version,v_components,v_resources,v_events,v_relations,v_machines,v_services,v_schedules,v_systems,v_access,v_lints}:String.join(["{\"version\":",U32.show(v_version),",\"components\":",R.array(components(v_components)),",\"resources\":",R.array(resources(v_resources)),",\"events\":",R.array(events(v_events)),",\"relations\":",R.array(relations(v_relations)),",\"machines\":",R.array(machines(v_machines)),",\"services\":",R.array(services(v_services)),",\"schedules\":",R.array(schedules(v_schedules)),",\"systems\":",R.array(systems(v_systems)),",\"access\":",R.indexes(v_access),",\"lints\":",R.array(lints(v_lints)),"}"],"")

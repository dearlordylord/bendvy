import Base
import debug-metadata.bend as M
import debug-state-metadata.bend as State
import debug-services.bend as Services
import debug-index.bend as Index
import debug-lints.bend as Lints
# Typed detached Description output; no format publication/owner access here.
type DebugEvent is Data:
  DebugEvent{name:String}
type Description is Data:
  Description{version:U32,components:List<&2,M.Component>,resources:List<&2,M.Resource>,events:List<&2,DebugEvent>,relations:List<&2,M.Relation>,machines:List<&2,State.Machine>,services:List<&2,M.Service>,schedules:List<&2,M.Schedule>,systems:List<&2,M.System>,access:M.Indexes,lints:List<&2,M.Lint>}
def component_names(cs:List<&2,M.Component>) -> List<&2,String>:
  match cs:
    case []:[]
    case M.Component{name,storage}<>tail:name<>component_names(tail)
def resource_names(rs:List<&2,M.Resource>) -> List<&2,String>:
  match rs:
    case []:[]
    case M.Resource{name,storage,present}<>tail:name<>resource_names(tail)
def event_names(es:List<&2,DebugEvent>) -> List<&2,String>:
  match es:
    case []:[]
    case DebugEvent{name}<>tail:name<>event_names(tail)
def assembled(cs:List<&2,M.Component>,rs:List<&2,M.Resource>,es:List<&2,DebugEvent>,relations:List<&2,M.Relation>,machines:List<&2,State.Machine>,provided:List<&2,String>,schedules:List<&2,M.Schedule>,+systems:List<&2,M.System>,resolved:List<&2,M.ResolvedSchedule>,+access:M.Indexes) -> Description:
  Description{1,cs,rs,es,relations,machines,Services.describe(provided,systems),schedules,systems,access,Lints.assemble(resolved,systems,access)}
# Registry/provider supplies genuine observations and actual-identity placements.
# No inferred registration identity or arbitrary affine payload cloning.
def describe(+cs:List<&2,M.Component>,+rs:List<&2,M.Resource>,+es:List<&2,DebugEvent>,relations:List<&2,M.Relation>,machines:List<&2,State.Machine>,provided:List<&2,String>,schedules:List<&2,M.Schedule>,+systems:List<&2,M.System>,resolved:List<&2,M.ResolvedSchedule>) -> Description:
  assembled(cs,rs,es,relations,machines,provided,schedules,systems,resolved,Index.build(systems,M.Indexes{Index.blank(component_names(cs)),Index.blank(resource_names(rs)),Index.blank(event_names(es))}))

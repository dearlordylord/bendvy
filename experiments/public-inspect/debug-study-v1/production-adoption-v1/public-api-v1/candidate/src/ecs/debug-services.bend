import Base
import debug-metadata.bend as M
import debug-index.bend as I
# Detached static labels: no service value alias, invocation, or access grant.
def service_names(system:M.System) -> List<&2,String>:
  match system:
    case M.System{name,placements,queries,resources,events,machines,removed,despawned,relationFailures,services,when}:services
def declared_names(systems:List<&2,M.System>) -> List<&2,String>:
  match systems:
    case []:[]
    case head<>tail:List.append(&2,String,service_names(head),declared_names(tail))
def contains(names:List<&2,String>,+name:String) -> Bool:
  match names:
    case []:False{}
    case head<>tail:Bool.or(String.eq(head,name),contains(tail,name))
def dedup(names:List<&2,String>,output:List<&2,String>) -> List<&2,String>:
  match names:
    case []:output
    case head<>tail:dedup(tail,I.unique(head,output))
def entries(names:List<&2,String>,+provided:List<&2,String>) -> List<&2,M.Service>:
  match names:
    case []:[]
    case +head<>tail:M.Service{head,contains(provided,head)}<>entries(tail,provided)
def describe(+provided:List<&2,String>,systems:List<&2,M.System>) -> List<&2,M.Service>:
  entries(dedup(List.append(&2,String,provided,declared_names(systems)),[]),provided)

import Base
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as Provision
import ../metadata.bend as M
import ./owner-observation.bend as Owner
import ./render.bend as Render
# Closed schema nominal tokens. Names are projections, never lookup authority.
type Component is Data:
  Plain{}
  Constructed{}
  Transient{}
  Absent{}
type Resource is Data:
  RPlain{}
  RMissing{}
  RConstructed{}
  RTransient{}
type Service is Data:
  Clock{}
  HostOnly{}
  Missing{}
type Machine is Data:
  Text{}
  Numeric{}
type Query is Data:
  Query{slot:String,reads:List<&2,Component>,writes:List<&2,Component>,optional:List<&2,Component>,with:List<&2,Component>,without:List<&2,Component>,added:List<&2,Component>,changed:List<&2,Component>}
type Definition<-S:Data> is Data:
  Definition{name:String,queries:List<&2,Query>,readResources:List<&2,Resource>,writeResources:List<&2,Resource>,readMachines:List<&2,Machine>,nextMachines:List<&2,Machine>,removed:List<&2,Component>,despawned:Bool,relationFailures:List<&2,String>,services:List<&2,Service>}
def component_name(value:Component) -> String:
  match value:
    case Plain{}:"Plain"
    case Constructed{}:"Constructed"
    case Transient{}:"Transient"
    case Absent{}:"Absent"
def resource_name(value:Resource) -> String:
  match value:
    case RPlain{}:"RPlain"
    case RMissing{}:"RMissing"
    case RConstructed{}:"RConstructed"
    case RTransient{}:"RTransient"
def resource_id(value:Resource) -> U32:
  match value:
    case RPlain{}:1
    case RMissing{}:2
    case RConstructed{}:3
    case RTransient{}:4
def service_name(value:Service) -> String:
  match value:
    case Clock{}:"Clock"
    case HostOnly{}:"HostOnly"
    case Missing{}:"Missing"
def service_id(value:Service) -> U32:
  match value:
    case Clock{}:1
    case HostOnly{}:2
    case Missing{}:3
def machine_name(value:Machine) -> String:
  match value:
    case Text{}:"Text"
    case Numeric{}:"Numeric"
def component_names(values:List<&2,Component>) -> List<&2,String>:
  match values:
    case []:[]
    case head<>tail:component_name(head)<>component_names(tail)
def resource_names(values:List<&2,Resource>) -> List<&2,String>:
  match values:
    case []:[]
    case head<>tail:resource_name(head)<>resource_names(tail)
def service_names(values:List<&2,Service>) -> List<&2,String>:
  match values:
    case []:[]
    case head<>tail:service_name(head)<>service_names(tail)
def machine_names(values:List<&2,Machine>) -> List<&2,String>:
  match values:
    case []:[]
    case head<>tail:machine_name(head)<>machine_names(tail)
def query(value:Query) -> M.Query:
  match value:
    case Query{slot,reads,writes,optional,with,without,added,changed}:M.Query{slot,component_names(reads),component_names(writes),component_names(optional),component_names(with),component_names(without),component_names(added),component_names(changed),[]}
def queries(values:List<&2,Query>) -> List<&2,M.Query>:
  match values:
    case []:[]
    case head<>tail:query(head)<>queries(tail)
def metadata(~S:Data,value:Definition<S>,positions:List<&2,String>) -> M.System:
  match value:
    case Definition{name,qs,readResources,writeResources,readMachines,nextMachines,removed,despawned,failures,services}:M.System{name,positions,queries(qs),M.Access{resource_names(readResources),resource_names(writeResources)},M.Access{[],[]},M.MachineAccess{machine_names(readMachines),machine_names(nextMachines),[],[]},component_names(removed),despawned,failures,service_names(services),[]}
def resource_needs(~S:Data,values:List<&2,Resource>) -> List<&2,Provision.Requirement<S>>:
  match values:
    case []:[]
    case head<>tail:Provision.Resource{resource_id(head)}<>resource_needs(~S,tail)
def service_needs(~S:Data,values:List<&2,Service>) -> List<&2,Provision.Requirement<S>>:
  match values:
    case []:[]
    case head<>tail:Provision.Service{service_id(head)}<>service_needs(~S,tail)
# Pinned TS System collects resources, machines and services, not optional query
# component reads. Existing SP cannot represent machines: retain typed Slot
# declarations separately rather than inventing an SP machine/resource token.
def provision_needs(~S:Data,value:Definition<S>) -> List<&2,Provision.Requirement<S>>:
  match value:
    case Definition{_,_,rs,ws,_,_,_,_,_,services}:Provision.unique(~S,List.append(&2,Provision.Requirement<S>,service_needs(~S,services),List.append(&2,Provision.Requirement<S>,resource_needs(~S,rs),resource_needs(~S,ws))))
def registration_access(~S:Data,value:Definition<S>) -> List<&2,String>:
  [Render.system(metadata(~S,value,[]))]
def inspect() -> Definition<Owner.Schema>:
  Definition{"Inspect",[Query{"q",[Plain{}],[Constructed{}],[Transient{}],[Plain{}],[Absent{}],[Transient{}],[Constructed{}]}],[RPlain{}],[RMissing{}],[Numeric{}],[Text{}],[Absent{}],True{},["Follows"],[Clock{},Missing{}]}
def name(~S:Data,value:Definition<S>) -> String:
  match value:
    case Definition{name,_,_,_,_,_,_,_,_,_}:name
def same_needs(~S:Data,left:List<&2,Provision.Requirement<S>>,right:List<&2,Provision.Requirement<S>>) -> Bool:
  match left right:
    case Nil{} Nil{}:True{}
    case Con{a,left} Con{b,right}:Bool.and(Provision.same(~S,a,b),same_needs(~S,left,right))
    case _ _:False{}

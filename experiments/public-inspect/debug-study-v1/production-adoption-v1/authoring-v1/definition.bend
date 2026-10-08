import Base
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as Provision
import ../candidate/src/ecs/debug-metadata.bend as M
# Schema-owned nominal Data tokens. None of the projected names is authority.
# Pure closed setup functions project these same tokens to labels/requirements.
type Query<C:Data,L:Data> is Data:
  Query{slot:String,reads:List<&2,C>,writes:List<&2,C>,optional:List<&2,C>,with:List<&2,C>,without:List<&2,C>,added:List<&2,C>,changed:List<&2,C>,relations:List<&2,L>}
type Definition<-S:Data,C:Data,R:Data,E:Data,Mach:Data,L:Data,V:Data,K:Data> is Data:
  Definition{name:String,queries:List<&2,Query<C,L>>,readResources:List<&2,R>,writeResources:List<&2,R>,readEvents:List<&2,E>,writeEvents:List<&2,E>,readMachines:List<&2,Mach>,nextMachines:List<&2,Mach>,transitions:List<&2,Mach>,transitionEvents:List<&2,Mach>,removed:List<&2,C>,despawned:Bool,relationFailures:List<&2,L>,services:List<&2,V>,when:List<&2,K>}
def labels(~T:Data,~name:T->String,values:List<&2,T>) -> List<&2,String>:
  match values:
    case []:[]
    case head<>tail:name(head)<>labels(~T,~name,tail)
def query(~C:Data,~L:Data,~cn:C->String,~ln:L->String,value:Query<C,L>) -> M.Query:
  match value:
    case Query{slot,rs,ws,opts,with,without,added,changed,rels}:M.Query{slot,labels(~C,~cn,rs),labels(~C,~cn,ws),labels(~C,~cn,opts),labels(~C,~cn,with),labels(~C,~cn,without),labels(~C,~cn,added),labels(~C,~cn,changed),labels(~L,~ln,rels)}
def queries(~C:Data,~L:Data,~cn:C->String,~ln:L->String,values:List<&2,Query<C,L>>) -> List<&2,M.Query>:
  match values:
    case []:[]
    case head<>tail:query(~C,~L,~cn,~ln,head)<>queries(~C,~L,~cn,~ln,tail)
def metadata(~S:Data,~C:Data,~R:Data,~E:Data,~Mach:Data,~L:Data,~V:Data,~K:Data,~cn:C->String,~rn:R->String,~en:E->String,~mn:Mach->String,~ln:L->String,~vn:V->String,~kn:K->String,value:Definition<S,C,R,E,Mach,L,V,K>,positions:List<&2,String>) -> M.System:
  match value:
    case Definition{name,qs,rr,rw,er,ew,mr,mnxt,mt,me,removed,despawned,failures,services,when}:M.System{name,positions,queries(~C,~L,~cn,~ln,qs),M.Access{labels(~R,~rn,rr),labels(~R,~rn,rw)},M.Access{labels(~E,~en,er),labels(~E,~en,ew)},M.MachineAccess{labels(~Mach,~mn,mr),labels(~Mach,~mn,mnxt),labels(~Mach,~mn,mt),labels(~Mach,~mn,me)},labels(~C,~cn,removed),despawned,labels(~L,~ln,failures),labels(~V,~vn,services),labels(~K,~kn,when)}
def name(~S:Data,~C:Data,~R:Data,~E:Data,~Mach:Data,~L:Data,~V:Data,~K:Data,value:Definition<S,C,R,E,Mach,L,V,K>) -> String:
  match value:
    case Definition{name,_,_,_,_,_,_,_,_,_,_,_,_,_,_}:name
# Requirements come from the actual schema binding, not a global fixture id.
# Query optional/components/events do not become mandatory SP requirements.
# SP has no Machine variant; no machine key is recast as a Resource id.
def needs(~S:Data,~T:Data,~requirement:T->Provision.Requirement<S>,values:List<&2,T>) -> List<&2,Provision.Requirement<S>>:
  match values:
    case []:[]
    case head<>tail:requirement(head)<>needs(~S,~T,~requirement,tail)
def provision_needs(~S:Data,~C:Data,~R:Data,~E:Data,~Mach:Data,~L:Data,~V:Data,~K:Data,~resource:R->Provision.Requirement<S>,~service:V->Provision.Requirement<S>,value:Definition<S,C,R,E,Mach,L,V,K>) -> List<&2,Provision.Requirement<S>>:
  match value:
    case Definition{_,_,rr,rw,_,_,_,_,_,_,_,_,_,services,_}:Provision.unique(~S,List.append(&2,Provision.Requirement<S>,needs(~S,~V,~service,services),List.append(&2,Provision.Requirement<S>,needs(~S,~R,~resource,rr),needs(~S,~R,~resource,rw))))
# The access-record encoding is author-selected descriptive data, not a format.
# Registration and debug must call this same metadata projection, retained with
# the actual Registry. Physical grants remain existing core capabilities.
def access(~encode:M.System->List<&2,String>,value:M.System) -> List<&2,String>:
  encode(value)

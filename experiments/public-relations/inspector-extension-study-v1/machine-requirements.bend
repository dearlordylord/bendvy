import Base
import root-source/inspector-metadata.bend as Legacy

# Trusted authoring precondition: within one schema, canonical machine IDs
# are injective over nominal K. Metadata erases K and does NOT prove this map.
# Gameplay grants retain K; names confer no authority. Distinct K must use
# distinct machine IDs; a Resource may reuse the same numeric ID.
# Additive category-aware metadata facade. Existing Resource/Metadata API is
# untouched; conversion preserves resource order, names and constructor values.
type Machine<-S:Data,-K:Data> is Data:
  Machine{id:U32,name:String}
type Requirement<S:Data> is Data:
  Resource{value:Legacy.Resource<S>}
  MachineRequirement{id:U32,name:String}
def machine(~S:Data,~K:Data,value:Machine<S,K>) -> Requirement<S>:
  match value:
    case Machine{id,name}:MachineRequirement{id,name}
def same(~S:Data,a:Requirement<S>,b:Requirement<S>) -> Bool:
  match a b:
    case Resource{Legacy.Resource{a,_}} Resource{Legacy.Resource{b,_}}:U32.is_eq(a,b)
    case MachineRequirement{a,_} MachineRequirement{b,_}:U32.is_eq(a,b)
    case _ _:False{}
def contains(~S:Data,items:List<&2,Requirement<S>>,+value:Requirement<S>) -> Bool:
  match items:
    case []:False{}
    case head <> rest:Bool.or(same(~S,head,value),contains(~S,rest,value))
def keep(~S:Data,present:Bool,value:Requirement<S>,rest:List<&2,Requirement<S>>) -> List<&2,Requirement<S>>:
  match present:
    case True{}:rest
    case False{}:value <> rest
# Missing entries retain declaration order and never grant a read provider.
def missing(~S:Data,~available:Requirement<S> -> Bool,required:List<&2,Requirement<S>>) -> List<&2,Requirement<S>>:
  match required:
    case []:[]
    case +head <> rest:keep(~S,available(head),head,missing(~S,~available,rest))
def resources(~S:Data,items:List<&2,Legacy.Resource<S>>) -> List<&2,Requirement<S>>:
  match items:
    case []:[]
    case head <> rest:Resource{head} <> resources(~S,rest)
# Preflight keeps all caller-owned state/instance/arguments untouched on refusal.
type Gate<-S:Data,-Owner:Type,-Instance:Type,-Args:Data> is Type:
  Ready{owner:Owner,instance:Instance,args:Args}
  Missing{owner:Owner,instance:Instance,args:Args,requirements:List<&2,Requirement<S>>}
def gate(~S:Data,~Owner:Type,~Instance:Type,~Args:Data,requirements:List<&2,Requirement<S>>,owner:Owner,instance:Instance,args:Args) -> Gate<S,Owner,Instance,Args>:
  match requirements:
    case []:Ready{owner,instance,args}
    case head <> rest:Missing{owner,instance,args,head <> rest}

import Base
import schedule-provision.bend as Provision

# Trusted declaration metadata carries no provider, World or callback grant.
type Resource<S:Data> is Data:
  Resource{id:U32,name:String}
type Metadata<S:Data> is Data:
  Metadata{name:String,requirements:List<&2,Resource<S>>}
type Definition<-S:Data,-Plan:Type> is Type:
  Definition{metadata:Metadata<S>,plan:Plan}

def token(~S:Data,value:Resource<S>) -> Provision.Requirement<S>:
  match value:
    case Resource{id,_}:Provision.Resource{id}
def tokens(~S:Data,values:List<&2,Resource<S>>) -> List<&2,Provision.Requirement<S>>:
  match values:
    case []:[]
    case value <> rest:token(~S,value) <> tokens(~S,rest)
def choose_first(~S:Data,matched:Bool,value:Resource<S>,alternative:Maybe<&2,Resource<S>>) -> Maybe<&2,Resource<S>>:
  match matched:
    case True{}:Some{value}
    case False{}:alternative
def first(~S:Data,+id:U32,values:List<&2,Resource<S>>) -> Maybe<&2,Resource<S>>:
  match values:
    case []:None{}
    case +value <> rest:
      match value:
        case Resource{key,_}:
          choose_first(~S,U32.is_eq(id,key),value,first(~S,id,rest))
def keep(~S:Data,value:Maybe<&2,Resource<S>>,rest:List<&2,Resource<S>>) -> List<&2,Resource<S>>:
  match value:
    case None{}:rest
    case Some{value}:value <> rest
# Internal keys are lowered exclusively from Resource; wider provision token
# cases have no source entry and confer no category/provider capability.
def names(~S:Data,keys:List<&2,Provision.Requirement<S>>,+values:List<&2,Resource<S>>) -> List<&2,Resource<S>>:
  match keys:
    case []:[]
    case Provision.Resource{id} <> rest:keep(~S,first(~S,id,values),names(~S,rest,values))
    case _ <> rest:names(~S,rest,values)
def normalize(~S:Data,+values:List<&2,Resource<S>>) -> List<&2,Resource<S>>:
  names(~S,Provision.unique(~S,tokens(~S,values)),values)
def make(~S:Data,~Plan:Type,name:String,requirements:List<&2,Resource<S>>,plan:Plan) -> Definition<S,Plan>:
  Definition{Metadata{name,normalize(~S,requirements)},plan}
def read(~S:Data,~Plan:Type,definition:Definition<S,Plan>) -> Definition<S,Plan> & Metadata<S>:
  match definition:
    case Definition{+metadata,plan}:(Definition{metadata,plan},metadata)
def into_plan(~S:Data,~Plan:Type,definition:Definition<S,Plan>) -> Plan:
  match definition:
    case Definition{_,plan}:plan
def kind(~S:Data,metadata:Metadata<S>) -> String:
  "inspector"
def name(~S:Data,metadata:Metadata<S>) -> String:
  match metadata:
    case Metadata{name,_}:name
def requirements(~S:Data,metadata:Metadata<S>) -> List<&2,Resource<S>>:
  match metadata:
    case Metadata{_,requirements}:requirements

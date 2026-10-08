import Base
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP

# Single ordinary schema declaration. The closed layout is a storage TYPE index.
type Layout<-S:Data,-P:Type,-Q:Type> is Data:
  Layout{leftKey:String,rightKey:String}
type Owner<-S:Data,-P:Type,-Q:Type,-layout:Layout<S,P,Q>> is Type:
  Owner{entries:List<&2,Entry<S>>,left:P,right:Q}
type Path is Data:
  Left{}
  Right{}
type Entry<-S:Data> is Data:
  Entry{id:U32,key:String,name:String}
def schema(~S:Data,~P:Type,~Q:Type,leftKey:String,rightKey:String) -> Layout<S,P,Q>:
  Layout{leftKey,rightKey}
# Numbering belongs to SCHEMA traversal, not Params traversal. All subsequent
# consumers project this one schema assignment even if paths are reversed.
def left_id() -> U32:
  U32.add(0,1)
def right_id() -> U32:
  U32.add(left_id(),1)
def entry(~S:Data,~P:Type,~Q:Type,layout:Layout<S,P,Q>,path:Path) -> Entry<S>:
  match layout path:
    case Layout{+key,_},Left{}:Entry{left_id(),key,key}
    case Layout{_,+key},Right{}:Entry{right_id(),key,key}
def requirement(~S:Data,entry:Entry<S>) -> SP.Requirement<S>:
  match entry:
    case Entry{id,_,_}:SP.Resource{id}
def Value(~V:Data,~U:Data,path:Path) -> Data:
  match path:
    case Left{}:V
    case Right{}:U
# Type-indexed closed paths choose actual slot, value type, name and needs.
def left_done(~S:Data,~P:Type,~Q:Type,~layout:Layout<S,P,Q>,~V:Data,entries:List<&2,Entry<S>>,right:Q,observed:P & V) -> Owner<S,P,Q,layout> & V:
  match observed:
    case (left,value):(Owner{entries,left,right},value)
def right_done(~S:Data,~P:Type,~Q:Type,~layout:Layout<S,P,Q>,~U:Data,entries:List<&2,Entry<S>>,left:P,observed:Q & U) -> Owner<S,P,Q,layout> & U:
  match observed:
    case (right,value):(Owner{entries,left,right},value)
def left_value(~S:Data,~P:Type,~Q:Type,~layout:Layout<S,P,Q>,~V:Data,~show:P -> P & V,owner:Owner<S,P,Q,layout>) -> Owner<S,P,Q,layout> & V:
  match owner:
    case Owner{entries,left,right}:left_done(~S,~P,~Q,~layout,~V,entries,right,show(left))
def right_value(~S:Data,~P:Type,~Q:Type,~layout:Layout<S,P,Q>,~U:Data,~show:Q -> Q & U,owner:Owner<S,P,Q,layout>) -> Owner<S,P,Q,layout> & U:
  match owner:
    case Owner{entries,left,right}:right_done(~S,~P,~Q,~layout,~U,entries,left,show(right))
type Params<-S:Data,-P:Type,-Q:Type,-layout:Layout<S,P,Q>> is Data:
  Params{first:Path,second:Path}
def params(~S:Data,~P:Type,~Q:Type,~layout:Layout<S,P,Q>,first:Path,second:Path) -> Params<S,P,Q,layout>:
  Params{first,second}
def first(~S:Data,~P:Type,~Q:Type,~layout:Layout<S,P,Q>,value:Params<S,P,Q,layout>) -> Path:
  match value:
    case Params{first,_}:first
def second(~S:Data,~P:Type,~Q:Type,~layout:Layout<S,P,Q>,value:Params<S,P,Q,layout>) -> Path:
  match value:
    case Params{_,second}:second
def entries(~S:Data,~P:Type,~Q:Type,~layout:Layout<S,P,Q>,value:Params<S,P,Q,layout>) -> List<&2,Entry<S>>:
  match value:
    case Params{a,b}:[entry(~S,~P,~Q,layout,a),entry(~S,~P,~Q,layout,b)]
def needs(~S:Data,values:List<&2,Entry<S>>) -> List<&2,SP.Requirement<S>>:
  match values:
    case []:[]
    case value<>rest:requirement(~S,value)<>needs(~S,rest)
def names(~S:Data,values:List<&2,Entry<S>>) -> List<&2,String>:
  match values:
    case []:[]
    case Entry{_,_,name}<>rest:name<>names(~S,rest)

# Actual owner registry created from the same declaration before any grant.
def bootstrap(~S:Data,~P:Type,~Q:Type,~layout:Layout<S,P,Q>,left:P,right:Q) -> Owner<S,P,Q,layout>:
  Owner{[entry(~S,~P,~Q,layout,Left{}),entry(~S,~P,~Q,layout,Right{})],left,right}
def owner_entries(~S:Data,~P:Type,~Q:Type,~layout:Layout<S,P,Q>,owner:Owner<S,P,Q,layout>) -> Owner<S,P,Q,layout> & List<&2,Entry<S>>:
  match owner:
    case Owner{+entries,left,right}:(Owner{entries,left,right},entries)
def owner_needs(~S:Data,~P:Type,~Q:Type,~layout:Layout<S,P,Q>,owner:Owner<S,P,Q,layout>) -> Owner<S,P,Q,layout> & List<&2,SP.Requirement<S>>:
  match owner:
    case Owner{+entries,left,right}:(Owner{entries,left,right},needs(~S,entries))

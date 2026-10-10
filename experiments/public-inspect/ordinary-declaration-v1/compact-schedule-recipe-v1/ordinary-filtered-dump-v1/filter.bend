import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
# Native typed criteria. The component token comes from the operational declaration.
type Component<S:Data> is Data:
  Component{key:String}
type Filter<S:Data> is Data:
  Filter{entities:Maybe<&2,List<&2,U32>>,with:List<&2,Component<S>>,limit:Maybe<&2,Nat>}
type Value is Data:
  Value{key:String,value:String}
type Row<S:Data> is Data:
  Row{entity:W.Handle<S>,components:List<&2,Value>}
def component(~S:Data,~Payload:Type,declaration:Identity.Declaration<S,Payload>) -> Component<S>:
  match declaration:
    case Identity.Declaration{key}:Component{key}
def contains_id(+id:U32,ids:List<&2,U32>) -> Bool:
  match ids:
    case []:False{}
    case next <> rest:Bool.or(U32.is_eq(id,next),contains_id(id,rest))
def includes(~S:Data,ids:Maybe<&2,List<&2,U32>>,entity:W.Handle<S>) -> Bool:
  match ids entity:
    case None{} _:True{}
    case Some{ids} W.Handle{_,id}:contains_id(id,ids)
def contains(+key:String,values:List<&2,Value>) -> Bool:
  match values:
    case []:False{}
    case Value{other,_} <> rest:Bool.or(String.eq(key,other),contains(key,rest))
def requirements(~S:Data,required:List<&2,Component<S>>,+present:List<&2,Value>) -> Bool:
  match required:
    case []:True{}
    case Component{key} <> rest:Bool.and(contains(key,present),requirements(~S,rest,present))
def accepted(~S:Data,ids:Maybe<&2,List<&2,U32>>,required:List<&2,Component<S>>,row:Row<S>) -> Bool:
  match row:
    case Row{entity,values}:Bool.and(includes(~S,ids,entity),requirements(~S,required,values))
def decrement(limit:Maybe<&2,Nat>) -> Maybe<&2,Nat>:
  match limit:
    case None{}:None{}
    case Some{0n}:Some{0n}
    case Some{1n+k}:Some{k}
def choice(~S:Data,row:Row<S>,limit:Maybe<&2,Nat>,rest:Maybe<&2,Nat> -> List<&2,Row<S>>,include:Bool) -> List<&2,Row<S>>:
  match include:
    case True{}:row <> rest(decrement(limit))
    case False{}:rest(limit)
def select(~S:Data,+ids:Maybe<&2,List<&2,U32>>,+required:List<&2,Component<S>>,rows:List<&2,Row<S>>,+limit:Maybe<&2,Nat>) -> List<&2,Row<S>>:
  match rows limit:
    case _ Some{0n}:[]
    case [] _:[]
    case +row <> rest limit:choice(~S,row,limit,next => select(~S,ids,required,rest,next),accepted(~S,ids,required,row))
def apply(~S:Data,filter:Filter<S>,rows:List<&2,Row<S>>) -> List<&2,Row<S>>:
  match filter:
    case Filter{ids,required,limit}:select(~S,ids,required,rows,limit)

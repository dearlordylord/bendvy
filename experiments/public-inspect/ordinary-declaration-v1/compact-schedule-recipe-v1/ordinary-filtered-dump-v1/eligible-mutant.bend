import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as Fragment
import ./filter-mutant.bend as Filter
# Presence derives from the ordinary count traversal on one actual alive handle.
def present_choice(~S:Data,key:String,tail:List<&2,Filter.Value>,absent:Bool) -> List<&2,Filter.Value>:
  match absent:
    case True{}:tail
    case False{}:Filter.Value{key,""} <> tail
def present(~S:Data,pairs:List<&1,Fragment.Entry<S> & Maybe<&2,U32>>) -> List<&2,Filter.Value>:
  match pairs:
    case []:[]
    case (Fragment.Entry{Fragment.Component{},key,_},Some{count}) <> rest:present_choice(~S,key,present(~S,rest),U32.is_eq(count,0))
    case _ <> rest:present(~S,rest)
def kept(~S:Data,~C:Type,handle:W.Handle<S>,result:C & List<&2,W.Handle<S>>) -> C & List<&2,W.Handle<S>>:
  match result:
    case (store,after):(store,handle <> after)
def required(~S:Data,~C:Type,handle:W.Handle<S>,limit:Maybe<&2,Nat>,rest:C -> Maybe<&2,Nat> -> C & List<&2,W.Handle<S>>,store:C,include:Bool) -> C & List<&2,W.Handle<S>>:
  match include:
    case True{}:kept(~S,~C,handle,rest(store,Filter.decrement(limit)))
    case False{}:rest(store,limit)
def selected(~S:Data,~C:Type,entries:List<&2,Fragment.Entry<S>>,criteria:List<&2,Filter.Component<S>>,handle:W.Handle<S>,limit:Maybe<&2,Nat>,rest:C -> Maybe<&2,Nat> -> C & List<&2,W.Handle<S>>,result:C & List<&2,Maybe<&2,U32>>) -> C & List<&2,W.Handle<S>>:
  match result:
    case (store,slots):required(~S,~C,handle,limit,rest,store,Filter.requirements(~S,criteria,present(~S,List.zip(&2,Fragment.Entry<S>,&2,Maybe<&2,U32>,entries,slots))))
def included(~S:Data,~C:Type,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,entries:List<&2,Fragment.Entry<S>>,criteria:List<&2,Filter.Component<S>>,+handle:W.Handle<S>,limit:Maybe<&2,Nat>,rest:C -> Maybe<&2,Nat> -> C & List<&2,W.Handle<S>>,store:C,include:Bool) -> C & List<&2,W.Handle<S>>:
  match include:
    case False{}:rest(store,limit)
    case True{}:selected(~S,~C,entries,criteria,handle,limit,rest,count(store,[handle]))
def scan(~S:Data,~C:Type,~count:C -> List<&2,W.Handle<S>> -> C & List<&2,Maybe<&2,U32>>,handles:List<&2,W.Handle<S>>,+entries:List<&2,Fragment.Entry<S>>,+ids:Maybe<&2,List<&2,U32>>,+criteria:List<&2,Filter.Component<S>>,limit:Maybe<&2,Nat>,store:C) -> C & List<&2,W.Handle<S>>:
  match handles limit:
    case _ Some{0n}:(store,[])
    case [] _:(store,[])
    case +handle <> rest limit:included(~S,~C,~count,entries,criteria,handle,limit,next => remaining => scan(~S,~C,~count,rest,entries,ids,criteria,remaining,next),store,Filter.includes(~S,ids,handle))

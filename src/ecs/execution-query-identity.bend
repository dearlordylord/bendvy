import Base
import ./world.bend as W
import ./entity-key.bend as K
import ./execution-state.bend as State
import ./execution-query-domain.bend as D
import ./indexed-lifecycle.bend as Indexed
import ./chunk-column.bend as Column

# Captured handles must originate from admitted actual World/Prepared state.
# Comparing all namespace/key/generation fields precedes physical conversion.
type Offset<-S:Data> is Data:
  MissingEntity{handle:W.Handle<S>}
  OutsideStorage{handle:W.Handle<S>,capacity:U32}
  Physical{handle:W.Handle<S>,offset:U32}
def checked_range(~S:Data,+handle:W.Handle<S>,+capacity:U32,+logical:U32,live:Bool,inRange:Bool) -> Offset<S>:
  match live inRange:
    case False{} _:MissingEntity{handle}
    case True{} False{}:OutsideStorage{handle,capacity}
    case True{} True{}:Physical{handle,U32.sub(logical,1)}
def checked_logical(~S:Data,+namespace:U32,+handles:List<&2,W.Handle<S>>,+capacity:U32,+handle:W.Handle<S>,+handleNamespace:U32,+key:K.Key) -> Offset<S>:
  checked_range(~S,handle,capacity,K.index(key),Bool.and(U32.is_eq(namespace,handleNamespace),State.member(~S,handle,handles)),Bool.and(Indexed.normal(K.index(key)),U32.is_le(K.index(key),capacity)))
def checked_offset(~S:Data,namespace:U32,handles:List<&2,W.Handle<S>>,capacity:U32,handle:W.Handle<S>) -> Offset<S>:
  match handle:
    case W.Handle{+hn,+key}:checked_logical(~S,namespace,handles,capacity,W.Handle{hn,key},hn,key)
type TargetCheck<-S:Data> is Data:
  Targets{handles:List<&2,W.Handle<S>>,offsets:D.Domain}
  Refused{handles:List<&2,W.Handle<S>>}
def unique(~S:Data,handles:List<&2,W.Handle<S>>) -> Bool:
  match handles:
    case []:True{}
    case +head <> +tail:Bool.and(Bool.not(State.member(~S,head,tail)),unique(~S,tail))

def offset_handles(~S:Data,~C:Type,~R:Type,~E:Data,namespace:U32,capacity:U32,handle:W.Handle<S>,result:W.World<S,C,R,E> & List<&2,W.Handle<S>>) -> W.World<S,C,R,E> & Offset<S>:
  match result:
    case (world,handles):(world,checked_offset(~S,namespace,handles,capacity,handle))
def offset_namespace(~S:Data,~C:Type,~R:Type,~E:Data,capacity:U32,handle:W.Handle<S>,result:W.World<S,C,R,E> & U32) -> W.World<S,C,R,E> & Offset<S>:
  match result:
    case (world,namespace):offset_handles(~S,~C,~R,~E,namespace,capacity,handle,W.handles(~S,~C,~R,~E,world))
def offset_valid(~S:Data,~C:Type,~R:Type,~E:Data,capacity:U32,handle:W.Handle<S>,result:W.World<S,C,R,E> & Bool) -> W.World<S,C,R,E> & Offset<S>:
  match result:
    case (world,False{}):(world,MissingEntity{handle})
    case (world,True{}):offset_namespace(~S,~C,~R,~E,capacity,handle,W.namespace(~S,~C,~R,~E,world))
def world_offset(~S:Data,~C:Type,~R:Type,~E:Data,world:W.World<S,C,R,E>,capacity:U32,+handle:W.Handle<S>) -> W.World<S,C,R,E> & Offset<S>:
  offset_valid(~S,~C,~R,~E,capacity,handle,W.valid(~S,~C,~R,~E,world,handle))

def index_checked(+logical:U32,normal:Bool) -> Maybe<&2,U32>:
  match normal:
    case False{}:None{}
    case True{}:Some{U32.sub(logical,1)}
def physical_index(+logical:U32) -> Maybe<&2,U32>:
  index_checked(logical,Indexed.normal(logical))
def captured_offset(~S:Data,+handles:List<&2,W.Handle<S>>,handle:W.Handle<S>) -> Offset<S>:
  match handles:
    case []:MissingEntity{handle}
    case W.Handle{+namespace,+key} <> +rest:checked_offset(~S,namespace,W.Handle{namespace,key} <> rest,Column.maximum_capacity(),handle)
def physical_live(~S:Data,checked:Offset<S>) -> Bool:
  match checked:
    case Physical{_,_}:True{}
    case _:False{}
def captured_live(~S:Data,handles:List<&2,W.Handle<S>>,handle:W.Handle<S>) -> Bool:
  physical_live(~S,captured_offset(~S,handles,handle))
def prepend_offset(~S:Data,tail:Maybe<&2,List<&2,U32>>,checked:Offset<S>) -> Maybe<&2,List<&2,U32>>:
  match tail checked:
    case Some{tail} Physical{_,offset}:Some{offset <> tail}
    case _ _:None{}
def target_offsets(~S:Data,+namespace:U32,+all:List<&2,W.Handle<S>>,remaining:List<&2,W.Handle<S>>) -> Maybe<&2,List<&2,U32>>:
  match remaining:
    case []:Some{[]}
    case +head <> tail:prepend_offset(~S,target_offsets(~S,namespace,all,tail),checked_offset(~S,namespace,all,Column.maximum_capacity(),head))
def targets_valid(~S:Data,handles:List<&2,W.Handle<S>>,domain:D.Domain,valid:Bool) -> TargetCheck<S>:
  match valid:
    case False{}:Refused{handles}
    case True{}:Targets{handles,domain}
def targets_validation(~S:Data,+handles:List<&2,W.Handle<S>>,+domain:D.Domain,validation:D.Validation) -> TargetCheck<S>:
  match validation:
    case D.Valid{}:targets_valid(~S,handles,domain,unique(~S,handles))
    case _:Refused{handles}
def targets_offsets(~S:Data,handles:List<&2,W.Handle<S>>,offsets:Maybe<&2,List<&2,U32>>) -> TargetCheck<S>:
  match offsets:
    case None{}:Refused{handles}
    case Some{+offsets}:targets_validation(~S,handles,D.Domain{offsets},D.validate(Column.maximum_capacity(),D.Domain{offsets}))
def targets(~S:Data,namespace:U32,+handles:List<&2,W.Handle<S>>) -> TargetCheck<S>:
  targets_offsets(~S,handles,target_offsets(~S,namespace,handles,handles))

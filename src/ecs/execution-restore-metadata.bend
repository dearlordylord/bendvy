import Base
import ./execution-save-metadata.bend as Metadata
import ./execution-save-data.bend as Saved
import ./entity-allocator.bend as A
import ./entity-key.bend as Key
import ./clock-state.bend as Clock
import ./change-tick.bend as Tick
import ./lifecycle.bend as Life

def contains_index(values:List<&2,U32>,+index:U32) -> Bool:
  match values:
    case []:False{}
    case value <> rest:Bool.or(U32.is_eq(value,index),contains_index(rest,index))
def contains_key(values:List<&2,Key.Key>,+key:Key.Key) -> Bool:
  match values:
    case []:False{}
    case other <> rest:Bool.or(Key.equal(other,key),contains_key(rest,key))
def index_in_keys(values:List<&2,Key.Key>,+index:U32) -> Bool:
  match values:
    case []:False{}
    case key <> rest:Bool.or(U32.is_eq(Key.index(key),index),index_in_keys(rest,index))
def lookup(values:List<&2,A.Slot>,index:Nat) -> Maybe<&2,A.Slot>:
  match values index:
    case [], _:None{}
    case value <> _, 0n:Some{value}
    case _ <> rest, 1n+index:lookup(rest,index)
def slot(values:List<&2,A.Slot>,index:U32) -> Maybe<&2,A.Slot>:lookup(values,U32.to_nat(index))
def free_slot(value:Maybe<&2,A.Slot>) -> Bool:
  match value:
    case Some{A.Slot{_,A.Free{}}}:True{}
    case _:False{}
def order_slot(key:Key.Key,value:Maybe<&2,A.Slot>) -> Bool:
  match value:
    case Some{A.Slot{generation,phase}}:Bool.and(U32.is_eq(Key.generation(key),generation),A.metadata(phase))
    case None{}:False{}
def free(values:List<&2,U32>,+slots:List<&2,A.Slot>,+next:U32) -> Bool:
  match values:
    case []:True{}
    case +index <> +rest:Bool.and(Bool.and(U32.is_lt(0,index),U32.is_lt(index,next)),Bool.and(Bool.not(contains_index(rest,index)),Bool.and(free_slot(slot(slots,index)),free(rest,slots,next))))
def order(values:List<&2,Key.Key>,+slots:List<&2,A.Slot>,+next:U32) -> Bool:
  match values:
    case []:True{}
    case +key <> +rest:Bool.and(Bool.and(U32.is_lt(0,Key.index(key)),U32.is_lt(Key.index(key),next)),Bool.and(Bool.not(index_in_keys(rest,Key.index(key))),Bool.and(order_slot(key,slot(slots,Key.index(key))),order(rest,slots,next))))
def live_keys(values:List<&2,Saved.Entity>) -> List<&2,Key.Key>:
  match values:
    case []:[]
    case Saved.Entity{key,_} <> rest:key <> live_keys(rest)
def phase_slot(+index:U32,+generation:U32,phase:A.Phase,free:List<&2,U32>,order:List<&2,Key.Key>,live:List<&2,Key.Key>) -> Bool:
  match phase:
    case A.Free{}:Bool.and(contains_index(free,index),Bool.not(index_in_keys(live,index)))
    case A.Live{}:Bool.and(contains_key(order,Key.EntityKey{index,generation}),contains_key(live,Key.EntityKey{index,generation}))
    case A.Consumed{}:Bool.and(Bool.not(contains_index(free,index)),Bool.not(index_in_keys(live,index)))
    case _:Bool.and(contains_key(order,Key.EntityKey{index,generation}),Bool.not(index_in_keys(live,index)))
def slot_allowed(check:Bool,index:U32,generation:U32,phase:A.Phase,free:List<&2,U32>,order:List<&2,Key.Key>,live:List<&2,Key.Key>) -> Bool:
  match check:
    case False{}:True{}
    case True{}:phase_slot(index,generation,phase,free,order,live)
def slots(values:List<&2,A.Slot>,+index:U32,+next:U32,+free:List<&2,U32>,+order:List<&2,Key.Key>,+live:List<&2,Key.Key>) -> Bool:
  match values:
    case []:True{}
    case A.Slot{generation,phase} <> rest:Bool.and(slot_allowed(Bool.and(U32.is_lt(0,index),U32.is_lt(index,next)),index,generation,phase,free,order,live),slots(rest,U32.add(index,1),next,free,order,live))
def count_slots(values:List<&2,A.Slot>) -> Nat:
  match values:
    case []:0n
    case _ <> rest:1n+count_slots(rest)
def capacity(depth:Nat) -> Nat:
  match depth:
    case 0n:1n
    case 1n+rest:Nat.mul(2n,capacity(rest))
def live_slot(key:Key.Key,value:Maybe<&2,A.Slot>) -> Bool:
  match value:
    case Some{A.Slot{generation,A.Live{}}}:U32.is_eq(Key.generation(key),generation)
    case _:False{}
def live(values:List<&2,Key.Key>,+slots:List<&2,A.Slot>,+next:U32) -> Bool:
  match values:
    case []:True{}
    case +key <> rest:Bool.and(Bool.and(U32.is_lt(0,Key.index(key)),U32.is_lt(Key.index(key),next)),Bool.and(live_slot(key,slot(slots,Key.index(key))),live(rest,slots,next)))
def allocator(value:Metadata.Allocator,+entities:List<&2,Saved.Entity>) -> Bool:
  match value:
    case Metadata.Allocator{+next,high,+size,depth,+values,+freeValues,+orderValues}:Bool.and(Bool.and(U32.is_lt(0,next),Bool.and(U32.is_le(next,131073),U32.is_eq(high,U32.sub(next,1)))),Bool.and(Bool.and(U32.is_le(next,size),Bool.and(Nat.is_eq(U32.to_nat(size),count_slots(values)),Nat.is_eq(U32.to_nat(size),capacity(depth)))),Bool.and(free(freeValues,values,next),Bool.and(order(orderValues,values,next),Bool.and(slots(values,0,next,freeValues,orderValues,live_keys(entities)),live(live_keys(entities),values,next))))))
def tick(value:Maybe<&2,Tick.Tick>,now:Tick.Tick) -> Bool:
  match value:
    case None{}:True{}
    case Some{value}:Tick.not_future(value,now)
def stamp(value:Maybe<&2,Life.Stamp>,+now:Tick.Tick) -> Bool:
  match value:
    case None{}:True{}
    case Some{Life.Stamp{added,changed}}:Bool.and(tick(added,now),tick(changed,now))
def fields(values:List<&2,Saved.Field>,+now:Tick.Tick) -> Bool:
  match values:
    case []:True{}
    case Saved.Field{_,_,_,value} <> rest:Bool.and(stamp(value,now),fields(rest,now))
def entities(values:List<&2,Saved.Entity>,+now:Tick.Tick) -> Bool:
  match values:
    case []:True{}
    case Saved.Entity{_,values} <> rest:Bool.and(fields(values,now),entities(rest,now))
def clock_empty(scopes:List<&2,Tick.Tick>) -> Bool:
  match scopes:
    case []:True{}
    case _:False{}
# Source metadata is checked as detached input, never installed as receiver
# identity, callbacks, active readers, allocator authority or execution scopes.
def valid(~S:Data,input:Saved.Snapshot<S>) -> Bool:
  match input:
    case Saved.Snapshot{_,Metadata.Metadata{+namespace,source,Clock.State{+now,scopes},Metadata.Lifecycle{journalNamespace,_,_,_}},+values,resources}:Bool.and(Bool.and(U32.is_lt(0,namespace),U32.is_eq(namespace,journalNamespace)),Bool.and(clock_empty(scopes),Bool.and(allocator(source,values),Bool.and(entities(values,now),fields(resources,now)))))

import Base
import ./world.bend as W
import ./entity-key.bend as K
import ./entity-allocator.bend as A
import ./chunk-column.bend as Column
import ./change-tick.bend as Tick

# Framework storage for one declared component family. Payloads remain affine
# until a whole-World barrier applies them or returns them in a refusal receipt.
type Entry<-S:Data,-P:Type> is Type:
  Entry{handle:W.Handle<S>,incoming:Maybe<&1,P>}
type Receipt<-S:Data,-P:Type> is Type:
  Applied{handle:W.Handle<S>,previous:Maybe<&1,P>}
  Refused{handle:W.Handle<S>,incoming:Maybe<&1,P>}
type Buffer<-S:Data,-P:Type> is Type:
  Buffer{pending:List<Entry<S,P>>,receipts:List<Receipt<S,P>>}
type Applied<-S:Data,-P:Type> is Type:
  AppliedOne{allocator:A.Allocator,column:Column.Column<S,P>,receipt:Receipt<S,P>}
type Drained<-S:Data,-P:Type> is Type:
  Drained{allocator:A.Allocator,column:Column.Column<S,P>,receipts:List<Receipt<S,P>>}

# Bevy ad678262, schedule/executor/single_threaded.rs: run_without_applying_deferred
# keeps the system's authored buffer, including after a handled RunSystemError.
# Enqueue here only transfers ownership; no component storage is available.
def empty(~S:Data,~P:Type) -> Buffer<S,P>:Buffer{[],[]}
def insert(~S:Data,~P:Type,buffer:Buffer<S,P>,handle:W.Handle<S>,incoming:P) -> Buffer<S,P>:
  match buffer:
    case Buffer{pending,receipts}:Buffer{Entry{handle,Some{incoming}} <> pending,receipts}
def remove(~S:Data,~P:Type,buffer:Buffer<S,P>,handle:W.Handle<S>) -> Buffer<S,P>:
  match buffer:
    case Buffer{pending,receipts}:Buffer{Entry{handle,None{}} <> pending,receipts}
def pending(~S:Data,~P:Type,buffer:Buffer<S,P>) -> Buffer<S,P> & Bool:
  match buffer:
    case Buffer{[],receipts}:(Buffer{[],receipts},False{})
    case Buffer{head <> rest,receipts}:(Buffer{head <> rest,receipts},True{})
def take_receipts(~S:Data,~P:Type,buffer:Buffer<S,P>) -> Buffer<S,P> & List<Receipt<S,P>>:
  match buffer:
    case Buffer{pending,receipts}:(Buffer{pending,[]},List.reverse(&1,Receipt<S,P>,receipts))

# Trusted interpreter: its allocator and column come from the complete World.
# The incoming owner is returned on stale generation, foreign namespace or
# capacity refusal. Replaced and removed owners are returned on success.
def swapped(~S:Data,~P:Type,allocator:A.Allocator,handle:W.Handle<S>,result:Column.SwapOutcome<S,P>) -> Applied<S,P>:
  match result:
    case Column.Accepted{column,previous}:AppliedOne{allocator,column,Applied{handle,previous}}
    case Column.Rejected{column,incoming}:AppliedOne{allocator,column,Refused{handle,incoming}}
def admitted(~S:Data,~P:Type,column:Column.Column<S,P>,+handle:W.Handle<S>,incoming:Maybe<&1,P>,tick:Tick.Tick,result:A.Allocator & Bool) -> Applied<S,P>:
  match handle result:
    case handle, (allocator,False{}):AppliedOne{allocator,column,Refused{handle,incoming}}
    case W.Handle{namespace,+key}, (allocator,True{}):swapped(~S,~P,allocator,W.Handle{namespace,key},Column.swap_at(~S,~P,Column.ensure(~S,~P,column,U32.add(K.index(key),1)),K.index(key),incoming,tick))
def namespaced(~S:Data,~P:Type,allocator:A.Allocator,column:Column.Column<S,P>,+handle:W.Handle<S>,incoming:Maybe<&1,P>,tick:Tick.Tick,allowed:Bool) -> Applied<S,P>:
  match handle allowed:
    case handle False{}:AppliedOne{allocator,column,Refused{handle,incoming}}
    case W.Handle{+namespace,+key} True{}:admitted(~S,~P,column,W.Handle{namespace,key},incoming,tick,A.checked(allocator,key,1))
def apply(~S:Data,~P:Type,namespace:U32,allocator:A.Allocator,column:Column.Column<S,P>,entry:Entry<S,P>,tick:Tick.Tick) -> Applied<S,P>:
  match entry:
    case Entry{W.Handle{+ownerNamespace,key},incoming}:namespaced(~S,~P,allocator,column,W.Handle{ownerNamespace,key},incoming,tick,U32.is_eq(namespace,ownerNamespace))
def recorded(~S:Data,~P:Type,receipts:List<Receipt<S,P>>,result:Applied<S,P>) -> Drained<S,P>:
  match result:
    case AppliedOne{allocator,column,receipt}:Drained{allocator,column,receipt <> receipts}
def next(~S:Data,~P:Type,namespace:U32,entry:Entry<S,P>,tick:Tick.Tick,result:Drained<S,P>) -> Drained<S,P>:
  match result:
    case Drained{allocator,column,receipts}:recorded(~S,~P,receipts,apply(~S,~P,namespace,allocator,column,entry,tick))

# Pending is stored newest first. Recurse before applying each entry so one
# system observes its own command order. Independent buffers have no promised
# global order, matching Bevy system command queues.
def drain(~S:Data,~P:Type,+namespace:U32,entries:List<Entry<S,P>>,allocator:A.Allocator,column:Column.Column<S,P>,+tick:Tick.Tick,receipts:List<Receipt<S,P>>) -> Drained<S,P>:
  match entries:
    case []:Drained{allocator,column,receipts}
    case entry <> rest:next(~S,~P,namespace,entry,tick,drain(~S,~P,namespace,rest,allocator,column,tick,receipts))
def finished(~S:Data,~P:Type,result:Drained<S,P>) -> A.Allocator & (Column.Column<S,P> & Buffer<S,P>):
  match result:
    case Drained{allocator,column,receipts}:(allocator,(column,Buffer{[],receipts}))
def flush(~S:Data,~P:Type,namespace:U32,allocator:A.Allocator,column:Column.Column<S,P>,buffer:Buffer<S,P>,tick:Tick.Tick) -> A.Allocator & (Column.Column<S,P> & Buffer<S,P>):
  match buffer:
    case Buffer{entries,receipts}:finished(~S,~P,drain(~S,~P,namespace,entries,allocator,column,tick,receipts))

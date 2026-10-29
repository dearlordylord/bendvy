import Base
import ./machine.bend as M
import ./machine-queue.bend as Queue
import ./execution-machine-stream.bend as Stream
import ./change-tick.bend as Tick

# The Cell is framework storage. Ordinary bodies receive declaration-derived ops.
type Cell<-S:Data,-K:Data,-V:Data> is Type:
  Cell{slot:M.Slot<S,K,V>,stream:Stream.Store<V>,revision:Nat,stamp:Maybe<&2,Tick.Tick>,nextStamp:Maybe<&2,Tick.Tick>,sequence:Nat,initialPending:Bool,namespace:Maybe<&2,U32>,intent:Intent<V>}
type Intent<-V:Data> is Data:
  Idle{}
  Initial{value:V}
  Transition{from:V,to:V,runExitEnter:Bool}
type View<-S:Data,-K:Data,-V:Data> is Data:
  View{current:M.CurrentView<S,K,V>,next:M.NextView<S,K,V>,revision:Nat,stamp:Maybe<&2,Tick.Tick>,nextStamp:Maybe<&2,Tick.Tick>,intent:Intent<V>}
def empty(~S:Data,~K:Data,~V:Data) -> Cell<S,K,V>:
  Cell{M.Missing{},Stream.empty(~V),0n,None{},None{},0n,False{},None{},Idle{}}
def projected(-S:Data,-K:Data,-V:Data,cell:Cell<S,K,V>) -> Cell<S,K,V> & View<S,K,V>:
  match cell:
    case Cell{+slot,stream,+revision,+stamp,+nextStamp,sequence,initialPending,namespace,+intent}:(Cell{slot,stream,revision,stamp,nextStamp,sequence,initialPending,namespace,intent},View{M.current_view_generic(S,K,V,slot),M.next_view_generic(S,K,V,slot),revision,stamp,nextStamp,intent})
def queue_generic(-S:Data,-K:Data,-V:Data,same:V -> V -> Bool,cell:Cell<S,K,V>,request:M.QueueInput<V>) -> Cell<S,K,V>:
  match cell request:
    case Cell{slot,stream,revision,stamp,nextStamp,sequence,initialPending,namespace,intent} M.Set{value,skipSame}:Cell{Queue.queue_generic(S,K,V,same,slot,value,skipSame),stream,revision,stamp,nextStamp,sequence,initialPending,namespace,intent}
    case Cell{slot,stream,revision,stamp,nextStamp,sequence,initialPending,namespace,intent} M.Reset{}:Cell{M.reset_generic(S,K,V,slot),stream,revision,stamp,nextStamp,sequence,initialPending,namespace,intent}
# Next setters and pending consumption have their own actual write stamp:
# https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_state/src/state/resources.rs#L197-L234
def queue(~S:Data,~K:Data,~V:Data,~same:V -> V -> Bool,cell:Cell<S,K,V>,request:M.QueueInput<V>) -> Cell<S,K,V>:
  queue_generic(S,K,V,same,cell,request)

def request_stamped_generic(-S:Data,-K:Data,-V:Data,tick:Tick.Tick,cell:Cell<S,K,V>) -> Cell<S,K,V> & Unit:
  match cell:
    case Cell{M.Missing{},stream,revision,stamp,nextStamp,sequence,initialPending,namespace,intent}:(Cell{M.Missing{},stream,revision,stamp,nextStamp,sequence,initialPending,namespace,intent},Unit{})
    case Cell{slot,stream,revision,stamp,_,sequence,initialPending,namespace,intent}:(Cell{slot,stream,revision,stamp,Some{tick},sequence,initialPending,namespace,intent},Unit{})
def request_stamped(~S:Data,~K:Data,~V:Data,tick:Tick.Tick,cell:Cell<S,K,V>) -> Cell<S,K,V> & Unit:
  request_stamped_generic(S,K,V,tick,cell)

def queued_at_generic(-S:Data,-K:Data,-V:Data,same:V -> V -> Bool,request:M.QueueInput<V>,tick:Tick.Tick,cell:Cell<S,K,V>) -> Cell<S,K,V> & Unit:
  request_stamped_generic(S,K,V,tick,queue_generic(S,K,V,same,cell,request))
def queued_at(~S:Data,~K:Data,~V:Data,~same:V -> V -> Bool,request:M.QueueInput<V>,tick:Tick.Tick,cell:Cell<S,K,V>) -> Cell<S,K,V> & Unit:
  queued_at_generic(S,K,V,same,request,tick,cell)

def initialized(~S:Data,~K:Data,~V:Data,+value:V,+tick:Tick.Tick,stream:Stream.Store<V>,+sequence:Nat,namespace:Maybe<&2,U32>) -> Cell<S,K,V>:
  Cell{M.Present{value,M.NoPending{},None{},True{}},Stream.publish(~V,stream,1n+sequence,M.Initial{value}),1n,Some{tick},Some{tick},1n+sequence,True{},namespace,Initial{value}}
def initialize(~S:Data,~K:Data,~V:Data,cell:Cell<S,K,V>,value:V,tick:Tick.Tick) -> Cell<S,K,V>:
  match cell:
    case Cell{M.Missing{},stream,_,_,_,sequence,_,namespace,_}:initialized(~S,~K,~V,value,tick,stream,sequence,namespace)
    case cell:cell
def next_revision(same:Bool,revision:Nat) -> Nat:
  match same:
    case True{}:revision
    case False{}:1n+revision
def next_stamp(same:Bool,stamp:Maybe<&2,Tick.Tick>,tick:Tick.Tick) -> Maybe<&2,Tick.Tick>:
  match same:
    case True{}:stamp
    case False{}:Some{tick}
# Bevy commits State and emits StateTransitionEvent before phase schedules:
# https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_state/src/state/transitions.rs#L138-L205
# Comparator equality retains actual Current; exited/Previous/event use the
# requested value, including when equal values have different representations.
def retained(~V:Data,equal:Bool,from:V,to:V) -> V:
  match equal:
    case True{}:from
    case False{}:to
def exited(~V:Data,equal:Bool,from:V,to:V) -> V:
  match equal:
    case True{}:to
    case False{}:from
def committed(~S:Data,~K:Data,~V:Data,+from:V,+to:V,skipSame:Bool,stream:Stream.Store<V>,revision:Nat,stamp:Maybe<&2,Tick.Tick>,+sequence:Nat,+tick:Tick.Tick,+equal:Bool,namespace:Maybe<&2,U32>) -> Cell<S,K,V>:
  Cell{M.Present{retained(~V,equal,from,to),M.NoPending{},Some{exited(~V,equal,from,to)},Bool.not(equal)},Stream.publish(~V,stream,1n+sequence,M.Transition{exited(~V,equal,from,to),to}),next_revision(equal,revision),next_stamp(equal,stamp,tick),Some{tick},1n+sequence,False{},namespace,Transition{exited(~V,equal,from,to),to,Bool.or(Bool.not(skipSame),Bool.not(equal))}}
def apply(~S:Data,~K:Data,~V:Data,~same:V -> V -> Bool,cell:Cell<S,K,V>,tick:Tick.Tick) -> Cell<S,K,V>:
  match cell:
    case Cell{M.Present{+current,M.Queued{+value,skipSame},_,_},stream,revision,stamp,nextStamp,sequence,_,namespace,_}:committed(~S,~K,~V,current,value,skipSame,stream,revision,stamp,sequence,tick,same(current,value),namespace)
    case Cell{slot,stream,revision,stamp,nextStamp,sequence,True{},namespace,intent}:Cell{slot,stream,revision,stamp,nextStamp,sequence,False{},namespace,intent}
    case Cell{slot,stream,revision,stamp,nextStamp,sequence,False{},namespace,_}:Cell{M.clear_changed(~S,~K,~V,slot),stream,revision,stamp,nextStamp,sequence,False{},namespace,Idle{}}
def run_exit(-V:Data,intent:Intent<V>) -> Bool:
  match intent:
    case Transition{_,_,allowed}:allowed
    case _:False{}
def run_transition(-V:Data,intent:Intent<V>) -> Bool:
  match intent:
    case Transition{_,_,_}:True{}
    case _:False{}
def run_enter(-V:Data,intent:Intent<V>) -> Bool:
  match intent:
    case Initial{_}:True{}
    case Transition{_,_,allowed}:allowed
    case _:False{}
def matches(~S:Data,~K:Data,~V:Data,~same:V -> V -> Bool,value:V,view:View<S,K,V>) -> Bool:
  match view:
    case View{current,_,_,_,_,_}:M.is_current(~S,~K,~V,~same,current,value)

def bind(~S:Data,~K:Data,~V:Data,namespace:U32,cell:Cell<S,K,V>) -> Cell<S,K,V>:
  match cell:
    case Cell{slot,stream,revision,stamp,nextStamp,sequence,initialPending,None{},intent}:Cell{slot,stream,revision,stamp,nextStamp,sequence,initialPending,Some{namespace},intent}
    case cell:cell
def maintain(~S:Data,~K:Data,~V:Data,tick:Tick.Tick,cell:Cell<S,K,V>) -> Cell<S,K,V>:
  match cell:
    case Cell{slot,stream,revision,stamp,nextStamp,+sequence,initialPending,namespace,intent}:Cell{slot,Stream.maintain(~V,sequence,tick,stream),revision,stamp,nextStamp,sequence,initialPending,namespace,intent}

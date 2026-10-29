import Base
import ./change-tick.bend as Tick
import ./machine.bend as M
import ./machine-stream.bend as St
import ./ordinary-machine-declaration.bend as OD
import ./world.bend as W

# Runtime constructor inputs remain runtime values, never erased closure captures.
def with_resource(~S:Data,~C:Type,~R:Type,~E:Data,~Out:Type,effect:R -> R & Out,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & Out:
  match world:
    case W.World{+namespace,allocator,store,resource,+events,pending,+registrations,+nextSystemId,+clock,lifecycle}:W.observe_resource_finish(~S,~C,~R,~E,~Out,effect(resource),namespace,allocator,store,events,pending,registrations,nextSystemId,clock,lifecycle)

# The operational slot, stream and change revision share one schema-owned cell.
# Revisions are not Registry cursors; each registered condition owns its observation.
type State<S:Data,K:Data,V:Data> is Data:
  State{slot:M.Slot<S,K,V>,stream:St.Stream<V>,revision:Nat}
def empty(~S:Data,~K:Data,~V:Data) -> State<S,K,V>:
  State{M.Missing{},St.empty(~V),0n}
def slot(~S:Data,~K:Data,~V:Data,+state:State<S,K,V>) -> State<S,K,V> & M.Slot<S,K,V>:
  match state:
    case State{+value,stream,revision}:(State{value,stream,revision},value)
def revision(~S:Data,~K:Data,~V:Data,+state:State<S,K,V>) -> State<S,K,V> & Nat:
  match state:
    case State{value,stream,+revision}:(State{value,stream,revision},revision)
def same_current(~S:Data,~K:Data,~V:Data,~same:V -> V -> Bool,before:M.Slot<S,K,V>,after:M.Slot<S,K,V>) -> Bool:
  match before after:
    case M.Missing{} M.Missing{}:True{}
    case M.Present{a,_,_,_} M.Present{b,_,_,_}:same(a,b)
    case _ _:False{}
def next_revision(same:Bool,revision:Nat) -> Nat:
  match same:
    case True{}:revision
    case False{}:(revision + 1n : Nat)
# Queue-only writes preserve revision. Actual unequal commits increment it.
def replaced(~S:Data,~K:Data,~V:Data,~same:V -> V -> Bool,state:State<S,K,V>,+value:M.Slot<S,K,V>) -> State<S,K,V>:
  match state:
    case State{old,stream,revision}:State{value,stream,next_revision(same_current(~S,~K,~V,~same,old,value),revision)}
def insertion_slot(~S:Data,~K:Data,~V:Data,value:V,old:M.Slot<S,K,V>) -> M.Slot<S,K,V>:
  match old:
    case M.Missing{}:M.Present{value,M.NoPending{},None{},True{}}
    case M.Present{_,pending,previous,_}:M.Present{value,pending,previous,True{}}
# Recreating an absent State appends; only occupied insert_state clears messages.
def insertion_stream(~S:Data,~K:Data,~V:Data,old:M.Slot<S,K,V>,stream:St.Stream<V>,tick:Nat,value:V) -> St.Stream<V>:
  match old:
    case M.Missing{}:St.publish(~V,stream,tick,M.Initial{value})
    case _:St.initial(~V,stream,tick,value)
def inserted(~S:Data,~K:Data,~V:Data,state:State<S,K,V>,+value:V,tick:Nat) -> State<S,K,V>:
  match state:
    case State{+old,stream,revision}:State{insertion_slot(~S,~K,~V,value,old),insertion_stream(~S,~K,~V,old,stream,tick,value),(revision + 1n : Nat)}
def slot_returned(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & State<S,K,V>,~put:R -> State<S,K,V> -> R,resource:R,pair:State<S,K,V> & M.Slot<S,K,V>) -> R & M.Slot<S,K,V>:
  match pair:
    case (state,value):(put(resource,state),value)
def taken_slot(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & State<S,K,V>,~put:R -> State<S,K,V> -> R,pair:R & State<S,K,V>) -> R & M.Slot<S,K,V>:
  match pair:
    case (resource,state):slot_returned(~S,~K,~V,~R,~take,~put,resource,slot(~S,~K,~V,state))
def take_slot(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & State<S,K,V>,~put:R -> State<S,K,V> -> R,resource:R) -> R & M.Slot<S,K,V>:
  taken_slot(~S,~K,~V,~R,~take,~put,take(resource))
def put_taken(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & State<S,K,V>,~put:R -> State<S,K,V> -> R,~same:V -> V -> Bool,value:M.Slot<S,K,V>,pair:R & State<S,K,V>) -> R:
  match pair:
    case (resource,state):put(resource,replaced(~S,~K,~V,~same,state,value))
def put_slot(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & State<S,K,V>,~put:R -> State<S,K,V> -> R,~same:V -> V -> Bool,resource:R,value:M.Slot<S,K,V>) -> R:
  put_taken(~S,~K,~V,~R,~take,~put,~same,value,take(resource))
def declared(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & State<S,K,V>,~put:R -> State<S,K,V> -> R,name:String,values:List<&2,V>) -> OD.Declaration<S,K,V,R,take_slot(~S,~K,~V,~R,~take,~put)>:
  OD.declared(~S,~K,~V,~R,~take_slot(~S,~K,~V,~R,~take,~put),name,values)
def insert_taken(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & State<S,K,V>,~put:R -> State<S,K,V> -> R,value:V,tick:Nat,pair:R & State<S,K,V>) -> R & Unit:
  match pair:
    case (resource,state):(put(resource,inserted(~S,~K,~V,state,value,tick)),Unit{})
def inserted_world(~S:Data,~C:Type,~R:Type,~E:Data,pair:W.World<S,C,R,E> & Unit) -> W.World<S,C,R,E>:
  match pair:
    case (world,_):world
def insert_clocked(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & State<S,K,V>,~put:R -> State<S,K,V> -> R,~C:Type,~E:Data,value:V,pair:W.World<S,C,R,E> & Tick.Tick) -> W.World<S,C,R,E>:
  match pair:
    case (world,tick):inserted_world(~S,~C,~R,~E,with_resource(~S,~C,~R,~E,~Unit,(resource => insert_taken(~S,~K,~V,~R,~take,~put,value,Tick.total(tick),take(resource))),world))
# Stream publication advances administrative time independently of component run ticks.
def insert_state(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & State<S,K,V>,~put:R -> State<S,K,V> -> R,~C:Type,~E:Data,~declaration:OD.Declaration<S,K,V,R,take_slot(~S,~K,~V,~R,~take,~put)>,world:W.World<S,C,R,E>,value:V) -> W.World<S,C,R,E>:
  insert_clocked(~S,~K,~V,~R,~take,~put,~C,~E,value,W.advance_clock(~S,~C,~R,~E,world))
def defaulted(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & State<S,K,V>,~put:R -> State<S,K,V> -> R,~C:Type,~E:Data,~declaration:OD.Declaration<S,K,V,R,take_slot(~S,~K,~V,~R,~take,~put)>,pair:W.World<S,C,R,E> & V) -> W.World<S,C,R,E>:
  match pair:
    case (world,value):insert_state(~S,~K,~V,~R,~take,~put,~C,~E,~declaration,world,value)
def init_checked(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & State<S,K,V>,~put:R -> State<S,K,V> -> R,~C:Type,~E:Data,~declaration:OD.Declaration<S,K,V,R,take_slot(~S,~K,~V,~R,~take,~put)>,~make:W.World<S,C,R,E> -> W.World<S,C,R,E> & V,pair:W.World<S,C,R,E> & M.Slot<S,K,V>) -> W.World<S,C,R,E>:
  match pair:
    case (world,M.Missing{}):defaulted(~S,~K,~V,~R,~take,~put,~C,~E,~declaration,make(world))
    case (world,_):world
def init_state(~S:Data,~K:Data,~V:Data,~R:Type,~take:R -> R & State<S,K,V>,~put:R -> State<S,K,V> -> R,~C:Type,~E:Data,~declaration:OD.Declaration<S,K,V,R,take_slot(~S,~K,~V,~R,~take,~put)>,~make:W.World<S,C,R,E> -> W.World<S,C,R,E> & V,world:W.World<S,C,R,E>) -> W.World<S,C,R,E>:
  init_checked(~S,~K,~V,~R,~take,~put,~C,~E,~declaration,~make,W.observe_resource(~S,~C,~R,~E,~M.Slot<S,K,V>,~take_slot(~S,~K,~V,~R,~take,~put),world))

import Base
import transaction.bend as Tx

# Experimental machine metadata. World and component owners remain arbitrary Type.
# This module follows the pinned reference marker snapshot semantics; that behavior
# is not approval of the disputed blanket next-marker retention requirement.
type Pending<V: Data> is Data:
  NoPending{}
  Queued{value: V, skipSame: Bool}

type Transition<V: Data> is Data:
  Transition{from: V, to: V}

type Slot<S: Data, M: Data, V: Data> is Data:
  Missing{}
  Present{current: V, pending: Pending<V>, previous: Maybe<&2,V>, changed: Bool}

# Public capability projections intentionally expose less than debug metadata.
type CurrentView<S: Data,M: Data,V: Data> is Data:
  Unavailable{}
  Current{value: V}
type NextView<S: Data,M: Data,V: Data> is Data:
  NoNext{}
  Next{value: V}

def current_view(~S: Data,~M: Data,~V: Data,slot: Slot<S,M,V>) -> CurrentView<S,M,V>:
  match slot:
    case Missing{}: Unavailable{}
    case Present{current,_,_,_}: Current{current}
def pending_view(~S: Data,~M: Data,~V: Data,pending: Pending<V>) -> NextView<S,M,V>:
  match pending:
    case NoPending{}: NoNext{}
    case Queued{value,_}: Next{value}
def next_view(~S: Data,~M: Data,~V: Data,slot: Slot<S,M,V>) -> NextView<S,M,V>:
  match slot:
    case Missing{}: NoNext{}
    case Present{_,pending,_,_}: pending_view(~S,~M,~V,pending)

def is_current(~S: Data,~M: Data,~V: Data,~same: V -> V -> Bool,view: CurrentView<S,M,V>,value: V) -> Bool:
  match view:
    case Unavailable{}: False{}
    case Current{current}: same(current,value)

type Family<S: Data,M: Data,V: Data,W: Type,
  -take: W -> W & Slot<S,M,V>,-put: W -> Slot<S,M,V> -> W> is Data:
  Family{name: String}

type QueueInput<V: Data> is Data:
  Set{value: V,skipSame: Bool}
  Reset{}

type Snapshot<V: Data> is Data:
  Unscheduled{}
  Scheduled{value: V, skipSame: Bool}

type Applied<S: Data, M: Data, V: Data> is Data:
  Applied{slot: Slot<S,M,V>, event: Maybe<&2,Transition<V>>}

def queue(~S: Data,~M: Data,~V: Data,slot: Slot<S,M,V>,value: V,skipSame: Bool) -> Slot<S,M,V>:
  match slot:
    case Missing{}: Missing{}
    case Present{current,_,previous,changed}: Present{current,Queued{value,skipSame},previous,changed}

def reset(~S: Data,~M: Data,~V: Data,slot: Slot<S,M,V>) -> Slot<S,M,V>:
  match slot:
    case Missing{}: Missing{}
    case Present{current,_,previous,changed}: Present{current,NoPending{},previous,changed}

def clear_changed(~S: Data,~M: Data,~V: Data,slot: Slot<S,M,V>) -> Slot<S,M,V>:
  match slot:
    case Missing{}: Missing{}
    case Present{current,pending,previous,_}: Present{current,pending,previous,False{}}

def snapshot_pending(~V: Data,pending: Pending<V>) -> Snapshot<V>:
  match pending:
    case NoPending{}: Unscheduled{}
    case Queued{value,skipSame}: Scheduled{value,skipSame}

def snapshot(~S: Data,~M: Data,~V: Data,slot: Slot<S,M,V>) -> Snapshot<V>:
  match slot:
    case Missing{}: Unscheduled{}
    case Present{_,pending,_,_}: snapshot_pending(~V,pending)

def apply_decision(~S: Data,~M: Data,~V: Data,+current: V,+value: V,previous: Maybe<&2,V>,changed: Bool,skip: Bool) -> Applied<S,M,V>:
  match skip:
    case True{}: Applied{Present{current,NoPending{},previous,changed},None{}}
    case False{}: Applied{Present{value,NoPending{},Some{current},True{}},Some{Transition{current,value}}}

def apply_present(~S: Data,~M: Data,~V: Data,~same: V -> V -> Bool,+current: V,+value: V,previous: Maybe<&2,V>,changed: Bool,skipSame: Bool) -> Applied<S,M,V>:
  apply_decision(~S,~M,~V,current,value,previous,changed,Bool.and(skipSame,same(current,value)))

# Captured initial value is authoritative; current pending is deleted at the
# machine's turn, matching Runtime.ts:1534 even when an earlier hook overwrote it.
def apply_snapshot(~S: Data,~M: Data,~V: Data,~same: V -> V -> Bool,slot: Slot<S,M,V>,captured: Snapshot<V>) -> Applied<S,M,V>:
  match slot captured:
    case slot Unscheduled{}: Applied{slot,None{}}
    case Missing{} Scheduled{_,_}: Applied{Missing{},None{}}
    case Present{current,_,previous,changed} Scheduled{value,skipSame}:
      apply_present(~S,~M,~V,~same,current,value,previous,changed,skipSame)

# Journal the complete old slot before replacing it. Aliases see the current
# world through the same affine transaction; no independent machine owner copy.
def write_taken(~S: Data,~M: Data,~V: Data,~W: Type,~E: Data,
  ~put: W -> Slot<S,M,V> -> W,
  pair: W & Slot<S,M,V>,undo: List<&1,(W -> W)>,commands: List<&1,(W -> W)>,events: List<&2,E>,value: V,skipSame: Bool) -> Tx.Tx<W,E>:
  match pair:
    case (world,+old):
      Tx.Tx{put(world,queue(~S,~M,~V,old,value,skipSame)),(world => put(world,old)) <> undo,commands,events}

def write(~S: Data,~M: Data,~V: Data,~W: Type,~E: Data,
  ~take: W -> W & Slot<S,M,V>,~put: W -> Slot<S,M,V> -> W,
  tx: Tx.Tx<W,E>,value: V,skipSame: Bool) -> Tx.Tx<W,E>:
  match tx:
    case Tx.Tx{world,undo,commands,events}:
      write_taken(~S,~M,~V,~W,~E,~put,take(world),undo,commands,events,value,skipSame)

def reset_taken(~S: Data,~M: Data,~V: Data,~W: Type,~E: Data,
  ~put: W -> Slot<S,M,V> -> W,
  pair: W & Slot<S,M,V>,undo: List<&1,(W -> W)>,commands: List<&1,(W -> W)>,events: List<&2,E>) -> Tx.Tx<W,E>:
  match pair:
    case (world,+old):
      Tx.Tx{put(world,reset(~S,~M,~V,old)),(world => put(world,old)) <> undo,commands,events}

def reset_tx(~S: Data,~M: Data,~V: Data,~W: Type,~E: Data,
  ~take: W -> W & Slot<S,M,V>,~put: W -> Slot<S,M,V> -> W,
  tx: Tx.Tx<W,E>) -> Tx.Tx<W,E>:
  match tx:
    case Tx.Tx{world,undo,commands,events}:
      reset_taken(~S,~M,~V,~W,~E,~put,take(world),undo,commands,events)

def next(~S: Data,~M: Data,~V: Data,~W: Type,~E: Data,
  ~take: W -> W & Slot<S,M,V>,~put: W -> Slot<S,M,V> -> W,
  tx: Tx.Tx<W,E>,request: QueueInput<V>) -> Tx.Tx<W,E>:
  match request:
    case Set{value,skipSame}: write(~S,~M,~V,~W,~E,~take,~put,tx,value,skipSame)
    case Reset{}: reset_tx(~S,~M,~V,~W,~E,~take,~put,tx)

def read_taken(~S: Data,~M: Data,~V: Data,~W: Type,~E: Data,
  pair: W & Slot<S,M,V>,undo: List<&1,(W -> W)>,commands: List<&1,(W -> W)>,events: List<&2,E>) -> Tx.Tx<W,E> & Slot<S,M,V>:
  match pair:
    case (world,slot): (Tx.Tx{world,undo,commands,events},slot)

def read(~S: Data,~M: Data,~V: Data,~W: Type,~E: Data,
  ~take: W -> W & Slot<S,M,V>,tx: Tx.Tx<W,E>) -> Tx.Tx<W,E> & Slot<S,M,V>:
  match tx:
    case Tx.Tx{world,undo,commands,events}: read_taken(~S,~M,~V,~W,~E,take(world),undo,commands,events)

def read_declared(~S: Data,~M: Data,~V: Data,~W: Type,~E: Data,
  ~take: W -> W & Slot<S,M,V>,~put: W -> Slot<S,M,V> -> W,
  _: Family<S,M,V,W,take,put>,tx: Tx.Tx<W,E>) -> Tx.Tx<W,E> & Slot<S,M,V>:
  read(~S,~M,~V,~W,~E,~take,tx)

def next_declared(~S: Data,~M: Data,~V: Data,~W: Type,~E: Data,
  ~take: W -> W & Slot<S,M,V>,~put: W -> Slot<S,M,V> -> W,
  _: Family<S,M,V,W,take,put>,tx: Tx.Tx<W,E>,request: QueueInput<V>) -> Tx.Tx<W,E>:
  next(~S,~M,~V,~W,~E,~take,~put,tx,request)

type Condition<V: Data> is Data:
  InState{value: V}
  StateChanged{}
  Not{inner: Condition<V>}
  Constant{value: Bool}
  And{left: Condition<V>,right: Condition<V>}
  Or{left: Condition<V>,right: Condition<V>}

def current_matches(~S: Data,~M: Data,~V: Data,~same: V -> V -> Bool,slot: Slot<S,M,V>,value: V) -> Bool:
  match slot:
    case Missing{}: False{}
    case Present{current,_,_,_}: same(current,value)

def changed(~S: Data,~M: Data,~V: Data,slot: Slot<S,M,V>) -> Bool:
  match slot:
    case Missing{}: False{}
    case Present{_,_,_,flag}: flag

# Arbitrary public variadic combinations become a structural Boolean tree.
# Empty and/or preserve the primary API identities.
def all(~V: Data,items: List<&2,Condition<V>>) -> Condition<V>:
  match items:
    case Nil{}: Constant{True{}}
    case Con{head,tail}: And{head,all(~V,tail)}

def any(~V: Data,items: List<&2,Condition<V>>) -> Condition<V>:
  match items:
    case Nil{}: Constant{False{}}
    case Con{head,tail}: Or{head,any(~V,tail)}

def evaluate(~S: Data,~M: Data,~V: Data,~same: V -> V -> Bool,condition: Condition<V>,+slot: Slot<S,M,V>) -> Bool:
  match condition:
    case InState{value}: current_matches(~S,~M,~V,~same,slot,value)
    case StateChanged{}: changed(~S,~M,~V,slot)
    case Not{inner}: Bool.not(evaluate(~S,~M,~V,~same,inner,slot))
    case Constant{value}: value
    case And{left,right}: Bool.and(evaluate(~S,~M,~V,~same,left,slot),evaluate(~S,~M,~V,~same,right,slot))
    case Or{left,right}: Bool.or(evaluate(~S,~M,~V,~same,left,slot),evaluate(~S,~M,~V,~same,right,slot))

# A heterogeneous marker snapshot owns each callback exactly once. Each callback
# captures a Data machine value and closed lenses, never a world/component owner.
type Marker<S: Data,W: Type> is Type:
  Marker{steps: List<&1,(W -> W)>}

def marker_steps(~W: Type,steps: List<&1,(W -> W)>,world: W) -> W:
  match steps:
    case Nil{}: world
    case Con{step,rest}: marker_steps(~W,rest,step(world))

def run_marker(~S: Data,~W: Type,marker: Marker<S,W>,world: W) -> W:
  match marker:
    case Marker{steps}: marker_steps(~W,steps,world)

# Registered schedule/transition owners live alongside the world and are also
# threaded, rather than copied into one closure per machine.
type OwnedMarker<S: Data,W: Type,H: Type> is Type:
  OwnedMarker{steps: List<&1,(H -> W -> H & W)>}

def marker_next(~W: Type,~H: Type,next: H -> W -> H & W,pair: H & W) -> H & W:
  (owners,world)=pair
  next(owners,world)

def owned_marker_steps(~W: Type,~H: Type,steps: List<&1,(H -> W -> H & W)>,owners: H,world: W) -> H & W:
  match steps:
    case Nil{}: (owners,world)
    case Con{step,rest}: marker_next(~W,~H,h => w => owned_marker_steps(~W,~H,rest,h,w),step(owners,world))

def run_owned_marker(~S: Data,~W: Type,~H: Type,marker: OwnedMarker<S,W,H>,owners: H,world: W) -> H & W:
  match marker:
    case OwnedMarker{steps}: owned_marker_steps(~W,~H,steps,owners,world)

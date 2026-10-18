import Base
import entity-key.bend as K

type Phase is Data:
  Consumed{}
  Pending{}
  Live{}
  DeadRetained{}
  Free{}
type Slot is Data:
  Slot{generation:U32,phase:Phase}
type Allocator is Type:
  Allocator{next:U32,high:U32,slots:Array<Slot>,capacity:U32,depth:Nat,free:List<&2,U32>,order:List<&2,K.Key>}
type Reservation is Data:
  Reserved{key:K.Key}
  Exhausted{}

def empty() -> Allocator:
  Allocator{1,0,Array.new(Slot,0n,Slot{0,Consumed{}}),1,0n,[],[]}

def live(phase:Phase) -> Bool:
  match phase:
    case Live{}:True{}
    case _:False{}
def pending(phase:Phase) -> Bool:
  match phase:
    case Pending{}:True{}
    case _:False{}
def metadata(phase:Phase) -> Bool:
  match phase:
    case Free{}:False{}
    case _:True{}
def phase_valid(mode:U32,phase:Phase) -> Bool:
  match mode:
    case 0:metadata(phase)
    case 1:live(phase)
    case _:pending(phase)
def slot_valid(+key:K.Key,mode:U32,slot:Slot) -> Bool:
  match slot:
    case Slot{generation,phase}:Bool.and(U32.is_eq(K.generation(key),generation),phase_valid(mode,phase))
def checked_slot(+key:K.Key,mode:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,+free:List<&2,U32>,+order:List<&2,K.Key>,observed:Array<Slot> & Slot) -> Allocator & Bool:
  match observed:
    case (slots,slot):(Allocator{next,high,slots,capacity,depth,free,order},slot_valid(key,mode,slot))
def checked_bounds(allowed:Bool,allocator:Allocator,+key:K.Key,mode:U32) -> Allocator & Bool:
  match allowed allocator:
    case False{} allocator:(allocator,False{})
    case True{} Allocator{+next,+high,slots,+capacity,+depth,+free,+order}:checked_slot(key,mode,next,high,capacity,depth,free,order,Array.get(Slot,slots,K.index(key)))
def checked(allocator:Allocator,+key:K.Key,mode:U32) -> Allocator & Bool:
  match allocator:
    case Allocator{+next,high,slots,+capacity,depth,free,order}:checked_bounds(Bool.and(U32.is_lt(0,K.index(key)),Bool.and(U32.is_lt(K.index(key),next),U32.is_lt(K.index(key),capacity))),Allocator{next,high,slots,capacity,depth,free,order},key,mode)

def keep(same:Bool,head:K.Key,rest:List<&2,K.Key>) -> List<&2,K.Key>:
  match same:
    case True{}:rest
    case False{}:head <> rest

def without(keys:List<&2,K.Key>,+key:K.Key) -> List<&2,K.Key>:
  match keys:
    case []:[]
    case +head <> rest:keep(K.equal(head,key),head,without(rest,key))

def phase_slot(key:K.Key,phase:Phase) -> Slot:
  Slot{K.generation(key),phase}
def write_phase(allocator:Allocator,+key:K.Key,phase:Phase) -> Allocator:
  match allocator:
    case Allocator{next,high,slots,capacity,depth,free,order}:Allocator{next,high,Array.set(Slot,slots,K.index(key),phase_slot(key,phase)),capacity,depth,free,order}
def set_checked(phase:Phase,+key:K.Key,observed:Allocator & Bool) -> Allocator & Bool:
  match observed:
    case (allocator,False{}):(allocator,False{})
    case (allocator,True{}):(write_phase(allocator,key,phase),True{})
def set(allocator:Allocator,+key:K.Key,phase:Phase) -> Allocator & Bool:
  set_checked(phase,key,checked(allocator,key,0))
def abandon_checked(+key:K.Key,observed:Allocator & Bool) -> Allocator:
  match observed:
    case (allocator,False{}):allocator
    case (Allocator{next,high,slots,capacity,depth,free,order},True{}):Allocator{next,high,Array.set(Slot,slots,K.index(key),phase_slot(key,Consumed{})),capacity,depth,free,without(order,key)}
def abandon(allocator:Allocator,+key:K.Key) -> Allocator:
  abandon_checked(key,checked(allocator,key,2))

def release_checked(+key:K.Key,observed:Allocator & Bool) -> Allocator:
  match observed:
    case (allocator,False{}):allocator
    case (Allocator{next,high,slots,capacity,depth,free,order},True{}):Allocator{next,high,Array.set(Slot,slots,K.index(key),Slot{(K.generation(key) + 1 : U32),Free{}}),capacity,depth,K.index(key) <> free,without(order,key)}
def release(allocator:Allocator,+key:K.Key) -> Allocator:
  release_checked(key,checked(allocator,key,0))

def reserve_recycled(+index:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,+free:List<&2,U32>,+order:List<&2,K.Key>,observed:Array<Slot> & Slot) -> Allocator & Reservation:
  match observed:
    case (slots,Slot{+generation,_}):(Allocator{next,high,Array.set(Slot,slots,index,Slot{generation,Consumed{}}),capacity,depth,free,List.append(&2,K.Key,order,[K.EntityKey{index,generation}])},Reserved{K.EntityKey{index,generation}})
def reserve_fresh(available:Bool,grow:Bool,allocator:Allocator) -> Allocator & Reservation:
  match available grow allocator:
    case False{} _ allocator:(allocator,Exhausted{})
    case True{} False{} Allocator{+next,_,slots,+capacity,+depth,free,order}:(Allocator{(next + 1 : U32),next,Array.set(Slot,slots,next,Slot{0,Consumed{}}),capacity,depth,free,List.append(&2,K.Key,order,[K.EntityKey{next,0}])},Reserved{K.EntityKey{next,0}})
    case True{} True{} Allocator{+next,_,slots,+capacity,+depth,free,order}:(Allocator{(next + 1 : U32),next,Array.set(Slot,ANode{slots,Array.new(Slot,depth,Slot{0,Consumed{}})},next,Slot{0,Consumed{}}),(capacity * 2 : U32),1n+depth,free,List.append(&2,K.Key,order,[K.EntityKey{next,0}])},Reserved{K.EntityKey{next,0}})
def reserve(allocator:Allocator) -> Allocator & Reservation:
  match allocator:
    case Allocator{+next,high,slots,+capacity,depth,[],order}:reserve_fresh(U32.is_lt(next,131073),Bool.not(U32.is_lt(next,capacity)),Allocator{next,high,slots,capacity,depth,[],order})
    case Allocator{+next,+high,slots,+capacity,+depth,+index <> free,+order}:reserve_recycled(index,next,high,capacity,depth,free,order,Array.get(Slot,slots,index))

def visible_join(+key:K.Key,next:Allocator -> List<&2,K.Key> -> Allocator & List<&2,K.Key>,reversed:List<&2,K.Key>,observed:Allocator & Bool) -> Allocator & List<&2,K.Key>:
  match observed:
    case (allocator,present):next(allocator,keep(Bool.not(present),key,reversed))
def visible_loop(keys:List<&2,K.Key>,allocator:Allocator,reversed:List<&2,K.Key>) -> Allocator & List<&2,K.Key>:
  match keys:
    case []:(allocator,List.reverse(&2,K.Key,reversed))
    case +key <> rest:visible_join(key,(allocator => reversed => visible_loop(rest,allocator,reversed)),reversed,checked(allocator,key,1))
def visible(allocator:Allocator) -> Allocator & List<&2,K.Key>:
  match allocator:
    case Allocator{next,high,slots,capacity,depth,free,+order}:visible_loop(order,Allocator{next,high,slots,capacity,depth,free,order},[])

# Restore cancellation consumes queued reservations without freeing their IDs.
def abandon_pending_kept(+key:K.Key,observed:Allocator & List<&2,K.Key>) -> Allocator & List<&2,K.Key>:
  match observed:
    case (allocator,keys):(allocator,key <> keys)
def abandon_pending_checked(+key:K.Key,next:Allocator -> Allocator & List<&2,K.Key>,observed:Allocator & Bool) -> Allocator & List<&2,K.Key>:
  match observed:
    case (allocator,True{}):next(write_phase(allocator,key,Consumed{}))
    case (allocator,False{}):abandon_pending_kept(key,next(allocator))
def abandon_pending_loop(keys:List<&2,K.Key>,allocator:Allocator) -> Allocator & List<&2,K.Key>:
  match keys:
    case []:(allocator,[])
    case +key <> rest:abandon_pending_checked(key,next => abandon_pending_loop(rest,next),checked(allocator,key,2))
def abandon_pending_join(observed:Allocator & List<&2,K.Key>) -> Allocator:
  match observed:
    case (Allocator{next,high,slots,capacity,depth,free,_},order):Allocator{next,high,slots,capacity,depth,free,order}
def abandon_pending(allocator:Allocator) -> Allocator:
  match allocator:
    case Allocator{+next,+high,slots,+capacity,+depth,+free,+order}:abandon_pending_join(abandon_pending_loop(order,Allocator{next,high,slots,capacity,depth,free,order}))

# A file may advance fresh-index progress, never replace generations or owners.
def floor_finish(+floor:U32,allocator:Allocator) -> Allocator:
  match allocator:
    case Allocator{next,high,slots,capacity,depth,free,order}:Allocator{U32.max(next,floor),U32.max(high,U32.sub(floor,1)),slots,capacity,depth,free,order}
def floor_step(grow:Bool,+floor:U32,next:Allocator -> Allocator,allocator:Allocator) -> Allocator:
  match grow allocator:
    case False{} allocator:floor_finish(floor,allocator)
    case True{} Allocator{n,high,slots,+capacity,+depth,free,order}:next(Allocator{n,high,ANode{slots,Array.new(Slot,depth,Slot{0,Consumed{}})},(capacity * 2 : U32),1n+depth,free,order})
def floor_grow(fuel:Nat,+floor:U32,allocator:Allocator) -> Allocator:
  match fuel allocator:
    case 0n allocator:floor_finish(floor,allocator)
    case 1n+rest Allocator{+next,+high,slots,+capacity,+depth,+free,+order}:floor_step(U32.is_lt(capacity,floor),floor,owner => floor_grow(rest,floor,owner),Allocator{next,high,slots,capacity,depth,free,order})
def floor_checked(allowed:Bool,+floor:U32,allocator:Allocator) -> Allocator & Bool:
  match allowed:
    case False{}:(allocator,False{})
    case True{}:(floor_grow(18n,floor,allocator),True{})
def advance_floor(allocator:Allocator,+floor:U32) -> Allocator & Bool:
  floor_checked(Bool.and(U32.is_lt(0,floor),U32.is_le(floor,131073)),floor,allocator)

def count_keys(keys:List<&2,K.Key>) -> Nat:
  match keys:
    case []:0n
    case _ <> rest:1n+count_keys(rest)
def count_free(keys:List<&2,U32>) -> Nat:
  match keys:
    case []:0n
    case _ <> rest:1n+count_free(rest)
def restore_room_join(+floor:U32,needed:Nat,observed:Allocator & List<&2,K.Key>) -> Allocator & Bool:
  match observed:
    case (Allocator{+next,+high,slots,+capacity,+depth,+free,+order},live):
      (Allocator{next,high,slots,capacity,depth,free,order},Bool.and(Bool.and(U32.is_lt(0,floor),U32.is_le(floor,131073)),Nat.is_le(needed,Nat.add(Nat.add(count_keys(live),count_free(free)),U32.to_nat(U32.sub(131073,U32.max(next,floor)))))))
def restore_room(allocator:Allocator,floor:U32,needed:Nat) -> Allocator & Bool:
  restore_room_join(floor,needed,visible(allocator))

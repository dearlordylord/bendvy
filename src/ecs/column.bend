import Base
import lifecycle.bend as L

# Schema provisioning owns columns. Gameplay receives abstract providers instead.
# IDs are one-based; this bounded slice supports at most 131072 slots.
type Column<-S: Data, -C: Type> is Type:
  Column{values: Array<Maybe<&1,C>>,stamps: List<&2,L.Entry>}

type SwapOutcome<-S: Data, -C: Type> is Type:
  Accepted{column: Column<S,C>, previous: Maybe<&1,C>}
  Rejected{column: Column<S,C>, incoming: Maybe<&1,C>}

def absent(~C: Type, +depth: Nat) -> Array<Maybe<&1,C>>:
  match depth:
    case 0n:
      ALeaf{None{}}
    case 1n+rest:
      ANode{absent(~C, rest), absent(~C, rest)}

def empty(~S: Data, ~C: Type) -> Column<S,C>:
  Column{ALeaf{None{}},[]}

def grow(~S: Data, ~C: Type, fuel: Nat, values: Array<Maybe<&1,C>>, +stamps: List<&2,L.Entry>, +size: U32, +depth: Nat, +target: U32, enough: Bool) -> Column<S,C>:
  match fuel enough:
    case _ True{}:
      Column{values,stamps}
    case 0n False{}:
      Column{values,stamps}
    case 1n+rest False{}:
      +next = U32.shl(size)
      grow(~S, ~C, rest, ANode{values, absent(~C, depth)}, stamps, next, 1n+depth, target, U32.is_le(target, next))

def ensure_sized(~S: Data, ~C: Type, +target: U32, +stamps: List<&2,L.Entry>, sized: Array<Maybe<&1,C>> & U32) -> Column<S,C>:
  (values, +size) = sized
  grow(~S, ~C, 17n, values, stamps, size, U32.log2(size), target, U32.is_le(target, size))

def ensure_checked(~S: Data, ~C: Type, column: Column<S,C>, target: U32, valid: Bool) -> Column<S,C>:
  match column valid:
    case _ False{}:
      column
    case Column{values,stamps} True{}:
      ensure_sized(~S, ~C, target, stamps, Array.size(Maybe<&1,C>, values))

def ensure(~S: Data, ~C: Type, column: Column<S,C>, +target: U32) -> Column<S,C>:
  ensure_checked(~S, ~C, column, target, U32.is_gt(target, 0) && U32.is_le(target, 131072))

def swapped(~S: Data, ~C: Type, result: Array<Maybe<&1,C>> & Maybe<&1,C>,stamps: List<&2,L.Entry>) -> SwapOutcome<S,C>:
  (values, previous) = result
  Accepted{Column{values,stamps}, previous}

def swap_checked(~S: Data, ~C: Type, values: Array<Maybe<&1,C>>,stamps: List<&2,L.Entry>, id: U32, incoming: Maybe<&1,C>, valid: Bool) -> SwapOutcome<S,C>:
  match valid:
    case False{}:
      Rejected{Column{values,stamps}, incoming}
    case True{}:
      swapped(~S, ~C, Array.swap(Maybe<&1,C>, values, U32.sub(id, 1), incoming),stamps)

def swap_sized(~S: Data, ~C: Type, +id: U32, incoming: Maybe<&1,C>, stamps: List<&2,L.Entry>, sized: Array<Maybe<&1,C>> & U32) -> SwapOutcome<S,C>:
  (values, size) = sized
  swap_checked(~S, ~C, values, stamps, id, incoming, U32.is_gt(id, 0) && U32.is_le(id, size) && U32.is_le(id, 131072))

def swap(~S: Data, ~C: Type, column: Column<S,C>, id: U32, incoming: Maybe<&1,C>) -> SwapOutcome<S,C>:
  Column{values,stamps} = column
  swap_sized(~S, ~C, id, incoming, stamps, Array.size(Maybe<&1,C>, values))

def remove(~S: Data, ~C: Type, column: Column<S,C>, id: U32) -> SwapOutcome<S,C>:
  swap(~S, ~C, column, id, None{})

def restored(~S: Data, ~C: Type, ~V: Data, result: Array<Maybe<&1,C>> & Maybe<&1,C>, projection: V,stamps: List<&2,L.Entry>) -> Column<S,C> & Maybe<&2,V>:
  (values, none) = result
  (Column{values,stamps}, Some{projection})

def viewed(~S: Data, ~C: Type, ~V: Data, projected: C & V, column: Column<S,C>, id: U32) -> Column<S,C> & Maybe<&2,V>:
  match projected column:
    case (owner, result) Column{values,stamps}:
      restored(~S, ~C, ~V, Array.swap(Maybe<&1,C>, values, U32.sub(id, 1), Some{owner}), result,stamps)

def view_taken(~S: Data, ~C: Type, ~V: Data, ~project: C -> C & V, id: U32, outcome: SwapOutcome<S,C>) -> Column<S,C> & Maybe<&2,V>:
  match outcome:
    case Rejected{column, incoming}:
      (column, None{})
    case Accepted{column, None{}}:
      (column, None{})
    case Accepted{column, Some{owner}}:
      viewed(~S, ~C, ~V, project(owner), column, id)

def view(~S: Data, ~C: Type, ~V: Data, ~project: C -> C & V, column: Column<S,C>, +id: U32) -> Column<S,C> & Maybe<&2,V>:
  view_taken(~S, ~C, ~V, ~project, id, swap(~S, ~C, column, id, None{}))

def present(~C: Type, owner: C) -> C & Bool:
  (owner, True{})

def presence(~S: Data, ~C: Type, result: Column<S,C> & Maybe<&2,Bool>) -> Column<S,C> & Bool:
  match result:
    case (column, None{}):
      (column, False{})
    case (column, Some{found}):
      (column, found)

def has(~S: Data, ~C: Type, column: Column<S,C>, id: U32) -> Column<S,C> & Bool:
  presence(~S, ~C, view(~S, ~C, ~Bool, ~present(~C), column, id))

# Raw owner swaps/projection are metadata-neutral. Only the component world
# write seam advances stamps, and rollback restores a saved stamp explicitly.
def lifecycle(~S: Data,~C: Type,column: Column<S,C>,+id: U32) -> Column<S,C> & L.Stamp:
  match column:
    case Column{values,+stamps}: (Column{values,stamps},L.get(stamps,id))

def restore_stamp(~S: Data,~C: Type,column: Column<S,C>,+id: U32,stamp: L.Stamp) -> Column<S,C>:
  match column:
    case Column{values,stamps}: Column{values,L.set(stamps,id,stamp)}

def mark(~S: Data,~C: Type,column: Column<S,C>,+id: U32,incoming: Bool,wasPresent: Bool,tick: U32) -> Column<S,C>:
  match column:
    case Column{values,+stamps}: Column{values,L.set(stamps,id,L.after_write(incoming,wasPresent,L.get(stamps,id),tick))}

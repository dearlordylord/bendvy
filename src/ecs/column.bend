import Base

# Schema provisioning owns columns. Gameplay receives abstract providers instead.
# IDs are one-based; this bounded slice supports at most 131072 slots.
type Column<-S: Data, -C: Type> is Type:
  Column{values: Array<Maybe<&1,C>>}

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
  Column{ALeaf{None{}}}

def grow(~S: Data, ~C: Type, fuel: Nat, values: Array<Maybe<&1,C>>, +size: U32, +depth: Nat, +target: U32, enough: Bool) -> Column<S,C>:
  match fuel enough:
    case _ True{}:
      Column{values}
    case 0n False{}:
      Column{values}
    case 1n+rest False{}:
      +next = U32.shl(size)
      grow(~S, ~C, rest, ANode{values, absent(~C, depth)}, next, 1n+depth, target, U32.is_le(target, next))

def ensure_sized(~S: Data, ~C: Type, +target: U32, sized: Array<Maybe<&1,C>> & U32) -> Column<S,C>:
  (values, +size) = sized
  grow(~S, ~C, 17n, values, size, U32.log2(size), target, U32.is_le(target, size))

def ensure_checked(~S: Data, ~C: Type, column: Column<S,C>, target: U32, valid: Bool) -> Column<S,C>:
  match column valid:
    case _ False{}:
      column
    case Column{values} True{}:
      ensure_sized(~S, ~C, target, Array.size(Maybe<&1,C>, values))

def ensure(~S: Data, ~C: Type, column: Column<S,C>, +target: U32) -> Column<S,C>:
  ensure_checked(~S, ~C, column, target, U32.is_gt(target, 0) && U32.is_le(target, 131072))

def swapped(~S: Data, ~C: Type, result: Array<Maybe<&1,C>> & Maybe<&1,C>) -> SwapOutcome<S,C>:
  (values, previous) = result
  Accepted{Column{values}, previous}

def swap_checked(~S: Data, ~C: Type, values: Array<Maybe<&1,C>>, id: U32, incoming: Maybe<&1,C>, valid: Bool) -> SwapOutcome<S,C>:
  match valid:
    case False{}:
      Rejected{Column{values}, incoming}
    case True{}:
      swapped(~S, ~C, Array.swap(Maybe<&1,C>, values, U32.sub(id, 1), incoming))

def swap_sized(~S: Data, ~C: Type, +id: U32, incoming: Maybe<&1,C>, sized: Array<Maybe<&1,C>> & U32) -> SwapOutcome<S,C>:
  (values, size) = sized
  swap_checked(~S, ~C, values, id, incoming, U32.is_gt(id, 0) && U32.is_le(id, size) && U32.is_le(id, 131072))

def swap(~S: Data, ~C: Type, column: Column<S,C>, id: U32, incoming: Maybe<&1,C>) -> SwapOutcome<S,C>:
  Column{values} = column
  swap_sized(~S, ~C, id, incoming, Array.size(Maybe<&1,C>, values))

def remove(~S: Data, ~C: Type, column: Column<S,C>, id: U32) -> SwapOutcome<S,C>:
  swap(~S, ~C, column, id, None{})

def restored(~S: Data, ~C: Type, ~V: Data, result: Array<Maybe<&1,C>> & Maybe<&1,C>, projection: V) -> Column<S,C> & Maybe<&2,V>:
  (values, none) = result
  (Column{values}, Some{projection})

def viewed(~S: Data, ~C: Type, ~V: Data, projected: C & V, column: Column<S,C>, id: U32) -> Column<S,C> & Maybe<&2,V>:
  match projected column:
    case (owner, result) Column{values}:
      restored(~S, ~C, ~V, Array.swap(Maybe<&1,C>, values, U32.sub(id, 1), Some{owner}), result)

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

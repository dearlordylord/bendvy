import Base

type Batch is Data:
  Batch{tick: U32, values: List<&2, U32>}
type Cursor is Data:
  Cursor{last: U32, registered: U32}
type Trimmed is Data:
  Trimmed{batches: List<&2, Batch>, dropped: U32}
type Log is Type:
  Log{capacity: Nat, batches: List<&2, Batch>, dropped: U32}

def min_choose(smaller: Bool, a: U32, b: U32) -> U32:
  match smaller:
    case True{}: a
    case False{}: b
def minimum(+a: U32, +b: U32) -> U32:
  min_choose(U32.is_lt(a, b), a, b)
def maximum(+a: U32, +b: U32) -> U32:
  min_choose(U32.is_lt(a, b), b, a)
def oldest_boundary(xs: List<&2, Cursor>, boundary: U32) -> U32:
  match xs:
    case Nil{}: boundary
    case Con{Cursor{last, _}, tail}: oldest_boundary(tail, minimum(last, boundary))
def expired(xs: List<&2, Batch>, boundary: U32) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{Batch{tick, _}, _}: U32.is_le(tick, boundary)
def expire_rows(xs: List<&2, Batch>, old: Bool, +boundary: U32, dropped: U32) -> Trimmed:
  match xs old:
    case Nil{} _: Trimmed{[], dropped}
    case Con{batch, tail} False{}: Trimmed{batch <> tail, dropped}
    case Con{Batch{tick, _}, +tail} True{}: expire_rows(tail, expired(tail, boundary), boundary, maximum(dropped, tick))
def size(xs: List<&2, Batch>) -> Nat:
  match xs:
    case Nil{}: 0n
    case Con{Batch{_, values}, tail}: Nat.add(List.length(&2, U32, values), size(tail))
def capacity_rows(xs: List<&2, Batch>, overflow: Bool, +capacity: Nat, total: Nat, dropped: U32) -> Trimmed:
  match xs overflow:
    case Nil{} _: Trimmed{[], dropped}
    case Con{batch, tail} False{}: Trimmed{batch <> tail, dropped}
    case Con{Batch{tick, values}, +tail} True{}: capacity_rows(tail, Nat.is_gt(Nat.sub(total, List.length(&2, U32, values)), capacity), capacity, size(tail), maximum(dropped, tick))
def trim_result(capacity: Nat, result: Trimmed) -> Log:
  match result:
    case Trimmed{xs, dropped}: Log{capacity, xs, dropped}
def trim_capacity(+capacity: Nat, result: Trimmed) -> Log:
  match result:
    case Trimmed{+xs, dropped}: trim_result(capacity, capacity_rows(xs, Nat.is_gt(size(xs), capacity), capacity, size(xs), dropped))
def trim(l: Log, +readers: List<&2, Cursor>, +window: U32) -> Log:
  match l:
    case Log{capacity, +xs, dropped}: trim_capacity(capacity, expire_rows(xs, expired(xs, oldest_boundary(readers, window)), oldest_boundary(readers, window), dropped))
def append_values(nonempty: Bool, capacity: Nat, batches: List<&2, Batch>, dropped: U32, tick: U32, values: List<&2, U32>) -> Log:
  match nonempty:
    case False{}: Log{capacity, batches, dropped}
    case True{}: Log{capacity, List.append(&2, Batch, batches, [Batch{tick, values}]), dropped}
def append(l: Log, tick: U32, +values: List<&2, U32>) -> Log:
  match l:
    case Log{capacity, batches, dropped}: append_values(Nat.is_gt(List.length(&2, U32, values), 0n), capacity, batches, dropped, tick, values)
def read_choose(new: Bool, values: List<&2, U32>, rest: List<&2, U32>) -> List<&2, U32>:
  match new:
    case False{}: rest
    case True{}: List.append(&2, U32, values, rest)
def since(xs: List<&2, Batch>, +last: U32) -> List<&2, U32>:
  match xs:
    case Nil{}: []
    case Con{Batch{tick, values}, tail}: read_choose(U32.is_gt(tick, last), values, since(tail, last))
def read(l: Log, cursor: Cursor) -> Log & (List<&2, U32> & Bool):
  match l cursor:
    case Log{capacity, +xs, +dropped} Cursor{+last, registered}: (Log{capacity, xs, dropped}, (since(xs, last), U32.is_gt(dropped, maximum(last, registered))))
def complete_success(cursor: Cursor, started: U32) -> Cursor:
  match cursor:
    case Cursor{_, registered}: Cursor{started, registered}
def complete(outcome: Bool, cursor: Cursor, started: U32) -> Cursor:
  match outcome:
    case True{}: complete_success(cursor, started)
    case False{}: cursor
def skip(cursor: Cursor, current: U32) -> Cursor:
  complete_success(cursor, current)

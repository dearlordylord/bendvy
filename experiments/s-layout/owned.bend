import Base

type Motion is Data:
  Motion{}
type Health is Data:
  Health{}
type Payload is Type:
  Payload{items: Array<U32>}
type Cell<-S: Data> is Type:
  Cell{payload: Payload, undo: List<&2, U32>}
type Store<-S: Data> is Type:
  Store{cells: Array<Maybe<Cell<S>>>, committed: List<&2, U32>, staged: List<&2, U32>}
def initial(~S: Data) -> Store<S>:
  Store{ANode{ALeaf{Some{Cell{Payload{[10 : U32^2n]}, []}}}, ALeaf{Some{Cell{Payload{[20 : U32^2n]}, []}}}}, [], []}
def got(~S: Data, undo: List<&2, U32>, result: Array<U32> & U32) -> Cell<S> & U32:
  match result:
    case (items, x): (Cell{Payload{items}, undo}, x)
def get(~S: Data, c: Cell<S>, token: S) -> Cell<S> & U32:
  match c:
    case Cell{Payload{items}, undo}: got(~S, undo, Array.get(U32, items, 1))
def set_got(~S: Data, x: U32, undo: List<&2, U32>, result: Array<U32> & U32) -> Cell<S>:
  match result:
    case (items, old): Cell{Payload{Array.set(U32, items, 1, x)}, old <> undo}
def set(~S: Data, c: Cell<S>, token: S, x: U32) -> Cell<S>:
  match c:
    case Cell{Payload{items}, undo}: set_got(~S, x, undo, Array.get(U32, items, 1))
def restore_values(undo: List<&2, U32>, items: Array<U32>) -> Array<U32>:
  match undo:
    case Nil{}: items
    case Con{x, tail}: restore_values(tail, Array.set(U32, items, 1, x))
def finish_cell(~S: Data, success: Bool, c: Cell<S>) -> Cell<S>:
  match success c:
    case True{} Cell{payload, _}: Cell{payload, []}
    case False{} Cell{Payload{items}, undo}: Cell{Payload{restore_values(undo, items)}, []}
def replaced(~S: Data, result: Array<Maybe<Cell<S>>> & Maybe<Cell<S>>) -> Array<Maybe<Cell<S>>>:
  match result:
    case (cells, _): cells

def replace(~S: Data, cells: Array<Maybe<Cell<S>>>, id: U32, value: Maybe<Cell<S>>) -> Array<Maybe<Cell<S>>>:
  replaced(~S, Array.swap(Maybe<Cell<S>>, cells, id, value))
def callback_result(~S: Data, success: Bool, id: U32, cells: Array<Maybe<Cell<S>>>, committed: List<&2, U32>, staged: List<&2, U32>, result: Cell<S> & String) -> Store<S> & String:
  match result:
    case (cell, text): (Store{replace(~S, cells, id, Some{finish_cell(~S, success, cell)}), committed, staged}, text)
def write_taken(~S: Data, ~callback: @-P: Type -> (P -> S -> P & U32) -> (P -> S -> U32 -> P) -> (P -> S -> U32 -> P) -> (P -> S -> P & U32) -> P -> P & String, success: Bool, id: U32, committed: List<&2, U32>, staged: List<&2, U32>, result: Array<Maybe<Cell<S>>> & Maybe<Cell<S>>) -> Store<S> & String:
  match result:
    case (cells, None{}): (Store{cells, committed, staged}, "MissingEntity")
    case (cells, Some{cell}): callback_result(~S, success, id, cells, committed, staged, callback(Cell<S>, get(~S), set(~S), set(~S), get(~S), cell))
def write_checked(~S: Data, ~callback: @-P: Type -> (P -> S -> P & U32) -> (P -> S -> U32 -> P) -> (P -> S -> U32 -> P) -> (P -> S -> P & U32) -> P -> P & String, valid: Bool, success: Bool, +id: U32, s: Store<S>) -> Store<S> & String:
  match valid s:
    case False{} s: (s, "MissingEntity")
    case True{} Store{cells, committed, staged}: write_taken(~S, ~callback, success, id, committed, staged, Array.swap(Maybe<Cell<S>>, cells, id, None{}))
def writable(~S: Data, ~callback: @-P: Type -> (P -> S -> P & U32) -> (P -> S -> U32 -> P) -> (P -> S -> U32 -> P) -> (P -> S -> P & U32) -> P -> P & String, success: Bool, +id: U32, s: Store<S>) -> Store<S> & String:
  write_checked(~S, ~callback, (id < 2 : U32), success, id, s)
def read_result(~S: Data, id: U32, cells: Array<Maybe<Cell<S>>>, committed: List<&2, U32>, staged: List<&2, U32>, result: Cell<S> & String) -> Store<S> & String:
  match result:
    case (cell, text): (Store{replace(~S, cells, id, Some{cell}), committed, staged}, text)
def read_taken(~S: Data, ~callback: @-P: Type -> (P -> S -> P & U32) -> P -> P & String, id: U32, committed: List<&2, U32>, staged: List<&2, U32>, result: Array<Maybe<Cell<S>>> & Maybe<Cell<S>>) -> Store<S> & String:
  match result:
    case (cells, None{}): (Store{cells, committed, staged}, "MissingEntity")
    case (cells, Some{cell}): read_result(~S, id, cells, committed, staged, callback(Cell<S>, get(~S), cell))
def read_checked(~S: Data, ~callback: @-P: Type -> (P -> S -> P & U32) -> P -> P & String, valid: Bool, +id: U32, s: Store<S>) -> Store<S> & String:
  match valid s:
    case False{} s: (s, "MissingEntity")
    case True{} Store{cells, committed, staged}: read_taken(~S, ~callback, id, committed, staged, Array.swap(Maybe<Cell<S>>, cells, id, None{}))
def read(~S: Data, ~callback: @-P: Type -> (P -> S -> P & U32) -> P -> P & String, +id: U32, s: Store<S>) -> Store<S> & String:
  read_checked(~S, ~callback, (id < 2 : U32), id, s)
def dispose_cell(~S: Data, cells: Array<Maybe<Cell<S>>>, committed: List<&2, U32>, staged: List<&2, U32>, result: Cell<S> & U32) -> Store<S> & String:
  match result:
    case (_, x): (Store{cells, committed, staged}, "disposed:" ++ U32.show(x))
def dispose_taken(~S: Data, token: S, committed: List<&2, U32>, staged: List<&2, U32>, result: Array<Maybe<Cell<S>>> & Maybe<Cell<S>>) -> Store<S> & String:
  match result:
    case (cells, None{}): (Store{cells, committed, staged}, "MissingEntity")
    case (cells, Some{cell}): dispose_cell(~S, cells, committed, staged, get(~S, cell, token))
def remove_checked(~S: Data, valid: Bool, token: S, id: U32, s: Store<S>) -> Store<S> & String:
  match valid s:
    case False{} s: (s, "MissingEntity")
    case True{} Store{cells, committed, staged}: dispose_taken(~S, token, committed, staged, Array.swap(Maybe<Cell<S>>, cells, id, None{}))
def remove(~S: Data, token: S, +id: U32, s: Store<S>) -> Store<S> & String:
  remove_checked(~S, (id < 2 : U32), token, id, s)
def full_last(~S: Data, undo: List<&2, U32>, text: String, result: Array<U32> & U32) -> Cell<S> & String:
  match result:
    case (items, x): (Cell{Payload{items}, undo}, text ++ U32.show(x))
def full_third(~S: Data, undo: List<&2, U32>, text: String, result: Array<U32> & U32) -> Cell<S> & String:
  match result:
    case (items, x): full_last(~S, undo, text ++ U32.show(x) ++ ",", Array.get(U32, items, 3))
def full_second(~S: Data, undo: List<&2, U32>, text: String, result: Array<U32> & U32) -> Cell<S> & String:
  match result:
    case (items, x): full_third(~S, undo, text ++ U32.show(x) ++ ",", Array.get(U32, items, 2))
def full_first(~S: Data, undo: List<&2, U32>, result: Array<U32> & U32) -> Cell<S> & String:
  match result:
    case (items, x): full_second(~S, undo, U32.show(x) ++ ",", Array.get(U32, items, 1))
def full(~S: Data, c: Cell<S>) -> Cell<S> & String:
  match c:
    case Cell{Payload{items}, undo}: full_first(~S, undo, Array.get(U32, items, 0))
def leaf_full(~S: Data, result: Cell<S> & String) -> Array<Maybe<Cell<S>>> & String:
  match result:
    case (c, text): (ALeaf{Some{c}}, "[" ++ text ++ "]")
def leaf(~S: Data, c: Maybe<Cell<S>>) -> Array<Maybe<Cell<S>>> & String:
  match c:
    case None{}: (ALeaf{None{}}, "vacant")
    case Some{c}: leaf_full(~S, full(~S, c))
def full_join_right(~S: Data, left: Array<Maybe<Cell<S>>>, text: String, right: Array<Maybe<Cell<S>>> & String) -> Array<Maybe<Cell<S>>> & String:
  match right:
    case (right, tail): (ANode{left, right}, text ++ ";" ++ tail)
def full_join(~S: Data, left: Array<Maybe<Cell<S>>> & String, right: Array<Maybe<Cell<S>>> & String) -> Array<Maybe<Cell<S>>> & String:
  match left:
    case (left, text): full_join_right(~S, left, text, right)
def full_cells(~S: Data, cells: Array<Maybe<Cell<S>>>) -> Array<Maybe<Cell<S>>> & String:
  match cells:
    case ALeaf{c}: leaf(~S, c)
    case ANode{a, b}: full_join(~S, full_cells(~S, a), full_cells(~S, b))
def full_store(~S: Data, committed: List<&2, U32>, staged: List<&2, U32>, result: Array<Maybe<Cell<S>>> & String) -> Store<S> & String:
  match result:
    case (cells, text): (Store{cells, committed, staged}, text)
def snapshot(~S: Data, s: Store<S>) -> Store<S> & String:
  match s:
    case Store{cells, committed, staged}: full_store(~S, committed, staged, full_cells(~S, cells))

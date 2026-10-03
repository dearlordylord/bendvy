import Base

type Cell<-S: Data> is Type:
  Cell{x: U32}
type Row<-S: Data, -A: Type> is Type:
  Row{label: String, cell: Cell<S>, aux: A}
type World<-S: Data, -A: Type> is Type:
  World{rows: List<Row<S, A>>}
type Selection is Data:
  Required{}
  Present{}
  Absent{}
  Optional{}
type LookupResult is Data:
  Matched{observation: String}
  QueryMismatch{}
  MissingEntity{}

def cell_get(-S: Data, c: Cell<S>, token: S) -> Cell<S> & U32:
  match c:
    case Cell{+x}: (Cell{x}, x)
def cell_set(-S: Data, c: Cell<S>, token: S, x: U32) -> Cell<S>:
  match c:
    case Cell{_}: Cell{x}
def selected(s: Selection, present: Bool) -> Bool:
  match s present:
    case Required{} p: True{}
    case Optional{} p: True{}
    case Present{} p: p
    case Absent{} True{}: False{}
    case Absent{} False{}: True{}

def restore_row(-S: Data, -A: Type, label: String, result: Cell<S> & (A & String)) -> Row<S, A> & String:
  match result:
    case (c, (a, text)): (Row{label, c, a}, text)
def join_row(-S: Data, -A: Type, row: Row<S, A>, text: String, tail: List<Row<S, A>> & String) -> List<Row<S, A>> & String:
  match tail:
    case (rows, rest): (row <> rows, text ++ rest)

def read_join(-S: Data, -A: Type, result: Row<S, A> & String, tail: List<Row<S, A>> & String) -> List<Row<S, A>> & String:
  match result:
    case (row, text): join_row(S, A, row, text, tail)

# Callback checked for arbitrary cell/aux handle types; no world is supplied.
def read_row(~S: Data, ~A: Type, ~D: Data, ~callback: @-P: Type -> @-M: Type -> (P -> S -> P & U32) -> (M -> M & D) -> String -> P -> M -> P & (M & String), ~aux_get: A -> A & D, row: Row<S, A>) -> Row<S, A> & String:
  match row:
    case Row{+label, c, a}:
      restore_row(S, A, label, callback(Cell<S>, A, cell_get(S), aux_get, label, c, a))

def read_include(~S: Data, ~A: Type, ~D: Data, ~callback: @-P: Type -> @-M: Type -> (P -> S -> P & U32) -> (M -> M & D) -> String -> P -> M -> P & (M & String), ~aux_get: A -> A & D, include: Bool, row: Row<S, A>) -> Row<S, A> & String:
  match include:
    case False{}: (row, "")
    case True{}: read_row(~S, ~A, ~D, ~callback, ~aux_get, row)
def read_presence(~S: Data, ~A: Type, ~D: Data, ~callback: @-P: Type -> @-M: Type -> (P -> S -> P & U32) -> (M -> M & D) -> String -> P -> M -> P & (M & String), ~aux_get: A -> A & D, selection: Selection, label: String, c: Cell<S>, presence: A & Bool) -> Row<S, A> & String:
  match presence:
    case (a, p): read_include(~S, ~A, ~D, ~callback, ~aux_get, selected(selection, p), Row{label, c, a})
def read_decide(~S: Data, ~A: Type, ~D: Data, ~callback: @-P: Type -> @-M: Type -> (P -> S -> P & U32) -> (M -> M & D) -> String -> P -> M -> P & (M & String), ~aux_get: A -> A & D, ~has: A -> A & Bool, selection: Selection, row: Row<S, A>) -> Row<S, A> & String:
  match row:
    case Row{label, c, a}: read_presence(~S, ~A, ~D, ~callback, ~aux_get, selection, label, c, has(a))
def read_rows(~S: Data, ~A: Type, ~D: Data, ~callback: @-P: Type -> @-M: Type -> (P -> S -> P & U32) -> (M -> M & D) -> String -> P -> M -> P & (M & String), ~aux_get: A -> A & D, ~has: A -> A & Bool, +selection: Selection, rows: List<Row<S, A>>) -> List<Row<S, A>> & String:
  match rows:
    case Nil{}: (Nil{}, "")
    case Con{row, tail}:
      read_join(S, A, read_decide(~S, ~A, ~D, ~callback, ~aux_get, ~has, selection, row), read_rows(~S, ~A, ~D, ~callback, ~aux_get, ~has, selection, tail))
def restore_world(-S: Data, -A: Type, result: List<Row<S, A>> & String) -> World<S, A> & String:
  match result:
    case (rows, text): (World{rows}, text)
def query(~S: Data, ~A: Type, ~D: Data, ~callback: @-P: Type -> @-M: Type -> (P -> S -> P & U32) -> (M -> M & D) -> String -> P -> M -> P & (M & String), ~aux_get: A -> A & D, ~has: A -> A & Bool, selection: Selection, world: World<S, A>) -> World<S, A> & String:
  match world:
    case World{rows}: restore_world(S, A, read_rows(~S, ~A, ~D, ~callback, ~aux_get, ~has, selection, rows))

def write_row(~S: Data, ~A: Type, ~D: Data, ~callback: @-P: Type -> @-M: Type -> (P -> S -> P & U32) -> (P -> S -> U32 -> P) -> (P -> S -> P & U32) -> (M -> M & D) -> String -> P -> M -> P & (M & String), ~aux_get: A -> A & D, row: Row<S, A>) -> Row<S, A> & String:
  match row:
    case Row{+label, c, a}: restore_row(S, A, label, callback(Cell<S>, A, cell_get(S), cell_set(S), cell_get(S), aux_get, label, c, a))
def write_rows(~S: Data, ~A: Type, ~D: Data, ~callback: @-P: Type -> @-M: Type -> (P -> S -> P & U32) -> (P -> S -> U32 -> P) -> (P -> S -> P & U32) -> (M -> M & D) -> String -> P -> M -> P & (M & String), ~aux_get: A -> A & D, rows: List<Row<S, A>>) -> List<Row<S, A>> & String:
  match rows:
    case Nil{}: (Nil{}, "")
    case Con{row, tail}: read_join(S, A, write_row(~S, ~A, ~D, ~callback, ~aux_get, row), write_rows(~S, ~A, ~D, ~callback, ~aux_get, tail))
def writable(~S: Data, ~A: Type, ~D: Data, ~callback: @-P: Type -> @-M: Type -> (P -> S -> P & U32) -> (P -> S -> U32 -> P) -> (P -> S -> P & U32) -> (M -> M & D) -> String -> P -> M -> P & (M & String), ~aux_get: A -> A & D, world: World<S, A>) -> World<S, A> & String:
  match world:
    case World{rows}: restore_world(S, A, write_rows(~S, ~A, ~D, ~callback, ~aux_get, rows))
def lookup_restore(-S: Data, -A: Type, row: Row<S, A>, tail: List<Row<S, A>> & LookupResult) -> List<Row<S, A>> & LookupResult:
  match tail:
    case (rows, result): (row <> rows, result)
def lookup_match(-S: Data, -A: Type, row: Row<S, A> & String, tail: List<Row<S, A>>) -> List<Row<S, A>> & LookupResult:
  match row:
    case (r, text): (r <> tail, Matched{text})
def lookup_include(~S: Data, ~A: Type, ~D: Data, ~callback: @-P: Type -> @-M: Type -> (P -> S -> P & U32) -> (M -> M & D) -> String -> P -> M -> P & (M & String), ~aux_get: A -> A & D, include: Bool, row: Row<S, A>, rows: List<Row<S, A>>) -> List<Row<S, A>> & LookupResult:
  match include:
    case False{}: (row <> rows, QueryMismatch{})
    case True{}: lookup_match(S, A, read_row(~S, ~A, ~D, ~callback, ~aux_get, row), rows)
def lookup_presence_rows(~S: Data, ~A: Type, ~D: Data, ~callback: @-P: Type -> @-M: Type -> (P -> S -> P & U32) -> (M -> M & D) -> String -> P -> M -> P & (M & String), ~aux_get: A -> A & D, selection: Selection, label: String, c: Cell<S>, presence: A & Bool, rows: List<Row<S, A>>) -> List<Row<S, A>> & LookupResult:
  match presence:
    case (a, p): lookup_include(~S, ~A, ~D, ~callback, ~aux_get, selected(selection, p), Row{label, c, a}, rows)
def lookup_presence(~S: Data, ~A: Type, ~D: Data, ~callback: @-P: Type -> @-M: Type -> (P -> S -> P & U32) -> (M -> M & D) -> String -> P -> M -> P & (M & String), ~aux_get: A -> A & D, selection: Selection, label: String, c: Cell<S>, presence: A & Bool, tail: List<Row<S, A>> & LookupResult) -> List<Row<S, A>> & LookupResult:
  match tail:
    case (rows, _): lookup_presence_rows(~S, ~A, ~D, ~callback, ~aux_get, selection, label, c, presence, rows)
def lookup_decide(~S: Data, ~A: Type, ~D: Data, ~callback: @-P: Type -> @-M: Type -> (P -> S -> P & U32) -> (M -> M & D) -> String -> P -> M -> P & (M & String), ~aux_get: A -> A & D, ~has: A -> A & Bool, selection: Selection, equal: Bool, row: Row<S, A>, tail: List<Row<S, A>> & LookupResult) -> List<Row<S, A>> & LookupResult:
  match equal row:
    case False{} r: lookup_restore(S, A, r, tail)
    case True{} Row{label, c, a}: lookup_presence(~S, ~A, ~D, ~callback, ~aux_get, selection, label, c, has(a), tail)
def lookup_row(~S: Data, ~A: Type, ~D: Data, ~callback: @-P: Type -> @-M: Type -> (P -> S -> P & U32) -> (M -> M & D) -> String -> P -> M -> P & (M & String), ~aux_get: A -> A & D, ~has: A -> A & Bool, selection: Selection, target: String, row: Row<S, A>, tail: List<Row<S, A>> & LookupResult) -> List<Row<S, A>> & LookupResult:
  match row:
    case Row{+label, c, a}: lookup_decide(~S, ~A, ~D, ~callback, ~aux_get, ~has, selection, String.eq(target, label), Row{label, c, a}, tail)
def lookup_rows(~S: Data, ~A: Type, ~D: Data, ~callback: @-P: Type -> @-M: Type -> (P -> S -> P & U32) -> (M -> M & D) -> String -> P -> M -> P & (M & String), ~aux_get: A -> A & D, ~has: A -> A & Bool, +selection: Selection, +target: String, rows: List<Row<S, A>>) -> List<Row<S, A>> & LookupResult:
  match rows:
    case Nil{}: (Nil{}, MissingEntity{})
    case Con{row, tail}: lookup_row(~S, ~A, ~D, ~callback, ~aux_get, ~has, selection, target, row, lookup_rows(~S, ~A, ~D, ~callback, ~aux_get, ~has, selection, target, tail))
def lookup_world(-S: Data, -A: Type, result: List<Row<S, A>> & LookupResult) -> World<S, A> & LookupResult:
  match result:
    case (rows, result): (World{rows}, result)
def lookup(~S: Data, ~A: Type, ~D: Data, ~callback: @-P: Type -> @-M: Type -> (P -> S -> P & U32) -> (M -> M & D) -> String -> P -> M -> P & (M & String), ~aux_get: A -> A & D, ~has: A -> A & Bool, selection: Selection, target: String, world: World<S, A>) -> World<S, A> & LookupResult:
  match world:
    case World{rows}: lookup_world(S, A, lookup_rows(~S, ~A, ~D, ~callback, ~aux_get, ~has, selection, target, rows))

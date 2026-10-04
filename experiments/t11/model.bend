import Base

type Row is Data:
  Row{slot: Nat, value: Nat, tagged: Bool}
type Handle is Data:
  Handle{world: Nat, slot: Nat}
type Command is Data:
  Spawn{slot: Nat, value: Nat}
  Tag{slot: Nat, present: Bool}
  Despawn{slot: Nat}
type World is Data:
  World{id: Nat, next: Nat, rows: List<&2, Row>, pending: List<&2, Command>}
type Lookup is Data:
  Missing{}
  Mismatch{}
  Found{row: Row}
type Selection is Data:
  Any{}
  Present{}
  Absent{}
type Reservation is Data:
  Rejected{world: World}
  Reserved{world: World, handle: Handle}

def accepts(selection: Selection, tagged: Bool) -> Bool:
  match selection:
    case Any{}: True{}
    case Present{}: tagged
    case Absent{}: Bool.not(tagged)
def select_row(keep: Bool, row: Row, tail: List<&2, Row>) -> List<&2, Row>:
  match keep:
    case True{}: row <> tail
    case False{}: tail
def query(+selection: Selection, rows: List<&2, Row>) -> List<&2, Row>:
  match rows:
    case Nil{}: []
    case Con{Row{slot, value, +tagged}, tail}: select_row(accepts(selection, tagged), Row{slot, value, tagged}, query(selection, tail))
def found(keep: Bool, row: Row) -> Lookup:
  match keep:
    case True{}: Found{row}
    case False{}: Mismatch{}
def local_choose(equal: Bool, selection: Selection, row: Row, rest: Lookup) -> Lookup:
  match equal row:
    case True{} Row{slot, value, +tagged}: found(accepts(selection, tagged), Row{slot, value, tagged})
    case False{} _: rest
def lookup_rows(+slot: Nat, +selection: Selection, rows: List<&2, Row>) -> Lookup:
  match rows:
    case Nil{}: Missing{}
    case Con{Row{+id, value, tagged}, tail}: local_choose(Nat.is_eq(slot, id), selection, Row{id, value, tagged}, lookup_rows(slot, selection, tail))
def lookup_guard(equal: Bool, slot: Nat, selection: Selection, rows: List<&2, Row>) -> Lookup:
  match equal:
    case False{}: Missing{}
    case True{}: lookup_rows(slot, selection, rows)
def lookup(w: World, h: Handle, selection: Selection) -> Lookup:
  match w h:
    case World{id, _, rows, _} Handle{world, slot}: lookup_guard(Nat.is_eq(id, world), slot, selection, rows)
def reserve_available(available: Bool, +id: Nat, +next: Nat, +rows: List<&2, Row>, +pending: List<&2, Command>, value: Nat) -> Reservation:
  match available:
    case False{}: Rejected{World{id, next, rows, pending}}
    case True{}: Reserved{World{id, 1n+next, rows, Spawn{next, value} <> pending}, Handle{id, next}}
def reserve_until(+limit: Nat, w: World, value: Nat) -> Reservation:
  match w:
    case World{+id, +next, rows, pending}: reserve_available(Nat.is_lt(next, limit), id, next, rows, pending, value)
def reserve(w: World, value: Nat) -> Reservation:
  reserve_until(U32.to_nat(4294967295), w, value)
def within_world(limit: Nat, w: World) -> Bool:
  match w:
    case World{_, next, _, _}: Nat.is_le(next, limit)
def within(limit: Nat, result: Reservation) -> Bool:
  match result:
    case Rejected{w}: within_world(limit, w)
    case Reserved{w, _}: within_world(limit, w)
def enqueue_guard(equal: Bool, id: Nat, next: Nat, rows: List<&2, Row>, pending: List<&2, Command>, command: Command) -> World:
  match equal:
    case False{}: World{id, next, rows, pending}
    case True{}: World{id, next, rows, command <> pending}
def enqueue(w: World, h: Handle, command: Command) -> World:
  match w h:
    case World{+id, next, rows, pending} Handle{world, _}: enqueue_guard(Nat.is_eq(id, world), id, next, rows, pending, command)
def modify_row(equal: Bool, despawn: Bool, tagged: Bool, row: Row, rest: List<&2, Row>) -> List<&2, Row>:
  match equal despawn row:
    case False{} _ r: r <> rest
    case True{} True{} _: rest
    case True{} False{} Row{id, value, _}: Row{id, value, tagged} <> rest
def modify(+slot: Nat, +despawn: Bool, +tagged: Bool, rows: List<&2, Row>) -> List<&2, Row>:
  match rows:
    case Nil{}: []
    case Con{Row{+id, value, old}, tail}: modify_row(Nat.is_eq(slot, id), despawn, tagged, Row{id, value, old}, modify(slot, despawn, tagged, tail))
def apply(command: Command, rows: List<&2, Row>) -> List<&2, Row>:
  match command:
    case Spawn{slot, value}: List.append(&2, Row, rows, [Row{slot, value, False{}}])
    case Tag{slot, tagged}: modify(slot, False{}, tagged, rows)
    case Despawn{slot}: modify(slot, True{}, False{}, rows)
def apply_all(commands: List<&2, Command>, rows: List<&2, Row>) -> List<&2, Row>:
  match commands:
    case Nil{}: rows
    case Con{command, tail}: apply_all(tail, apply(command, rows))
def flush(w: World) -> World:
  match w:
    case World{id, next, rows, pending}: World{id, next, apply_all(List.reverse(&2, Command, pending), rows), []}
def tick(w: World) -> World:
  w

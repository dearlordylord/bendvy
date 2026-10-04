import Base
import ./types.bend as T

def create_if(ok: Bool, +next: Nat) -> T.Creation:
  match ok:
    case False{}: T.Full{T.Factory{next}}
    case True{}: T.Created{T.Factory{1n+next}, T.World{next, 1n, [], []}}
def create(limit: Nat, factory: T.Factory) -> T.Creation:
  match factory:
    case T.Factory{+next}: create_if(Nat.is_lt(next, limit), next)
def two_second(first: Nat, result: T.Creation) -> Maybe<&2,T.Namespaces>:
  match result:
    case T.Full{_}: None{}
    case T.Created{_, T.World{id, _, _, _}}: Some{T.Namespaces{first,id}}
def two_first(+limit: Nat, result: T.Creation) -> Maybe<&2,T.Namespaces>:
  match result:
    case T.Full{_}: None{}
    case T.Created{factory, T.World{id, _, _, _}}: two_second(id, create(limit, factory))
def two_namespaces(+limit: Nat, factory: T.Factory) -> Maybe<&2,T.Namespaces>:
  two_first(limit, create(limit, factory))
def reserve_if(ok: Bool, +id: Nat, +next: Nat, +rows: List<&2, T.Row>, +pending: List<&2, T.Command>, value: Nat) -> T.Reservation:
  match ok:
    case False{}: T.Rejected{T.World{id, next, rows, pending}}
    case True{}: T.Reserved{T.World{id, 1n+next, rows, List.append(&2, T.Command, pending, [T.Spawn{next, value}])}, T.Handle{id, next}}
def reserve(limit: Nat, world: T.World, value: Nat) -> T.Reservation:
  match world:
    case T.World{id, +next, rows, pending}: reserve_if(Nat.is_lt(next, limit), id, next, rows, pending, value)
def unwrap(result: T.Reservation) -> T.World:
  match result:
    case T.Rejected{world}: world
    case T.Reserved{world, _}: world

def accepts(selection: T.Selection, tag: Bool) -> Bool:
  match selection:
    case T.Any{}: True{}
    case T.Present{}: tag
    case T.Absent{}: Bool.not(tag)
def choose_selected(ok: Bool, row: T.Row) -> T.Lookup:
  match ok:
    case False{}: T.Mismatch{}
    case True{}: T.Found{row}
def choose_lookup(equal: Bool, selection: T.Selection, row: T.Row, rest: T.Lookup) -> T.Lookup:
  match equal row:
    case False{} _: rest
    case True{} T.Row{slot, value, +tag}: choose_selected(accepts(selection, tag), T.Row{slot, value, tag})
def lookup_rows(+slot: Nat, +selection: T.Selection, rows: List<&2, T.Row>) -> T.Lookup:
  match rows:
    case Nil{}: T.Missing{}
    case Con{T.Row{+id, value, tag}, tail}: choose_lookup(Nat.is_eq(slot, id), selection, T.Row{id, value, tag}, lookup_rows(slot, selection, tail))
def lookup_if(local: Bool, slot: Nat, selection: T.Selection, rows: List<&2, T.Row>) -> T.Lookup:
  match local:
    case False{}: T.Missing{}
    case True{}: lookup_rows(slot, selection, rows)
def lookup(world: T.World, handle: T.Handle, selection: T.Selection) -> T.Lookup:
  match world handle:
    case T.World{id, _, rows, _} T.Handle{namespace, slot}: lookup_if(Nat.is_eq(id, namespace), slot, selection, rows)
def publish_if(local: Bool, id: Nat, next: Nat, rows: List<&2, T.Row>, pending: List<&2, T.Command>, slot: Nat, action: T.Action) -> T.World:
  match local:
    case False{}: T.World{id, next, rows, pending}
    case True{}: T.World{id, next, rows, List.append(&2, T.Command, pending, [T.Target{slot, action}])}
def publish(world: T.World, handle: T.Handle, action: T.Action) -> T.World:
  match world handle:
    case T.World{+id, next, rows, pending} T.Handle{namespace, slot}: publish_if(Nat.is_eq(id, namespace), id, next, rows, pending, slot, action)

def modify_one(equal: Bool, action: T.Action, row: T.Row, tail: List<&2, T.Row>) -> List<&2, T.Row>:
  match equal action row:
    case False{} _ r: r <> tail
    case True{} T.Insert{} T.Row{slot, value, _}: T.Row{slot, value, True{}} <> tail
    case True{} T.Remove{} T.Row{slot, value, _}: T.Row{slot, value, False{}} <> tail
    case True{} T.Despawn{} _: tail
def modify(+slot: Nat, +action: T.Action, rows: List<&2, T.Row>) -> List<&2, T.Row>:
  match rows:
    case Nil{}: []
    case Con{T.Row{+id, value, tag}, tail}: modify_one(Nat.is_eq(slot, id), action, T.Row{id, value, tag}, modify(slot, action, tail))
def apply(command: T.Command, rows: List<&2, T.Row>) -> List<&2, T.Row>:
  match command:
    case T.Spawn{slot, value}: T.Row{slot, value, False{}} <> rows
    case T.Target{slot, action}: modify(slot, action, rows)
def apply_all(commands: List<&2, T.Command>, rows: List<&2, T.Row>) -> List<&2, T.Row>:
  match commands:
    case Nil{}: rows
    case Con{command, tail}: apply_all(tail, apply(command, rows))
def flush(world: T.World) -> T.World:
  match world:
    case T.World{id, next, rows, pending}: T.World{id, next, apply_all(pending, rows), []}

def insert_sorted_if(before: Bool, row: T.Row, head: T.Row, tail: List<&2, T.Row>, recur: T.Row -> List<&2, T.Row>) -> List<&2, T.Row>:
  match before:
    case True{}: row <> head <> tail
    case False{}: head <> recur(row)
def insert_sorted(rows: List<&2, T.Row>, row: T.Row) -> List<&2, T.Row>:
  match rows row:
    case Nil{} r: [r]
    case Con{T.Row{+id, value, tag}, +tail} T.Row{+slot, +v, +t}: insert_sorted_if(Nat.is_lt(slot, id), T.Row{slot, v, t}, T.Row{id, value, tag}, tail, r => insert_sorted(tail, r))
def include(ok: Bool, row: T.Row, tail: List<&2, T.Row>) -> List<&2, T.Row>:
  match ok:
    case False{}: tail
    case True{}: insert_sorted(tail, row)
def query_rows(+selection: T.Selection, rows: List<&2, T.Row>) -> List<&2, T.Row>:
  match rows:
    case Nil{}: []
    case Con{T.Row{slot, value, +tag}, tail}: include(accepts(selection, tag), T.Row{slot, value, tag}, query_rows(selection, tail))
def query(world: T.World, selection: T.Selection) -> List<&2, T.Row>:
  match world:
    case T.World{_, _, rows, _}: query_rows(selection, rows)
def observe(world: T.World) -> T.Observation:
  match world:
    case T.World{id, next, rows, pending}: T.Observation{id, next, query_rows(T.Any{}, rows), pending}
def bump_one(equal: Bool, row: T.Row) -> T.Row:
  match equal row:
    case False{} r: r
    case True{} T.Row{slot, value, tag}: T.Row{slot, 1n+value, tag}
def bump_rows(+slot: Nat, rows: List<&2, T.Row>) -> List<&2, T.Row>:
  match rows:
    case Nil{}: []
    case Con{T.Row{+id, value, tag}, tail}: bump_one(Nat.is_eq(slot, id), T.Row{id, value, tag}) <> bump_rows(slot, tail)
def bump(world: T.World, slot: Nat) -> T.World:
  match world:
    case T.World{id, next, rows, pending}: T.World{id, next, bump_rows(slot, rows), pending}
def step(limit: Nat, world: T.World, step: T.Step) -> T.World:
  match step:
    case T.Reserve{value}: unwrap(reserve(limit, world, value))
    case T.Publish{handle, action}: publish(world, handle, action)
    case T.Bump{slot}: bump(world, slot)
    case T.Barrier{}: flush(world)
def M_step(limit: Nat, world: T.World, s: T.Step) -> T.World:
  step(limit, world, s)

# Unique/bounded physical rows and spawn reservations; nonspawn unknown targets
# are permitted and ignored only at application, like the selected TS target.
def tick(steps: List<&2, T.Step>, +limit: Nat, world: T.World) -> T.World:
  match steps:
    case Nil{}: world
    case Con{step, tail}: tick(tail, limit, M_step(limit, world, step))

def contains(+slot: Nat, rows: List<&2, T.Row>) -> Bool:
  match rows:
    case Nil{}: False{}
    case Con{T.Row{id, _, _}, tail}: Bool.or(Nat.is_eq(slot, id), contains(slot, tail))
def rows_valid(+next: Nat, rows: List<&2, T.Row>) -> Bool:
  match rows:
    case Nil{}: True{}
    case Con{T.Row{+slot, _, _}, +tail}: Bool.and(Nat.is_lt(slot, next), Bool.and(Bool.not(contains(slot, tail)), rows_valid(next, tail)))
def spawn_contains(+slot: Nat, commands: List<&2, T.Command>) -> Bool:
  match commands:
    case Nil{}: False{}
    case Con{T.Spawn{id, _}, tail}: Bool.or(Nat.is_eq(slot, id), spawn_contains(slot, tail))
    case Con{T.Target{_, _}, tail}: spawn_contains(slot, tail)
def pending_valid(+next: Nat, +rows: List<&2, T.Row>, commands: List<&2, T.Command>) -> Bool:
  match commands:
    case Nil{}: True{}
    case Con{T.Spawn{+slot, _}, +tail}: Bool.and(Nat.is_lt(slot, next), Bool.and(Bool.not(contains(slot, rows)), Bool.and(Bool.not(spawn_contains(slot, tail)), pending_valid(next, rows, tail))))
    case Con{T.Target{_, _}, tail}: pending_valid(next, rows, tail)
def admissible(limit: Nat, world: T.World) -> Bool:
  match world:
    case T.World{_, +next, +rows, pending}: Bool.and(Nat.is_le(next, limit), Bool.and(rows_valid(next, rows), pending_valid(next, rows, pending)))

def reverse_world(world: T.World) -> T.World:
  match world:
    case T.World{id, next, rows, pending}: T.World{id, next, List.reverse(&2, T.Row, rows), pending}
def reserved_lookup(result: T.Reservation) -> T.Lookup:
  match result:
    case T.Rejected{_}: T.Missing{}
    case T.Reserved{world,handle}: lookup(world,handle,T.Any{})

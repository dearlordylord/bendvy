import Base
import ../t08/core.bend as C
import ../t08/log.bend as L

# Owned fixed array; checked logical IDs map to reversed physical slots.
# Membership is sorted and independent of physical array traversal.
type World is Type:
  World{limit: U32, rows: Array<C.Row>, members: List<&2, U32>, meta: C.World}
type Outcome is Type:
  Outcome{world: World, observed: U32}
type Projection is Data:
  Projection{count: U32, sum: U32, text: String}
def slot(+limit: U32, id: U32) -> U32:
  (limit - 1 - id : U32)
def checked_get(valid: Bool, limit: U32, rows: Array<C.Row>, id: U32) -> Array<C.Row> & C.Row:
  match valid:
    case False{}: (rows, C.Row{id, None{}, 0, 0})
    case True{}: Array.get(C.Row, rows, slot(limit, id))
def get(+limit: U32, rows: Array<C.Row>, +id: U32) -> Array<C.Row> & C.Row:
  checked_get((id < limit : U32), limit, rows, id)
def checked_set(valid: Bool, limit: U32, rows: Array<C.Row>, id: U32, row: C.Row) -> Array<C.Row>:
  match valid:
    case False{}: rows
    case True{}: Array.set(C.Row, rows, slot(limit, id), row)
def set(+limit: U32, rows: Array<C.Row>, +id: U32, row: C.Row) -> Array<C.Row>:
  checked_set((id < limit : U32), limit, rows, id, row)
def keep_sparse(mode: U32, +id: U32) -> Bool:
  match mode:
    case 1: U32.is_eq(U32.mod(id, 8), 0)
    case _: True{}
def filled(yes: Bool, id: U32, rows: Array<C.Row>, rest: List<&2, U32>) -> Array<C.Row> & List<&2, U32>:
  match yes:
    case True{}: (rows, id <> rest)
    case False{}: (rows, rest)
def initial_value(keep: Bool) -> Maybe<&2, U32>:
  match keep:
    case True{}: Some{1}
    case False{}: None{}
def fill_next(+yes: Bool, limit: U32, +id: U32, result: Array<C.Row> & List<&2, U32>) -> Array<C.Row> & List<&2, U32>:
  match result:
    case (rows, rest): filled(yes, id, set(limit, rows, id, C.Row{id, initial_value(yes), 0, 0}), rest)
def fill(n: Nat, +limit: U32, +mode: U32, +id: U32, rows: Array<C.Row>) -> Array<C.Row> & List<&2, U32>:
  match n:
    case 0n: (rows, [])
    case 1n+k: fill_next(keep_sparse(mode, id), limit, id, fill(k, limit, mode, (id + 1 : U32), rows))
def make(limit: U32, result: Array<C.Row> & List<&2, U32>) -> World:
  match result:
    case (rows, members): World{limit, rows, members, C.initial(65536n)}
def setup_checked(valid: Bool, +limit: U32, mode: U32) -> World:
  match valid:
    case False{}: World{0, [C.Row{0, None{}, 0, 0} : C.Row^11n], [], C.initial(65536n)}
    case True{}: make(limit, fill(U32.to_nat(limit), limit, mode, 0, [C.Row{0, None{}, 0, 0} : C.Row^11n]))
def setup(+limit: U32, mode: U32) -> World:
  setup_checked((limit <= 2048 : U32), limit, mode)
def value(row: C.Row) -> U32:
  match row:
    case C.Row{_, Some{x}, _, _}: x
    case _: 0
def sum_got(sum: U32, result: Array<C.Row> & C.Row) -> Array<C.Row> & U32:
  match result:
    case (rows, row): (rows, (sum + value(row) : U32))
def sum_next(id: U32, limit: U32, result: Array<C.Row> & U32) -> Array<C.Row> & U32:
  match result:
    case (rows, sum): sum_got(sum, get(limit, rows, id))
def sum_rows(ids: List<&2, U32>, +limit: U32, rows: Array<C.Row>, acc: U32) -> Array<C.Row> & U32:
  match ids:
    case Nil{}: (rows, acc)
    case Con{id, tail}: sum_next(id, limit, sum_rows(tail, limit, rows, acc))
def observe_result(limit: U32, members: List<&2, U32>, meta: C.World, result: Array<C.Row> & U32) -> Outcome:
  match result:
    case (rows, sum): Outcome{World{limit, rows, members, meta}, sum}
def observe(w: World) -> Outcome:
  match w:
    case World{+limit, rows, +members, meta}: observe_result(limit, members, meta, sum_rows(members, limit, rows, 0))
def advance(w: World) -> World:
  match w:
    case World{limit, rows, members, C.World{tick, frame, rs, pending, removed, despawned, messages, slots}}: World{limit, rows, members, C.World{(tick + 1 : U32), frame, rs, pending, removed, despawned, messages, slots}}
def frame(w: World) -> World:
  match w:
    case World{limit, rows, members, meta}: World{limit, rows, members, C.frame(meta)}
def write_got(limit: U32, id: U32, x: U32, tick: U32, result: Array<C.Row> & C.Row) -> Array<C.Row>:
  match result:
    case (rows, row): set(limit, rows, id, C.set_row(x, tick, row))
def write_rows(ids: List<&2, U32>, +limit: U32, rows: Array<C.Row>, +x: U32, +tick: U32) -> Array<C.Row>:
  match ids:
    case Nil{}: rows
    case Con{+id, tail}: write_rows(tail, limit, write_got(limit, id, x, tick, get(limit, rows, id)), x, tick)
def write(x: U32, w: World) -> World:
  match w:
    case World{+limit, rows, +members, C.World{+tick, frame, rs, pending, removed, despawned, messages, slots}}: World{limit, write_rows(members, limit, rows, x, (tick + 1 : U32)), members, C.World{(tick + 1 : U32), frame, rs, pending, removed, despawned, messages, slots}}
# The measured rollback mutates the owned Array and restores inverse old rows.
# Row is Data; the owned payload stage separately establishes genuine Type values.
type Undo is Data:
  Undo{id: U32, row: C.Row}
type Written is Type:
  Written{rows: Array<C.Row>, undo: List<&2, Undo>, observed: U32}
def journal_seen(undo: List<&2, Undo>, observed: U32, result: Array<C.Row> & C.Row) -> Written:
  match result:
    case (rows, row): Written{rows, undo, (observed + value(row) : U32)}
def journal_got(+limit: U32, +id: U32, x: U32, tick: U32, observed: U32, undo: List<&2, Undo>, result: Array<C.Row> & C.Row) -> Written:
  match result:
    case (rows, +old): journal_seen(Undo{id, old} <> undo, observed, get(limit, set(limit, rows, id, C.set_row(x, tick, old)), id))
def journal(ids: List<&2, U32>, +limit: U32, +x: U32, +tick: U32, written: Written) -> Written:
  match ids written:
    case Nil{} written: written
    case Con{+id, tail} Written{rows, undo, observed}: journal(tail, limit, x, tick, journal_got(limit, id, x, tick, observed, undo, get(limit, rows, id)))
def restore(undo: List<&2, Undo>, +limit: U32, rows: Array<C.Row>) -> Array<C.Row>:
  match undo:
    case Nil{}: rows
    case Con{Undo{+id, row}, tail}: restore(tail, limit, set(limit, rows, id, row))
def failed_result(+limit: U32, members: List<&2, U32>, meta: C.World, written: Written) -> Outcome:
  match written:
    case Written{rows, undo, observed}: Outcome{World{limit, restore(undo, limit, rows), members, meta}, observed}
def fail_round(x: U32, w: World) -> Outcome:
  match w:
    case World{+limit, rows, +members, C.World{+tick, frame, rs, pending, removed, despawned, messages, slots}}: failed_result(limit, members, C.World{(tick + 1 : U32), frame, rs, pending, removed, despawned, messages, slots}, journal(members, limit, x, (tick + 1 : U32), Written{rows, [], 0}))
def member_insert_choose(same: Bool, before: Bool, id: U32, head: U32, tail: List<&2, U32>, rest: Unit -> List<&2, U32>) -> List<&2, U32>:
  match same before:
    case True{} _: head <> tail
    case False{} True{}: id <> head <> tail
    case False{} False{}: head <> rest(Unit{})
def member_insert(ids: List<&2, U32>, +id: U32) -> List<&2, U32>:
  match ids:
    case Nil{}: [id]
    case Con{+head, +tail}: member_insert_choose(U32.is_eq(id, head), (id < head : U32), id, head, tail, _ => member_insert(tail, id))
def member_remove_choose(same: Bool, head: U32, tail: List<&2, U32>, rest: Unit -> List<&2, U32>) -> List<&2, U32>:
  match same:
    case True{}: tail
    case False{}: head <> rest(Unit{})
def member_remove(ids: List<&2, U32>, +id: U32) -> List<&2, U32>:
  match ids:
    case Nil{}: []
    case Con{+head, +tail}: member_remove_choose(U32.is_eq(head, id), head, tail, _ => member_remove(tail, id))
def command_id(command: C.Command) -> U32:
  match command:
    case C.Spawn{id, _}: id
    case C.Insert{id, _}: id
    case C.Remove{id}: id
    case C.Despawn{id}: id
def row_members(row: C.Row, members: List<&2, U32>) -> List<&2, U32>:
  match row:
    case C.Row{id, Some{_}, _, _}: member_insert(members, id)
    case C.Row{id, None{}, _, _}: member_remove(members, id)
def applied_rows(+limit: U32, +id: U32, rows: Array<C.Row>, members: List<&2, U32>, updated: C.World) -> World:
  match updated:
    case C.World{tick, frame, Nil{}, pending, removed, despawned, messages, slots}: World{limit, set(limit, rows, id, C.Row{4294967295, None{}, 0, 0}), member_remove(members, id), C.World{tick, frame, [], pending, removed, despawned, messages, slots}}
    case C.World{tick, frame, Con{+row, _}, pending, removed, despawned, messages, slots}: World{limit, set(limit, rows, id, row), row_members(row, members), C.World{tick, frame, [], pending, removed, despawned, messages, slots}}
def row_list(valid: Bool, row: C.Row) -> List<&2, C.Row>:
  match valid:
    case True{}: [row]
    case False{}: []
def row_id(row: C.Row) -> U32:
  match row:
    case C.Row{id, _, _, _}: id
def apply_row(limit: U32, +id: U32, command: C.Command, members: List<&2, U32>, tick: U32, frame: U32, pending: List<&2, C.Command>, removed: L.Log, despawned: L.Log, messages: L.Log, slots: C.Slots, result: Array<C.Row> & C.Row) -> World:
  match result:
    case (rows, +row): applied_rows(limit, id, rows, members, C.apply(command, C.World{tick, frame, row_list(U32.is_eq(id, row_id(row)), row), pending, removed, despawned, messages, slots}))
def apply_got(limit: U32, id: U32, command: C.Command, members: List<&2, U32>, meta: C.World, result: Array<C.Row> & C.Row) -> World:
  match meta:
    case C.World{tick, frame, _, pending, removed, despawned, messages, slots}: apply_row(limit, id, command, members, tick, frame, pending, removed, despawned, messages, slots, result)
def apply_valid(valid: Bool, command: C.Command, +id: U32, w: World) -> World:
  match valid w:
    case False{} w: w
    case True{} World{+limit, rows, members, meta}: apply_got(limit, id, command, members, meta, get(limit, rows, id))
def apply(+command: C.Command, w: World) -> World:
  match w:
    case World{+limit, rows, members, meta}: apply_valid((command_id(command) < limit : U32), command, command_id(command), World{limit, rows, members, meta})
def apply_all(commands: List<&2, C.Command>, w: World) -> World:
  match commands:
    case Nil{}: w
    case Con{command, tail}: apply_all(tail, apply(command, w))
def queue(commands: List<&2, C.Command>, w: World) -> World:
  match w:
    case World{limit, rows, members, meta}: World{limit, rows, members, C.queue(commands, meta)}
def flush(w: World) -> World:
  match w:
    case World{limit, rows, members, C.World{tick, frame, rs, pending, removed, despawned, messages, slots}}: apply_all(pending, World{limit, rows, members, C.World{(tick + 1 : U32), frame, rs, [], removed, despawned, messages, slots}})
def churn(w: World) -> World:
  flush(queue([C.Remove{0}, C.Insert{0, 1}], w))
def event_read_result(limit: U32, rows: Array<C.Row>, members: List<&2, U32>, result: C.World & U32) -> Outcome:
  match result:
    case (meta, n): Outcome{World{limit, rows, members, meta}, n}
def values_sum(xs: List<&2, U32>) -> U32:
  match xs:
    case Nil{}: 0
    case Con{x, tail}: (x + values_sum(tail) : U32)
def read_log_result(tick: U32, frame: U32, rs: List<&2, C.Row>, pending: List<&2, C.Command>, removed: L.Log, despawned: L.Log, slots: C.Slots, result: L.Log & (List<&2, U32> & Bool)) -> C.World & U32:
  match result:
    case (messages, (values, _)): (C.World{tick, frame, rs, pending, removed, despawned, messages, slots}, values_sum(values))
def event_meta(w: C.World) -> C.World & U32:
  match w:
    case C.World{+tick, frame, rs, pending, removed, despawned, messages, slots}: read_log_result((tick + 2 : U32), frame, rs, pending, removed, despawned, slots, L.read(L.append(messages, (tick + 2 : U32), [1]), L.Cursor{tick, 0}))
def event_round(w: World) -> Outcome:
  match w:
    case World{limit, rows, members, meta}: event_read_result(limit, rows, members, event_meta(meta))
def churn_read_result(tick: U32, frame: U32, rs: List<&2, C.Row>, pending: List<&2, C.Command>, despawned: L.Log, messages: L.Log, slots: C.Slots, result: L.Log & (List<&2, U32> & Bool)) -> C.World & U32:
  match result:
    case (removed, (ids, _)): (C.World{(tick + 1 : U32), frame, rs, pending, removed, despawned, messages, slots}, U32.from_nat(List.length(&2, U32, ids)))
def churn_meta(w: World) -> Outcome:
  match w:
    case World{limit, rows, members, C.World{+tick, frame, rs, pending, removed, despawned, messages, slots}}: event_read_result(limit, rows, members, churn_read_result(tick, frame, rs, pending, despawned, messages, slots, L.read(removed, L.Cursor{(tick - 2 : U32), 0})))
def step(mode: U32, x: U32, w: World) -> Outcome:
  match mode:
    case 0: observe(advance(w))
    case 1: observe(advance(w))
    case 2: Outcome{write(x, w), 0}
    case 3: churn_meta(churn(w))
    case 4: event_round(w)
    case _: fail_round(x, w)
def add_observed(previous: U32, result: Outcome) -> Outcome:
  match result:
    case Outcome{w, observed}: Outcome{w, (previous + observed : U32)}
def loops(n: Nat, +mode: U32, +round: U32, result: Outcome) -> Outcome:
  match n result:
    case 0n result: result
    case 1n+k Outcome{w, observed}: loops(k, mode, (round + 1 : U32), add_observed(observed, step(mode, round, frame(w))))
def project_row(count: U32, sum: U32, text: String, result: Array<C.Row> & C.Row) -> Array<C.Row> & Projection:
  match result:
    case (rows, C.Row{id, Some{+x}, _, _}): (rows, Projection{(count + 1 : U32), (sum + x : U32), U32.show(id) ++ "=" ++ U32.show(x) ++ "," ++ text})
    case (rows, _): (rows, Projection{count, sum, text})
def project_got(acc: Projection, result: Array<C.Row> & C.Row) -> Array<C.Row> & Projection:
  match acc:
    case Projection{count, sum, text}: project_row(count, sum, text, result)
def project_next(id: U32, limit: U32, result: Array<C.Row> & Projection) -> Array<C.Row> & Projection:
  match result:
    case (rows, acc): project_got(acc, get(limit, rows, id))
def project(ids: List<&2, U32>, +limit: U32, rows: Array<C.Row>, acc: Projection) -> Array<C.Row> & Projection:
  match ids:
    case Nil{}: (rows, acc)
    case Con{id, tail}: project_next(id, limit, project(tail, limit, rows, acc))
def finish_projection(observed: U32, result: Array<C.Row> & Projection) -> String:
  match result:
    case (_, Projection{count, sum, text}): U32.show(count) ++ ":" ++ U32.show(sum) ++ ":" ++ U32.show(observed) ++ "|" ++ text
def finish(result: Outcome) -> String:
  match result:
    case Outcome{World{+limit, rows, members, _}, observed}: finish_projection(observed, project(members, limit, rows, Projection{0, 0, ""}))

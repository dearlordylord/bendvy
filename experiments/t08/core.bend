import Base
import ./log.bend as L

type Row is Data:
  Row{id: U32, value: Maybe<&2, U32>, added: U32, changed: U32}
type Reader is Data:
  Reader{last: U32, message: U32, registered: U32}
type Slots is Data:
  Slots{a: Maybe<&2, Reader>, b: Maybe<&2, Reader>}
type Command is Data:
  Spawn{id: U32, value: U32}
  Insert{id: U32, value: U32}
  Remove{id: U32}
  Despawn{id: U32}
type World is Type:
  World{clock: U32, frame: U32, rows: List<&2, Row>, pending: List<&2, Command>, removed: L.Log, despawned: L.Log, messages: L.Log, slots: Slots}
type Op is Data:
  Frame{}
  Queue{commands: List<&2, Command>}
  Flush{}
  Write{value: U32, success: Bool}
  EmitOp{value: U32}
  ReadOp{b: Bool, success: Bool, name: String}
  SkipOp{b: Bool}
type Output is Type:
  Output{world: World, text: String}

def initial(+capacity: Nat) -> World:
  World{0, 0, [], [], L.Log{capacity, [], 0}, L.Log{capacity, [], 0}, L.Log{capacity, [], 0}, Slots{None{}, None{}}}
def include(c: Maybe<&2, Reader>, tail: List<&2, L.Cursor>, message: Bool) -> List<&2, L.Cursor>:
  match c message:
    case None{} _: tail
    case Some{Reader{last, _, reg}} False{}: L.Cursor{last, reg} <> tail
    case Some{Reader{_, msg, reg}} True{}: L.Cursor{msg, reg} <> tail
def holders(slots: Slots, +message: Bool) -> List<&2, L.Cursor>:
  match slots:
    case Slots{a, b}: include(a, include(b, [], message), message)
def frame(w: World) -> World:
  match w:
    case World{+clock, +old, rows, pending, removed, despawned, messages, +slots}: World{clock, clock, rows, pending, L.trim(removed, holders(slots, False{}), old), L.trim(despawned, holders(slots, False{}), old), L.trim(messages, holders(slots, True{}), old), slots}
def set_row(value: U32, +tick: U32, row: Row) -> Row:
  match row:
    case Row{id, None{}, _, _}: Row{id, Some{value}, tick, tick}
    case Row{id, Some{_}, added, _}: Row{id, Some{value}, added, tick}
def update_choose(found: Bool, row: Row, value: U32, tick: U32) -> Row:
  match found:
    case True{}: set_row(value, tick, row)
    case False{}: row
def update(rows: List<&2, Row>, +id: U32, +value: U32, +tick: U32) -> List<&2, Row>:
  match rows:
    case Nil{}: []
    case Con{Row{+key, old, added, changed}, tail}: update_choose(U32.is_eq(key, id), Row{key, old, added, changed}, value, tick) <> update(tail, id, value, tick)
def removed_row(found: Bool, row: Row, despawn: Bool, tail: List<&2, Row>) -> List<&2, Row>:
  match found row despawn:
    case False{} r _: r <> tail
    case True{} _ True{}: tail
    case True{} Row{id, _, added, changed} False{}: Row{id, None{}, added, changed} <> tail
def erase(rows: List<&2, Row>, +id: U32, +despawn: Bool) -> List<&2, Row>:
  match rows:
    case Nil{}: []
    case Con{Row{+key, value, added, changed}, tail}: removed_row(U32.is_eq(key, id), Row{key, value, added, changed}, despawn, erase(tail, id, despawn))
def present_row(found: Bool, value: Maybe<&2, U32>, rest: Bool) -> Bool:
  match found value:
    case True{} Some{_}: True{}
    case _ _: rest
def present(rows: List<&2, Row>, +id: U32) -> Bool:
  match rows:
    case Nil{}: False{}
    case Con{Row{key, value, _, _}, tail}: present_row(U32.is_eq(key, id), value, present(tail, id))
def exists(rows: List<&2, Row>, +id: U32) -> Bool:
  match rows:
    case Nil{}: False{}
    case Con{Row{key, _, _, _}, tail}: Bool.or(U32.is_eq(key, id), exists(tail, id))
def append_if(yes: Bool, log: L.Log, tick: U32, id: U32) -> L.Log:
  match yes:
    case False{}: log
    case True{}: L.append(log, tick, [id])
def apply(command: Command, w: World) -> World:
  match command w:
    case Spawn{id, value} World{+tick, frame, rows, pending, removed, despawned, messages, slots}: World{tick, frame, List.append(&2, Row, rows, [Row{id, Some{value}, tick, tick}]), pending, removed, despawned, messages, slots}
    case Insert{id, value} World{+tick, frame, rows, pending, removed, despawned, messages, slots}: World{tick, frame, update(rows, id, value, tick), pending, removed, despawned, messages, slots}
    case Remove{+id} World{+tick, frame, +rows, pending, removed, despawned, messages, slots}: World{tick, frame, erase(rows, id, False{}), pending, append_if(present(rows, id), removed, tick, id), despawned, messages, slots}
    case Despawn{+id} World{+tick, frame, +rows, pending, removed, despawned, messages, slots}: World{tick, frame, erase(rows, id, True{}), pending, append_if(present(rows, id), removed, tick, id), append_if(exists(rows, id), despawned, tick, id), messages, slots}
def apply_all(commands: List<&2, Command>, w: World) -> World:
  match commands:
    case Nil{}: w
    case Con{command, tail}: apply_all(tail, apply(command, w))
def queue(commands: List<&2, Command>, w: World) -> World:
  match w:
    case World{tick, frame, rows, pending, removed, despawned, messages, slots}: World{(tick + 1 : U32), frame, rows, List.append(&2, Command, pending, commands), removed, despawned, messages, slots}
def flush(w: World) -> World:
  match w:
    case World{tick, frame, rows, pending, removed, despawned, messages, slots}: apply_all(pending, World{(tick + 1 : U32), frame, rows, [], removed, despawned, messages, slots})
def write_present(old: Maybe<&2, U32>, id: U32, value: U32, added: U32, changed: U32, tick: U32) -> Row:
  match old:
    case None{}: Row{id, None{}, added, changed}
    case Some{_}: Row{id, Some{value}, added, tick}
def write_rows(rows: List<&2, Row>, +value: U32, +tick: U32) -> List<&2, Row>:
  match rows:
    case Nil{}: []
    case Con{Row{id, old, added, changed}, tail}: write_present(old, id, value, added, changed, tick) <> write_rows(tail, value, tick)
def write_commit(success: Bool, old: List<&2, Row>, next: List<&2, Row>) -> List<&2, Row>:
  match success:
    case True{}: next
    case False{}: old
def write(value: U32, success: Bool, w: World) -> World:
  match w:
    case World{+tick, frame, +rows, pending, removed, despawned, messages, slots}: World{(tick + 1 : U32), frame, write_commit(success, rows, write_rows(rows, value, (tick + 1 : U32))), pending, removed, despawned, messages, slots}
def emit(value: U32, w: World) -> World:
  match w:
    case World{+tick, frame, rows, pending, removed, despawned, messages, slots}: World{(tick + 2 : U32), frame, rows, pending, removed, despawned, L.append(messages, (tick + 2 : U32), [value]), slots}
def selected(b: Bool, slots: Slots) -> Maybe<&2, Reader>:
  match b slots:
    case False{} Slots{a, _}: a
    case True{} Slots{_, b}: b
def registered(c: Maybe<&2, Reader>, tick: U32) -> Reader:
  match c:
    case None{}: Reader{0, 0, tick}
    case Some{c}: c
def set_slot(b: Bool, slots: Slots, c: Reader) -> Slots:
  match b slots:
    case False{} Slots{_, b}: Slots{Some{c}, b}
    case True{} Slots{a, _}: Slots{a, Some{c}}
def complete(success: Bool, c: Reader, +tick: U32) -> Reader:
  match success c:
    case True{} Reader{_, _, registered}: Reader{tick, tick, registered}
    case False{} old: old
def skipped(b: Bool, +tick: U32, frame: U32, rows: List<&2, Row>, pending: List<&2, Command>, removed: L.Log, despawned: L.Log, messages: L.Log, slots: Slots, c: Maybe<&2, Reader>) -> World:
  match c:
    case None{}: World{tick, frame, rows, pending, removed, despawned, messages, slots}
    case Some{Reader{last, _, reg}}: World{tick, frame, rows, pending, removed, despawned, messages, set_slot(b, slots, Reader{last, tick, reg})}
def skip(+b: Bool, w: World) -> World:
  match w:
    case World{+tick, frame, rows, pending, removed, despawned, messages, +slots}: skipped(b, tick, frame, rows, pending, removed, despawned, messages, slots, selected(b, slots))
def values_text(values: List<&2, U32>) -> String:
  match values:
    case Nil{}: ""
    case Con{v, tail}: U32.show(v) ++ "," ++ values_text(tail)
def choose_text(yes: Bool, value: U32) -> String:
  match yes:
    case True{}: U32.show(value) ++ ","
    case False{}: ""
def observe_row(value: Maybe<&2, U32>, added: U32, changed: U32, +since: U32) -> String & String:
  match value:
    case None{}: ("", "")
    case Some{+value}: (choose_text(U32.is_gt(added, since), value), choose_text(U32.is_gt(changed, since), value))
def merge_rest(a: String, c: String, rest: String & String) -> String & String:
  match rest:
    case (b, d): (a ++ b, c ++ d)
def merge_rows(first: String & String, rest: String & String) -> String & String:
  match first:
    case (a, c): merge_rest(a, c, rest)
def observe_rows(rows: List<&2, Row>, +since: U32) -> String & String:
  match rows:
    case Nil{}: ("", "")
    case Con{Row{_, value, added, changed}, tail}: merge_rows(observe_row(value, added, changed, since), observe_rows(tail, since))
def live_value(value: Maybe<&2, U32>) -> String:
  match value:
    case None{}: ""
    case Some{value}: U32.show(value) ++ ","
def live_values(rows: List<&2, Row>) -> String:
  match rows:
    case Nil{}: ""
    case Con{Row{_, value, _, _}, tail}: live_value(value) ++ live_values(tail)
def read_messages(+started: U32, b: Bool, success: Bool, frame: U32, rows: List<&2, Row>, pending: List<&2, Command>, slots: Slots, c: Reader, text: String, removed: L.Log, despawned: L.Log, result: L.Log & (List<&2, U32> & Bool)) -> Output:
  match result:
    case (m, (mv, _)): Output{World{started, frame, rows, pending, removed, despawned, m, set_slot(b, slots, complete(success, c, started))}, text ++ ";e=" ++ values_text(mv)}
def read_despawned(started: U32, b: Bool, success: Bool, frame: U32, rows: List<&2, Row>, pending: List<&2, Command>, slots: Slots, c: Reader, text: String, removed: L.Log, result: L.Log & (List<&2, U32> & Bool), messages: L.Log & (List<&2, U32> & Bool)) -> Output:
  match result:
    case (d, (dv, _)): read_messages(started, b, success, frame, rows, pending, slots, c, text ++ ";d=" ++ values_text(dv), removed, d, messages)
def read_removed(started: U32, b: Bool, success: Bool, frame: U32, rows: List<&2, Row>, pending: List<&2, Command>, slots: Slots, c: Reader, text: String, result: L.Log & (List<&2, U32> & Bool), despawned: L.Log & (List<&2, U32> & Bool), messages: L.Log & (List<&2, U32> & Bool)) -> Output:
  match result:
    case (r, (rv, _)): read_despawned(started, b, success, frame, rows, pending, slots, c, text ++ ";r=" ++ values_text(rv), r, despawned, messages)
def read_finish(started: U32, b: Bool, success: Bool, frame: U32, +rows: List<&2, Row>, pending: List<&2, Command>, slots: Slots, c: Reader, changes: String & String, removed: L.Log & (List<&2, U32> & Bool), despawned: L.Log & (List<&2, U32> & Bool), messages: L.Log & (List<&2, U32> & Bool)) -> Output:
  match changes:
    case (a, changed): read_removed(started, b, success, frame, rows, pending, slots, c, "v=" ++ live_values(rows) ++ ";a=" ++ a ++ ";c=" ++ changed, removed, despawned, messages)
def read_start(+tick: U32, b: Bool, success: Bool, frame: U32, +rows: List<&2, Row>, pending: List<&2, Command>, removed: L.Log, despawned: L.Log, messages: L.Log, slots: Slots, c: Reader) -> Output:
  match c:
    case Reader{+last, +msg, +reg}: read_finish((tick + 1 : U32), b, success, frame, rows, pending, slots, Reader{last, msg, reg}, observe_rows(rows, last), L.read(removed, L.Cursor{last, reg}), L.read(despawned, L.Cursor{last, reg}), L.read(messages, L.Cursor{msg, reg}))
def read(+b: Bool, success: Bool, w: World) -> Output:
  match w:
    case World{+tick, frame, rows, pending, removed, despawned, messages, +slots}: read_start(tick, b, success, frame, rows, pending, removed, despawned, messages, slots, registered(selected(b, slots), tick))
def named(name: String, result: Output) -> Output:
  match result:
    case Output{w, text}: Output{w, name ++ ":" ++ text ++ "\n"}
def step(op: Op, w: World) -> Output:
  match op:
    case Frame{}: Output{frame(w), ""}
    case Queue{commands}: Output{queue(commands, w), ""}
    case Flush{}: Output{flush(w), ""}
    case Write{value, success}: Output{write(value, success, w), ""}
    case EmitOp{value}: Output{emit(value, w), ""}
    case ReadOp{b, success, name}: named(name, read(b, success, w))
    case SkipOp{b}: Output{skip(b, w), ""}
def append_text(prefix: String, result: Output) -> Output:
  match result:
    case Output{w, text}: Output{w, prefix ++ text}
def run(ops: List<&2, Op>, result: Output) -> Output:
  match ops result:
    case Nil{} result: result
    case Con{op, tail} Output{w, text}: run(tail, append_text(text, step(op, w)))
def trace(result: Output) -> String:
  match result:
    case Output{_, text}: text

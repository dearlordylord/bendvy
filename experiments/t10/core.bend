import Base
import ../t08/core.bend as C
import ../t08/log.bend as L

type Stats is Data:
  Stats{count: U32, sum: U32, events: U32}
type Outcome is Type:
  Outcome{world: C.World, observed: U32}
def spawns(n: Nat, +id: U32) -> List<&2, C.Command>:
  match n:
    case 0n: []
    case 1n+k: C.Spawn{id, 1} <> spawns(k, (id + 1 : U32))
def sparse_command(keep: Bool, id: U32, tail: List<&2, C.Command>) -> List<&2, C.Command>:
  match keep:
    case True{}: tail
    case False{}: C.Remove{id} <> tail
def sparse(n: Nat, +id: U32) -> List<&2, C.Command>:
  match n:
    case 0n: []
    case 1n+k: sparse_command(U32.is_eq(U32.mod(id, 8), 0), id, sparse(k, (id + 1 : U32)))
def setup_sparse(mode: U32, +n: U32, w: C.World) -> C.World:
  match mode:
    case 1: C.flush(C.queue(sparse(U32.to_nat(n), 0), w))
    case _: w
def setup(+n: U32, mode: U32) -> C.World:
  setup_sparse(mode, n, C.flush(C.queue(spawns(U32.to_nat(n), 0), C.initial(U32.to_nat(65536)))))
def add_value(value: Maybe<&2, U32>, stats: Stats) -> Stats:
  match value stats:
    case None{} stats: stats
    case Some{x} Stats{count, sum, events}: Stats{(count + 1 : U32), (sum + x : U32), events}
def stats_rows(rows: List<&2, C.Row>) -> Stats:
  match rows:
    case Nil{}: Stats{0, 0, 0}
    case Con{C.Row{_, value, _, _}, tail}: add_value(value, stats_rows(tail))
def sum_value(stats: Stats) -> U32:
  match stats:
    case Stats{_, sum, _}: sum
def observe(w: C.World) -> Outcome:
  match w:
    case C.World{clock, frame, +rows, pending, removed, despawned, messages, slots}: Outcome{C.World{clock, frame, rows, pending, removed, despawned, messages, slots}, sum_value(stats_rows(rows))}
def advance(w: C.World) -> C.World:
  match w:
    case C.World{tick, frame, rows, pending, removed, despawned, messages, slots}: C.World{(tick + 1 : U32), frame, rows, pending, removed, despawned, messages, slots}
def read_values(values: List<&2, U32>) -> U32:
  match values:
    case Nil{}: 0
    case Con{x, tail}: (x + read_values(tail) : U32)
def read_events_result(wclock: U32, frame: U32, rows: List<&2, C.Row>, pending: List<&2, C.Command>, removed: L.Log, despawned: L.Log, slots: C.Slots, result: L.Log & (List<&2, U32> & Bool)) -> Outcome:
  match result:
    case (messages, (values, _)): Outcome{C.World{wclock, frame, rows, pending, removed, despawned, messages, slots}, read_values(values)}
def read_events(cursor: U32, w: C.World) -> Outcome:
  match w:
    case C.World{clock, frame, rows, pending, removed, despawned, messages, slots}: read_events_result(clock, frame, rows, pending, removed, despawned, slots, L.read(messages, L.Cursor{cursor, 0}))
def churn(w: C.World) -> C.World:
  C.flush(C.queue([C.Remove{0}, C.Insert{0, 1}], w))
def event_round(w: C.World) -> Outcome:
  match w:
    case C.World{+tick, frame, rows, pending, removed, despawned, messages, slots}: read_events(tick, C.emit(1, C.World{tick, frame, rows, pending, removed, despawned, messages, slots}))
def churn_read_result(clock: U32, frame: U32, rows: List<&2, C.Row>, pending: List<&2, C.Command>, despawned: L.Log, messages: L.Log, slots: C.Slots, result: L.Log & (List<&2, U32> & Bool)) -> Outcome:
  match result:
    case (removed, (ids, _)): Outcome{C.World{(clock + 1 : U32), frame, rows, pending, removed, despawned, messages, slots}, U32.from_nat(List.length(&2, U32, ids))}
def churn_read(before: U32, w: C.World) -> Outcome:
  match w:
    case C.World{clock, frame, rows, pending, removed, despawned, messages, slots}: churn_read_result(clock, frame, rows, pending, despawned, messages, slots, L.read(removed, L.Cursor{before, 0}))
def churn_round(w: C.World) -> Outcome:
  match w:
    case C.World{+tick, frame, rows, pending, removed, despawned, messages, slots}: churn_read(tick, churn(C.World{tick, frame, rows, pending, removed, despawned, messages, slots}))
def fail_ready(tick: U32, frame: U32, old: List<&2, C.Row>, +written: List<&2, C.Row>, pending: List<&2, C.Command>, removed: L.Log, despawned: L.Log, messages: L.Log, slots: C.Slots) -> Outcome:
  Outcome{C.World{tick, frame, C.write_commit(False{}, old, written), pending, removed, despawned, messages, slots}, sum_value(stats_rows(written))}
def fail_round(value: U32, w: C.World) -> Outcome:
  match w:
    case C.World{+tick, frame, +rows, pending, removed, despawned, messages, slots}: fail_ready((tick + 1 : U32), frame, rows, C.write_rows(rows, value, (tick + 1 : U32)), pending, removed, despawned, messages, slots)
def step(mode: U32, value: U32, w: C.World) -> Outcome:
  match mode:
    case 0: observe(advance(w))
    case 1: observe(advance(w))
    case 2: Outcome{C.write(value, True{}, w), 0}
    case 3: churn_round(w)
    case 4: event_round(w)
    case _: fail_round(value, w)
def add_observed(previous: U32, result: Outcome) -> Outcome:
  match result:
    case Outcome{w, value}: Outcome{w, (previous + value : U32)}
def loops(n: Nat, +mode: U32, +round: U32, result: Outcome) -> Outcome:
  match n result:
    case 0n result: result
    case 1n+k Outcome{w, observed}: loops(k, mode, (round + 1 : U32), add_observed(observed, step(mode, round, C.frame(w))))
def final_stats(observed: U32, stats: Stats) -> String:
  match stats:
    case Stats{count, sum, _}: U32.show(count) ++ ":" ++ U32.show(sum) ++ ":" ++ U32.show(observed)
def row_text(row: C.Row) -> String:
  match row:
    case C.Row{id, Some{value}, _, _}: U32.show(id) ++ "=" ++ U32.show(value) ++ ","
    case _: ""
def ordered_rows(rows: List<&2, C.Row>) -> String:
  match rows:
    case Nil{}: ""
    case Con{row, tail}: row_text(row) ++ ordered_rows(tail)
def finish(result: Outcome) -> String:
  match result:
    case Outcome{C.World{_, _, +rows, _, _, _, _, _}, observed}: final_stats(observed, stats_rows(rows)) ++ "|" ++ ordered_rows(rows)

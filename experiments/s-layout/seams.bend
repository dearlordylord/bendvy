import Base
import ./core.bend as B
import ../t08/core.bend as C

type Output is Type:
  Output{world: B.World, text: String}
def empty_checked(valid: Bool, limit: U32) -> B.World:
  match valid:
    case False{}: B.World{0, [C.Row{4294967295, None{}, 0, 0} : C.Row^11n], [], C.initial(65536n)}
    case True{}: B.World{limit, [C.Row{4294967295, None{}, 0, 0} : C.Row^11n], [], C.initial(65536n)}
def empty(+limit: U32) -> B.World:
  empty_checked((limit <= 2048 : U32), limit)
def rows_got(rest: List<&2, C.Row>, result: Array<C.Row> & C.Row) -> Array<C.Row> & List<&2, C.Row>:
  match result:
    case (a, row): (a, row <> rest)
def rows_next(id: U32, limit: U32, result: Array<C.Row> & List<&2, C.Row>) -> Array<C.Row> & List<&2, C.Row>:
  match result:
    case (a, rest): rows_got(rest, B.get(limit, a, id))
def rows(ids: List<&2, U32>, +limit: U32, a: Array<C.Row>) -> Array<C.Row> & List<&2, C.Row>:
  match ids:
    case Nil{}: (a, [])
    case Con{id, tail}: rows_next(id, limit, rows(tail, limit, a))
def restore_read(limit: U32, a: Array<C.Row>, members: List<&2, U32>, output: C.Output) -> Output:
  match output:
    case C.Output{C.World{clock, frame, _, pending, removed, despawned, messages, slots}, text}: Output{B.World{limit, a, members, C.World{clock, frame, [], pending, removed, despawned, messages, slots}}, text}
def with_rows(rs: List<&2, C.Row>, meta: C.World) -> C.World:
  match meta:
    case C.World{clock, frame, _, pending, removed, despawned, messages, slots}: C.World{clock, frame, rs, pending, removed, despawned, messages, slots}
def read_rows(limit: U32, members: List<&2, U32>, meta: C.World, b: Bool, success: Bool, result: Array<C.Row> & List<&2, C.Row>) -> Output:
  match result:
    case (a, rs): restore_read(limit, a, members, C.read(b, success, with_rows(rs, meta)))
def read(b: Bool, success: Bool, w: B.World) -> Output:
  match w:
    case B.World{+limit, a, +members, meta}: read_rows(limit, members, meta, b, success, rows(members, limit, a))
def emit(value: U32, w: B.World) -> B.World:
  match w:
    case B.World{limit, a, members, meta}: B.World{limit, a, members, C.emit(value, meta)}
def skip(b: Bool, w: B.World) -> B.World:
  match w:
    case B.World{limit, a, members, meta}: B.World{limit, a, members, C.skip(b, meta)}
def from_outcome(result: B.Outcome) -> B.World:
  match result:
    case B.Outcome{w, _}: w
def write(success: Bool, value: U32, w: B.World) -> B.World:
  match success:
    case True{}: B.write(value, w)
    case False{}: from_outcome(B.fail_round(value, w))
def named(name: String, result: Output) -> Output:
  match result:
    case Output{w, text}: Output{w, name ++ ":" ++ text ++ "\n"}
def step(op: C.Op, w: B.World) -> Output:
  match op:
    case C.Frame{}: Output{B.frame(w), ""}
    case C.Queue{commands}: Output{B.queue(commands, w), ""}
    case C.Flush{}: Output{B.flush(w), ""}
    case C.Write{value, success}: Output{write(success, value, w), ""}
    case C.EmitOp{value}: Output{emit(value, w), ""}
    case C.ReadOp{b, success, name}: named(name, read(b, success, w))
    case C.SkipOp{b}: Output{skip(b, w), ""}
def append_text(prefix: String, result: Output) -> Output:
  match result:
    case Output{w, text}: Output{w, prefix ++ text}
def run(ops: List<&2, C.Op>, result: Output) -> Output:
  match ops result:
    case Nil{} result: result
    case Con{op, tail} Output{w, text}: run(tail, append_text(text, step(op, w)))
def trace(result: Output) -> String:
  match result:
    case Output{_, text}: text

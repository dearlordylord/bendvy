import Base
import ./streams.bend as S

type Slots is Data:
  Slots{a: Maybe<&2, S.Cursor>, b: Maybe<&2, S.Cursor>}
type World is Type:
  World{clock: U32, frame: U32, retained: U32, log: S.Log, slots: Slots}
type Op is Data:
  Frame{}
  EmitOp{values: List<&2, U32>, success: Bool}
  ReadOp{b: Bool, success: Bool, name: String}
  SkipOp{b: Bool}
type StepResult is Type:
  StepResult{world: World, trace: String}

def initial(capacity: Nat) -> World:
  World{0, 0, 0, S.Log{capacity, [], 0}, Slots{None{}, None{}}}
def include(c: Maybe<&2, S.Cursor>, tail: List<&2, S.Cursor>) -> List<&2, S.Cursor>:
  match c:
    case None{}: tail
    case Some{c}: c <> tail
def cursors(slots: Slots) -> List<&2, S.Cursor>:
  match slots:
    case Slots{a, b}: include(a, include(b, []))
def frame(w: World) -> World:
  match w:
    case World{+clock, +previous, +retained, log, +slots}: World{clock, clock, S.maximum(previous, retained), S.trim(log, cursors(slots), S.maximum(previous, retained)), slots}
def emit_publish(success: Bool, nonempty: Bool, +started: U32, frame: U32, retained: U32, log: S.Log, slots: Slots, values: List<&2, U32>) -> World:
  match success nonempty:
    case True{} True{}: World{(started + 1 : U32), frame, retained, S.append(log, (started + 1 : U32), values), slots}
    case _ _: World{started, frame, retained, log, slots}
def emit(w: World, +values: List<&2, U32>, success: Bool) -> World:
  match w:
    case World{clock, frame, retained, log, slots}: emit_publish(success, Nat.is_gt(List.length(&2, U32, values), 0n), (clock + 1 : U32), frame, retained, log, slots, values)
def slot(b: Bool, slots: Slots) -> Maybe<&2, S.Cursor>:
  match b slots:
    case False{} Slots{a, _}: a
    case True{} Slots{_, b}: b
def registered(cursor: Maybe<&2, S.Cursor>, clock: U32) -> S.Cursor:
  match cursor:
    case None{}: S.Cursor{0, clock}
    case Some{c}: c
def set_slot(b: Bool, slots: Slots, cursor: S.Cursor) -> Slots:
  match b slots:
    case False{} Slots{_, b}: Slots{Some{cursor}, b}
    case True{} Slots{a, _}: Slots{a, Some{cursor}}
def bool_text(b: Bool) -> String:
  match b:
    case True{}: "true"
    case False{}: "false"
def values_text(values: List<&2, U32>) -> String:
  match values:
    case Nil{}: ""
    case Con{v, tail}: U32.show(v) ++ "," ++ values_text(tail)
def read_result(b: Bool, success: Bool, +started: U32, frame: U32, retained: U32, slots: Slots, cursor: S.Cursor, result: S.Log & (List<&2, U32> & Bool)) -> StepResult:
  match result:
    case (log, (values, lagged)): StepResult{World{started, frame, retained, log, set_slot(b, slots, S.complete(success, cursor, started))}, values_text(values) ++ ":" ++ bool_text(lagged)}
def read_start(b: Bool, success: Bool, +clock: U32, frame: U32, retained: U32, log: S.Log, slots: Slots, +cursor: S.Cursor) -> StepResult:
  read_result(b, success, (clock + 1 : U32), frame, retained, slots, cursor, S.read(log, cursor))
def read(+b: Bool, success: Bool, w: World) -> StepResult:
  match w:
    case World{+clock, frame, retained, log, +slots}: read_start(b, success, clock, frame, retained, log, slots, registered(slot(b, slots), clock))
def skipped(b: Bool, +clock: U32, frame: U32, retained: U32, log: S.Log, +slots: Slots, reader: Maybe<&2, S.Cursor>) -> World:
  match reader:
    case None{}: World{clock, frame, retained, log, slots}
    case Some{c}: World{clock, frame, retained, log, set_slot(b, slots, S.skip(c, clock))}
def skip(+b: Bool, w: World) -> World:
  match w:
    case World{+clock, frame, retained, log, +slots}: skipped(b, clock, frame, retained, log, slots, slot(b, slots))
def read_named(name: String, result: StepResult) -> StepResult:
  match result:
    case StepResult{w, text}: StepResult{w, name ++ ":" ++ text ++ "\n"}
def step(op: Op, w: World) -> StepResult:
  match op:
    case Frame{}: StepResult{frame(w), ""}
    case EmitOp{values, success}: StepResult{emit(w, values, success), ""}
    case ReadOp{b, success, name}: read_named(name, read(b, success, w))
    case SkipOp{b}: StepResult{skip(b, w), ""}
def append_trace(prefix: String, result: StepResult) -> StepResult:
  match result:
    case StepResult{w, text}: StepResult{w, prefix ++ text}
def run(ops: List<Op>, result: StepResult) -> StepResult:
  match ops result:
    case Nil{} result: result
    case Con{op, tail} StepResult{w, text}: run(tail, append_trace(text, step(op, w)))
def trace(result: StepResult) -> String:
  match result:
    case StepResult{_, text}: text

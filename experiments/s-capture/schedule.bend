import Base
import ./core.bend as C
import ./local.bend as L
import ./system.bend as S
type ScheduleOwner is Type:
  ScheduleOwner{a: L.Local, b: L.Local, world: C.World, tail: U32}
type Input is Data:
  Execute{label: String, which: Bool, mode: S.Mode, skip: Bool}
  Barrier{label: String}
  EmitForSkip{}
  EmptySchedule{}
def initial() -> ScheduleOwner:
  ScheduleOwner{L.initial(), L.initial(), C.initial(), 0}
def show_outcome(outcome: C.Outcome) -> String:
  match outcome:
    case C.Success{}: "Success"
    case C.Failure{name, code}: name ++ ":" ++ U32.show(code)
def local_b(a: L.Local, b_result: L.Local & U32, w: C.World, +tail: U32, prefix: String, x: U32, state: String, unread: U32) -> ScheduleOwner & String:
  match b_result:
    case (b, y): (ScheduleOwner{a, b, w, tail}, prefix ++ ":" ++ state ++ ":local=" ++ U32.show(x) ++ "," ++ U32.show(y) ++ ":B-unread=" ++ U32.show(unread) ++ ":tail=" ++ U32.show(tail) ++ "\n")
def local_a(b: L.Local, w: C.World, tail: U32, prefix: String, state: String, unread: U32, a_result: L.Local & U32) -> ScheduleOwner & String:
  match a_result:
    case (a, x): local_b(a, L.observe(b), w, tail, prefix, x, state, unread)
def observed(a: L.Local, b: L.Local, tail: U32, prefix: String, unread: U32, result: C.World & String) -> ScheduleOwner & String:
  match result:
    case (w, state): local_a(b, w, tail, prefix, state, unread, L.observe(a))
def counted(a: L.Local, b: L.Local, tail: U32, prefix: String, result: C.World & U32) -> ScheduleOwner & String:
  match result:
    case (w, unread): observed(a, b, tail, prefix, unread, C.observe(w))
# The nested child returns its typed outcome; failure prevents the parent's tail.
def nested_parent(a: L.Local, b: L.Local, tail: U32, label: String, result: C.Prepared<C.World>) -> ScheduleOwner & String:
  match result:
    case C.Prepared{w, C.Success{}, text}:
      +next = (tail + 1 : U32)
      counted(a, b, next, text ++ "tail:" ++ U32.show(next) ++ "\n" ++ label ++ ":result=Success", C.unread(w))
    case C.Prepared{w, C.Failure{name, code}, text}: counted(a, b, tail, text ++ label ++ ":result=" ++ name ++ ":" ++ U32.show(code), C.unread(w))
def prefix_result(prefix: String, result: C.Prepared<C.World>) -> C.Prepared<C.World>:
  match result:
    case C.Prepared{w, outcome, text}: C.Prepared{w, outcome, prefix ++ text}
def provision(~body: @-T: Type -> (T -> C.Motion -> T & U32) -> (T -> C.Motion -> U32 -> T) -> (T -> C.Motion -> U32 -> T) -> (T -> T & String) -> (T -> U32 -> String -> T) -> S.Mode -> Bool -> U32 -> T -> C.Prepared<T>, mode: S.Mode, +which: Bool, count: U32, w: C.World) -> C.Prepared<C.World>:
  C.finish(which, body(C.Tx, C.read, C.write, C.write, C.project, C.stage, mode, which, count, C.begin(w)))
def run_step(+which: Bool, +count: U32, mode: S.Mode, result: C.World & String) -> C.Prepared<C.World>:
  match result:
    case (w, text): prefix_result("invoke:" ++ S.named(which) ++ ":local=" ++ U32.show(count) ++ ":seen=" ++ text ++ "\n", provision(~S.step, mode, which, count, w))
def no_seen(w: C.World) -> C.World & String:
  (w, "")
def run(which: Bool, count: U32, mode: S.Mode, w: C.World) -> C.Prepared<C.World>:
  match which:
    case False{}: run_step(False{}, count, mode, no_seen(w))
    case True{}: run_step(True{}, count, mode, C.seen(w))
def after_a(which: Bool, mode: S.Mode, label: String, b: L.Local, w: C.World, tail: U32, result: L.Local & U32) -> ScheduleOwner & String:
  match result:
    case (a, count): nested_parent(a, b, tail, label, run(which, count, mode, w))
def after_b(mode: S.Mode, label: String, a: L.Local, w: C.World, tail: U32, result: L.Local & U32) -> ScheduleOwner & String:
  match result:
    case (b, count): nested_parent(a, b, tail, label, run(True{}, count, mode, w))
def invoke(which: Bool, mode: S.Mode, label: String, a: L.Local, b: L.Local, w: C.World, tail: U32) -> ScheduleOwner & String:
  match which:
    case False{}: after_a(False{}, mode, label, b, w, tail, L.invoke(a))
    case True{}: after_b(mode, label, a, w, tail, L.invoke(b))
def execute(skip: Bool, which: Bool, mode: S.Mode, label: String, state: ScheduleOwner) -> ScheduleOwner & String:
  match skip state:
    case False{} ScheduleOwner{a, b, w, tail}: invoke(which, mode, label, a, b, w, tail)
    case True{} ScheduleOwner{a, b, w, tail}: nested_parent(a, b, tail, label, C.Prepared{C.skipped(w), C.Success{}, ""})
def barrier(label: String, state: ScheduleOwner) -> ScheduleOwner & String:
  match state:
    case ScheduleOwner{a, b, w, tail}: (ScheduleOwner{a, b, C.barrier(w), tail}, "barrier:" ++ label ++ ":commands=0\n")
def emit_observed(a: L.Local, b: L.Local, tail: U32, result: C.World & U32) -> ScheduleOwner & String:
  match result:
    case (w, unread): (ScheduleOwner{a, b, w, tail}, "before-skip:B-unread=" ++ U32.show(unread) ++ "\n")
def emit_skip(state: ScheduleOwner) -> ScheduleOwner & String:
  match state:
    case ScheduleOwner{a, b, w, tail}: emit_observed(a, b, tail, C.unread(C.emit_for_skip(w)))
def empty(state: ScheduleOwner) -> ScheduleOwner & String:
  match state:
    case ScheduleOwner{a, b, w, tail}: counted(a, b, tail, "empty-schedule:result=Success", C.unread(w))
def apply(input: Input, state: ScheduleOwner) -> ScheduleOwner & String:
  match input:
    case Execute{label, which, mode, skip}: execute(skip, which, mode, label, state)
    case Barrier{label}: barrier(label, state)
    case EmitForSkip{}: emit_skip(state)
    case EmptySchedule{}: empty(state)
def inputs() -> List<&2, Input>:
  [EmptySchedule{}, Execute{"empty", True{}, S.Noop{}, False{}}, Execute{"earlier", False{}, S.Run{}, False{}}, Execute{"failed", True{}, S.Injected{}, False{}}, Execute{"retry", True{}, S.Run{}, False{}}, Execute{"repeat", True{}, S.Run{}, False{}}, Execute{"other-repeat", False{}, S.Run{}, False{}}, Execute{"noop", True{}, S.Noop{}, False{}}, Barrier{"off"}, EmitForSkip{}, Execute{"skip", True{}, S.Run{}, True{}}, Barrier{"on"}, Execute{"after-skip", True{}, S.Noop{}, False{}}]
def combined(prefix: String, result: ScheduleOwner & String) -> ScheduleOwner & String:
  match result:
    case (state, text): (state, prefix ++ text)
def folded(acc: ScheduleOwner & String, input: Input) -> ScheduleOwner & String:
  match acc:
    case (state, prefix): combined(prefix, apply(input, state))
def final(result: ScheduleOwner & String) -> String:
  match result:
    case (_, text): text
def loop(inputs: List<&2, Input>, state: ScheduleOwner, prefix: String) -> String:
  final(List.foldl(~&2, ~Input, ~(ScheduleOwner & String), ~folded, inputs, (state, prefix)))

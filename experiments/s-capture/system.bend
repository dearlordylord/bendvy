import Base
import ./core.bend as C
type Mode is Data:
  Noop{}
  Run{}
  Injected{}
def result(mode: Mode) -> C.Outcome:
  match mode:
    case Injected{}: C.Failure{"B", 7}
    case _: C.Success{}
def named(which: Bool) -> String:
  match which:
    case False{}: "A"
    case True{}: "B"
def publication(which: Bool, count: U32) -> U32 & String:
  match which:
    case False{}: (count, "remove:A")
    case True{}: (9, "insert:B")
def publish_pair(-T: Type, stage: T -> U32 -> String -> T, mode: Mode, +name: String, +count: U32, t: T, text: String, pair: U32 & String) -> C.Prepared<T>:
  match pair:
    case (value, command): C.Prepared{stage(t, value, command), result(mode), "own:" ++ name ++ ":" ++ text ++ "\nhost:" ++ name ++ ":" ++ U32.show(count) ++ "\n"}
def after(-T: Type, stage: T -> U32 -> String -> T, mode: Mode, +which: Bool, +count: U32, result: T & String) -> C.Prepared<T>:
  match result:
    case (t, text): publish_pair(T, stage, mode, named(which), count, t, text, publication(which, count))
def choose_write(-T: Type, write1: T -> C.Motion -> U32 -> T, write2: T -> C.Motion -> U32 -> T, project: T -> T & String, stage: T -> U32 -> String -> T, mode: Mode, which: Bool, count: U32, t: T, +old: U32) -> C.Prepared<T>:
  match which:
    case False{}: after(T, stage, mode, False{}, count, project(write1(t, C.Motion{}, (old + 1 : U32))))
    case True{}: after(T, stage, mode, True{}, count, project(write2(write1(t, C.Motion{}, (old + 10 : U32)), C.Motion{}, (old + 20 : U32))))
def writes(-T: Type, write1: T -> C.Motion -> U32 -> T, write2: T -> C.Motion -> U32 -> T, project: T -> T & String, stage: T -> U32 -> String -> T, mode: Mode, which: Bool, count: U32, pair: T & U32) -> C.Prepared<T>:
  match pair:
    case (t, old): choose_write(T, write1, write2, project, stage, mode, which, count, t, old)
def step(-T: Type, read: T -> C.Motion -> T & U32, write1: T -> C.Motion -> U32 -> T, write2: T -> C.Motion -> U32 -> T, project: T -> T & String, stage: T -> U32 -> String -> T, mode: Mode, which: Bool, count: U32, t: T) -> C.Prepared<T>:
  match mode:
    case Noop{}: C.Prepared{t, C.Success{}, ""}
    case mode: writes(T, write1, write2, project, stage, mode, which, count, read(t, C.Motion{}))

import Base
import ./owned.bend as A
import ./owned-main.bend as M

type Outcome is Type:
  Outcome{store: A.Store<A.Motion>, own: String}
def next(result: A.Store<A.Motion> & String) -> Outcome:
  match result:
    case (s, text): Outcome{s, text}
def loops(n: Nat, result: Outcome) -> Outcome:
  match n result:
    case 0n result: result
    case 1n+k Outcome{s, _}: loops(k, next(A.writable(~A.Motion, ~M.motion_step, False{}, 0, s)))
def prepared(result: A.Store<A.Motion> & String) -> A.Store<A.Motion>:
  match result:
    case (s, _): s
def setup() -> A.Store<A.Motion>:
  prepared(A.writable(~A.Motion, ~M.motion_step, True{}, 1, A.initial(~A.Motion)))
def finish_second(own: String, before: String, result: A.Store<A.Motion> & String) -> String:
  match result:
    case (_, second): own ++ ";restored=" ++ before ++ ";earlier=" ++ second
def finish_first(own: String, result: A.Store<A.Motion> & String) -> String:
  match result:
    case (s, first): finish_second(own, first, A.read(~A.Motion, ~M.motion_read, 1, s))
def finish(result: Outcome) -> String:
  match result:
    case Outcome{s, own}: finish_first(own, A.read(~A.Motion, ~M.motion_read, 0, s))
def stop(start: Nat, text: String) -> IO(Unit):
  do IO<Unit>:
    end : Nat <- IO.now()
    IO.print(text ++ ":" ++ Nat.show(Nat.sub(end, start)))
def measured(s: A.Store<A.Motion>, count: Nat) -> IO(Unit):
  do IO<Unit>:
    start : Nat <- IO.now()
    stop(start, finish(loops(count, Outcome{s, ""})))
def main() -> IO(Unit):
  do IO<Unit>:
    IO.print("warm:" ++ finish(loops(10000n, Outcome{setup(), ""})))
    IO.print("warm:" ++ finish(loops(10000n, Outcome{setup(), ""})))
    IO.print("warm:" ++ finish(loops(10000n, Outcome{setup(), ""})))
    measured(setup(), 10000n)

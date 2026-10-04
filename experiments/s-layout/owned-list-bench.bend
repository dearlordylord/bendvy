import Base
import ./owned.bend as A
import ./owned-list.bend as L
import ./owned-main.bend as M

type Outcome is Type:
  Outcome{store: L.Store, own: String}
def next(result: L.Store & String) -> Outcome:
  match result:
    case (s, text): Outcome{s, text}
def loops(n: Nat, result: Outcome) -> Outcome:
  match n result:
    case 0n result: result
    case 1n+k Outcome{s, _}: loops(k, next(L.writable(~M.motion_step, False{}, s)))
def prepared(result: L.Store & String) -> L.Store:
  match result:
    case (s, _): s
def setup() -> L.Store:
  L.prepare(~M.motion_step, L.initial())
def finish_cell2(own: String, before: U32, result: A.Cell<A.Motion> & U32) -> String:
  match result:
    case (_, second): own ++ ";restored=" ++ U32.show(before) ++ ";earlier=" ++ U32.show(second)
def finish_cell1(own: String, second: A.Cell<A.Motion>, result: A.Cell<A.Motion> & U32) -> String:
  match result:
    case (_, first): finish_cell2(own, first, A.get(~A.Motion, second, A.Motion{}))
def finish(result: Outcome) -> String:
  match result:
    case Outcome{L.Store{Con{first, Con{second, _}}}, own}: finish_cell1(own, second, A.get(~A.Motion, first, A.Motion{}))
    case _: "MissingEntity"
def stop(start: Nat, text: String) -> IO(Unit):
  do IO<Unit>:
    end : Nat <- IO.now()
    IO.print(text ++ ":" ++ Nat.show(Nat.sub(end, start)))
def measured(s: L.Store, count: Nat) -> IO(Unit):
  do IO<Unit>:
    start : Nat <- IO.now()
    stop(start, finish(loops(count, Outcome{s, ""})))
def main() -> IO(Unit):
  do IO<Unit>:
    IO.print("warm:" ++ finish(loops(10000n, Outcome{setup(), ""})))
    IO.print("warm:" ++ finish(loops(10000n, Outcome{setup(), ""})))
    IO.print("warm:" ++ finish(loops(10000n, Outcome{setup(), ""})))
    measured(setup(), 10000n)

import Base
import ./owned.bend as A

def result_text(-P: Type, before: U32, result: P & U32) -> P & String:
  match result:
    case (p, after): (p, U32.show(before) ++ "->" ++ U32.show(after))
def motion_write(-P: Type, put: P -> A.Motion -> U32 -> P, put2: P -> A.Motion -> U32 -> P, after: P -> A.Motion -> P & U32, result: P & U32) -> P & String:
  match result:
    case (p, before): result_text(P, before, after(put2(put(p, A.Motion{}, 17), A.Motion{}, 19), A.Motion{}))
def motion_step(-P: Type, get: P -> A.Motion -> P & U32, put: P -> A.Motion -> U32 -> P, put2: P -> A.Motion -> U32 -> P, after: P -> A.Motion -> P & U32, p: P) -> P & String:
  motion_write(P, put, put2, after, get(p, A.Motion{}))
def health_write(-P: Type, put: P -> A.Health -> U32 -> P, put2: P -> A.Health -> U32 -> P, after: P -> A.Health -> P & U32, result: P & U32) -> P & String:
  match result:
    case (p, before): result_text(P, before, after(put2(put(p, A.Health{}, 21), A.Health{}, 23), A.Health{}))
def health_step(-P: Type, get: P -> A.Health -> P & U32, put: P -> A.Health -> U32 -> P, put2: P -> A.Health -> U32 -> P, after: P -> A.Health -> P & U32, p: P) -> P & String:
  health_write(P, put, put2, after, get(p, A.Health{}))
def read_text(-P: Type, result: P & U32) -> P & String:
  match result:
    case (p, x): (p, U32.show(x))
def motion_read(-P: Type, get: P -> A.Motion -> P & U32, p: P) -> P & String:
  read_text(P, get(p, A.Motion{}))
def health_read(-P: Type, get: P -> A.Health -> P & U32, p: P) -> P & String:
  read_text(P, get(p, A.Health{}))
def print_motion(prefix: String, result: A.Store<A.Motion> & String) -> IO(A.Store<A.Motion>):
  match result:
    case (s, text):
      do IO<A.Store<A.Motion>>:
        IO.print(prefix ++ text)
        return s
def print_health(prefix: String, result: A.Store<A.Health> & String) -> IO(A.Store<A.Health>):
  match result:
    case (s, text):
      do IO<A.Store<A.Health>>:
        IO.print(prefix ++ text)
        return s
def main() -> IO(Unit):
  do IO<Unit>:
    m : A.Store<A.Motion> = A.initial(~A.Motion)
    m : A.Store<A.Motion> <- print_motion("motion:setup:", A.read(~A.Motion, ~motion_read, 0, m))
    m : A.Store<A.Motion> <- print_motion("motion:commit-own:", A.writable(~A.Motion, ~motion_step, True{}, 0, m))
    m : A.Store<A.Motion> <- print_motion("motion:failed-own:", A.writable(~A.Motion, ~motion_step, False{}, 1, m))
    m : A.Store<A.Motion> <- print_motion("motion:earlier-commit:", A.read(~A.Motion, ~motion_read, 0, m))
    m : A.Store<A.Motion> <- print_motion("motion:restored:", A.read(~A.Motion, ~motion_read, 1, m))
    m : A.Store<A.Motion> <- print_motion("motion:full-restored:", A.snapshot(~A.Motion, m))
    m : A.Store<A.Motion> <- print_motion("motion:retry-own:", A.writable(~A.Motion, ~motion_step, True{}, 1, m))
    m : A.Store<A.Motion> <- print_motion("motion:retry-visible:", A.read(~A.Motion, ~motion_read, 1, m))
    m : A.Store<A.Motion> <- print_motion("motion:remove:", A.remove(~A.Motion, A.Motion{}, 1, m))
    m : A.Store<A.Motion> <- print_motion("motion:vacant:", A.read(~A.Motion, ~motion_read, 1, m))
    m : A.Store<A.Motion> <- print_motion("motion:full-after-remove:", A.snapshot(~A.Motion, m))
    m : A.Store<A.Motion> <- print_motion("motion:bound:", A.read(~A.Motion, ~motion_read, 2, m))
    m : A.Store<A.Motion> <- print_motion("motion:max-bound:", A.read(~A.Motion, ~motion_read, 4294967295, m))
    h : A.Store<A.Health> = A.initial(~A.Health)
    h : A.Store<A.Health> <- print_health("health:commit-own:", A.writable(~A.Health, ~health_step, True{}, 1, h))
    h : A.Store<A.Health> <- print_health("health:failed-own:", A.writable(~A.Health, ~health_step, False{}, 0, h))
    h : A.Store<A.Health> <- print_health("health:restored:", A.read(~A.Health, ~health_read, 0, h))
    h : A.Store<A.Health> <- print_health("health:committed:", A.read(~A.Health, ~health_read, 1, h))
    return Unit{}

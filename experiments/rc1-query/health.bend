import Base
import ./api.bend as A
import ./schemas.bend as S
import ./system.bend as C

def print_query(prefix: String, result: A.World<S.HealthToken, S.CombatCell> & String) -> IO(A.World<S.HealthToken, S.CombatCell>):
  match result:
    case (w, text):
      do IO<A.World<S.HealthToken, S.CombatCell>>:
        IO.print(prefix ++ text)
        return w
def lookup_text(result: A.LookupResult) -> String:
  match result:
    case A.QueryMismatch{}: "QueryMismatch"
    case A.MissingEntity{}: "MissingEntity"
    case A.Matched{text}: "match:" ++ text
def print_lookup(prefix: String, result: A.World<S.HealthToken, S.CombatCell> & A.LookupResult) -> IO(A.World<S.HealthToken, S.CombatCell>):
  match result:
    case (w, result):
      do IO<A.World<S.HealthToken, S.CombatCell>>:
        IO.print(prefix ++ lookup_text(result))
        return w
def observe(+checkpoint: String, w: A.World<S.HealthToken, S.CombatCell>) -> IO(A.World<S.HealthToken, S.CombatCell>):
  do IO<A.World<S.HealthToken, S.CombatCell>>:
    w : A.World<S.HealthToken, S.CombatCell> <- print_query("health:" ++ checkpoint ++ ":Required:", A.query(~S.HealthToken, ~S.CombatCell, ~S.CombatData, ~C.health_read, ~S.combat_get, ~S.combat_has, A.Required{}, w))
    w : A.World<S.HealthToken, S.CombatCell> <- print_query("health:" ++ checkpoint ++ ":Present:", A.query(~S.HealthToken, ~S.CombatCell, ~S.CombatData, ~C.health_read, ~S.combat_get, ~S.combat_has, A.Present{}, w))
    w : A.World<S.HealthToken, S.CombatCell> <- print_query("health:" ++ checkpoint ++ ":Absent:", A.query(~S.HealthToken, ~S.CombatCell, ~S.CombatData, ~C.health_read, ~S.combat_get, ~S.combat_has, A.Absent{}, w))
    w : A.World<S.HealthToken, S.CombatCell> <- print_query("health:" ++ checkpoint ++ ":Optional:", A.query(~S.HealthToken, ~S.CombatCell, ~S.CombatData, ~C.health_read, ~S.combat_get, ~S.combat_has, A.Optional{}, w))
    w : A.World<S.HealthToken, S.CombatCell> <- print_lookup("health:" ++ checkpoint ++ ":lookup-b-Required:", A.lookup(~S.HealthToken, ~S.CombatCell, ~S.CombatData, ~C.health_read, ~S.combat_get, ~S.combat_has, A.Required{}, "b", w))
    w : A.World<S.HealthToken, S.CombatCell> <- print_lookup("health:" ++ checkpoint ++ ":lookup-b-Present:", A.lookup(~S.HealthToken, ~S.CombatCell, ~S.CombatData, ~C.health_read, ~S.combat_get, ~S.combat_has, A.Present{}, "b", w))
    w : A.World<S.HealthToken, S.CombatCell> <- print_lookup("health:" ++ checkpoint ++ ":lookup-b-Optional:", A.lookup(~S.HealthToken, ~S.CombatCell, ~S.CombatData, ~C.health_read, ~S.combat_get, ~S.combat_has, A.Optional{}, "b", w))
    return w
def tick(+checkpoint: String, w: A.World<S.HealthToken, S.CombatCell>) -> IO(A.World<S.HealthToken, S.CombatCell>):
  do IO<A.World<S.HealthToken, S.CombatCell>>:
    w : A.World<S.HealthToken, S.CombatCell> <- print_query("health:" ++ checkpoint ++ ":own:", A.writable(~S.HealthToken, ~S.CombatCell, ~S.CombatData, ~C.health_step, ~S.combat_get, w))
    w : A.World<S.HealthToken, S.CombatCell> <- observe(checkpoint, w)
    return w
def run() -> IO(Unit):
  do IO<Unit>:
    w : A.World<S.HealthToken, S.CombatCell> <- observe("setup", S.health())
    w : A.World<S.HealthToken, S.CombatCell> <- tick("step1", w)
    w : A.World<S.HealthToken, S.CombatCell> <- tick("step2", w)
    w : A.World<S.HealthToken, S.CombatCell> <- tick("step3", w)
    return Unit{}
def main() -> IO(Unit):
  run()

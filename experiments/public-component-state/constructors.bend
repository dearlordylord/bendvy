import Base
import state.bend as V

def phase(value: Maybe<&2,V.Phase>) -> String:
  match value:
    case Some{value}: U32.show(V.phase_code(value))
    case None{}: "invalid"
def mode(value: Maybe<&2,V.Mode>) -> String:
  match value:
    case Some{value}: U32.show(V.mode_code(value))
    case None{}: "invalid"
def edge(pair: V.Phase & V.Phase) -> String:
  (from,to) = pair
  U32.show(V.phase_code(from)) ++ ":" ++ U32.show(V.phase_code(to))
def main() -> IO(Unit):
  IO.bind(Unit,Unit,IO.print("phase|" ++ phase(V.phase_raw("ready")) ++ "," ++ phase(V.phase_raw("windup")) ++ "," ++ phase(V.phase_raw("active")) ++ "," ++ phase(V.phase_raw("sleeping")) ++ "," ++ phase(V.phase_raw(""))),u =>
  IO.bind(Unit,Unit,IO.print("mode|" ++ mode(V.mode_decode(0)) ++ "," ++ mode(V.mode_decode(1)) ++ "," ++ mode(V.mode_decode(2)) ++ "," ++ mode(V.mode_decode(3)) ++ "," ++ mode(V.mode_decode(9))),u =>
  IO.print("edges|" ++ edge(V.endpoints(V.ReadyWindup{})) ++ "," ++ edge(V.endpoints(V.WindupActive{})) ++ "," ++ edge(V.endpoints(V.WindupReady{})) ++ "," ++ edge(V.endpoints(V.ActiveReady{})))))

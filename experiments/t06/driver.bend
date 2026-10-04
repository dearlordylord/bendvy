import Base
import ./core.bend as A

def outcome_text(outcome: A.Outcome) -> String:
  match outcome:
    case A.Success{}: "Success"
    case A.Failure{system, error}: system ++ ":" ++ U32.show(error)
def final_full(prefix: String, result: A.Store & String) -> String:
  match result:
    case (_, text): prefix ++ "\nfull:" ++ text
def final_observation(prefix: String, result: A.Store & String) -> String:
  match result:
    case (s, text): final_full(prefix ++ text, A.observe_full(s))
def completed(result_name: String, store_name: String, result: A.Store & A.Outcome) -> String:
  match result:
    case (s, outcome): final_observation(result_name ++ ":" ++ outcome_text(outcome) ++ "\n" ++ store_name ++ ":", A.observe(s))
def print_empty(empty: Bool, text: String) -> IO(Unit):
  match empty:
    case True{}: IO.pure(Unit, Unit{})
    case False{}: IO.print(text)
def execute(prefix: String, result_name: String, store_name: String, result: A.Prepared<A.Tx>) -> IO(Unit):
  match result:
    case A.Prepared{t, outcome, +text, event, queued}:
      do IO<Unit>:
        IO.print(prefix)
        print_empty(String.is_empty(text), text)
        IO.print(completed(result_name, store_name, A.finish((A.stage_command(A.stage_event(t, event), queued), outcome))))

import Base
import ./streams.bend as S
import ./runtime.bend as R

type Report is Type:
  Report{log: S.Log, text: String}
def read_result(prefix: String, text: String, result: S.Log & (List<&2, U32> & Bool)) -> Report:
  match result:
    case (log, (values, lagged)): Report{log, text ++ prefix ++ ":" ++ R.values_text(values) ++ ":" ++ R.bool_text(lagged) ++ "\n"}
def report(prefix: String, cursor: S.Cursor, state: Report) -> Report:
  match state:
    case Report{log, text}: read_result(prefix, text, S.read(log, cursor))
def emit(tick: U32, values: List<&2, U32>, state: Report) -> Report:
  match state:
    case Report{log, text}: Report{S.append(log, tick, values), text}
def trim(state: Report, cursors: List<&2, S.Cursor>, boundary: U32) -> Report:
  match state:
    case Report{log, text}: Report{S.trim(log, cursors, boundary), text}
def trace(state: Report) -> String:
  match state:
    case Report{_, text}: text
def history() -> String:
  trace(report("capacity:new-reader", S.Cursor{0, 5}, report("capacity:B-empty", S.Cursor{4, 0}, report("capacity:A-empty", S.Cursor{2, 0}, trim(emit(5, [5, 6, 7, 8], report("capacity:B-retry", S.Cursor{0, 0}, report("capacity:A-not-lagged", S.Cursor{2, 0}, report("capacity:B-failed", S.Cursor{0, 0}, trim(emit(3, [3, 4], report("capacity:A-first", S.Cursor{0, 0}, trim(emit(1, [1, 2], Report{S.Log{3n, [], 0}, ""}), [S.Cursor{0, 0}, S.Cursor{0, 0}], 0))), [S.Cursor{2, 0}, S.Cursor{0, 0}], 0))))), [S.Cursor{2, 0}, S.Cursor{4, 0}], 0)))))
def zero() -> String:
  trace(report("capacity:zero", S.Cursor{0, 0}, trim(emit(1, [1], Report{S.Log{0n, [], 0}, ""}), [S.Cursor{0, 0}], 0)))
def main() -> IO(Unit):
  IO.print(history() ++ zero())

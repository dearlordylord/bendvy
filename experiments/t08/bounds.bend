import Base
import ./log.bend as L
import ./core.bend as C

type Report is Type:
  Report{log: L.Log, text: String}
def boolean(value: Bool) -> String:
  match value:
    case True{}: "true"
    case False{}: "false"
def read_result(name: String, text: String, result: L.Log & (List<&2, U32> & Bool)) -> Report:
  match result:
    case (log, (values, lagged)): Report{log, text ++ name ++ ":" ++ C.values_text(values) ++ ":" ++ boolean(lagged) ++ "\n"}
def report(name: String, c: L.Cursor, r: Report) -> Report:
  match r:
    case Report{log, text}: read_result(name, text, L.read(log, c))
def trim(r: Report, readers: List<&2, L.Cursor>, tick: U32) -> Report:
  match r:
    case Report{log, text}: Report{L.trim(log, readers, tick), text}
def emit(+tick: U32, ids: List<&2, U32>, r: Report) -> Report:
  match ids r:
    case Nil{} r: r
    case Con{id, tail} Report{log, text}: emit(tick, tail, Report{L.append(log, tick, [id]), text})
def trace(r: Report) -> String:
  match r:
    case Report{_, text}: text
def main() -> IO(Unit):
  IO.print(trace(report("new-reader", L.Cursor{0, 3}, report("caught-up", L.Cursor{3, 0}, report("retry", L.Cursor{0, 0}, report("overflow", L.Cursor{0, 0}, trim(emit(3, [0, 1, 2, 3], Report{L.Log{3n, [], 0}, ""}), [L.Cursor{0, 0}], 3)))))))

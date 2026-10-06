import Base
import schema.bend as S
import ../../src/ecs/component.bend as C

def quoted(s: String) -> String:
  "\"" ++ s ++ "\""
def raw(s: String) -> String: s
def numbers(xs: List<&2,U32>) -> String:
  List.show(~&2,~U32,~U32.show,xs)
def stock(value: C.Access<S.StockView>) -> String:
  match value:
    case C.Found{S.StockView{value,owned}}: "{\"value\":" ++ U32.show(value) ++ ",\"owned\":" ++ numbers(owned) ++ "}"
    case C.ComponentAbsent{}: "null"
    case C.MissingEntity{}: "{\"missingEntity\":true}"
def recipe(value: C.Access<S.RecipeView>) -> String:
  match value:
    case C.Found{S.RecipeView{value,owned}}: "{\"value\":" ++ U32.show(value) ++ ",\"owned\":" ++ numbers(owned) ++ "}"
    case C.ComponentAbsent{}: "null"
    case C.MissingEntity{}: "{\"missingEntity\":true}"
def queue(value: C.Access<S.QueueView>) -> String:
  match value:
    case C.Found{S.QueueView{value,owned}}: "{\"value\":" ++ U32.show(value) ++ ",\"owned\":" ++ numbers(owned) ++ "}"
    case C.ComponentAbsent{}: "null"
    case C.MissingEntity{}: "{\"missingEntity\":true}"
def enabled(value: C.Access<S.Enabled>) -> String:
  match value:
    case C.Found{_}: "{}"
    case C.ComponentAbsent{}: "null"
    case C.MissingEntity{}: "{\"missingEntity\":true}"
def locked(value: C.Access<S.Locked>) -> String:
  match value:
    case C.Found{_}: "{}"
    case C.ComponentAbsent{}: "null"
    case C.MissingEntity{}: "{\"missingEntity\":true}"
def array(values: List<&2,String>) -> String:
  List.show(~&2,~String,~raw,values)
def boolean(value: Bool) -> String:
  match value:
    case True{}: "true"
    case False{}: "false"

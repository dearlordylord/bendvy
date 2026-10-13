import Base
import runtime-named-declarations.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as Errors

def tail(~A:Data,~format:A -> String,values:List<&2,A>) -> String:
  match values:
    case []:""
    case value <> rest:"," ++ format(value) ++ tail(~A,~format,rest)
def list(~A:Data,~format:A -> String,values:List<&2,A>) -> String:
  match values:
    case []:"[]"
    case value <> rest:"[" ++ format(value) ++ tail(~A,~format,rest) ++ "]"
def boolean(value:Bool) -> String:
  match value:
    case True{}:"true"
    case False{}:"false"
def string(value:String) -> String:
  "\"" ++ value ++ "\""
def counts(value:List<&2,U32>) -> String:
  list(~U32,~U32.show,value)
def required(~V:Data,~format:V -> String,value:C.Access<V>) -> String:
  match value:
    case C.Found{value}:format(value)
    case C.ComponentAbsent{}:"\"UNEXPECTED_ABSENT_REQUIRED\""
    case C.MissingEntity{}:"\"UNEXPECTED_MISSING_REQUIRED\""
def optional(~V:Data,~format:V -> String,value:C.Access<V>) -> String:
  match value:
    case C.Found{value}:"{\"present\":true,\"value\":" ++ format(value) ++ "}"
    case C.ComponentAbsent{}:"{\"present\":false}"
    case C.MissingEntity{}:"\"UNEXPECTED_MISSING_OPTIONAL\""
def value_empty(value:D.ValueEmpty) -> String:
  match value:
    case D.ValueEmpty{}:"{" ++ "}"
def value_optionalFour(value:D.ValueOptionalFour) -> String:
  match value:
    case D.ValueOptionalFour{stock,title,active,count}:"{" ++ "\"stock\":" ++ optional(~U32,~U32.show,stock) ++ ",\"title\":" ++ optional(~String,~string,title) ++ ",\"active\":" ++ optional(~Bool,~boolean,active) ++ ",\"count\":" ++ optional(~List<&2,U32>,~counts,count) ++ "}"
def value_requiredPair(value:D.ValueRequiredPair) -> String:
  match value:
    case D.ValueRequiredPair{stock,title,active,count}:"{" ++ "\"stock\":" ++ required(~U32,~U32.show,stock) ++ ",\"title\":" ++ required(~String,~string,title) ++ ",\"active\":" ++ optional(~Bool,~boolean,active) ++ ",\"count\":" ++ optional(~List<&2,U32>,~counts,count) ++ "}"
def value_fiveAlias(value:D.ValueFiveAlias) -> String:
  match value:
    case D.ValueFiveAlias{stock,title,active,count,stockAlias}:"{" ++ "\"stock\":" ++ required(~U32,~U32.show,stock) ++ ",\"title\":" ++ optional(~String,~string,title) ++ ",\"active\":" ++ optional(~Bool,~boolean,active) ++ ",\"count\":" ++ optional(~List<&2,U32>,~counts,count) ++ ",\"stockAlias\":" ++ optional(~U32,~U32.show,stockAlias) ++ "}"
def value_mixedFilters(value:D.ValueMixedFilters) -> String:
  match value:
    case D.ValueMixedFilters{active}:"{" ++ "\"active\":" ++ optional(~Bool,~boolean,active) ++ "}"
def value_optionalUnselectedFilter(value:D.ValueOptionalUnselectedFilter) -> String:
  match value:
    case D.ValueOptionalUnselectedFilter{title}:"{" ++ "\"title\":" ++ optional(~String,~string,title) ++ "}"
def row(~S:Data,~V:Data,~format:V -> String,value:Q.ProjectedRow<S,V>) -> String:
  match value:
    case Q.ProjectedRow{W.Handle{_,id},value}:"{\"entityId\":" ++ U32.show(id) ++ ",\"data\":" ++ format(value) ++ "}"
def value_unit(value:Unit) -> String:
  match value:
    case Unit{}:"{}"

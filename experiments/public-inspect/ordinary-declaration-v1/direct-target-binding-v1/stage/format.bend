import Base
import runtime-named-declarations.bend as D
import full-consumer.bend as Consumer
import core/inspector-query.bend as Q
import core/world.bend as W
import core/component.bend as C
import core/inspector-query.bend as Errors

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
def value_withWithout(value:D.ValueWithWithout) -> String:
  match value:
    case D.ValueWithWithout{}:"{" ++ "}"
def value_multipleWith(value:D.ValueMultipleWith) -> String:
  match value:
    case D.ValueMultipleWith{}:"{" ++ "}"
def value_multipleWithout(value:D.ValueMultipleWithout) -> String:
  match value:
    case D.ValueMultipleWithout{}:"{" ++ "}"
def value_repeated(value:D.ValueRepeated) -> String:
  match value:
    case D.ValueRepeated{}:"{" ++ "}"
def value_contradictory(value:D.ValueContradictory) -> String:
  match value:
    case D.ValueContradictory{}:"{" ++ "}"
def value_addedBoth(value:D.ValueAddedBoth) -> String:
  match value:
    case D.ValueAddedBoth{}:"{" ++ "}"
def value_changedBoth(value:D.ValueChangedBoth) -> String:
  match value:
    case D.ValueChangedBoth{}:"{" ++ "}"
def value_mixedFilters(value:D.ValueMixedFilters) -> String:
  match value:
    case D.ValueMixedFilters{active}:"{" ++ "\"active\":" ++ optional(~Bool,~boolean,active) ++ "}"
def value_repeatedAdded(value:D.ValueRepeatedAdded) -> String:
  match value:
    case D.ValueRepeatedAdded{}:"{" ++ "}"
def value_optionalUnselectedFilter(value:D.ValueOptionalUnselectedFilter) -> String:
  match value:
    case D.ValueOptionalUnselectedFilter{title}:"{" ++ "\"title\":" ++ optional(~String,~string,title) ++ "}"
def row(~S:Data,~V:Data,~format:V -> String,value:Q.ProjectedRow<S,V>) -> String:
  match value:
    case Q.ProjectedRow{W.Handle{_,id},value}:"{\"entityId\":" ++ U32.show(id) ++ ",\"data\":" ++ format(value) ++ "}"
def lookup(~S:Data,~V:Data,~format:V -> String,value:Result<&2,&2,Errors.LookupError,Q.ProjectedRow<S,V>>) -> String:
  match value:
    case Done{value}:"{\"ok\":true,\"value\":" ++ row(~S,~V,~format,value) ++ "}"
    case Fail{Errors.MissingEntity{id}}:"{\"ok\":false,\"error\":{\"_tag\":\"MissingEntity\",\"entityId\":" ++ U32.show(id) ++ "}}"
    case Fail{Errors.QueryMismatch{id}}:"{\"ok\":false,\"error\":{\"_tag\":\"QueryMismatch\",\"entityId\":" ++ U32.show(id) ++ "}}"
def single(~S:Data,~V:Data,~format:V -> String,value:Result<&2,&2,Errors.SingleError,Q.ProjectedRow<S,V>>) -> String:
  match value:
    case Done{value}:"{\"ok\":true,\"value\":" ++ row(~S,~V,~format,value) ++ "}"
    case Fail{Errors.NoEntities{}}:"{\"ok\":false,\"error\":{\"_tag\":\"NoEntities\"}}"
    case Fail{Errors.MultipleEntities{count}}:"{\"ok\":false,\"error\":{\"_tag\":\"MultipleEntities\",\"count\":" ++ Nat.show(count) ++ "}}"
def single_optional(~S:Data,~V:Data,~format:V -> String,value:Result<&2,&2,Errors.SingleError,Maybe<&2,Q.ProjectedRow<S,V>>>) -> String:
  match value:
    case Done{None{}}:"{\"ok\":true,\"value\":null}"
    case Done{Some{value}}:"{\"ok\":true,\"value\":" ++ row(~S,~V,~format,value) ++ "}"
    case Fail{Errors.NoEntities{}}:"{\"ok\":false,\"error\":{\"_tag\":\"NoEntities\"}}"
    case Fail{Errors.MultipleEntities{count}}:"{\"ok\":false,\"error\":{\"_tag\":\"MultipleEntities\",\"count\":" ++ Nat.show(count) ++ "}}"
def get(~S:Data,~V:Data,~format:V -> String,value:Consumer.Get<S,V>) -> String:
  match value:
    case Consumer.Get{W.Handle{_,id},result}:"{\"target\":" ++ U32.show(id) ++ ",\"result\":" ++ lookup(~S,~V,~format,result) ++ "}"
def snapshot(~S:Data,~V:Data,~format:V -> String,name:String,value:Consumer.Snapshot<S,V>) -> String:
  match value:
    case Consumer.Snapshot{rows,gets,one,optional}:"{\"query\":" ++ string(name) ++ ",\"each\":" ++ list(~Q.ProjectedRow<S,V>,~row(~S,~V,~format),rows) ++ ",\"get\":" ++ list(~Consumer.Get<S,V>,~get(~S,~V,~format),gets) ++ ",\"single\":" ++ single(~S,~V,~format,one) ++ ",\"singleOptional\":" ++ single_optional(~S,~V,~format,optional) ++ "}"
def main() -> Unit:
  Unit{}

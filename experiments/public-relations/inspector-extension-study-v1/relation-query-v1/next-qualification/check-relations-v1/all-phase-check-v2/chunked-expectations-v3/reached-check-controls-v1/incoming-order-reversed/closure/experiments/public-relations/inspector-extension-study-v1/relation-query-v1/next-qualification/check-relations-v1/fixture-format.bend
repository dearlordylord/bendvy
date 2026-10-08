import Base
import fixture-matrix.bend as Matrix
import fixture-observe.bend as O
import ../../fixture-specs.bend as Spec
import ../../selection.bend as Select
import ../../query.bend as Query
import ../../core-v1/src/ecs/component.bend as C
import ../../core-v1/src/ecs/world.bend as W
import ../../core-v1/src/ecs/inspector-query.bend as Errors
import ../../core-v1/src/ecs/relation-query.bend as RQ

def boolean(value:Bool) -> String:
  match value:
    case False{}:"false"
    case True{}:"true"
def ids(~S:Data,value:W.Handle<S>) -> String:
  match value:
    case W.Handle{_,id}:U32.show(id)
def stock(value:C.Access<U32>) -> String:
  match value:
    case C.Found{value}:U32.show(value)
    case C.ComponentAbsent{}:"null"
    case C.MissingEntity{}:"{\"error\":\"MissingEntity\"}"
def title(value:C.Access<String>) -> String:
  match value:
    case C.Found{value}:"\"" ++ value ++ "\""
    case C.ComponentAbsent{}:"null"
    case C.MissingEntity{}:"{\"error\":\"MissingEntity\"}"
def relation_value(~S:Data,value:RQ.Value<S>) -> String:
  match value:
    case RQ.Missing{}:"null"
    case RQ.Target{handle}:"{\"target\":" ++ ids(~S,handle) ++ "}"
    case RQ.Sources{handles}:"{\"sources\":" ++ List.show(&2,W.Handle<S>,ids(~S),handles) ++ "}"
def end(value:RQ.End) -> String:
  match value:
    case RQ.Outgoing{}:"outgoing"
    case RQ.Incoming{}:"incoming"
def cell(~S:Data,value:RQ.Cell<S>) -> String:
  match value:
    case RQ.Cell{key,direction,value}:"{\"key\":\"" ++ key ++ "\",\"end\":\"" ++ end(direction) ++ "\",\"value\":" ++ relation_value(~S,value) ++ "}"
def row(~S:Data,value:Query.Row<S,Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>>) -> String:
  match value:
    case Query.Row{entity,Select.Product{Select.Product{a,b},cells}}:"{\"entity\":" ++ ids(~S,entity) ++ ",\"stock\":" ++ stock(a) ++ ",\"title\":" ++ title(b) ++ ",\"cells\":" ++ List.show(&2,RQ.Cell<S>,cell(~S),cells) ++ "}"
def lookup_result(~S:Data,value:Result<&2,&2,Errors.LookupError,Query.Row<S,Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>>>) -> String:
  match value:
    case Done{value}:",\"row\":" ++ row(~S,value)
    case Fail{Errors.MissingEntity{_}}:",\"error\":\"MissingEntity\""
    case Fail{Errors.QueryMismatch{_}}:",\"error\":\"QueryMismatch\""
def foreign_field(value:Bool) -> String:
  match value:
    case True{}:""
    case False{}:",\"foreign\":true"
def lookup(~S:Data,+namespace:U32,value:O.Lookup<S,Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>>) -> String:
  match value:
    case O.Lookup{W.Handle{other,id},result}:"{\"entity\":" ++ U32.show(id) ++ foreign_field(U32.is_eq(other,namespace)) ++ lookup_result(~S,result) ++ "}"
def single_error(value:Errors.SingleError) -> String:
  match value:
    case Errors.NoEntities{}:"{\"error\":\"NoEntities\"}"
    case Errors.MultipleEntities{count}:"{\"error\":\"MultipleEntities\",\"count\":" ++ Nat.show(count) ++ "}"
def single(~S:Data,value:Result<&2,&2,Errors.SingleError,Query.Row<S,Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>>>) -> String:
  match value:
    case Done{value}:"{\"row\":" ++ row(~S,value) ++ "}"
    case Fail{error}:single_error(error)
def optional(~S:Data,value:Result<&2,&2,Errors.SingleError,Maybe<&2,Query.Row<S,Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>>>>) -> String:
  match value:
    case Done{None{}}:"{\"row\":null}"
    case Done{Some{value}}:"{\"row\":" ++ row(~S,value) ++ "}"
    case Fail{error}:single_error(error)
def shape(value:Spec.RelationShape) -> String:
  match value:
    case Spec.OptionalBoth{}:"optional-both"
    case Spec.RequiredOut{}:"required-out"
    case Spec.RequiredIn{}:"required-in"
    case Spec.RequiredBoth{}:"required-both"
    case Spec.WithOut{}:"with-out"
    case Spec.WithoutOut{}:"without-out"
    case Spec.WithIn{}:"with-in"
    case Spec.WithoutIn{}:"without-in"
def lookup_items(~S:Data,+namespace:U32,values:List<&2,O.Lookup<S,Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>>>) -> String:
  match values:
    case []:""
    case value <> []:lookup(~S,namespace,value)
    case value <> rest:lookup(~S,namespace,value) ++ "," ++ lookup_items(~S,namespace,rest)
def lookups_text(~S:Data,namespace:U32,values:List<&2,O.Lookup<S,Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>>>) -> String:
  "[" ++ lookup_items(~S,namespace,values) ++ "]"
def entry(~S:Data,+namespace:U32,value:Matrix.Entry<S>) -> String:
  match value:
    case Matrix.Entry{a,b,mode,O.Observation{rows,lookups,one,maybe}}:"{\"stockRequired\":" ++ boolean(a) ++ ",\"titleRequired\":" ++ boolean(b) ++ ",\"mode\":\"" ++ shape(mode) ++ "\",\"each\":" ++ List.show(&2,Query.Row<S,Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>>,row(~S),rows) ++ ",\"get\":" ++ lookups_text(~S,namespace,lookups) ++ ",\"single\":" ++ single(~S,one) ++ ",\"singleOptional\":" ++ optional(~S,maybe) ++ "}"

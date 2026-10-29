import Base
import ../../src/ecs/execution-relation-failure-message.bend as Message
import ../../src/ecs/execution-relation-operation.bend as Operation
import ../../src/ecs/relation-types.bend as T
import ../../src/ecs/entity-key.bend as Key
import ../../src/ecs/world.bend as W

def key(value:Key.Key) -> String:
  match value:
    case Key.EntityKey{index,generation}:U32.show(index) ++ ":" ++ U32.show(generation)
def handle(-S:Data,value:W.Handle<S>) -> String:
  match value:
    case W.Handle{namespace,value}:U32.show(namespace) ++ "/" ++ key(value)
def handles(-S:Data,values:List<&2,W.Handle<S>>) -> String:
  match values:
    case []:""
    case value <> rest:handle(S,value) ++ ";" ++ handles(S,rest)
def operation(-S:Data,value:Operation.Operation<S>) -> String:
  match value:
    case Operation.Relate{source,target}:"relate(" ++ handle(S,source) ++ "," ++ handle(S,target) ++ ")"
    case Operation.Unrelate{source}:"unrelate(" ++ handle(S,source) ++ ")"
    case Operation.Reorder{parent,children}:"reorder(" ++ handle(S,parent) ++ "," ++ "[" ++ handles(S,children) ++ "]" ++ ")"
def kind(value:T.RelationKind) -> String:
  match value:
    case T.Ordinary{}:"ordinary"
    case T.Hierarchy{}:"hierarchy"
def descriptor(-S:Data,value:T.Descriptor<S>) -> String:
  match value:
    case T.Descriptor{id,name,inverse,relationKind}:U32.show(id) ++ "/" ++ name ++ "/" ++ inverse ++ "/" ++ kind(relationKind)
def legacy_operation(value:T.Operation) -> String:
  match value:
    case T.Relate{}:"relate"
    case T.ReorderChildren{}:"reorder-children"
def error(value:T.Error) -> String:
  match value:
    case T.MissingEntity{source}:"missing-entity(" ++ key(source) ++ ")"
    case T.MissingTargetEntity{source,target,relation}:"missing-target(" ++ key(source) ++ "," ++ key(target) ++ "," ++ relation ++ ")"
    case T.SelfRelationNotAllowed{source,relation}:"self-relation(" ++ key(source) ++ "," ++ relation ++ ")"
    case T.HierarchyCycle{source,target,relation}:"hierarchy-cycle(" ++ key(source) ++ "," ++ key(target) ++ "," ++ relation ++ ")"
    case T.MissingChildEntity{source,child,relation}:"missing-child(" ++ key(source) ++ "," ++ key(child) ++ "," ++ relation ++ ")"
    case T.DuplicateChild{source,child,relation}:"duplicate-child(" ++ key(source) ++ "," ++ key(child) ++ "," ++ relation ++ ")"
    case T.ChildNotRelatedToParent{source,child,relation}:"child-not-related(" ++ key(source) ++ "," ++ key(child) ++ "," ++ relation ++ ")"
    case T.ChildSetMismatch{source,relation}:"child-set-mismatch(" ++ key(source) ++ "," ++ relation ++ ")"
def failure(-S:Data,value:T.Failure<S>) -> String:
  match value:
    case T.Failure{relation,legacy,source,target,reason}:"family=" ++ descriptor(S,relation) ++ ",legacy=" ++ legacy_operation(legacy) ++ ",source=" ++ key(source) ++ ",target=" ++ key(target) ++ ",reason=" ++ error(reason)
def message(-S:Data,-family:T.Descriptor<S>,value:Message.Message<S,family>) -> String:
  match value:
    case Message.RelationFailed{original,detail}:"relation-failed{" ++ operation(S,original) ++ "," ++ failure(S,detail) ++ "}"
    case Message.UnrelateFailed{original,source,reason}:"unrelate-failed{" ++ operation(S,original) ++ ",source=" ++ key(source) ++ ",reason=" ++ error(reason) ++ "}"

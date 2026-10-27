import Base
import ../../src/ecs/entity-allocator.bend as A
import ../../src/ecs/entity-key.bend as K
import ../../src/ecs/world.bend as W
import ../../src/ecs/relation-types.bend as T
import ../../src/ecs/execution-relation-operation.bend as O
import ../../src/ecs/execution-relation-interpreter.bend as I

# DRAFT. These subjects are unapproved and unproved. The erased allocator
# variables denote actual affine owners, not an inventory model.

# A foreign source must leave both the actual allocator and graph unchanged.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/relationship/mod.rs#L28-L36
# Bevy behavior: relation changes maintain the target collection from the source.
# Namespace refusal is Bend's World contract, not a claimed Bevy namespace model.
# This subject covers the interpreter, not queue admission or World installation.
law foreign_unrelate_exact:
  for -S:Data
  for -descriptor:T.Descriptor<S>
  for -namespace:U32
  for -foreignNamespace:U32
  for -key:K.Key
  for -allocator:A.Allocator
  for -graph:T.Graph<S>
  for different:{U32.is_eq(namespace,foreignNamespace) == False{} : Bool}
  {I.apply(~S,~descriptor,namespace,allocator,graph,O.Unrelate{W.Handle{foreignNamespace,key}}) == (allocator,O.Refused{graph,O.Unrelate{W.Handle{foreignNamespace,key}},O.RelationError{T.MissingEntity{key}}}) : A.Allocator & O.Outcome<S>}

# An ordinary descriptor cannot obtain hierarchy-reorder mutation authority.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/relationship/mod.rs#L28-L41
# Bevy behavior: source and target relationship types form a corresponding pair.
# The nominal hierarchy distinction and refusal name are Bend API decisions.
# This subject does not establish the ordinary public declaration boundary.
law ordinary_reorder_refuses_exact:
  for -S:Data
  for -key:U32
  for -name:String
  for -inverse:String
  for -namespace:U32
  for -allocator:A.Allocator
  for -graph:T.Graph<S>
  for -parent:W.Handle<S>
  for -children:List<&2,W.Handle<S>>
  {I.apply(~S,~(T.Descriptor{key,name,inverse,T.Ordinary{}}),namespace,allocator,graph,O.Reorder{parent,children}) == (allocator,O.Refused{graph,O.Reorder{parent,children},O.HierarchyRequired{}}) : A.Allocator & O.Outcome<S>}

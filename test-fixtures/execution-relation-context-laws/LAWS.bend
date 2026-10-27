import Base
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-resource-policy.bend as Policy
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/execution-relation-world-publication.bend as Publication
import ../../src/ecs/execution-relation-store.bend as Store
import ../../src/ecs/execution-relation-operation.bend as O
import ../../src/ecs/relation-types.bend as T
import ../../src/ecs/change-tick.bend as Tick

# DRAFT. Unapproved and unproved. The symbolic World is an actual affine owner;
# its namespace observation is metadata, not a replacement Data model of World.
# This says nothing about ordinary Root wiring or whole-application maintenance.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/relationship/mod.rs#L28-L41
# Bevy behavior: the source relationship controls the corresponding target list.
# World namespaces and exact owner retention are Bend-specific boundaries.
law foreign_context_preserves_actual_world_binding_and_operation:
  for -S:Data
  for -C:Type
  for -WR:Type
  for -E:Data
  for -resources:Layout.Layout
  for -same:{WR == Layout.resources(~S,resources) : Type}
  for -route:Layout.Route
  for -valid:{Layout.grant_valid(~resources,~route) == True{} : Bool}
  for -descriptor:T.Descriptor<S>
  for -payload:{Layout.payload(resources,route) == Store.Store<S,descriptor> : Type}
  for -view:{Layout.view(resources,route) == Store.View<S,descriptor> : Data}
  for -protected:{Layout.policy(resources,route) == Policy.ProtectedRelation{S,descriptor} : Policy.Policy}
  for -expected:U32
  for -actual:U32
  for -world:W.World<S,C,WR,E>
  for -operation:O.Operation<S>
  for -tick:Tick.Tick
  for observed:{W.namespace(~S,~C,~WR,~E,world) == (world,actual) : W.World<S,C,WR,E> & U32}
  for different:{U32.is_eq(expected,actual) == False{} : Bool}
  {Publication.apply(~S,~C,~WR,~E,~resources,~same,~route,~valid,~descriptor,~payload,~view,~protected,Context.Binding{Context.Context{expected}},world,operation,tick) == (world,(Context.Binding{Context.Context{expected}},Store.Refused{operation,Store.NamespaceMismatch{}})) : W.World<S,C,WR,E> & (Context.Binding<S,WR,resources,same,route,descriptor,payload,view,protected> & Store.Receipt<S>)}

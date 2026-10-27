import Base
import ../../src/ecs/execution-reservation-materialization.bend as M
import ../../src/ecs/execution-reservation-bundle.bend as B
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-resource-policy.bend as Policy
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/world.bend as W
import ../../src/ecs/entity-allocator.bend as A
import ../../src/ecs/entity-key.bend as K
import ../../src/ecs/clock-state.bend as Clock
import ../../src/ecs/execution-lifecycle-notices.bend as Notice
import ../../src/ecs/deferred-command.bend as Deferred
import ../../src/ecs/chunk-column.bend as Col
import ../../src/ecs/lifecycle.bend as Life
import ../../src/ecs/change-tick.bend as Tick

# Draft, unproved. Actual affine World fields and actual unlike bundle tree.
# This pins namespace refusal before allocator/store mutation. It does not
# assume the result of apply_at, pending_valid, or an owner-preserving callback.
law foreign_namespace_keeps_world_and_bundle:
  for -S:Data
  for -R:Type
  for -E:Data
  for -layout:L.Layout
  for -allocator:A.Allocator
  for -store:L.columns(~S,layout)
  for -resource:R
  for -events:List<&2,E>
  for -pending:List<Deferred.Command<W.World<S,L.columns(~S,layout),R,E>>>
  for -registrations:List<&2,W.RegistrationMeta>
  for -nextId:U32
  for -clock:Clock.State
  for -journal:Notice.Journal<S>
  for -key:K.Key
  for -bundle:B.Payload(layout)
  for -tick:Tick.Tick
  {M.apply_at(~S,~R,~E,~layout,Permission.EntityStructural{},W.World{0,allocator,store,resource,events,pending,registrations,nextId,clock,journal},W.Handle{1,key},bundle,tick) == B.RefusedPublication{W.World{0,allocator,store,resource,events,pending,registrations,nextId,clock,journal},W.Handle{1,key},bundle,B.InvalidPending{W.MissingEntity{}}} : B.Publication<S,L.columns(~S,layout),R,E,layout>}

# A concrete malformed actual value-array has one cell; canonical leaves need
# eight values AND eight stamps. Refusal retains that exact column and payload.
# This is the selected-family preflight helper, not a full World provenance law.
law malformed_leaf_keeps_actual_column_and_payload:
  for -S:Data
  for -P:Type
  for -V:Data
  for -refresh:P -> P & V
  for -key:String
  for -owner:P
  for -index:U32
  {M.check_leaf(~S,P,V,key,L.LayoutLeaf{P,V,refresh,key,Policy.Ordinary{}},index,L.ColumnSlot{Col.Leaf{ALeaf{None{}},[Life.Stamp{None{},None{}} : Life.Stamp^3n]}},Some{owner}) == (L.ColumnSlot{Col.Leaf{ALeaf{None{}},[Life.Stamp{None{},None{}} : Life.Stamp^3n]}},(Some{owner},Some{B.MalformedColumn{key}})) : L.ColumnSlot<S,L.Viewed<P,V>,key,L.LayoutLeaf{P,V,refresh,key,Policy.Ordinary{}}> & (Maybe<&1,P> & Maybe<&2,B.Refusal>)}

# Draft full-operation refusal with actual affine World/bundle owners.
# Actual allocator slot generation is one; incoming handle generation is zero.
law past_generation_keeps_world_and_bundle:
  for -S:Data
  for -R:Type
  for -E:Data
  for -layout:L.Layout
  for -store:L.columns(~S,layout)
  for -resource:R
  for -events:List<&2,E>
  for -pending:List<Deferred.Command<W.World<S,L.columns(~S,layout),R,E>>>
  for -registrations:List<&2,W.RegistrationMeta>
  for -nextId:U32
  for -clock:Clock.State
  for -journal:Notice.Journal<S>
  for -bundle:B.Payload(layout)
  for -tick:Tick.Tick
  {M.apply_at(~S,~R,~E,~layout,Permission.EntityStructural{},W.World{0,A.Allocator{2,1,[A.Slot{1,A.Pending{}} : A.Slot^1n],2,1n,[],[K.EntityKey{1,1}]},store,resource,events,pending,registrations,nextId,clock,journal},W.Handle{0,K.EntityKey{1,0}},bundle,tick) == B.RefusedPublication{W.World{0,A.Allocator{2,1,[A.Slot{1,A.Pending{}} : A.Slot^1n],2,1n,[],[K.EntityKey{1,1}]},store,resource,events,pending,registrations,nextId,clock,journal},W.Handle{0,K.EntityKey{1,0}},bundle,B.InvalidPending{W.MissingEntity{}}} : B.Publication<S,L.columns(~S,layout),R,E,layout>}


# Draft full-operation refusal with actual affine World/bundle owners.
# Actual allocator slot is Consumed, not Pending; metadata alone is insufficient.
law nonpending_keeps_world_and_bundle:
  for -S:Data
  for -R:Type
  for -E:Data
  for -layout:L.Layout
  for -store:L.columns(~S,layout)
  for -resource:R
  for -events:List<&2,E>
  for -pending:List<Deferred.Command<W.World<S,L.columns(~S,layout),R,E>>>
  for -registrations:List<&2,W.RegistrationMeta>
  for -nextId:U32
  for -clock:Clock.State
  for -journal:Notice.Journal<S>
  for -bundle:B.Payload(layout)
  for -tick:Tick.Tick
  {M.apply_at(~S,~R,~E,~layout,Permission.EntityStructural{},W.World{0,A.Allocator{2,1,[A.Slot{0,A.Consumed{}} : A.Slot^1n],2,1n,[],[K.EntityKey{1,0}]},store,resource,events,pending,registrations,nextId,clock,journal},W.Handle{0,K.EntityKey{1,0}},bundle,tick) == B.RefusedPublication{W.World{0,A.Allocator{2,1,[A.Slot{0,A.Consumed{}} : A.Slot^1n],2,1n,[],[K.EntityKey{1,0}]},store,resource,events,pending,registrations,nextId,clock,journal},W.Handle{0,K.EntityKey{1,0}},bundle,B.InvalidPending{W.MissingEntity{}}} : B.Publication<S,L.columns(~S,layout),R,E,layout>}

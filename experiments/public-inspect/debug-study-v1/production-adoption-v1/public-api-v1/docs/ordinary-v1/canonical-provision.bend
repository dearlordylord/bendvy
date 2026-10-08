import Base
import ./canonical-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP

# Actual World owner registry; no user-supplied availability adapter.
def provision(~S:Data,~Store:Type,~P:Type,~Q:Type,~E:Data,~layout:Schema.Layout<S,P,Q>,world:W.World<S,Store,Schema.Owner<S,P,Q,layout>,E>) -> W.World<S,Store,Schema.Owner<S,P,Q,layout>,E> & List<&2,SP.Requirement<S>>:
  W.observe_resource(~S,~Store,~Schema.Owner<S,P,Q,layout>,~E,~List<&2,SP.Requirement<S>>,~(owner => Schema.owner_needs(~S,~P,~Q,~layout,owner)),world)

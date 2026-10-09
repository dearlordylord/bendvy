import Base
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy-worktrees/parity-53-canonical-capability/experiments/public-owned-events/declaration-read-v1/canonical-capability-v1/reached-provide-v1/source/declaration-read-v1/declaration.bend as Decl
import /workspace/formal-proofs/bendvy-worktrees/parity-53-canonical-capability/experiments/public-owned-events/declaration-read-v1/canonical-capability-v1/reached-provide-v1/source/declaration-read-v1/controls.bend as C
import /workspace/formal-proofs/bendvy/experiments/public-owned-events/generic-scoped-read-v1/controls.bend as P
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/declaration.bend as Query

type Other is Data: Other{}
def crossed() -> Query.Declaration<Other,P.Payload,Cap.Request<P.Payload,P.Query,P.Projection>>:
  Decl.read(~Other,~P.Payload,~P.Query,~P.Projection,~P.at,"owned-events")
def reached(owner:P.Payload,args:P.Args) -> P.Payload & P.Observation:
  Decl.provide(~C.Schema,~P.Payload,~P.Query,~P.Projection,~P.Args,~P.Observation,~crossed(),~P.reader,owner,args)

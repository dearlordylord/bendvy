import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-53-canonical-capability/experiments/public-owned-events/declaration-read-v1/canonical-capability-v1/source/declaration-read-v1/declaration.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/experiments/public-owned-events/generic-scoped-read-v1/controls.bend as C
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/declaration.bend as Query

type Schema is Data: Schema{}
def reader() -> Query.Declaration<Schema,C.Payload,Cap.Request<C.Payload,C.Query,C.Projection>>:
  Decl.read(~Schema,~C.Payload,~C.Query,~C.Projection,~C.at,"owned-events")
def provide(owner:C.Payload,args:C.Args) -> C.Payload & C.Observation:
  Decl.provide(~Schema,~C.Payload,~C.Query,~C.Projection,~C.Args,~C.Observation,~reader(),~C.reader,owner,args)
def again(first:C.Payload & C.Observation) -> C.Payload & (C.Observation & C.Observation):
  match first:
    case (owner,view): C.join(view,provide(owner,C.second_args()))
def full() -> C.Payload & (C.Observation & C.Observation):
  again(provide(C.initial(),C.first_args()))
def metadata() -> List<&2,String>:
  Decl.access(~Schema,~C.Payload,~C.Query,~C.Projection,~reader())

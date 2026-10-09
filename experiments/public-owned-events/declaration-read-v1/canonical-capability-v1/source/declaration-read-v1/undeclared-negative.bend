import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-53-canonical-capability/experiments/public-owned-events/declaration-read-v1/canonical-capability-v1/source/declaration-read-v1/declaration.bend as Decl
import /workspace/formal-proofs/bendvy-worktrees/parity-53-canonical-capability/experiments/public-owned-events/declaration-read-v1/canonical-capability-v1/source/declaration-read-v1/controls.bend as C
import /workspace/formal-proofs/bendvy/experiments/public-owned-events/generic-scoped-read-v1/controls.bend as P
import /workspace/formal-proofs/bendvy/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/declaration.bend as Query

def undeclared() -> Query.Declaration<C.Schema,P.Payload,Unit>:
  Decl.absent(~C.Schema,~P.Payload)
def reached(owner:P.Payload,args:P.Args) -> P.Payload & P.Observation:
  Decl.provide(~C.Schema,~P.Payload,~P.Query,~P.Projection,~P.Args,~P.Observation,~undeclared(),~P.reader,owner,args)

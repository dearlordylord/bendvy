import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-53-canonical-capability/experiments/public-owned-events/declaration-read-v1/canonical-capability-v1/reached-provide-v1/source/declaration-read-v1/declaration.bend as Read
import /workspace/formal-proofs/bendvy/experiments/public-owned-events/generic-scoped-read-v1/controls.bend as C
import /workspace/formal-proofs/bendvy-worktrees/parity-53-canonical-capability/experiments/public-owned-events/declaration-read-v1/canonical-capability-v1/reached-provide-v1/source/declaration-read-v1/controls.bend as S
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def body(~H:Type,~read:Cap.Request<H,C.Query,C.Projection>,owner:H,args:C.Args) -> H & Cap.Request<H,C.Query,C.Projection>:
  (owner,read)
def reached(owner:C.Payload,args:C.Args) -> C.Payload & Cap.Request<C.Payload,C.Query,C.Projection>:
  Read.provide(~S.Schema,~C.Payload,~C.Query,~C.Projection,~C.Args,~Cap.Request<C.Payload,C.Query,C.Projection>,~S.reader(),~body,owner,args)

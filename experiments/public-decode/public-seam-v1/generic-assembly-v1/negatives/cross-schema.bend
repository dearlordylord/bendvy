import Base
import ../public-fixture.bend as Public
import ../declared.bend as Declared
import ../request.bend as Request
import ../second-owner.bend as B
import ../owned-component.bend as Write
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Query
import /workspace/formal-proofs/bendvy/experiments/public-decode/complete-v1/controls.bend as First
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/decode-data.bend as D
type Other is Data:Other{}
type Args is Type:Args{target:W.Handle<Other>,owner:B.Owner}
def write_field(~H:Type,ops:Public.Ops(~H)) -> Cap.OwnedRequest<H,Query.Insert<Unit,B.Owner>,Write.Output<B.Owner>>:
  match ops:
    case Declared.Ops{_,cap,_,_,_}:cap
def body(~H:Type,~ops:Public.Ops(~H),args:Args,ctx:H) -> H & Write.Output<B.Owner>:
  match args:
    case Args{target,owner}:Cap.owned_request(~H,~Query.Insert<Unit,B.Owner>,~Write.Output<B.Owner>,~write_field(~H,ops),ctx,Query.Insert{target,owner})
def main(frame:Public.Frame(),args:Args) -> Public.Frame() & Write.Output<B.Owner>:
  Declared.invoke(~Unit,~B.Store(),~First.Owner,~Unit,~B.Owner,~B.Recovery(),~D.Raw,~Unit,~Unit,~B.identity(),~B.project,~B.project,~B.take,~B.put,~B.install,~Args,~Write.Output<B.Owner>,~(H => ops => args => ctx => body(~H,~ops,args,ctx)),frame,args)

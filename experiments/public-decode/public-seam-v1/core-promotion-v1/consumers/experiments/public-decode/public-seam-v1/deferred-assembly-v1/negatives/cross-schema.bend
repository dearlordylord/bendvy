import Base
import ../assembly.bend as A
import ../fixture.bend as F
import ../../../../../../library/decode-requests.bend as Request
import ../../generic-assembly-v1/second-owner.bend as P
import ../../../complete-v1/controls.bend as R
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/bundle-requests.bend as Commands
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import ../../../../../../dependencies/snapshot/decode-data.bend as D
type Other is Data:Other{}
type Input is Type:Input{target:W.Handle<Other>,owner:P.Owner}
def body(~H:Type,~ops:F.Ops(~H),input:Input,ctx:H) -> H & Request.Output<Unit,P.Owner>:
  match input:
    case Input{target,owner}:F.decode(~H,~ops,ctx,Commands.Insert{target},owner)
def main(owner:F.Owner(),input:Input) -> F.Owner() & Request.Output<Unit,P.Owner>:
  A.invoke(~Unit,~P.Store(),~R.Owner,~Unit,~P.Owner,~P.identity(),~P.project,~Input,~Request.Output<Unit,P.Owner>,~(H => ops => input => ctx => body(~H,~ops,input,ctx)),owner,input)

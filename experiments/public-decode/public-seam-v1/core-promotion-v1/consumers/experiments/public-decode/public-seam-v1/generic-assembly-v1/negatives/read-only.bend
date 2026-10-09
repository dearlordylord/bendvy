import Base
import ../public-fixture.bend as Public
import ../../../../../../library/decode-declaration.bend as Declared
import ../../../../../../library/decode-requests.bend as Request
import ../second-owner.bend as B
import ../../../../../../library/decode-owned-component.bend as Write
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Query
import ../../../complete-v1/controls.bend as First
import ../../../../../../dependencies/snapshot/decode-data.bend as D
def body(~H:Type,~cap:Cap.Read<H,D.Raw>,owner:B.Owner,ctx:H) -> H & Request.Output<Unit,B.Owner>:
  Cap.owned_request(~H,~B.Owner,~Request.Output<Unit,B.Owner>,~cap,ctx,owner)
def main(frame:Public.Frame(),owner:B.Owner) -> Public.Frame() & Request.Output<Unit,B.Owner>:
  Declared.invoke_readonly(~Unit,~B.Store(),~First.Owner,~Unit,~B.Owner,~B.Recovery(),~D.Raw,~Unit,~Unit,~B.identity(),~B.project,~B.project,~B.take,~B.put,~B.install,~B.Owner,~Request.Output<Unit,B.Owner>,~(H => cap => owner => ctx => body(~H,~cap,owner,ctx)),frame,owner)

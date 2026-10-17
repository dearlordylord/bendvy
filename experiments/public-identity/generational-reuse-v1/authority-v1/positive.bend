import Base
import schema.bend as S
import ../fixture.bend as F
import ../../../../src/ecs/entity-key.bend as K
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/component.bend as C
import ../../../../src/ecs/capabilities.bend as Cap

def handle(namespace:U32,index:U32,generation:U32) -> W.Handle<F.Workshop>:W.Handle{namespace,K.EntityKey{index,generation}}
def owner(column:Col.Column<F.Workshop,S.Payload>) -> Col.Column<F.Workshop,S.Payload>:column
def read(~H:Type,~cap:Cap.Read<H,Unit>,owner:H) -> H & C.Access<Unit>:Cap.read(~H,~Unit,~cap,owner)
def write(~H:Type,~cap:Cap.Write<H,S.Payload,Unit>,owner:H,payload:S.Payload) -> H:Cap.set(~H,~S.Payload,~Unit,~cap,owner,payload)

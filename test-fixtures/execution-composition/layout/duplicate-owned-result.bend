import Base
import ./owned-result.bend as Owner
import ../../../src/ecs/execution-access.bend as Access

def repeated(~H:Type,result:H & Owner.Publication) -> H & (Owner.Publication & Owner.Publication):
  match result:
    case (scope,publication):(scope,(publication,publication))
def invoke(~H:Type,~cap:Access.ResourceWrite<H,Owner.Mailbox,U32>,scope:H,incoming:Array<U32>) -> H & (Owner.Publication & Owner.Publication):
  repeated(~H,Access.resource_own_field(~H,~Owner.Mailbox,~U32,Owner.Publication,cap)(mailbox => Owner.publish(incoming,mailbox),scope))

import Base
import ./owned-result.bend as Owner
import ../../../src/ecs/execution-access.bend as Access

def refuse(~H:Type,~cap:Access.ResourceRead<H,U32>,scope:H,incoming:Array<U32>) -> H & Owner.Publication:
  Access.resource_own_field(~H,~Owner.Mailbox,~U32,Owner.Publication,cap)(mailbox => Owner.publish(incoming,mailbox),scope)

import Base
import ./owned-result.bend as Owner
import ../../../src/ecs/execution-access.bend as Access

def escape(~H:Type,~cap:Access.ResourceWrite<H,Owner.Mailbox,U32>,scope:H) -> H & H:
  Access.resource_own_field(~H,~Owner.Mailbox,~U32,H,cap)(mailbox => (mailbox,scope),scope)

import Base
import schema.bend as S
import ../../../../src/ecs/capabilities.bend as Cap

def write(~H:Type,~cap:Cap.Read<H,Unit>,owner:H,payload:S.Payload) -> H:
  Cap.set(~H,~S.Payload,~Unit,~cap,owner,payload)

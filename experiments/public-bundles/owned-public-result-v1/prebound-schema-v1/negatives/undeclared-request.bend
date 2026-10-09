import Base
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap

def bad(~H:Type,~cap:Cap.ValueRead<H,U32>,owner:H) -> H & Unit:
  Cap.owned_request(~H,~Unit,~Unit,~cap,owner,Unit{})

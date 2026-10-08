import Base
import read.bend as Read
import controls.bend as Controls
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap

def write(~H:Type,~read:Cap.Request<H,U32,U32>,owner:H) -> H & U32:
  (Cap.value_set(~H,~U32,~U32,~read,owner,99),0)
def reached(owner:Controls.Payload) -> Controls.Payload & U32:
  Read.provide(~Controls.Payload,~U32,~Controls.at,~write,owner)

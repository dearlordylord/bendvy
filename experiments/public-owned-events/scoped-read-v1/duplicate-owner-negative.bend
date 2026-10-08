import Base
import read.bend as Read
import controls.bend as Controls
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap

def consume(~H:Type,owner:H) -> U32: 0
def duplicate(~H:Type,~read:Cap.Request<H,U32,U32>,owner:H) -> H & U32:
  (owner,consume(~H,owner))
def reached(owner:Controls.Payload) -> Controls.Payload & U32:
  Read.provide(~Controls.Payload,~U32,~Controls.at,~duplicate,owner)

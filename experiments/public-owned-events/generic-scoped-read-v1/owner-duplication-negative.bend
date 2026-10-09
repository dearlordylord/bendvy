import Base
import read.bend as Read
import controls.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def consume(~H:Type,owner:H) -> U32: 0
def body(~H:Type,~read:Cap.Request<H,C.Query,C.Projection>,owner:H,args:C.Args) -> H & U32:
  (owner,consume(~H,owner))
def reached(owner:C.Payload,args:C.Args) -> C.Payload & U32:
  Read.provide(~C.Payload,~C.Query,~C.Projection,~C.Args,~U32,~C.at,~body,owner,args)

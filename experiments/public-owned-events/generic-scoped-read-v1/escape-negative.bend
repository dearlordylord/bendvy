import Base
import read.bend as Read
import controls.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def body(~H:Type,~read:Cap.Request<H,C.Query,C.Projection>,owner:H,args:C.Args) -> H & Cap.Request<H,C.Query,C.Projection>:
  (owner,read)
def reached(owner:C.Payload,args:C.Args) -> C.Payload & Cap.Request<C.Payload,C.Query,C.Projection>:
  Read.provide(~C.Payload,~C.Query,~C.Projection,~C.Args,~Cap.Request<C.Payload,C.Query,C.Projection>,~C.at,~body,owner,args)

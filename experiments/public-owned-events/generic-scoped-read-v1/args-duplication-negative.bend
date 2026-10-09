import Base
import read.bend as Read
import controls.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def body(~H:Type,~read:Cap.Request<H,C.Query,C.Projection>,owner:H,args:C.Args) -> H & (C.Args & C.Args):
  (owner,(args,args))
def reached(owner:C.Payload,args:C.Args) -> C.Payload & (C.Args & C.Args):
  Read.provide(~C.Payload,~C.Query,~C.Projection,~C.Args,~(C.Args & C.Args),~C.at,~body,owner,args)

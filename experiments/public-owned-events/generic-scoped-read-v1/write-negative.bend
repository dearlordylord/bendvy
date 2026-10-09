import Base
import read.bend as Read
import controls.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def body(~H:Type,~read:Cap.Request<H,C.Query,C.Projection>,owner:H,args:C.Args) -> H & C.Projection:
  (Cap.value_set(~H,~C.Query,~C.Projection,~read,owner,C.Query{0,ALeaf{1}}),C.Projection{False{},"write",[]})
def reached(owner:C.Payload,args:C.Args) -> C.Payload & C.Projection:
  Read.provide(~C.Payload,~C.Query,~C.Projection,~C.Args,~C.Projection,~C.at,~body,owner,args)

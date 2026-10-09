import Base
import ./declaration.bend as Decl
import ./controls.bend as C
import /workspace/formal-proofs/bendvy/experiments/public-owned-events/generic-scoped-read-v1/controls.bend as P

type Other is Data:Other{}
def reached(owner:P.Payload,args:P.Args) -> P.Payload & P.Observation:
  Decl.provide(~Other,~P.Payload,~P.Query,~P.Projection,~P.Args,~P.Observation,~C.reader(),~P.reader,owner,args)

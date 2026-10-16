import Base
import ../fixture.bend as F
import ../schema.bend as Model
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-check-machine.bend as MC
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-check-declaration.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-declaration.bend as MD
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-checked-condition.bend as Cond
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-check-query.bend as CQ
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
def accepted(~S:Data,~Token:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,Token,V>,~declaration:MD.Declaration<S,Token,V,R,take>) -> D.Declaration<S,C,R,E,MC.Ops(~S,~Token,~V)>:MC.optional(~S,~Token,~V,~C,~R,~E,~take,~declaration)

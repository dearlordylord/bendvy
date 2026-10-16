import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-recovery-system.bend as System
import ../fixture.bend as F
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-recoverable-array-resource.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-recovery-resource-field.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-recovery-declaration.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Read
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product

type First is Data:First{}
type Other is Data:Other{}
def positive(owner:F.Owned(~First),world:F.World(~First),args:F.Args) -> System.Run<F.World(~First),F.Owned(~First),F.Args,F.Error,F.Output,F.Recovery()>:
  F.run(~First,owner,world,args)

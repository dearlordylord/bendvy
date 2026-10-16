import Base
import ../fixture.bend as F
import ../../../../src/ecs/ordinary-recoverable-component-capture.bend as O
import ../../../../src/ecs/ordinary-recoverable-array-resource.bend as A
import ../../../../src/ecs/ordinary-declaration.bend as D
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/owner-product.bend as Product
import ../../../../src/ecs/recoverable-component.bend as RC
import ../../../../src/ecs/recoverable-array.bend as Record

type First is Data:First{}
type Other is Data:Other{}
def positive(owner:F.Instance(~First),world:F.World(~First),args:F.Args<First>) -> F.Run(~First):
  F.run(~First,owner,world,args)

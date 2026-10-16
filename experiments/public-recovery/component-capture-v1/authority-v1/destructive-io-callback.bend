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
def destructive(value:Array<Array<U32>>) -> IO(Unit):
  IO.print("not a granted operation")
def rejected(~H:Type,~cap:O.CaptureWrite<Array<U32>,H>,owner:H) -> H:
  O.capture_replace(~Array<U32>,~H,~cap,owner,destructive)

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
def rejected(~H:Type,~cap:O.ComponentWrite<First,Array<Array<U32>>,F.identity(~First),H>,owner:H,handle:W.Handle<First>,incoming:Maybe<Array<Array<U32>>>) -> O.ComponentAttempt<H,Array<Array<U32>>>:
  O.component_replace(~First,~Array<Array<U32>>,~D.component(~First,~Array<Array<U32>>,"OtherPayload"),~H,~cap,owner,handle,incoming)

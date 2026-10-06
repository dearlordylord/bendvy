import Base
import ../../../src/ecs/column.bend as K

type Schema is Data:
  Schema{}
type Affine is Type:
  Affine{values: Array<U32>}
def project_read(r: Array<U32> & U32) -> Affine & U32:
  (values, n) = r
  (Affine{values}, n)
def project(x: Affine) -> Affine & U32:
  match x:
    case Affine{values}:
      project_read(Array.get(U32,values,0))
def final(r: K.Column<Schema,Affine> & Maybe<&2,U32>) -> U32:
  match r:
    case (column,Some{73}): 1
    case _: 0
def accept(r: K.SwapOutcome<Schema,Affine>) -> K.Column<Schema,Affine>:
  match r:
    case K.Accepted{column,old}: column
    case K.Rejected{column,incoming}: column
def rejected(r: K.SwapOutcome<Schema,Affine>) -> U32:
  match r:
    case K.Rejected{column,Some{owner}}:
      final(K.view(~Schema,~Affine,~U32,~project,accept(K.swap(~Schema,~Affine,column,3,Some{owner})),3))
    case _: 0
def zero(r: K.SwapOutcome<Schema,Affine>) -> U32:
  match r:
    case K.Rejected{column,Some{owner}}:
      rejected(K.swap(~Schema,~Affine,column,5,Some{owner}))
    case _: 0
def main() -> U32:
  zero(K.swap(~Schema,~Affine,K.ensure(~Schema,~Affine,K.empty(~Schema,~Affine),3),0,Some{Affine{ALeaf{73}}}))

import Base
import ../../../src/ecs/column.bend as K
type S is Data:
  S{}
def projection(x: U32) -> U32 & U32:
  +y = x
  (y,y)
def end(r: K.Column<S,U32> & Maybe<&2,U32>) -> U32:
  match r:
    case (column,Some{11}): 1
    case _: 0
def old(r: K.SwapOutcome<S,U32>) -> U32:
  match r:
    case K.Accepted{column,Some{22}}:
      end(K.view(~S,~U32,~U32,~projection,column,1))
    case _: 0
def untouched(r: K.Column<S,U32> & Bool) -> U32:
  match r:
    case (column,False{}): old(K.remove(~S,~U32,column,4))
    case _: 0
def after_growth(r: K.SwapOutcome<S,U32>) -> U32:
  match r:
    case K.Accepted{column,None{}}:
      untouched(K.has(~S,~U32,K.ensure(~S,~U32,K.ensure(~S,~U32,column,0),131073),5))
    case _: 0
def first(r: K.SwapOutcome<S,U32>) -> U32:
  match r:
    case K.Accepted{column,None{}}:
      after_growth(K.swap(~S,~U32,K.ensure(~S,~U32,column,4),4,Some{22}))
    case _: 0
def main() -> U32:
  first(K.swap(~S,~U32,K.empty(~S,~U32),1,Some{11}))

import Base

type Workshop is Data: Workshop{}
type Garden is Data: Garden{}
# Each concrete component owns an affine Array. Its public view retains the
# application value and a sentinel used by complete ownership observations.
type Cell is Data: Cell{value: U32,sentinel: U32}
def projected_second(value: U32,observed: Array<U32> & U32) -> Array<U32> & Cell:
  match observed:
    case (owner,sentinel): (owner,Cell{value,sentinel})
def projected_first(observed: Array<U32> & U32) -> Array<U32> & Cell:
  match observed:
    case (owner,value): projected_second(value,Array.get(U32,owner,1))
def project(owner: Array<U32>) -> Array<U32> & Cell:
  projected_first(Array.get(U32,owner,0))

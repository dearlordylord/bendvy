import Base
# Explicit backend source variant; cached capacity trusts exact shape.
def get(~P: Data,array: Array<P>,+capacity: U32,+index: U32) -> Array<P> & P:
  Array.get(P,array,index)
def swap(~P: Type,array: Array<P>,+capacity: U32,+index: U32,value: P) -> Array<P> & P:
  Array.swap(P,array,index,value)
def set(~P: Type,array: Array<P>,+capacity: U32,+index: U32,value: P) -> Array<P>:
  Array.set(P,array,index,value)

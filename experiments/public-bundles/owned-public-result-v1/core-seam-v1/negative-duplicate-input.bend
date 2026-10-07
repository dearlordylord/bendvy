import Base
import witness.bend as W
# An arbitrary affine input cannot be duplicated by the new entrypoint.
def bad(~P:Type,owner:W.Owner,input:P) -> W.Owner & (P & P):
  (owner,(input,input))

import Base
def increment(value: U32) -> U32:
  (value + 1 : U32)
def less(left: U32, right: U32) -> Bool:
  U32.is_lt(left,right)

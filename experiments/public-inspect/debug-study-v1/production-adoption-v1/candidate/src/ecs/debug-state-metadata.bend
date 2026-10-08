import Base
# Detached lossless observation of pinned TS StateValue = string | number.
# NumberBits are IEEE754 binary64 low/high words, never a F32/U32 conversion.
# spelling is the actual trusted String(value) label for diagnostic conditions.
# Native consumes normalized observations; no native JS Number parser claim.
type Value is Data:
  Text{value:String}
  NumberBits{low:U32,high:U32,spelling:String}
type Machine is Data:
  Machine{name:String,states:List<&2,Value>,current:Maybe<&2,Value>}
def spelling(value:Value) -> String:
  match value:
    case Text{value}:value
    case NumberBits{low,high,spelling}:spelling
# Registration token equality and runtime state equality are not inferred here.
# An arbitrary affine actual state owner must be projected and returned by its
# trusted read provider; this detached Data record does not clone that owner.

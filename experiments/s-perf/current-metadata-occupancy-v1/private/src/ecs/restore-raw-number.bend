import Base
import ./decode-data.bend as D

type Checked is Data:
  Value{value:U32}
  Invalid{}
def shifted(count:Nat,value:U32) -> U32:
  match count:
    case 0n: value
    case 1n+rest: shifted(rest,U32.mul(value,2))
def finite_checked(valid:Bool,value:U32,exponent:U32) -> Checked:
  match valid:
    case True{}:Value{shifted(U32.to_nat(U32.sub(exponent,1074)),value)}
    case False{}:Invalid{}
def finite(negative:Bool,high:U32,+low:U32,+exponent:U32) -> Checked:
  match negative high low:
    case False{} 0 0:Value{0}
    case False{} 0 n:finite_checked(U32.is_ge(exponent,1074) && U32.is_le(exponent,1105) && U32.is_le(exponent,U32.add(1074,U32.sub(31,U32.from_nat(U32.log2(n))))),n,exponent)
    case _ _ _:Invalid{}
def normalized(value:D.Numeric) -> Checked:
  match value:
    case D.Finite{negative,high,low,exponent}:finite(negative,high,low,exponent)
    case _:Invalid{}
def signed(valid:Bool,magnitude:Nat) -> Checked:
  match valid:
    case True{}:Value{U32.from_nat(magnitude)}
    case False{}:Invalid{}
def checked(raw:D.Raw) -> Checked:
  match raw:
    case D.Number{value}:Value{value}
    case D.SignedInteger{negative,+magnitude}:signed((Bool.not(negative) || Nat.is_eq(magnitude,0n)) && Nat.is_le(magnitude,4294967295n),magnitude)
    case D.Float{value}:normalized(D.float_numeric(F32.bits(value)))
    case D.Binary64{high,low}:normalized(D.binary_numeric(high,low))
    case _:Invalid{}

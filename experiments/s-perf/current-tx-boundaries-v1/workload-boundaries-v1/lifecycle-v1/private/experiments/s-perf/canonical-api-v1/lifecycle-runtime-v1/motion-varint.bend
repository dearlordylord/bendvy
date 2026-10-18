import Base

def u32_1(value:U32) -> String:SCon{Char.from_u32(U32.add(32,U32.and(value,31))),SNil{}}
def u32_2_choice(low:U32,quotient:U32,zero:Bool) -> String:
  match zero:
    case True{}:SCon{Char.from_u32(U32.add(32,low)),SNil{}}
    case False{}:SCon{Char.from_u32(U32.add(64,low)),u32_1(quotient)}
def u32_2_step(low:U32,+quotient:U32) -> String:u32_2_choice(low,quotient,U32.is_zero(quotient))
def u32_2(+value:U32) -> String:u32_2_step(U32.and(value,31),U32.shrn(value,5n))
def u32_3_choice(low:U32,quotient:U32,zero:Bool) -> String:
  match zero:
    case True{}:SCon{Char.from_u32(U32.add(32,low)),SNil{}}
    case False{}:SCon{Char.from_u32(U32.add(64,low)),u32_2(quotient)}
def u32_3_step(low:U32,+quotient:U32) -> String:u32_3_choice(low,quotient,U32.is_zero(quotient))
def u32_3(+value:U32) -> String:u32_3_step(U32.and(value,31),U32.shrn(value,5n))
def u32_4_choice(low:U32,quotient:U32,zero:Bool) -> String:
  match zero:
    case True{}:SCon{Char.from_u32(U32.add(32,low)),SNil{}}
    case False{}:SCon{Char.from_u32(U32.add(64,low)),u32_3(quotient)}
def u32_4_step(low:U32,+quotient:U32) -> String:u32_4_choice(low,quotient,U32.is_zero(quotient))
def u32_4(+value:U32) -> String:u32_4_step(U32.and(value,31),U32.shrn(value,5n))
def u32_5_choice(low:U32,quotient:U32,zero:Bool) -> String:
  match zero:
    case True{}:SCon{Char.from_u32(U32.add(32,low)),SNil{}}
    case False{}:SCon{Char.from_u32(U32.add(64,low)),u32_4(quotient)}
def u32_5_step(low:U32,+quotient:U32) -> String:u32_5_choice(low,quotient,U32.is_zero(quotient))
def u32_5(+value:U32) -> String:u32_5_step(U32.and(value,31),U32.shrn(value,5n))
def u32_6_choice(low:U32,quotient:U32,zero:Bool) -> String:
  match zero:
    case True{}:SCon{Char.from_u32(U32.add(32,low)),SNil{}}
    case False{}:SCon{Char.from_u32(U32.add(64,low)),u32_5(quotient)}
def u32_6_step(low:U32,+quotient:U32) -> String:u32_6_choice(low,quotient,U32.is_zero(quotient))
def u32_6(+value:U32) -> String:u32_6_step(U32.and(value,31),U32.shrn(value,5n))
def u32_7_choice(low:U32,quotient:U32,zero:Bool) -> String:
  match zero:
    case True{}:SCon{Char.from_u32(U32.add(32,low)),SNil{}}
    case False{}:SCon{Char.from_u32(U32.add(64,low)),u32_6(quotient)}
def u32_7_step(low:U32,+quotient:U32) -> String:u32_7_choice(low,quotient,U32.is_zero(quotient))
def u32_7(+value:U32) -> String:u32_7_step(U32.and(value,31),U32.shrn(value,5n))
def u32(value:U32) -> String:u32_7(value)
def nat_step(qr:Nat & Nat,acc:String,next:Nat -> String -> String) -> String:
  (quotient,low)=qr
  match quotient:
    case 0n:String.reverse(SCon{Char.from_u32(U32.add(32,U32.from_nat(low))),acc})
    case 1n+q:next(1n+q,SCon{Char.from_u32(U32.add(64,U32.from_nat(low))),acc})
def nat_go(fuel:Nat,value:Nat,acc:String) -> String:
  match fuel:
    case 0n:"~"
    case 1n+rest:nat_step(Nat.divmod(value,32n),acc,q=>digits=>nat_go(rest,q,digits))
def nat(+value:Nat) -> String:nat_go(1n+value,value,SNil{})

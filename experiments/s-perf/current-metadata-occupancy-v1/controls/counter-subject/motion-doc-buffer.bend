import Base

type Buffer is Type:
  Buffer{chunks:List<&2,String>,pieces:List<&2,String>,remaining:Nat}
def empty() -> Buffer:Buffer{[],[],4096n}
def join_rev(values:List<&2,String>,acc:String) -> String:
  match values:
    case []:acc
    case head <> rest:join_rev(rest,String.append(head,acc))
def added(chunks:List<&2,String>,pieces:List<&2,String>,value:String,remaining:Nat) -> Buffer:
  match remaining:
    case 0n:Buffer{join_rev(value <> pieces,SNil{}) <> chunks,[],4096n}
    case 1n+rest:Buffer{chunks,value <> pieces,1n+rest}
def piece(value:String,count:Nat,buffer:Buffer) -> Buffer:
  match buffer:
    case Buffer{chunks,pieces,remaining}:added(chunks,pieces,value,Nat.sub(remaining,count))
def allowance_checked(remaining:Nat,fits:Bool) -> Nat:
  match fits:
    case True{}:remaining
    case False{}:64n
def allowance(+remaining:Nat) -> Nat:allowance_checked(remaining,Nat.is_le(remaining,64n))
def room(buffer:Buffer) -> Buffer & Nat:
  match buffer:
    case Buffer{chunks,pieces,+remaining}:(Buffer{chunks,pieces,remaining},remaining)
def done(origin:String,used:Nat,buffer:Buffer) -> Buffer:
  match used:
    case 0n:buffer
    case 1n+rest:piece(origin,1n+rest,buffer)
def normalize_remaining(value:Nat) -> Nat:
  match value:
    case 0n:4096n
    case 1n+rest:1n+rest
def text_go(value:String,origin:String,+used:Nat,left:Nat,remaining:Nat,buffer:Buffer) -> Buffer:
  match value:
    case SNil{}:done(origin,used,buffer)
    case SCon{_,+rest}:
      match left:
        case 0n:buffer
        case 1n+more:
          match more:
            case 0n:
              +nextRemaining=normalize_remaining(Nat.sub(remaining,1n+used))
              text_go(rest,rest,0n,allowance(nextRemaining),nextRemaining,piece(String.take(origin,1n+used),1n+used,buffer))
            case 1n+tail:text_go(rest,origin,1n+used,1n+tail,remaining,buffer)
def text_next(+value:String,observed:Buffer & Nat) -> Buffer:
  match observed:
    case (buffer,+count):text_go(value,value,0n,allowance(count),count,buffer)
def text(value:String,buffer:Buffer) -> Buffer:text_next(value,room(buffer))
def code(value:U32,buffer:Buffer) -> Buffer:text(SCon{Char.from_u32(value),SNil{}},buffer)
def char(head:Char,buffer:Buffer) -> Buffer:code(Char.to_u32(head),buffer)
def u_1(value:U32,buffer:Buffer) -> Buffer:code(U32.add(32,U32.and(value,31)),buffer)
def u_2_choice(low:U32,quotient:U32,buffer:Buffer,zero:Bool) -> Buffer:
  match zero:
    case True{}:code(U32.add(32,low),buffer)
    case False{}:u_1(quotient,code(U32.add(64,low),buffer))
def u_2_step(low:U32,+quotient:U32,buffer:Buffer) -> Buffer:u_2_choice(low,quotient,buffer,U32.is_zero(quotient))
def u_2(+value:U32,buffer:Buffer) -> Buffer:u_2_step(U32.and(value,31),U32.shrn(value,5n),buffer)
def u_3_choice(low:U32,quotient:U32,buffer:Buffer,zero:Bool) -> Buffer:
  match zero:
    case True{}:code(U32.add(32,low),buffer)
    case False{}:u_2(quotient,code(U32.add(64,low),buffer))
def u_3_step(low:U32,+quotient:U32,buffer:Buffer) -> Buffer:u_3_choice(low,quotient,buffer,U32.is_zero(quotient))
def u_3(+value:U32,buffer:Buffer) -> Buffer:u_3_step(U32.and(value,31),U32.shrn(value,5n),buffer)
def u_4_choice(low:U32,quotient:U32,buffer:Buffer,zero:Bool) -> Buffer:
  match zero:
    case True{}:code(U32.add(32,low),buffer)
    case False{}:u_3(quotient,code(U32.add(64,low),buffer))
def u_4_step(low:U32,+quotient:U32,buffer:Buffer) -> Buffer:u_4_choice(low,quotient,buffer,U32.is_zero(quotient))
def u_4(+value:U32,buffer:Buffer) -> Buffer:u_4_step(U32.and(value,31),U32.shrn(value,5n),buffer)
def u_5_choice(low:U32,quotient:U32,buffer:Buffer,zero:Bool) -> Buffer:
  match zero:
    case True{}:code(U32.add(32,low),buffer)
    case False{}:u_4(quotient,code(U32.add(64,low),buffer))
def u_5_step(low:U32,+quotient:U32,buffer:Buffer) -> Buffer:u_5_choice(low,quotient,buffer,U32.is_zero(quotient))
def u_5(+value:U32,buffer:Buffer) -> Buffer:u_5_step(U32.and(value,31),U32.shrn(value,5n),buffer)
def u_6_choice(low:U32,quotient:U32,buffer:Buffer,zero:Bool) -> Buffer:
  match zero:
    case True{}:code(U32.add(32,low),buffer)
    case False{}:u_5(quotient,code(U32.add(64,low),buffer))
def u_6_step(low:U32,+quotient:U32,buffer:Buffer) -> Buffer:u_6_choice(low,quotient,buffer,U32.is_zero(quotient))
def u_6(+value:U32,buffer:Buffer) -> Buffer:u_6_step(U32.and(value,31),U32.shrn(value,5n),buffer)
def u_7_choice(low:U32,quotient:U32,buffer:Buffer,zero:Bool) -> Buffer:
  match zero:
    case True{}:code(U32.add(32,low),buffer)
    case False{}:u_6(quotient,code(U32.add(64,low),buffer))
def u_7_step(low:U32,+quotient:U32,buffer:Buffer) -> Buffer:u_7_choice(low,quotient,buffer,U32.is_zero(quotient))
def u_7(+value:U32,buffer:Buffer) -> Buffer:u_7_step(U32.and(value,31),U32.shrn(value,5n),buffer)
def u(value:U32,buffer:Buffer) -> Buffer:u_7(value,buffer)
def write_chunks(chunks:List<&2,String>,last:String) -> IO(Unit):
  match chunks:
    case []:IO.write(last)
    case head <> rest:IO.bind(Unit,Unit,IO.write(head),_=>write_chunks(rest,last))
def write(value:Buffer) -> IO(Unit):
  match value:
    case Buffer{chunks,pieces,_}:write_chunks(List.reverse(&2,String,chunks),join_rev(pieces,SNil{}))

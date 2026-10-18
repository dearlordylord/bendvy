import Base

type Buffer is Type:
  Buffer{chunks:List<&2,String>,scratch:Array<U32>,used:U32,remaining:Nat}
def empty() -> Buffer:Buffer{[],Array.new(U32,12n,0),0,4096n}
def materialize_go(remaining:Nat,index:U32,observed:Array<U32> & U32,acc:String) -> Array<U32> & String:
  match remaining observed:
    case 0n Tuple{scratch,value}:(scratch,SCon{Char.from_u32(value),acc})
    case 1n+rest Tuple{scratch,value}:
      +previous=U32.sub(index,1)
      materialize_go(rest,previous,Array.get(U32,scratch,previous),SCon{Char.from_u32(value),acc})
def materialize_count(count:Nat,used:U32,scratch:Array<U32>) -> Array<U32> & String:
  match count:
    case 0n:(scratch,SNil{})
    case 1n+rest:
      +previous=U32.sub(used,1)
      materialize_go(rest,previous,Array.get(U32,scratch,previous),SNil{})
def materialize(scratch:Array<U32>,+used:U32) -> Array<U32> & String:materialize_count(U32.to_nat(used),used,scratch)
def full(code:U32,chunks:List<&2,String>,observed:Array<U32> & String) -> Buffer:
  (scratch,text)=observed
  Buffer{text <> chunks,Array.set(U32,scratch,0,code),1,4095n}
def code(value:U32,buffer:Buffer) -> Buffer:
  match buffer:
    case Buffer{chunks,scratch,used,0n}:full(value,chunks,materialize(scratch,used))
    case Buffer{chunks,scratch,+used,1n+remaining}:Buffer{chunks,Array.set(U32,scratch,used,value),U32.add(used,1),remaining}
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
def text(value:String,buffer:Buffer) -> Buffer:
  match value:
    case SNil{}:buffer
    case SCon{head,rest}:text(rest,code(Char.to_u32(head),buffer))
def write_chunks(chunks:List<&2,String>,last:String) -> IO(Unit):
  match chunks:
    case []:IO.write(last)
    case head <> rest:IO.bind(Unit,Unit,IO.write(head),_=>write_chunks(rest,last))
def write_view(chunks:List<&2,String>,observed:Array<U32> & String) -> IO(Unit):
  (scratch,last)=observed
  write_chunks(List.reverse(&2,String,chunks),last)
def write(value:Buffer) -> IO(Unit):
  match value:
    case Buffer{chunks,scratch,used,_}:write_view(chunks,materialize(scratch,used))

import Base
import oracle.bend as O
import view.bend as V
# Fill every physical capacity cell; values intentionally include repeats and
# wrapped/max U32 cells. Logical prefix does not change physical work.
def fill(fuel:Nat,+index:U32,+offset:U32,array:Array<U32>) -> Array<U32>:
  match fuel:
    case 0n: array
    case 1n+rest: fill(rest,U32.add(index,1),offset,Array.set(U32,array,index,U32.add(offset,U32.mod(index,3))))
def input(+depth:Nat,+offset:U32) -> Array<U32>:
  fill(Nat.pow(2n,depth),0,offset,Array.new(U32,depth,0))
def after(+capacity:U32,+length:Nat,+snapshot:List<&2,U32>,observed:Array<U32> & List<&2,U32>) -> List<&2,List<&2,U32>>:
  match observed:
    case (_,physical): [[capacity,U32.from_nat(length)],snapshot,O.prefix(length,snapshot),physical,snapshot]
def first(+capacity:U32,+length:Nat,+slot:U32,observed:Array<U32> & List<&2,U32>) -> List<&2,List<&2,U32>>:
  match observed:
    case (array,+snapshot): after(capacity,length,snapshot,O.array_view(Array.set(U32,array,slot,2147483647)))
def observed(indexed:Bool,+depth:Nat,+length:Nat,+slot:U32,+offset:U32) -> List<&2,List<&2,U32>>:
  match indexed:
    case False{}: first(U32.pow(2,depth),length,slot,O.array_view(input(depth,offset)))
    case True{}: first(U32.pow(2,depth),length,slot,V.array_view(input(depth,offset)))
def length(kind:U32) -> Nat:
  match kind:
    case 0: 0n
    case 1: 1n
    case 2: 2n
    case 3: 9n
    case 4: 17n
    case 5: 33n
    case 6: 65n
    case _: 129n
def offset(kind:U32) -> U32:
  match kind:
    case 0: 0
    case 1: 12345
    case _: 4294967295
def slot(+capacity:U32,kind:U32) -> U32:
  match kind:
    case 0: 0
    case 1: U32.shr(capacity)
    case _: U32.sub(capacity,1)
def show(records:List<&2,List<&2,U32>>) -> String:
  List.show(&2,List<&2,U32>,(xs => List.show(&2,U32,U32.show,xs)),records)
def observation(+index:U32) -> String:
  +depth = U32.to_nat(U32.mod(index,8))
  +logical = length(U32.mod(U32.div(index,8),8))
  +position = slot(U32.pow(2,depth),U32.mod(U32.div(index,64),3))
  +base = offset(U32.mod(U32.div(index,192),3))
  U32.show(index) ++ "|" ++ show(observed(False{},depth,logical,position,base)) ++ "|" ++ show(observed(True{},depth,logical,position,base))
def refusal_array(status:U32,view:Array<U32> & List<&2,U32>) -> List<&2,List<&2,U32>>:
  match view:
    case (_,physical): [[status],physical]
def refusal_result(view:Array<U32> & Maybe<&2,U32>) -> List<&2,List<&2,U32>>:
  match view:
    case (array,None{}): refusal_array(0,O.array_view(array))
    case (array,Some{_}): refusal_array(1,O.array_view(array))
def refusal(+index:U32) -> IO(Unit):
  IO.print("R|" ++ show(refusal_result(V.read(input(2n,7),index,4))))
def loop(fuel:Nat,+index:U32) -> IO(Unit):
  match fuel:
    case 0n: IO.bind(Unit,Unit,refusal(4),u => IO.bind(Unit,Unit,refusal(5),u => refusal(4294967295)))
    case 1n+rest: IO.bind(Unit,Unit,IO.print(observation(index)),u => loop(rest,U32.add(index,1)))
def main() -> IO(Unit):
  loop(U32.to_nat(576),0)

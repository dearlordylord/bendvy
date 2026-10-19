import Base
import walk.bend as Walk
import ../../consumer/s-perf/canonical-api-v1/dense-runtime-v1/types.bend as T
import ../../consumer/s-perf/canonical-api-v1/dense-runtime-v1/payload.bend as P

def maximum() -> Nat:Nat.add(Nat.mul(65536n,4294967295n),65535n)
def view(value:T.PositionView) -> String:
  match value:
    case T.PositionView{T.Four{a,b,c,d},frame}:"[" ++ U32.show(a) ++ "," ++ U32.show(b) ++ "," ++ U32.show(c) ++ "," ++ U32.show(d) ++ "," ++ U32.show(frame) ++ "]"
def owner_last(first:T.PositionView,second:T.PositionView,old:U32,result:T.Position & T.PositionView) -> String:
  (_,last)=result
  "[" ++ view(first) ++ "," ++ view(second) ++ "," ++ U32.show(old) ++ "," ++ view(last) ++ "]"
def owner_swapped(first:T.PositionView,second:T.PositionView,result:T.Position & U32) -> String:
  (owner,old)=result
  owner_last(first,second,old,P.position_get(owner))
def owner_second(first:T.PositionView,result:T.Position & T.PositionView) -> String:
  (owner,second)=result
  owner_swapped(first,second,P.position_swap(owner,9))
def owner_first(result:T.Position & T.PositionView) -> String:
  (owner,first)=result
  owner_second(first,P.position_get(owner))
def owned() -> String:owner_first(P.position_get(T.Position{ANode{ANode{ALeaf{1},ALeaf{2}},ANode{ALeaf{3},ALeaf{4}}},7}))
def main() -> IO(Unit):
  IO.print("{\"nat\":[" ++ U32.show(Walk.natural(0n,0)) ++ "," ++ U32.show(Walk.natural(4294967295n,0)) ++ "," ++ U32.show(Walk.natural(Walk.radix(),0)) ++ "," ++ U32.show(Walk.natural(maximum(),0)) ++ "],\"order\":[" ++ U32.show(Walk.list(~U32,~Walk.number,[1,2],0)) ++ "," ++ U32.show(Walk.list(~U32,~Walk.number,[2,1],0)) ++ "],\"owner\":" ++ owned() ++ "}")

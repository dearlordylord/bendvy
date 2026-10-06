import Base
import /tmp/bendvy-closed-tx-element-probe/experiments/s-integrate/transaction.bend as X

type Raw is Type:
  Raw{payload:Array<U32>}
def second(world:U32,first:U32,pings:List<&2,U32>,marks:List<&2,U32>,result:Array<U32> & U32) -> U32 & (U32 & (U32 & (List<&2,U32> & List<&2,U32>))):
  match result:
    case (_,last): (world,(first,(last,(pings,marks))))
def first(world:U32,last:Array<U32>,pings:List<&2,U32>,marks:List<&2,U32>,result:Array<U32> & U32) -> U32 & (U32 & (U32 & (List<&2,U32> & List<&2,U32>))):
  match result:
    case (_,value): second(world,value,pings,marks,Array.get(U32,last,0))
def finish(result:X.Finished<U32,Raw,U32>) -> U32 & (U32 & (U32 & (List<&2,U32> & List<&2,U32>))):
  match result:
    case X.Committed{world,Con{Raw{a},Con{Raw{b},Nil{}}},pings,marks}: first(world,b,pings,marks,Array.get(U32,a,0))
    case _: (0,(0,(0,([],[]))))
def main() -> U32 & (U32 & (U32 & (List<&2,U32> & List<&2,U32>))):
  finish(X.prototype_closed_tx_finish_success(~Raw,U32,U32,X.Tx{9,6,[X.MainInverse{6,42}],[Raw{ALeaf{2}},Raw{ALeaf{1}}],[4,3],[7,8]}))

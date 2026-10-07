import Base
import oracle.bend as O
# Valid runtime Arrays have positive power-of-two capacity. Public checked
# reader exposes refusal BEFORE Array.get's masking, preserving its actual owner.
def read_result(observed:Array<U32> & U32) -> Array<U32> & Maybe<&2,U32>:
  match observed:
    case (array,value): (array,Some{value})
def read_checked(array:Array<U32>,+index:U32,valid:Bool) -> Array<U32> & Maybe<&2,U32>:
  match valid:
    case False{}: (array,None{})
    case True{}: read_result(Array.get(U32,array,index))
def read(array:Array<U32>,+index:U32,+capacity:U32) -> Array<U32> & Maybe<&2,U32>:
  read_checked(array,index,U32.is_lt(index,capacity))
# Each pending observation comes from one already-checked read. The actual
# owner returned by that read is the only owner passed to the next read.
type Collected is Type:
  Complete{array:Array<U32>,values:List<&2,U32>}
  Refused{array:Array<U32>,partial:List<&2,U32>}
def collect(fuel:Nat,+index:U32,+capacity:U32,reverse:List<&2,U32>,observed:Array<U32> & Maybe<&2,U32>) -> Collected:
  match fuel observed:
    case _, (array,None{}): Refused{array,reverse}
    case 0n, (array,Some{value}): Complete{array,List.reverse(&2,U32,value <> reverse)}
    case 1n+rest, (array,Some{value}): collect(rest,U32.add(index,1),capacity,value <> reverse,read(array,U32.add(index,1),capacity))
def finished(collected:Collected) -> Array<U32> & List<&2,U32>:
  match collected:
    case Complete{array,values}: (array,values)
    # This is not reached by valid size-derived view input. Malformed raw helper
    # calls explicitly refuse; fallback reconstructs a complete original view.
    case Refused{array,_}: O.array_view(array)
def sized(observed:Array<U32> & U32) -> Array<U32> & List<&2,U32>:
  match observed:
    case (array,+capacity): finished(collect(U32.to_nat(U32.sub(capacity,1)),0,capacity,[],read(array,0,capacity)))
def array_view(array:Array<U32>) -> Array<U32> & List<&2,U32>:
  sized(Array.size(U32,array))

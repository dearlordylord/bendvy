import Base

# Observe every cell of the affine fixture payload, including length, so a
# lost sentinel, extra cell or truncated owner cannot hide behind gameplay.
type FullCell is Data: FullCell{length: Nat,values: List<&2,U32>}
def prepended(value: U32,observed: Array<U32> & List<&2,U32>) -> Array<U32> & List<&2,U32>:
  match observed:
    case (owner,values): (owner,value <> values)
def fetched(next: Array<U32> -> Array<U32> & List<&2,U32>,observed: Array<U32> & U32) -> Array<U32> & List<&2,U32>:
  match observed:
    case (owner,value): prepended(value,next(owner))
def collect(count: Nat,+index: U32,owner: Array<U32>) -> Array<U32> & List<&2,U32>:
  match count:
    case 0n: (owner,[])
    case 1n+rest: fetched((owner => collect(rest,(index + 1 : U32),owner)),Array.get(U32,owner,index))
def completed(length: Nat,observed: Array<U32> & List<&2,U32>) -> Array<U32> & FullCell:
  match observed:
    case (owner,values): (owner,FullCell{length,values})
def sized(observed: Array<U32> & U32) -> Array<U32> & FullCell:
  match observed:
    case (owner,+length): completed(U32.to_nat(length),collect(U32.to_nat(length),0,owner))
def view(owner: Array<U32>) -> Array<U32> & FullCell:
  sized(Array.size(U32,owner))

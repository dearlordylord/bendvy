import Base
import /workspace/formal-proofs/bendvy/experiments/public-simulation/bend-v1/owner-view.bend as View

def owner_seen(observed:Array<U32> & View.FullCell) -> Maybe<&1,Array<U32>> & Maybe<&2,View.FullCell>:
  match observed:
    case (owner,value):(Some{owner},Some{value})
def owner(owner:Maybe<&1,Array<U32>>) -> Maybe<&1,Array<U32>> & Maybe<&2,View.FullCell>:
  match owner:
    case None{}:(None{},None{})
    case Some{value}:owner_seen(View.view(value))
def prepended(owner:Maybe<&1,Array<U32>>,value:Maybe<&2,View.FullCell>,observed:List<Maybe<&1,Array<U32>>> & List<&2,Maybe<&2,View.FullCell>>) -> List<Maybe<&1,Array<U32>>> & List<&2,Maybe<&2,View.FullCell>>:
  match observed:
    case (owners,values):(owner <> owners,value <> values)
def fetched(next:Unit -> List<Maybe<&1,Array<U32>>> & List<&2,Maybe<&2,View.FullCell>>,observed:Maybe<&1,Array<U32>> & Maybe<&2,View.FullCell>) -> List<Maybe<&1,Array<U32>>> & List<&2,Maybe<&2,View.FullCell>>:
  match observed:
    case (owner,value):prepended(owner,value,next(Unit{}))
def owners(items:List<Maybe<&1,Array<U32>>>) -> List<Maybe<&1,Array<U32>>> & List<&2,Maybe<&2,View.FullCell>>:
  match items:
    case []:([],[])
    case first <> rest:fetched((unit => owners(rest)),owner(first))
def none_result(expected:Nat,next:Nat -> Bool) -> Bool:
  match expected:
    case 0n:False{}
    case 1n+rest:next(rest)
def all_none_values(values:List<&2,Maybe<&2,View.FullCell>>,expected:Nat) -> Bool:
  match values:
    case []:Nat.is_eq(expected,0n)
    case None{} <> tail:none_result(expected,(rest => all_none_values(tail,rest)))
    case Some{_} <> _:False{}
def all_none(expected:Nat,values:List<&2,Maybe<&2,View.FullCell>>) -> Bool:
  all_none_values(values,expected)

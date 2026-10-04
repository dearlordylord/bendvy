import Base
import ./relation.bend as R
import ./context.bend as C
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

# A real required induction hypothesis, quantified over both physical layouts.
def Continuation(+steps: List<&2,T.Step>, +limit: Nat, +id: Nat) -> Type:
  @next: Nat -> @left: List<&2,T.Row> -> @right: List<&2,T.Row> -> @pending: List<&2,T.Command> ->
    {True{} == S.admissible(limit,T.World{id,next,left,pending}) : Bool} -> R.Slots(limit,0n,left,right) ->
      {M.observe(M.tick(steps,limit,T.World{id,next,left,pending}))
        == S.observe(S.run(steps,limit,T.World{id,next,right,pending})) : T.Observation}

def reserve_run(order: Cmp, +steps: List<&2,T.Step>, +limit: Nat, +id: Nat, +next: Nat,
  +left: List<&2,T.Row>, +right: List<&2,T.Row>, +pending: List<&2,T.Command>, +value: Nat,
  e: {order == Nat.cmp(next,limit) : Cmp}, valid: {True{} == S.admissible(limit,T.World{id,next,left,pending}) : Bool},
  related: R.Slots(limit,0n,left,right), ih: Continuation(steps,limit,id))
  -> {M.observe(M.tick(steps,limit,M.unwrap(M.reserve_if(Cmp.is_lt(order),id,next,left,pending,value))))
    == S.observe(S.run(steps,limit,S.unwrap(S.reserve_cmp(order,id,next,right,pending,value)))) : T.Observation}:
  match order:
    case LT{}:
      ih(1n+next,left,right,List.append(&2,T.Command,pending,[T.Spawn{next,value}]),
        C.reserve_success(limit,id,next,left,pending,value,valid,Equal.cong(Cmp,Bool,o => Cmp.is_lt(o),LT{},Nat.cmp(next,limit),e)),related)
    case EQ{}: ih(next,left,right,pending,valid,related)
    case GT{}: ih(next,left,right,pending,valid,related)

def publish_run(order: Cmp, +steps: List<&2,T.Step>, +limit: Nat, +id: Nat, +next: Nat,
  +left: List<&2,T.Row>, +right: List<&2,T.Row>, +pending: List<&2,T.Command>, +target: Nat, +action: T.Action,
  valid: {True{} == S.admissible(limit,T.World{id,next,left,pending}) : Bool},
  related: R.Slots(limit,0n,left,right), ih: Continuation(steps,limit,id))
  -> {M.observe(M.tick(steps,limit,M.publish_if(Cmp.is_eq(order),id,next,left,pending,target,action)))
    == S.observe(S.run(steps,limit,S.publish_cmp(order,id,next,right,pending,target,action))) : T.Observation}:
  match order:
    case EQ{}:
      ih(next,left,right,List.append(&2,T.Command,pending,[T.Target{target,action}]),C.publish_success(limit,id,next,left,pending,target,action,valid),related)
    case LT{}: ih(next,left,right,pending,valid,related)
    case GT{}: ih(next,left,right,pending,valid,related)

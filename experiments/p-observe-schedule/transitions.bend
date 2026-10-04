import Base
import ./relation.bend as R
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

# Shared metadata and a relation at the actual selected successor frontier.
# The larger interval on a successful reserve remains an explicit premise.
def reserve_related_case(+order: Cmp, +id: Nat, +next: Nat,
  +left: List<&2,T.Row>, +right: List<&2,T.Row>, +pending: List<&2,T.Command>, +value: Nat,
  old: R.Slots(next,0n,left,right), extended: R.Slots(1n+next,0n,left,right))
  -> R.Related(M.unwrap(M.reserve_if(Cmp.is_lt(order),id,next,left,pending,value)),
    S.unwrap(S.reserve_cmp(order,id,next,right,pending,value))):
  match order:
    case LT{}: R.related_shared(id,1n+next,left,right,List.append(&2,T.Command,pending,[T.Spawn{next,value}]),extended)
    case EQ{}: R.related_shared(id,next,left,right,pending,old)
    case GT{}: R.related_shared(id,next,left,right,pending,old)

def reserve_related(+limit: Nat, +id: Nat, +next: Nat,
  +left: List<&2,T.Row>, +right: List<&2,T.Row>, +pending: List<&2,T.Command>, +value: Nat,
  old: R.Slots(next,0n,left,right), extended: R.Slots(1n+next,0n,left,right))
  -> R.Related(M.step(limit,T.World{id,next,left,pending},T.Reserve{value}),
    S.step(limit,T.World{id,next,right,pending},T.Reserve{value})):
  reserve_related_case(Nat.cmp(next,limit),id,next,left,right,pending,value,old,extended)

# Publication compares actual namespaces; slot/action/FIFO queue stay literal.
def publish_related_case(+order: Cmp, +id: Nat, +next: Nat,
  +left: List<&2,T.Row>, +right: List<&2,T.Row>, +pending: List<&2,T.Command>, +slot: Nat, +action: T.Action,
  related: R.Slots(next,0n,left,right))
  -> R.Related(M.publish_if(Cmp.is_eq(order),id,next,left,pending,slot,action),
    S.publish_cmp(order,id,next,right,pending,slot,action)):
  match order:
    case EQ{}: R.related_shared(id,next,left,right,List.append(&2,T.Command,pending,[T.Target{slot,action}]),related)
    case LT{}: R.related_shared(id,next,left,right,pending,related)
    case GT{}: R.related_shared(id,next,left,right,pending,related)

def publish_related(+limit: Nat, +id: Nat, +next: Nat,
  +left: List<&2,T.Row>, +right: List<&2,T.Row>, +pending: List<&2,T.Command>, +namespace: Nat, +slot: Nat, +action: T.Action,
  related: R.Slots(next,0n,left,right))
  -> R.Related(M.step(limit,T.World{id,next,left,pending},T.Publish{T.Handle{namespace,slot},action}),
    S.step(limit,T.World{id,next,right,pending},T.Publish{T.Handle{namespace,slot},action})):
  publish_related_case(Nat.cmp(id,namespace),id,next,left,right,pending,slot,action,related)

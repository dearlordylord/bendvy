import Base
import ./frames.bend as F
import ../p-approved-owned-word-context/helpers.bend as W
import ../p-approved-u32-comparison/LAWS.bend as CL
import ../p-approved-u32-comparison/PROOF.bend as CP
import ../p-approved-u32-increment/LAWS.bend as IL
import ../p-approved-u32-increment/PROOF.bend as IP
import ../t11-replacement/runtime.bend as R
import ../t11-replacement/owned-spec.bend as O
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

def commands_append(+left: List<&2,R.Command>, +right: List<&2,R.Command>)
  -> {O.commands(List.append(&2,R.Command,left,right)) == List.append(&2,T.Command,O.commands(left),O.commands(right)) : List<&2,T.Command>}:
  match left:
    case Nil{}: {==}
    case Con{+head,+tail}:
      %commands_append(tail,right) : {O.command(head) <> O.commands(List.append(&2,R.Command,tail,right))
        == O.command(head) <> _ : List<&2,T.Command>}
      {==}

def increment(+value: U32, h: {True{} == U32.is_lt(value,4294967295) : Bool})
  -> {U32.to_nat(U32.add(value,1)) == 1n+U32.to_nat(value) : Nat}:
  %Equal.sym(Bool,True{},U32.is_lt(value,4294967295),h) : S.When(_,{U32.to_nat(U32.add(value,1)) == 1n+U32.to_nat(value) : Nat})
  IL.u32_increment_no_wrap(value)

def reserve_branch(accepts: Bool, +limit: U32, +id: U32, +next: U32, -rows: List<R.Cell>, +pending: List<&2,R.Command>, +value: U32,
  h: {accepts == U32.is_lt(next,limit) : Bool})
  -> {O.snapshot(R.reserve_world(R.reserve_if(accepts,id,next,rows,pending,value)))
    == M.unwrap(M.reserve_if(accepts,U32.to_nat(id),U32.to_nat(next),O.rows(rows),O.commands(pending),U32.to_nat(value))) : T.World}:
  match accepts:
    case False{}: {==}
    case True{}:
      %Equal.sym(Nat,U32.to_nat(U32.add(next,1)),1n+U32.to_nat(next),increment(next,W.reserve_below_max(next,limit,h))) :
        {T.World{U32.to_nat(id),_,O.rows(rows),O.commands(List.append(&2,R.Command,pending,[R.Spawn{next,value}]))}
          == T.World{U32.to_nat(id),1n+U32.to_nat(next),O.rows(rows),List.append(&2,T.Command,O.commands(pending),[T.Spawn{U32.to_nat(next),U32.to_nat(value)}])} : T.World}
      %Equal.sym(List<&2,T.Command>,O.commands(List.append(&2,R.Command,pending,[R.Spawn{next,value}])),List.append(&2,T.Command,O.commands(pending),O.commands([R.Spawn{next,value}])),commands_append(pending,[R.Spawn{next,value}])) :
        {T.World{U32.to_nat(id),1n+U32.to_nat(next),O.rows(rows),_}
          == T.World{U32.to_nat(id),1n+U32.to_nat(next),O.rows(rows),List.append(&2,T.Command,O.commands(pending),[T.Spawn{U32.to_nat(next),U32.to_nat(value)}])} : T.World}
      {==}

def reserve_observed(+limit: U32, +id: U32, +next: U32, -rows: List<R.Cell>, +pending: List<&2,R.Command>, +value: U32)
  -> {O.snapshot(R.reserve_world(R.reserve(limit,R.World{id,next,rows,pending},value)))
    == M.step(U32.to_nat(limit),O.snapshot(R.World{id,next,rows,pending}),T.Reserve{U32.to_nat(value)}) : T.World}:
  %CL.u32_comparison_agrees_nat(next,limit) :
    {O.snapshot(R.reserve_world(R.reserve_if(U32.is_lt(next,limit),id,next,rows,pending,value)))
      == M.unwrap(M.reserve_if(_,U32.to_nat(id),U32.to_nat(next),O.rows(rows),O.commands(pending),U32.to_nat(value))) : T.World}
  reserve_branch(U32.is_lt(next,limit),limit,id,next,rows,pending,value,{==})

def reserve(+limit: U32, world: R.World, +value: U32)
  -> F.WorldResult<R.step(limit,world,R.Reserve{value}),M.step(U32.to_nat(limit),O.snapshot(world),T.Reserve{U32.to_nat(value)})>:
  match world:
    case R.World{+id,+next,rows,+pending}:
      observed = reserve_observed(limit,id,next,rows,pending,value)
      F.WorldResult{R.reserve_world(R.reserve(limit,R.World{id,next,rows,pending},value)),{==},observed}

def publish_branch(local: Bool, +id: U32, +next: U32, -rows: List<R.Cell>, +pending: List<&2,R.Command>, +slot: U32, +action: T.Action)
  -> {O.snapshot(R.publish_if(local,id,next,rows,pending,slot,action))
    == M.publish_if(local,U32.to_nat(id),U32.to_nat(next),O.rows(rows),O.commands(pending),U32.to_nat(slot),action) : T.World}:
  match local:
    case False{}: {==}
    case True{}:
      %Equal.sym(List<&2,T.Command>,O.commands(List.append(&2,R.Command,pending,[R.Target{slot,action}])),List.append(&2,T.Command,O.commands(pending),O.commands([R.Target{slot,action}])),commands_append(pending,[R.Target{slot,action}])) :
        {T.World{U32.to_nat(id),U32.to_nat(next),O.rows(rows),_}
          == T.World{U32.to_nat(id),U32.to_nat(next),O.rows(rows),List.append(&2,T.Command,O.commands(pending),[T.Target{U32.to_nat(slot),action}])} : T.World}
      {==}

def publish_observed(+id: U32, +next: U32, -rows: List<R.Cell>, +pending: List<&2,R.Command>, +namespace: U32, +slot: U32, +action: T.Action)
  -> {O.snapshot(R.publish(R.World{id,next,rows,pending},R.Handle{namespace,slot},action))
    == M.publish(O.snapshot(R.World{id,next,rows,pending}),T.Handle{U32.to_nat(namespace),U32.to_nat(slot)},action) : T.World}:
  %W.equality(id,namespace) : {O.snapshot(R.publish_if(U32.is_eq(id,namespace),id,next,rows,pending,slot,action))
    == M.publish_if(_,U32.to_nat(id),U32.to_nat(next),O.rows(rows),O.commands(pending),U32.to_nat(slot),action) : T.World}
  publish_branch(U32.is_eq(id,namespace),id,next,rows,pending,slot,action)

def publish(+limit: U32, world: R.World, +handle: R.Handle, +action: T.Action)
  -> F.WorldResult<R.step(limit,world,R.Publish{handle,action}),M.step(U32.to_nat(limit),O.snapshot(world),O.step(R.Publish{handle,action}))>:
  match world handle:
    case R.World{+id,+next,rows,+pending} R.Handle{+namespace,+slot}:
      observed = publish_observed(id,next,rows,pending,namespace,slot,action)
      F.WorldResult{R.publish(R.World{id,next,rows,pending},R.Handle{namespace,slot},action),{==},observed}

import Base
import ./safety.bend as V
import ../p-observe-schedule/relation.bend as R
import ../p-observe-schedule/context.bend as C
import ../p-observe-schedule/successor.bend as U
import ../p-observe-schedule/barrier.bend as B
import ../p-observe-flush/prefix.bend as F
import ../p-observe-queries/helpers.bend as H
import ../p-observe-queries/invariants.bend as Q
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

def Continuation(+steps: List<&2,T.Step>,+limit: Nat,+id: Nat) -> Type:
  @next: Nat -> @left: List<&2,T.Row> -> @right: List<&2,T.Row> -> @pending: List<&2,T.Command> ->
  {True{} == S.admissible(limit,T.World{id,next,left,pending}) : Bool} -> R.Slots(limit,0n,left,right) ->
  {True{} == S.run_safe(steps,limit,T.World{id,next,right,pending}) : Bool} ->
  {True{} == V.ModelSafe(steps,limit,T.World{id,next,left,pending}) : Bool}

def reserve_run(order: Cmp, +steps: List<&2,T.Step>, +limit: Nat, +id: Nat, +next: Nat,
  +left: List<&2,T.Row>, +right: List<&2,T.Row>, +pending: List<&2,T.Command>, +value: Nat,
  e: {order == Nat.cmp(next,limit) : Cmp}, valid: {True{} == S.admissible(limit,T.World{id,next,left,pending}) : Bool},
  related: R.Slots(limit,0n,left,right), ih: Continuation(steps,limit,id), safe: {True{} == S.run_safe(steps,limit,S.unwrap(S.reserve_cmp(order,id,next,right,pending,value))) : Bool})
  -> {True{} == V.ModelSafe(steps,limit,M.unwrap(M.reserve_if(Cmp.is_lt(order),id,next,left,pending,value))) : Bool}:
  match order:
    case LT{}:
      ih(1n+next,left,right,List.append(&2,T.Command,pending,[T.Spawn{next,value}]),
        C.reserve_success(limit,id,next,left,pending,value,valid,Equal.cong(Cmp,Bool,o => Cmp.is_lt(o),LT{},Nat.cmp(next,limit),e)),related,safe)
    case EQ{}: ih(next,left,right,pending,valid,related,safe)
    case GT{}: ih(next,left,right,pending,valid,related,safe)

def publish_run(order: Cmp, +steps: List<&2,T.Step>, +limit: Nat, +id: Nat, +next: Nat,
  +left: List<&2,T.Row>, +right: List<&2,T.Row>, +pending: List<&2,T.Command>, +target: Nat, +action: T.Action,
  valid: {True{} == S.admissible(limit,T.World{id,next,left,pending}) : Bool},
  related: R.Slots(limit,0n,left,right), ih: Continuation(steps,limit,id), safe: {True{} == S.run_safe(steps,limit,S.publish_cmp(order,id,next,right,pending,target,action)) : Bool})
  -> {True{} == V.ModelSafe(steps,limit,M.publish_if(Cmp.is_eq(order),id,next,left,pending,target,action)) : Bool}:
  match order:
    case EQ{}:
      ih(next,left,right,List.append(&2,T.Command,pending,[T.Target{target,action}]),C.publish_success(limit,id,next,left,pending,target,action,valid),related,safe)
    case LT{}: ih(next,left,right,pending,valid,related,safe)
    case GT{}: ih(next,left,right,pending,valid,related,safe)

def dispatch(+operation: T.Step,+steps: List<&2,T.Step>,+limit: Nat,+id: Nat,+next: Nat,
  +left: List<&2,T.Row>,+right: List<&2,T.Row>,+pending: List<&2,T.Command>,
  +valid: {True{} == S.admissible(limit,T.World{id,next,left,pending}) : Bool}, related: R.Slots(limit,0n,left,right),
  safe: {True{} == S.run_safe(steps,limit,S.step(limit,T.World{id,next,right,pending},operation)) : Bool}, ih: Continuation(steps,limit,id))
  -> {True{} == V.ModelSafe(steps,limit,M.step(limit,T.World{id,next,left,pending},operation)) : Bool}:
  match operation:
    case T.Reserve{value}: reserve_run(Nat.cmp(next,limit),steps,limit,id,next,left,right,pending,value,{==},valid,related,ih,safe)
    case T.Publish{T.Handle{namespace,target},action}: publish_run(Nat.cmp(id,namespace),steps,limit,id,next,left,right,pending,target,action,valid,related,ih,safe)
    case T.Bump{target}:
      ih(next,M.bump_rows(target,left),S.bumped(next,0n,target,right),pending,
        C.bump_success(limit,id,next,left,pending,target,valid),
        U.bump_slots(limit,0n,next,target,left,right,C.live_valid(limit,id,next,left,pending,valid),related),safe)
    case T.Barrier{}:
      ih(next,M.apply_all(pending,left),S.materialize(next,0n,right,pending),[],
        B.barrier_success(limit,id,next,left,pending,valid),
        B.barrier_slots(limit,0n,next,left,right,pending,F.apply_all_rows_valid(pending,left,next,C.live_valid(limit,id,next,left,pending,valid),C.queue_valid(limit,id,next,left,pending,valid)),related),safe)

def join_split(+fuel: Nat,+start: Nat,+left: List<&2,T.Row>,+right: List<&2,T.Row>,+head: {S.at(left,start) == S.at(right,start) : Maybe<&2,T.Row>},
  pair: R.Slots(fuel,1n+start,left,right) & R.Slots(fuel,1n+start,left,right))
  -> R.Slots(1n+fuel,start,left,right) & R.Slots(1n+fuel,start,left,right):
  (a,b) = pair
  ((head,a),(head,b))

def split_slots(+fuel: Nat,+start: Nat,+left: List<&2,T.Row>,+right: List<&2,T.Row>,related: R.Slots(fuel,start,left,right))
  -> R.Slots(fuel,start,left,right) & R.Slots(fuel,start,left,right):
  match fuel:
    case 0n: (Unit{},Unit{})
    case 1n+rest:
      (+head,tail) = related
      join_split(rest,start,left,right,head,split_slots(rest,1n+start,left,right,tail))

def head_safe(+head: T.Step,+tail: List<&2,T.Step>,+limit: Nat,+id: Nat,+next: Nat,
  +left: List<&2,T.Row>,+right: List<&2,T.Row>,+pending: List<&2,T.Command>,
  +valid: {True{} == S.admissible(limit,T.World{id,next,left,pending}) : Bool},
  pair: R.Slots(limit,0n,left,right) & R.Slots(limit,0n,left,right),
  +safe: {True{} == S.run_safe(head <> tail,limit,T.World{id,next,right,pending}) : Bool},ih: Continuation(tail,limit,id))
  -> {True{} == V.ModelSafe(head <> tail,limit,T.World{id,next,left,pending}) : Bool}:
  (step_slots,tail_slots) = pair
  +right_valid = H.and_left(S.admissible(limit,T.World{id,next,right,pending}),Bool.and(S.step_safe(T.World{id,next,right,pending},head),S.run_safe(tail,limit,S.step(limit,T.World{id,next,right,pending},head))),safe)
  +rest = H.and_right(S.admissible(limit,T.World{id,next,right,pending}),Bool.and(S.step_safe(T.World{id,next,right,pending},head),S.run_safe(tail,limit,S.step(limit,T.World{id,next,right,pending},head))),safe)
  Q.and_intro(S.admissible(limit,T.World{id,next,left,pending}),Bool.and(S.step_safe(T.World{id,next,left,pending},head),V.ModelSafe(tail,limit,M.step(limit,T.World{id,next,left,pending},head))),valid,
    Q.and_intro(S.step_safe(T.World{id,next,left,pending},head),V.ModelSafe(tail,limit,M.step(limit,T.World{id,next,left,pending},head)),
      Equal.trans(Bool,True{},S.step_safe(T.World{id,next,right,pending},head),S.step_safe(T.World{id,next,left,pending},head),
        H.and_left(S.step_safe(T.World{id,next,right,pending},head),S.run_safe(tail,limit,S.step(limit,T.World{id,next,right,pending},head)),rest),
        Equal.sym(Bool,S.step_safe(T.World{id,next,left,pending},head),S.step_safe(T.World{id,next,right,pending},head),V.step_safe(head,limit,id,next,left,right,pending,valid,right_valid,step_slots))),
      dispatch(head,tail,limit,id,next,left,right,pending,valid,tail_slots,
        H.and_right(S.step_safe(T.World{id,next,right,pending},head),S.run_safe(tail,limit,S.step(limit,T.World{id,next,right,pending},head)),rest),
        ih)))

def related_safe(+steps: List<&2,T.Step>,+limit: Nat,+id: Nat,+next: Nat,
  +left: List<&2,T.Row>,+right: List<&2,T.Row>,+pending: List<&2,T.Command>,
  +valid: {True{} == S.admissible(limit,T.World{id,next,left,pending}) : Bool}, related: R.Slots(limit,0n,left,right),
  +safe: {True{} == S.run_safe(steps,limit,T.World{id,next,right,pending}) : Bool})
  -> {True{} == V.ModelSafe(steps,limit,T.World{id,next,left,pending}) : Bool}:
  match steps:
    case Nil{}: valid
    case Con{+head,+tail}:
      head_safe(head,tail,limit,id,next,left,right,pending,valid,split_slots(limit,0n,left,right,related),safe,
        n => l => r => p => v => slots => h => related_safe(tail,limit,id,n,l,r,p,v,slots,h))

def from_independent(+steps: List<&2,T.Step>,+limit: Nat,+world: T.World,
  +safe: {True{} == S.run_safe(steps,limit,world) : Bool})
  -> {True{} == V.ModelSafe(steps,limit,world) : Bool}:
  match steps:
    case Nil{}: safe
    case Con{+head,+tail}:
      match world:
        case T.World{+id,+next,+rows,+pending}:
          related_safe(head <> tail,limit,id,next,rows,rows,pending,
            H.and_left(S.admissible(limit,T.World{id,next,rows,pending}),Bool.and(S.step_safe(T.World{id,next,rows,pending},head),S.run_safe(tail,limit,S.step(limit,T.World{id,next,rows,pending},head))),safe),R.slots_refl(limit,0n,rows),safe)

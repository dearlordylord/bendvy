import Base
import ../t11-replacement/types.bend as T
import ../t11-replacement/spec.bend as S
import ../t11-replacement/model.bend as M
import ../p-observe-schedule/relation.bend as R
import ../p-observe-schedule/context.bend as C
import ../p-observe-schedule/successor.bend as U
import ../p-observe-queries/enum-lookup.bend as E
import ../p-observe-queries/invariants.bend as Q
import ../p-observe-queries/helpers.bend as H

def ModelSafe(steps: List<&2,T.Step>, +limit: Nat, +world: T.World) -> Bool:
  match steps:
    case Nil{}: S.admissible(limit,world)
    case Con{+head,tail}: Bool.and(S.admissible(limit,world),Bool.and(S.step_safe(world,head),ModelSafe(tail,limit,M.step(limit,world,head))))

def inside(+next: Nat,+left: List<&2,T.Row>,+right: List<&2,T.Row>,+target: Nat,
  +bound: {True{} == Nat.is_lt(target,next) : Bool}, related: R.Slots(next,0n,left,right))
  -> {S.at(left,target) == S.at(right,target) : Maybe<&2,T.Row>}:
  %Equal.sym(Maybe<&2,T.Row>,S.at(left,target),S.at(S.enumerate_rows(next,0n,left,T.Any{}),target),E.lookup_inside(next,0n,left,target,Q.zero_le(target),bound)) : {_ == S.at(right,target) : Maybe<&2,T.Row>}
  %Equal.sym(Maybe<&2,T.Row>,S.at(right,target),S.at(S.enumerate_rows(next,0n,right,T.Any{}),target),E.lookup_inside(next,0n,right,target,Q.zero_le(target),bound)) : {S.at(S.enumerate_rows(next,0n,left,T.Any{}),target) == _ : Maybe<&2,T.Row>}
  Equal.cong(List<&2,T.Row>,Maybe<&2,T.Row>,rows => S.at(rows,target),S.enumerate_rows(next,0n,left,T.Any{}),S.enumerate_rows(next,0n,right,T.Any{}),R.enumerate_related(next,0n,left,right,T.Any{},related))

def point_case(order: Cmp,+next: Nat,+left: List<&2,T.Row>,+right: List<&2,T.Row>,+target: Nat,
  +e: {order == Nat.cmp(target,next) : Cmp},
  +lv: {True{} == S.rows_valid(left,left,next) : Bool}, rv: {True{} == S.rows_valid(right,right,next) : Bool},
  related: R.Slots(next,0n,left,right))
  -> {S.at(left,target) == S.at(right,target) : Maybe<&2,T.Row>}:
  match order:
    case LT{}: inside(next,left,right,target,Equal.cong(Cmp,Bool,o => Cmp.is_lt(o),LT{},Nat.cmp(target,next),e),related)
    case EQ{}:
      Equal.trans(Maybe<&2,T.Row>,S.at(left,target),None{},S.at(right,target),Equal.sym(Maybe<&2,T.Row>,None{},S.at(left,target),U.missing_after_bound(left,left,next,target,lv,U.order_ge(EQ{},target,next,e))),U.missing_after_bound(right,right,next,target,rv,U.order_ge(EQ{},target,next,e)))
    case GT{}:
      Equal.trans(Maybe<&2,T.Row>,S.at(left,target),None{},S.at(right,target),Equal.sym(Maybe<&2,T.Row>,None{},S.at(left,target),U.missing_after_bound(left,left,next,target,lv,U.order_ge(GT{},target,next,e))),U.missing_after_bound(right,right,next,target,rv,U.order_ge(GT{},target,next,e)))

def step_safe(+operation: T.Step,+limit: Nat,+id: Nat,+next: Nat,+left: List<&2,T.Row>,+right: List<&2,T.Row>,+pending: List<&2,T.Command>,
  +lv: {True{} == S.admissible(limit,T.World{id,next,left,pending}) : Bool},
  rv: {True{} == S.admissible(limit,T.World{id,next,right,pending}) : Bool}, related: R.Slots(limit,0n,left,right))
  -> {S.step_safe(T.World{id,next,left,pending},operation) == S.step_safe(T.World{id,next,right,pending},operation) : Bool}:
  match operation:
    case T.Bump{+target}:
      %H.cmp_reflexive(id) : {S.no_overflow_lookup(S.lookup_namespace(_,left,target,T.Any{})) == S.no_overflow_lookup(S.lookup_namespace(_,right,target,T.Any{})) : Bool}
      %Equal.sym(Maybe<&2,T.Row>,S.at(left,target),S.at(right,target),point_case(Nat.cmp(target,next),next,left,right,target,{==},C.live_valid(limit,id,next,left,pending,lv),C.live_valid(limit,id,next,right,pending,rv),R.slots_prefix(limit,next,0n,left,right,C.frontier_bound(limit,id,next,left,pending,lv),related))) :
        {S.no_overflow_lookup(S.describe(T.Any{},_)) == S.no_overflow_lookup(S.describe(T.Any{},S.at(right,target))) : Bool}
      {==}
    case T.Reserve{value}: {==}
    case T.Publish{handle,action}: {==}
    case T.Barrier{}: {==}

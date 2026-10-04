import Base
import ./relation.bend as R
import ./successor.bend as U
import ./context.bend as C
import ../p-observe-queries/invariants.bend as Q
import ../p-observe-flush/coherence.bend as F
import ../p-observe-flush/prefix.bend as P
import ../p-observe-flush/materialization.bend as E
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

# Barrier commits the actual FIFO prefix and clears the queue.
def barrier_success(+limit: Nat, +id: Nat, +next: Nat, +rows: List<&2,T.Row>, +pending: List<&2,T.Command>,
  +valid: {True{} == S.admissible(limit,T.World{id,next,rows,pending}) : Bool})
  -> {True{} == S.admissible(limit,T.World{id,next,M.apply_all(pending,rows),[]}) : Bool}:
  Q.and_intro(Nat.is_le(next,limit),Bool.and(S.rows_valid(M.apply_all(pending,rows),M.apply_all(pending,rows),next),True{}),
    C.frontier_bound(limit,id,next,rows,pending,valid),
    Q.and_intro(S.rows_valid(M.apply_all(pending,rows),M.apply_all(pending,rows),next),True{},
      P.apply_all_rows_valid(pending,rows,next,C.live_valid(limit,id,next,rows,pending,valid),C.queue_valid(limit,id,next,rows,pending,valid)),{==}))

def barrier_slot_outside(+next: Nat, +left: List<&2,T.Row>, +right: List<&2,T.Row>, +pending: List<&2,T.Command>, +slot: Nat,
  valid: {True{} == S.rows_valid(M.apply_all(pending,left),M.apply_all(pending,left),next) : Bool},
  +bound: {True{} == Nat.is_le(next,slot) : Bool})
  -> {S.at(M.apply_all(pending,left),slot) == S.at(S.materialize(next,0n,right,pending),slot) : Maybe<&2,T.Row>}:
  Equal.trans(Maybe<&2,T.Row>,S.at(M.apply_all(pending,left),slot),None{},S.at(S.materialize(next,0n,right,pending),slot),
    Equal.sym(Maybe<&2,T.Row>,None{},S.at(M.apply_all(pending,left),slot),U.missing_after_bound(M.apply_all(pending,left),M.apply_all(pending,left),next,slot,valid,bound)),
    E.materialize_above(next,0n,right,pending,slot,bound))

def barrier_slot_case(order: Cmp, +next: Nat, +left: List<&2,T.Row>, +right: List<&2,T.Row>, +pending: List<&2,T.Command>, +slot: Nat,
  e: {order == Nat.cmp(slot,next) : Cmp},
  valid: {True{} == S.rows_valid(M.apply_all(pending,left),M.apply_all(pending,left),next) : Bool},
  related: {S.at(left,slot) == S.at(right,slot) : Maybe<&2,T.Row>})
  -> {S.at(M.apply_all(pending,left),slot) == S.at(S.materialize(next,0n,right,pending),slot) : Maybe<&2,T.Row>}:
  match order:
    case LT{}:
      Equal.trans(Maybe<&2,T.Row>,S.at(M.apply_all(pending,left),slot),S.replay(pending,slot,S.at(left,slot)),S.at(S.materialize(next,0n,right,pending),slot),
        F.mixed_fifo_slot(pending,left,slot),
        Equal.trans(Maybe<&2,T.Row>,S.replay(pending,slot,S.at(left,slot)),S.replay(pending,slot,S.at(right,slot)),S.at(S.materialize(next,0n,right,pending),slot),
          Equal.cong(Maybe<&2,T.Row>,Maybe<&2,T.Row>,found => S.replay(pending,slot,found),S.at(left,slot),S.at(right,slot),related),
          Equal.sym(Maybe<&2,T.Row>,S.at(S.materialize(next,0n,right,pending),slot),S.replay(pending,slot,S.at(right,slot)),
            E.materialize_inside(next,0n,right,pending,slot,Q.zero_le(slot),Equal.cong(Cmp,Bool,o => Cmp.is_lt(o),LT{},Nat.cmp(slot,next),e)))))
    case EQ{}: barrier_slot_outside(next,left,right,pending,slot,valid,U.order_ge(EQ{},slot,next,e))
    case GT{}: barrier_slot_outside(next,left,right,pending,slot,valid,U.order_ge(GT{},slot,next,e))

def barrier_slots(+fuel: Nat, +start: Nat, +next: Nat, +left: List<&2,T.Row>, +right: List<&2,T.Row>, +pending: List<&2,T.Command>,
  +valid: {True{} == S.rows_valid(M.apply_all(pending,left),M.apply_all(pending,left),next) : Bool},
  related: R.Slots(fuel,start,left,right))
  -> R.Slots(fuel,start,M.apply_all(pending,left),S.materialize(next,0n,right,pending)):
  match fuel:
    case 0n: Unit{}
    case 1n+rest:
      (head,tail) = related
      (barrier_slot_case(Nat.cmp(start,next),next,left,right,pending,start,{==},valid,head),
        barrier_slots(rest,1n+start,next,left,right,pending,valid,tail))

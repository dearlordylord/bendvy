import Base
import ./relation.bend as R
import ./bump.bend as B
import ../p-observe-queries/helpers.bend as H
import ../p-observe-queries/invariants.bend as Q
import ../p-observe-queries/intervals.bend as X
import ../p-observe-queries/order.bend as N
import ../p-observe-queries/enum-lookup.bend as E
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

# The model's independent row bounds exclude all keys at/beyond next.
def missing_after_bound(+rows: List<&2,T.Row>, +all: List<&2,T.Row>, +next: Nat, +slot: Nat,
  +valid: {True{} == S.rows_valid(rows,all,next) : Bool}, +bound: {True{} == Nat.is_le(next,slot) : Bool})
  -> {None{} == S.at(rows,slot) : Maybe<&2,T.Row>}:
  match rows:
    case Nil{}: {==}
    case Con{T.Row{+id,+value,+tag},+tail}:
      +rest = H.and_right(Nat.is_eq(S.count(all,id),1n),Bool.and(Nat.is_lt(id,next),S.rows_valid(tail,all,next)),valid)
      different = Q.lt_not_eq(id,slot,N.lt_le_trans(id,next,slot,H.and_left(Nat.is_lt(id,next),S.rows_valid(tail,all,next),rest),bound))
      Equal.trans(Maybe<&2,T.Row>,None{},S.at(tail,slot),S.at(T.Row{id,value,tag} <> tail,slot),
        missing_after_bound(tail,all,next,slot,H.and_right(Nat.is_lt(id,next),S.rows_valid(tail,all,next),rest),bound),
        X.skip_head(id,value,tag,tail,slot,different))

def bumped_inside(+next: Nat, +target: Nat, +rows: List<&2,T.Row>, +slot: Nat,
  bound: {True{} == Nat.is_lt(slot,next) : Bool})
  -> {S.at(S.bumped(next,0n,target,rows),slot) == S.immediate(Nat.cmp(slot,target),S.at(rows,slot)) : Maybe<&2,T.Row>}:
  %B.bump_enumeration(next,0n,target,rows) : {S.at(_,slot) == S.immediate(Nat.cmp(slot,target),S.at(rows,slot)) : Maybe<&2,T.Row>}
  Equal.trans(Maybe<&2,T.Row>,S.at(M.bump_rows(target,S.enumerate_rows(next,0n,rows,T.Any{})),slot),
    S.immediate(Nat.cmp(slot,target),S.at(S.enumerate_rows(next,0n,rows,T.Any{}),slot)),S.immediate(Nat.cmp(slot,target),S.at(rows,slot)),
    B.bump_point(S.enumerate_rows(next,0n,rows,T.Any{}),target,slot),
    Equal.cong(Maybe<&2,T.Row>,Maybe<&2,T.Row>,found => S.immediate(Nat.cmp(slot,target),found),
      S.at(S.enumerate_rows(next,0n,rows,T.Any{}),slot),S.at(rows,slot),
      Equal.sym(Maybe<&2,T.Row>,S.at(rows,slot),S.at(S.enumerate_rows(next,0n,rows,T.Any{}),slot),E.lookup_inside(next,0n,rows,slot,Q.zero_le(slot),bound))))

def bumped_above(+next: Nat, +target: Nat, +rows: List<&2,T.Row>, +slot: Nat,
  bound: {True{} == Nat.is_le(next,slot) : Bool})
  -> {None{} == S.at(S.bumped(next,0n,target,rows),slot) : Maybe<&2,T.Row>}:
  %B.bump_enumeration(next,0n,target,rows) : {None{} == S.at(_,slot) : Maybe<&2,T.Row>}
  %Equal.sym(Maybe<&2,T.Row>,S.at(M.bump_rows(target,S.enumerate_rows(next,0n,rows,T.Any{})),slot),
    S.immediate(Nat.cmp(slot,target),S.at(S.enumerate_rows(next,0n,rows,T.Any{}),slot)),B.bump_point(S.enumerate_rows(next,0n,rows,T.Any{}),target,slot)) :
    {None{} == _ : Maybe<&2,T.Row>}
  %E.lookup_above(next,0n,rows,slot,bound) : {None{} == S.immediate(Nat.cmp(slot,target),_) : Maybe<&2,T.Row>}
  B.bump_missing(Nat.cmp(slot,target))

def reverse_ge(+order: Cmp) -> {Cmp.is_ge(order) == Cmp.is_le(N.reverse_cmp(order)) : Bool}:
  match order:
    case EQ{}: {==}
    case LT{}: {==}
    case GT{}: {==}

def order_ge(+order: Cmp, +slot: Nat, +next: Nat, e: {order == Nat.cmp(slot,next) : Cmp})
  -> {Cmp.is_ge(order) == Nat.is_le(next,slot) : Bool}:
  %N.cmp_reverse(slot,next) : {Cmp.is_ge(order) == Cmp.is_le(_) : Bool}
  %e : {Cmp.is_ge(order) == Cmp.is_le(N.reverse_cmp(_)) : Bool}
  reverse_ge(order)

def bump_slot_outside(+next: Nat, +target: Nat, +left: List<&2,T.Row>, +right: List<&2,T.Row>, +slot: Nat,
  valid: {True{} == S.rows_valid(left,left,next) : Bool}, +bound: {True{} == Nat.is_le(next,slot) : Bool})
  -> {S.at(M.bump_rows(target,left),slot) == S.at(S.bumped(next,0n,target,right),slot) : Maybe<&2,T.Row>}:
  %Equal.sym(Maybe<&2,T.Row>,S.at(M.bump_rows(target,left),slot),S.immediate(Nat.cmp(slot,target),S.at(left,slot)),B.bump_point(left,target,slot)) :
    {_ == S.at(S.bumped(next,0n,target,right),slot) : Maybe<&2,T.Row>}
  %missing_after_bound(left,left,next,slot,valid,bound) :
    {S.immediate(Nat.cmp(slot,target),_) == S.at(S.bumped(next,0n,target,right),slot) : Maybe<&2,T.Row>}
  %B.bump_missing(Nat.cmp(slot,target)) : {_ == S.at(S.bumped(next,0n,target,right),slot) : Maybe<&2,T.Row>}
  bumped_above(next,target,right,slot,bound)

def bump_slot_case(order: Cmp, +next: Nat, +target: Nat, +left: List<&2,T.Row>, +right: List<&2,T.Row>, +slot: Nat,
  e: {order == Nat.cmp(slot,next) : Cmp}, valid: {True{} == S.rows_valid(left,left,next) : Bool},
  related: {S.at(left,slot) == S.at(right,slot) : Maybe<&2,T.Row>})
  -> {S.at(M.bump_rows(target,left),slot) == S.at(S.bumped(next,0n,target,right),slot) : Maybe<&2,T.Row>}:
  match order:
    case LT{}:
      Equal.trans(Maybe<&2,T.Row>,S.at(M.bump_rows(target,left),slot),S.immediate(Nat.cmp(slot,target),S.at(left,slot)),S.at(S.bumped(next,0n,target,right),slot),
        B.bump_point(left,target,slot),
        Equal.trans(Maybe<&2,T.Row>,S.immediate(Nat.cmp(slot,target),S.at(left,slot)),S.immediate(Nat.cmp(slot,target),S.at(right,slot)),S.at(S.bumped(next,0n,target,right),slot),
          Equal.cong(Maybe<&2,T.Row>,Maybe<&2,T.Row>,found => S.immediate(Nat.cmp(slot,target),found),S.at(left,slot),S.at(right,slot),related),
          Equal.sym(Maybe<&2,T.Row>,S.at(S.bumped(next,0n,target,right),slot),S.immediate(Nat.cmp(slot,target),S.at(right,slot)),
            bumped_inside(next,target,right,slot,Equal.cong(Cmp,Bool,o => Cmp.is_lt(o),LT{},Nat.cmp(slot,next),e)))))
    case EQ{}: bump_slot_outside(next,target,left,right,slot,valid,order_ge(EQ{},slot,next,e))
    case GT{}: bump_slot_outside(next,target,left,right,slot,valid,order_ge(GT{},slot,next,e))

def bump_slots(+fuel: Nat, +start: Nat, +next: Nat, +target: Nat, +left: List<&2,T.Row>, +right: List<&2,T.Row>,
  +valid: {True{} == S.rows_valid(left,left,next) : Bool}, related: R.Slots(fuel,start,left,right))
  -> R.Slots(fuel,start,M.bump_rows(target,left),S.bumped(next,0n,target,right)):
  match fuel:
    case 0n: Unit{}
    case 1n+rest:
      (head,tail) = related
      (bump_slot_case(Nat.cmp(start,next),next,target,left,right,start,{==},valid,head),
        bump_slots(rest,1n+start,next,target,left,right,valid,tail))

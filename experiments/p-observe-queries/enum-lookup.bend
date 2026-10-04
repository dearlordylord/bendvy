import Base
import ./helpers.bend as H
import ./invariants.bend as I
import ./intervals.bend as X
import ./order.bend as N
import ./complete.bend as Q
import ../t11-replacement/types.bend as T
import ../t11-replacement/spec.bend as S

# Actual Any emission leaves a distinct target's lookup unchanged.
def skip_emitted(+row: Maybe<&2,T.Row>, +start: Nat, +target: Nat, +body: List<&2,T.Row>,
  key: I.AtKey(row,start), h: {False{} == Nat.is_eq(start,target) : Bool})
  -> {S.at(body,target) == S.at(S.query_at(T.Any{},row,body),target) : Maybe<&2,T.Row>}:
  match row:
    case None{}: {==}
    case Some{T.Row{+id,+value,+tag}}:
      X.skip_head(id,value,tag,body,target,
        Equal.trans(Bool,False{},Nat.is_eq(start,target),Nat.is_eq(id,target),h,
          Equal.cong(Nat,Bool,n => Nat.is_eq(n,target),start,id,Equal.sym(Nat,id,start,I.eq_reflect(id,start,key)))))

# All emitted keys lie at or above start, even for malformed/duplicate raw rows.
def lookup_below(+fuel: Nat, +start: Nat, +rows: List<&2,T.Row>, +target: Nat,
  +h: {True{} == Nat.is_lt(target,start) : Bool})
  -> {None{} == S.at(S.enumerate_rows(fuel,start,rows,T.Any{}),target) : Maybe<&2,T.Row>}:
  match fuel:
    case 0n: {==}
    case 1n+rest:
      Equal.trans(Maybe<&2,T.Row>,None{},S.at(S.enumerate_rows(rest,1n+start,rows,T.Any{}),target),S.at(S.enumerate_rows(1n+rest,start,rows,T.Any{}),target),
        lookup_below(rest,1n+start,rows,target,I.lt_succ_right(target,start,h)),
        skip_emitted(S.at(rows,start),start,target,S.enumerate_rows(rest,1n+start,rows,T.Any{}),I.at_key(rows,start),
          Equal.trans(Bool,False{},Nat.is_eq(target,start),Nat.is_eq(start,target),I.lt_not_eq(target,start,h),I.eq_symmetric(target,start))))

# A current-slot emission resolves exactly to the original optional row.
def lookup_current(+row: Maybe<&2,T.Row>, +start: Nat, +body: List<&2,T.Row>, key: I.AtKey(row,start),
  h: {None{} == S.at(body,start) : Maybe<&2,T.Row>})
  -> {row == S.at(S.query_at(T.Any{},row,body),start) : Maybe<&2,T.Row>}:
  match row:
    case None{}: h
    case Some{T.Row{+id,+value,+tag}}:
      %Equal.trans(Cmp,EQ{},Nat.cmp(id,id),Nat.cmp(id,start),H.cmp_reflexive(id),
        Equal.cong(Nat,Cmp,n => Nat.cmp(id,n),id,start,I.eq_reflect(id,start,key))) :
        {Some{T.Row{id,value,tag}} == S.pick(_,T.Row{id,value,tag},_ => S.at(body,start)) : Maybe<&2,T.Row>}
      {==}

# Actual bound-comparison step for an inside-interval target.
def inside_step(order: Cmp, +rest: Nat, +start: Nat, +rows: List<&2,T.Row>, +target: Nat,
  +e: {order == Nat.cmp(target,start) : Cmp}, lo: {True{} == Nat.is_le(start,target) : Bool},
  hi: {True{} == Nat.is_lt(target,Nat.add(start,1n+rest)) : Bool},
  ih: {True{} == Nat.is_le(1n+start,target) : Bool} -> {True{} == Nat.is_lt(target,Nat.add(1n+start,rest)) : Bool}
    -> {S.at(rows,target) == S.at(S.enumerate_rows(rest,1n+start,rows,T.Any{}),target) : Maybe<&2,T.Row>})
  -> {S.at(rows,target) == S.at(S.enumerate_rows(1n+rest,start,rows,T.Any{}),target) : Maybe<&2,T.Row>}:
  match order:
    case LT{}:
      Empty.absurd({S.at(rows,target) == S.at(S.enumerate_rows(1n+rest,start,rows,T.Any{}),target) : Maybe<&2,T.Row>},
        H.false_true_absurd(Equal.trans(Bool,False{},Nat.is_le(start,target),True{},Q.cmp_less_lower_false(target,start,e),Equal.sym(Bool,True{},Nat.is_le(start,target),lo))))
    case EQ{}:
      %Equal.sym(Nat,target,start,Q.cmp_equal(target,start,e)) :
        {S.at(rows,_) == S.at(S.enumerate_rows(1n+rest,start,rows,T.Any{}),_) : Maybe<&2,T.Row>}
      lookup_current(S.at(rows,start),start,S.enumerate_rows(rest,1n+start,rows,T.Any{}),I.at_key(rows,start),
        lookup_below(rest,1n+start,rows,start,N.lt_self_succ(start)))
    case GT{}:
      +later = Q.cmp_greater(target,start,e)
      Equal.trans(Maybe<&2,T.Row>,S.at(rows,target),S.at(S.enumerate_rows(rest,1n+start,rows,T.Any{}),target),S.at(S.enumerate_rows(1n+rest,start,rows,T.Any{}),target),
        ih(N.lt_succ_le(start,target,later),
          Equal.trans(Bool,True{},Nat.is_lt(target,Nat.add(start,1n+rest)),Nat.is_lt(target,Nat.add(1n+start,rest)),hi,
            Equal.cong(Nat,Bool,n => Nat.is_lt(target,n),Nat.add(start,1n+rest),Nat.add(1n+start,rest),
              Equal.sym(Nat,Nat.add(1n+start,rest),Nat.add(start,1n+rest),N.add_succ_right(start,rest))))),
        skip_emitted(S.at(rows,start),start,target,S.enumerate_rows(rest,1n+start,rows,T.Any{}),I.at_key(rows,start),I.lt_not_eq(start,target,later)))

# Bounded lookup inverse; no raw-row validity or uniqueness hypothesis required.
def lookup_inside(+fuel: Nat, +start: Nat, +rows: List<&2,T.Row>, +target: Nat,
  lo: {True{} == Nat.is_le(start,target) : Bool}, hi: {True{} == Nat.is_lt(target,Nat.add(start,fuel)) : Bool})
  -> {S.at(rows,target) == S.at(S.enumerate_rows(fuel,start,rows,T.Any{}),target) : Maybe<&2,T.Row>}:
  match fuel:
    case 0n:
      hi_start = Equal.trans(Bool,True{},Nat.is_lt(target,Nat.add(start,0n)),Nat.is_lt(target,start),hi,
        Equal.cong(Nat,Bool,n => Nat.is_lt(target,n),Nat.add(start,0n),start,
          Equal.sym(Nat,start,Nat.add(start,0n),I.add_zero(start))))
      Empty.absurd({S.at(rows,target) == None{} : Maybe<&2,T.Row>},I.le_lt_cycle(start,target,lo,hi_start))
    case 1n+rest:
      inside_step(Nat.cmp(target,start),rest,start,rows,target,{==},lo,hi,
        lower => upper => lookup_inside(rest,1n+start,rows,target,lower,upper))

# Outside the upper boundary, including the boundary itself, no row is emitted.
def lookup_above(+fuel: Nat, +start: Nat, +rows: List<&2,T.Row>, +target: Nat,
  +h: {True{} == Nat.is_le(Nat.add(start,fuel),target) : Bool})
  -> {None{} == S.at(S.enumerate_rows(fuel,start,rows,T.Any{}),target) : Maybe<&2,T.Row>}:
  match fuel:
    case 0n: {==}
    case 1n+rest:
      +later = N.lt_le_trans(start,Nat.add(start,1n+rest),target,N.positive_endpoint(start,rest),h)
      Equal.trans(Maybe<&2,T.Row>,None{},S.at(S.enumerate_rows(rest,1n+start,rows,T.Any{}),target),S.at(S.enumerate_rows(1n+rest,start,rows,T.Any{}),target),
        lookup_above(rest,1n+start,rows,target,
          Equal.trans(Bool,True{},Nat.is_le(Nat.add(start,1n+rest),target),Nat.is_le(Nat.add(1n+start,rest),target),h,
            Equal.cong(Nat,Bool,n => Nat.is_le(n,target),Nat.add(start,1n+rest),Nat.add(1n+start,rest),
              Equal.sym(Nat,Nat.add(1n+start,rest),Nat.add(start,1n+rest),N.add_succ_right(start,rest))))),
        skip_emitted(S.at(rows,start),start,target,S.enumerate_rows(rest,1n+start,rows,T.Any{}),I.at_key(rows,start),I.lt_not_eq(start,target,later)))

# A structural interval relation avoids copying an affine callback proof.
def Slots(fuel: Nat, +start: Nat, +left: List<&2,T.Row>, +right: List<&2,T.Row>) -> Type:
  match fuel:
    case 0n: Unit
    case 1n+rest: {S.at(left,start) == S.at(right,start) : Maybe<&2,T.Row>} & Slots(rest,1n+start,left,right)

# Build pointwise inverse evidence throughout a subinterval of one materialization.
def enumerated_slots(+remaining: Nat, +start: Nat, +total: Nat, +origin: Nat, +rows: List<&2,T.Row>,
  +lo: {True{} == Nat.is_le(origin,start) : Bool},
  +upper: {True{} == Nat.is_le(Nat.add(start,remaining),Nat.add(origin,total)) : Bool})
  -> Slots(remaining,start,rows,S.enumerate_rows(total,origin,rows,T.Any{})):
  match remaining:
    case 0n: Unit{}
    case 1n+rest:
      (lookup_inside(total,origin,rows,start,lo,
        N.lt_le_trans(start,Nat.add(start,1n+rest),Nat.add(origin,total),N.positive_endpoint(start,rest),upper)),
       enumerated_slots(rest,1n+start,total,origin,rows,N.le_succ_right(origin,start,lo),
         Equal.trans(Bool,True{},Nat.is_le(Nat.add(start,1n+rest),Nat.add(origin,total)),Nat.is_le(Nat.add(1n+start,rest),Nat.add(origin,total)),upper,
           Equal.cong(Nat,Bool,n => Nat.is_le(n,Nat.add(origin,total)),Nat.add(start,1n+rest),Nat.add(1n+start,rest),
             Equal.sym(Nat,Nat.add(1n+start,rest),Nat.add(start,1n+rest),N.add_succ_right(start,rest))))))

# Independent enumeration is congruent over the interval's actual lookup relation.
def related_enumerations(+fuel: Nat, +start: Nat, +left: List<&2,T.Row>, +right: List<&2,T.Row>, +selection: T.Selection,
  relation: Slots(fuel,start,left,right))
  -> {S.enumerate_rows(fuel,start,left,selection) == S.enumerate_rows(fuel,start,right,selection) : List<&2,T.Row>}:
  match fuel relation:
    case 0n _: {==}
    case 1n+rest Tuple{head,tail}:
      %head : {S.query_at(selection,S.at(left,start),S.enumerate_rows(rest,1n+start,left,selection))
        == S.query_at(selection,_,S.enumerate_rows(rest,1n+start,right,selection)) : List<&2,T.Row>}
      %related_enumerations(rest,1n+start,left,right,selection,tail) :
        {S.query_at(selection,S.at(left,start),S.enumerate_rows(rest,1n+start,left,selection)) == S.query_at(selection,S.at(left,start),_) : List<&2,T.Row>}
      {==}

# Materializing Any rows does not alter any subsequent same-interval selection.
def enumeration_stable(+fuel: Nat, +start: Nat, +rows: List<&2,T.Row>, +selection: T.Selection)
  -> {S.enumerate_rows(fuel,start,rows,selection)
    == S.enumerate_rows(fuel,start,S.enumerate_rows(fuel,start,rows,T.Any{}),selection) : List<&2,T.Row>}:
  related_enumerations(fuel,start,rows,S.enumerate_rows(fuel,start,rows,T.Any{}),selection,
    enumerated_slots(fuel,start,fuel,start,rows,N.le_reflexive(start),N.le_reflexive(Nat.add(start,fuel))))

# Same public independent observation after canonical Any materialization.
def observation_stable(+id: Nat, +next: Nat, +rows: List<&2,T.Row>, +pending: List<&2,T.Command>)
  -> {S.observe(T.World{id,next,rows,pending})
    == S.observe(T.World{id,next,S.enumerate_rows(next,0n,rows,T.Any{}),pending}) : T.Observation}:
  %enumeration_stable(next,0n,rows,T.Any{}) :
    {T.Observation{id,next,S.enumerate_rows(next,0n,rows,T.Any{}),pending}
      == T.Observation{id,next,_,pending} : T.Observation}
  {==}

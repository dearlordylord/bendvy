import Base
import ./helpers.bend as H
import ./invariants.bend as I
import ./intervals.bend as X
import ./order.bend as N
import ./insertion.bend as J
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

# Tying comparison answers to actual key comparison, not independent fixtures.
def swapped(+order: Cmp, +id: Nat, +slot: Nat, e: {order == Nat.cmp(id,slot) : Cmp})
  -> {N.reverse_cmp(order) == Nat.cmp(slot,id) : Cmp}:
  Equal.trans(Cmp,N.reverse_cmp(order),N.reverse_cmp(Nat.cmp(id,slot)),Nat.cmp(slot,id),
    Equal.cong(Cmp,Cmp,o => N.reverse_cmp(o),order,Nat.cmp(id,slot),e),N.cmp_reverse(id,slot))

def cmp_equal(+id: Nat, +slot: Nat, e: {EQ{} == Nat.cmp(id,slot) : Cmp}) -> {id == slot : Nat}:
  I.eq_reflect(id,slot,Equal.cong(Cmp,Bool,o => Cmp.is_eq(o),EQ{},Nat.cmp(id,slot),e))

def cmp_greater(+id: Nat, +slot: Nat, e: {GT{} == Nat.cmp(id,slot) : Cmp}) -> {True{} == Nat.is_lt(slot,id) : Bool}:
  Equal.cong(Cmp,Bool,o => Cmp.is_lt(o),LT{},Nat.cmp(slot,id),swapped(GT{},id,slot,e))

def cmp_less_lower_false(+id: Nat, +slot: Nat, e: {LT{} == Nat.cmp(id,slot) : Cmp}) -> {False{} == Nat.is_le(slot,id) : Bool}:
  Equal.cong(Cmp,Bool,o => Cmp.is_le(o),GT{},Nat.cmp(slot,id),swapped(LT{},id,slot,e))

# Positive-fuel step, carrying the recursive interval equality as real evidence.
def insert_step(order: Cmp, +rest: Nat, +slot: Nat, +id: Nat, +value: Nat, +tag: Bool,
  +tail: List<&2,T.Row>, +selection: T.Selection, +e: {order == Nat.cmp(id,slot) : Cmp},
  lo: {True{} == Nat.is_le(slot,id) : Bool}, hi: {True{} == Nat.is_lt(id,Nat.add(slot,1n+rest)) : Bool},
  hz: {0n == S.count(tail,id) : Nat},
  ih: {True{} == Nat.is_le(1n+slot,id) : Bool} -> {True{} == Nat.is_lt(id,Nat.add(1n+slot,rest)) : Bool}
    -> {M.include(M.accepts(selection,tag),T.Row{id,value,tag},S.enumerate_rows(rest,1n+slot,tail,selection))
      == S.enumerate_rows(rest,1n+slot,T.Row{id,value,tag} <> tail,selection) : List<&2,T.Row>})
  -> {M.include(M.accepts(selection,tag),T.Row{id,value,tag},S.enumerate_rows(1n+rest,slot,tail,selection))
    == S.enumerate_rows(1n+rest,slot,T.Row{id,value,tag} <> tail,selection) : List<&2,T.Row>}:
  match order:
    case LT{}:
      Empty.absurd({M.include(M.accepts(selection,tag),T.Row{id,value,tag},S.enumerate_rows(1n+rest,slot,tail,selection))
        == S.enumerate_rows(1n+rest,slot,T.Row{id,value,tag} <> tail,selection) : List<&2,T.Row>},
        H.false_true_absurd(Equal.trans(Bool,False{},Nat.is_le(slot,id),True{},cmp_less_lower_false(id,slot,e),Equal.sym(Bool,True{},Nat.is_le(slot,id),lo))))
    case EQ{}:
      %Equal.sym(Nat,id,slot,cmp_equal(id,slot,e)) :
        {M.include(M.accepts(selection,tag),T.Row{_,value,tag},S.enumerate_rows(1n+rest,slot,tail,selection))
          == S.enumerate_rows(1n+rest,slot,T.Row{_,value,tag} <> tail,selection) : List<&2,T.Row>}
      J.insert_at_slot(rest,slot,value,tag,tail,selection,
        Equal.trans(Nat,0n,S.count(tail,id),S.count(tail,slot),hz,
          Equal.cong(Nat,Nat,n => S.count(tail,n),id,slot,cmp_equal(id,slot,e))))
    case GT{}:
      +later = cmp_greater(id,slot,e)
      %X.skip_head(id,value,tag,tail,slot,
        Equal.trans(Bool,False{},Nat.is_eq(slot,id),Nat.is_eq(id,slot),I.lt_not_eq(slot,id,later),I.eq_symmetric(slot,id))) :
        {M.include(M.accepts(selection,tag),T.Row{id,value,tag},S.query_at(selection,S.at(tail,slot),S.enumerate_rows(rest,1n+slot,tail,selection)))
          == S.query_at(selection,_,S.enumerate_rows(rest,1n+slot,T.Row{id,value,tag} <> tail,selection)) : List<&2,T.Row>}
      %ih(N.lt_succ_le(slot,id,later),
        Equal.trans(Bool,True{},Nat.is_lt(id,Nat.add(slot,1n+rest)),Nat.is_lt(id,Nat.add(1n+slot,rest)),hi,
          Equal.cong(Nat,Bool,n => Nat.is_lt(id,n),Nat.add(slot,1n+rest),Nat.add(1n+slot,rest),
            Equal.sym(Nat,Nat.add(1n+slot,rest),Nat.add(slot,1n+rest),N.add_succ_right(slot,rest))))) :
        {M.include(M.accepts(selection,tag),T.Row{id,value,tag},S.query_at(selection,S.at(tail,slot),S.enumerate_rows(rest,1n+slot,tail,selection)))
          == S.query_at(selection,S.at(tail,slot),_) : List<&2,T.Row>}
      J.commute_at(S.at(tail,slot),selection,slot,id,value,tag,S.enumerate_rows(rest,1n+slot,tail,selection),I.at_key(tail,slot),later)

# General interval theorem: keys inside the interval, absent in the tail.
def insert_interval(+fuel: Nat, +slot: Nat, +id: Nat, +value: Nat, +tag: Bool,
  +tail: List<&2,T.Row>, +selection: T.Selection,
  lo: {True{} == Nat.is_le(slot,id) : Bool}, hi: {True{} == Nat.is_lt(id,Nat.add(slot,fuel)) : Bool},
  +hz: {0n == S.count(tail,id) : Nat})
  -> {M.include(M.accepts(selection,tag),T.Row{id,value,tag},S.enumerate_rows(fuel,slot,tail,selection))
    == S.enumerate_rows(fuel,slot,T.Row{id,value,tag} <> tail,selection) : List<&2,T.Row>}:
  match fuel:
    case 0n:
      hi_slot = Equal.trans(Bool,True{},Nat.is_lt(id,Nat.add(slot,0n)),Nat.is_lt(id,slot),hi,
        Equal.cong(Nat,Bool,n => Nat.is_lt(id,n),Nat.add(slot,0n),slot,
          Equal.sym(Nat,slot,Nat.add(slot,0n),I.add_zero(slot))))
      Empty.absurd({M.include(M.accepts(selection,tag),T.Row{id,value,tag},[]) == [] : List<&2,T.Row>},
        I.le_lt_cycle(slot,id,lo,hi_slot))
    case 1n+rest:
      insert_step(Nat.cmp(id,slot),rest,slot,id,value,tag,tail,selection,{==},lo,hi,hz,
        lower => upper => insert_interval(rest,1n+slot,id,value,tag,tail,selection,lower,upper,hz))

# Checked final cons composition: the insertion proof remains required input.
def rows_cons_from_insert(+id: Nat, +value: Nat, +tag: Bool, +tail: List<&2,T.Row>, +next: Nat, +selection: T.Selection,
  ht: {M.query_rows(selection,tail) == S.enumerate_rows(next,0n,tail,selection) : List<&2,T.Row>},
  hi: {M.include(M.accepts(selection,tag),T.Row{id,value,tag},S.enumerate_rows(next,0n,tail,selection))
    == S.enumerate_rows(next,0n,T.Row{id,value,tag} <> tail,selection) : List<&2,T.Row>})
  -> {M.query_rows(selection,T.Row{id,value,tag} <> tail) == S.enumerate_rows(next,0n,T.Row{id,value,tag} <> tail,selection) : List<&2,T.Row>}:
  %Equal.sym(List<&2,T.Row>,M.query_rows(selection,tail),S.enumerate_rows(next,0n,tail,selection),ht) :
    {M.include(M.accepts(selection,tag),T.Row{id,value,tag},_) == S.enumerate_rows(next,0n,T.Row{id,value,tag} <> tail,selection) : List<&2,T.Row>}
  hi

# Concrete [0,next) specialization supplied to the list induction.
def insert_enumeration(+next: Nat, +id: Nat, +value: Nat, +tag: Bool,
  +tail: List<&2,T.Row>, +selection: T.Selection,
  hi: {True{} == Nat.is_lt(id,next) : Bool}, hz: {0n == S.count(tail,id) : Nat})
  -> {M.include(M.accepts(selection,tag),T.Row{id,value,tag},S.enumerate_rows(next,0n,tail,selection))
    == S.enumerate_rows(next,0n,T.Row{id,value,tag} <> tail,selection) : List<&2,T.Row>}:
  insert_interval(next,0n,id,value,tag,tail,selection,I.zero_le(id),hi,hz)

# The original domain is retained; the changed-all tail premise is now derived.
def rows_complete(+rows: List<&2,T.Row>, +next: Nat, +selection: T.Selection,
  +h: {True{} == S.rows_valid(rows,rows,next) : Bool})
  -> {M.query_rows(selection,rows) == S.enumerate_rows(next,0n,rows,selection) : List<&2,T.Row>}:
  match rows:
    case Nil{}: H.enumerate_empty(next,0n,selection)
    case Con{T.Row{+id,+value,+tag},+tail}:
      rows_cons_from_insert(id,value,tag,tail,next,selection,
        rows_complete(tail,next,selection,I.valid_tail(id,value,tag,tail,next,h)),
      insert_enumeration(next,id,value,tag,tail,selection,
        H.and_left(Nat.is_lt(id,next),S.rows_valid(tail,T.Row{id,value,tag} <> tail,next),
          H.and_right(Nat.is_eq(S.count(T.Row{id,value,tag} <> tail,id),1n),Bool.and(Nat.is_lt(id,next),S.rows_valid(tail,T.Row{id,value,tag} <> tail,next)),h)),
        H.unique_head_tail_zero(id,value,tag,tail,Equal.sym(Nat,S.count(T.Row{id,value,tag} <> tail,id),1n,
          I.eq_reflect(S.count(T.Row{id,value,tag} <> tail,id),1n,
            H.and_left(Nat.is_eq(S.count(T.Row{id,value,tag} <> tail,id),1n),Bool.and(Nat.is_lt(id,next),S.rows_valid(tail,T.Row{id,value,tag} <> tail,next)),h))))))

# Pass the computed guard as a parameter with a definitional tying equality.
def guarded(guard: Bool, +limit: Nat, +id: Nat, +next: Nat, +rows: List<&2,T.Row>,
  +pending: List<&2,T.Command>, +selection: T.Selection,
  e: {guard == S.admissible(limit,T.World{id,next,rows,pending}) : Bool})
  -> S.When(guard,{M.query_rows(selection,rows) == S.enumerate_rows(next,0n,rows,selection) : List<&2,T.Row>}):
  match guard:
    case False{}: Unit{}
    case True{}:
      rows_complete(rows,next,selection,
        H.and_left(S.rows_valid(rows,rows,next),S.pending_valid(pending,pending,rows,next),
          H.and_right(Nat.is_le(next,limit),Bool.and(S.rows_valid(rows,rows,next),S.pending_valid(pending,pending,rows,next)),e)))


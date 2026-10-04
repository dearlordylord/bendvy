import Base
import ./helpers.bend as H
import ./invariants.bend as I
import ./intervals.bend as X
import ./order.bend as N
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

# Inserting an earlier key before one actual emitted row.
def before_emit(ok: Bool, +id: Nat, +value: Nat, +tag: Bool, +key: Nat, +v: Nat, +t: Bool, +body: List<&2,T.Row>,
  h: {True{} == Nat.is_lt(id,key) : Bool},
  ih: {T.Row{id,value,tag} <> body == M.insert_sorted(body,T.Row{id,value,tag}) : List<&2,T.Row>})
  -> {T.Row{id,value,tag} <> S.emit(ok,T.Row{key,v,t},body) == M.insert_sorted(S.emit(ok,T.Row{key,v,t},body),T.Row{id,value,tag}) : List<&2,T.Row>}:
  match ok:
    case False{}: ih
    case True{}:
      %h : {T.Row{id,value,tag} <> T.Row{key,v,t} <> body == M.insert_sorted_if(_,T.Row{id,value,tag},T.Row{key,v,t},body,r => M.insert_sorted(body,r)) : List<&2,T.Row>}
      {==}

def before_at(+result: Maybe<&2,T.Row>, +selection: T.Selection, +slot: Nat,
  +id: Nat, +value: Nat, +tag: Bool, +body: List<&2,T.Row>, key: I.AtKey(result,slot),
  h: {True{} == Nat.is_lt(id,slot) : Bool},
  ih: {T.Row{id,value,tag} <> body == M.insert_sorted(body,T.Row{id,value,tag}) : List<&2,T.Row>})
  -> {T.Row{id,value,tag} <> S.query_at(selection,result,body) == M.insert_sorted(S.query_at(selection,result,body),T.Row{id,value,tag}) : List<&2,T.Row>}:
  match result:
    case None{}: ih
    case Some{T.Row{+k,+v,+t}}:
      before_emit(S.eligible(selection,t),id,value,tag,k,v,t,body,
        Equal.trans(Bool,True{},Nat.is_lt(id,slot),Nat.is_lt(id,k),h,
          Equal.cong(Nat,Bool,n => Nat.is_lt(id,n),slot,k,Equal.sym(Nat,k,slot,I.eq_reflect(k,slot,key)))),ih)

# Ordered insertion before all rows in a later logical enumeration interval.
def before_enumeration(+fuel: Nat, +slot: Nat, +rows: List<&2,T.Row>, +selection: T.Selection,
  +id: Nat, +value: Nat, +tag: Bool, +h: {True{} == Nat.is_lt(id,slot) : Bool})
  -> {T.Row{id,value,tag} <> S.enumerate_rows(fuel,slot,rows,selection)
    == M.insert_sorted(S.enumerate_rows(fuel,slot,rows,selection),T.Row{id,value,tag}) : List<&2,T.Row>}:
  match fuel:
    case 0n: {==}
    case 1n+rest:
      before_at(S.at(rows,slot),selection,slot,id,value,tag,S.enumerate_rows(rest,1n+slot,rows,selection),
        I.at_key(rows,slot),h,before_enumeration(rest,1n+slot,rows,selection,id,value,tag,I.lt_succ_right(id,slot,h)))

# Insertion at a later key commutes with an earlier actual emitted row.
def commute_emit(head_ok: Bool, row_ok: Bool, +id: Nat, +value: Nat, +tag: Bool,
  +key: Nat, +v: Nat, +t: Bool, +body: List<&2,T.Row>, h: {False{} == Nat.is_lt(id,key) : Bool})
  -> {M.include(head_ok,T.Row{id,value,tag},S.emit(row_ok,T.Row{key,v,t},body))
    == S.emit(row_ok,T.Row{key,v,t},M.include(head_ok,T.Row{id,value,tag},body)) : List<&2,T.Row>}:
  match head_ok row_ok:
    case False{} False{}: {==}
    case False{} True{}: {==}
    case True{} False{}: {==}
    case True{} True{}:
      %h : {M.insert_sorted_if(_,T.Row{id,value,tag},T.Row{key,v,t},body,r => M.insert_sorted(body,r)) == T.Row{key,v,t} <> M.insert_sorted(body,T.Row{id,value,tag}) : List<&2,T.Row>}
      {==}

def commute_at(+result: Maybe<&2,T.Row>, +selection: T.Selection, +slot: Nat,
  +id: Nat, +value: Nat, +tag: Bool, +body: List<&2,T.Row>, key: I.AtKey(result,slot),
  h: {True{} == Nat.is_lt(slot,id) : Bool})
  -> {M.include(M.accepts(selection,tag),T.Row{id,value,tag},S.query_at(selection,result,body))
    == S.query_at(selection,result,M.include(M.accepts(selection,tag),T.Row{id,value,tag},body)) : List<&2,T.Row>}:
  match result:
    case None{}: {==}
    case Some{T.Row{+k,+v,+t}}:
      commute_emit(M.accepts(selection,tag),S.eligible(selection,t),id,value,tag,k,v,t,body,
        Equal.trans(Bool,False{},Nat.is_lt(id,slot),Nat.is_lt(id,k),N.opposite_lt(slot,id,h),
          Equal.cong(Nat,Bool,n => Nat.is_lt(id,n),slot,k,Equal.sym(Nat,k,slot,I.eq_reflect(k,slot,key)))))

# Exact-slot insertion, with tag selection retaining its actual model decision.
def include_prepend(ok: Bool, +id: Nat, +value: Nat, +tag: Bool, +body: List<&2,T.Row>,
  h: {T.Row{id,value,tag} <> body == M.insert_sorted(body,T.Row{id,value,tag}) : List<&2,T.Row>})
  -> {M.include(ok,T.Row{id,value,tag},body) == S.emit(ok,T.Row{id,value,tag},body) : List<&2,T.Row>}:
  match ok:
    case False{}: {==}
    case True{}: Equal.sym(List<&2,T.Row>,T.Row{id,value,tag} <> body,M.insert_sorted(body,T.Row{id,value,tag}),h)

def insert_at_slot(+rest: Nat, +slot: Nat, +value: Nat, +tag: Bool, +tail: List<&2,T.Row>, +selection: T.Selection,
  hz: {0n == S.count(tail,slot) : Nat})
  -> {M.include(M.accepts(selection,tag),T.Row{slot,value,tag},S.enumerate_rows(1n+rest,slot,tail,selection))
    == S.enumerate_rows(1n+rest,slot,T.Row{slot,value,tag} <> tail,selection) : List<&2,T.Row>}:
  %H.cmp_reflexive(slot) :
    {M.include(M.accepts(selection,tag),T.Row{slot,value,tag},S.enumerate_rows(1n+rest,slot,tail,selection))
      == S.query_at(selection,S.pick(_,T.Row{slot,value,tag},_ => S.at(tail,slot)),S.enumerate_rows(rest,1n+slot,T.Row{slot,value,tag} <> tail,selection)) : List<&2,T.Row>}
  %H.at_count_zero(tail,slot,hz) :
    {M.include(M.accepts(selection,tag),T.Row{slot,value,tag},S.query_at(selection,_,S.enumerate_rows(rest,1n+slot,tail,selection)))
      == S.query_at(selection,Some{T.Row{slot,value,tag}},S.enumerate_rows(rest,1n+slot,T.Row{slot,value,tag} <> tail,selection)) : List<&2,T.Row>}
  %X.enumerate_after(rest,1n+slot,slot,value,tag,tail,selection,N.lt_self_succ(slot)) :
    {M.include(M.accepts(selection,tag),T.Row{slot,value,tag},S.enumerate_rows(rest,1n+slot,tail,selection))
      == S.query_at(selection,Some{T.Row{slot,value,tag}},_) : List<&2,T.Row>}
  %I.eligibility(selection,tag) :
    {M.include(M.accepts(selection,tag),T.Row{slot,value,tag},S.enumerate_rows(rest,1n+slot,tail,selection))
      == S.emit(_,T.Row{slot,value,tag},S.enumerate_rows(rest,1n+slot,tail,selection)) : List<&2,T.Row>}
  include_prepend(M.accepts(selection,tag),slot,value,tag,S.enumerate_rows(rest,1n+slot,tail,selection),
    before_enumeration(rest,1n+slot,tail,selection,slot,value,tag,N.lt_self_succ(slot)))

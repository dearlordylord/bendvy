import Base
import ./helpers.bend as H
import ./invariants.bend as I
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

# A known nonmatching head does not change the actual independent lookup.
def skip_pick(order: Cmp, +row: T.Row, +tail: Maybe<&2,T.Row>,
  h: {False{} == Cmp.is_eq(order) : Bool})
  -> {tail == S.pick(order,row,_ => tail) : Maybe<&2,T.Row>}:
  match order:
    case EQ{}: Empty.absurd({tail == Some{row} : Maybe<&2,T.Row>},H.false_true_absurd(h))
    case LT{}: {==}
    case GT{}: {==}

def skip_head(+id: Nat, +value: Nat, +tag: Bool, +tail: List<&2,T.Row>, +slot: Nat,
  h: {False{} == Nat.is_eq(id,slot) : Bool})
  -> {S.at(tail,slot) == S.at(T.Row{id,value,tag} <> tail,slot) : Maybe<&2,T.Row>}:
  skip_pick(Nat.cmp(id,slot),T.Row{id,value,tag},S.at(tail,slot),h)

# General outside-lower-bound case; arbitrary tail rows, payloads and selection.
def enumerate_after(fuel: Nat, +slot: Nat, +id: Nat, +value: Nat, +tag: Bool,
  +tail: List<&2,T.Row>, +selection: T.Selection,
  +h: {True{} == Nat.is_lt(id,slot) : Bool})
  -> {S.enumerate_rows(fuel,slot,tail,selection)
    == S.enumerate_rows(fuel,slot,T.Row{id,value,tag} <> tail,selection) : List<&2,T.Row>}:
  match fuel:
    case 0n: {==}
    case 1n+rest:
      %skip_head(id,value,tag,tail,slot,I.lt_not_eq(id,slot,h)) :
        {S.query_at(selection,S.at(tail,slot),S.enumerate_rows(rest,1n+slot,tail,selection))
          == S.query_at(selection,_,S.enumerate_rows(rest,1n+slot,T.Row{id,value,tag} <> tail,selection)) : List<&2,T.Row>}
      %enumerate_after(rest,1n+slot,id,value,tag,tail,selection,I.lt_succ_right(id,slot,h)) :
        {S.query_at(selection,S.at(tail,slot),S.enumerate_rows(rest,1n+slot,tail,selection))
          == S.query_at(selection,S.at(tail,slot),_) : List<&2,T.Row>}
      {==}

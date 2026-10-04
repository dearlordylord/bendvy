import Base
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S
import ./coherence.bend as C
import ../p-observe-queries/enum-lookup.bend as E

# No uniqueness/bounds premise: pointwise FIFO observation connects the oracle's
# per-slot materialization to enumeration of actual whole-list application.
def materialize_enumeration(+fuel: Nat, +slot: Nat, +rows: List<&2,T.Row>, +pending: List<&2,T.Command>) -> {S.materialize(fuel,slot,rows,pending) == S.enumerate_rows(fuel,slot,M.apply_all(pending,rows),T.Any{}) : List<&2,T.Row>}:
  match fuel:
    case 0n: {==}
    case 1n+rest:
      %C.mixed_fifo_slot(pending,rows,slot) : {S.query_at(T.Any{},_,S.materialize(rest,1n+slot,rows,pending)) == S.query_at(T.Any{},S.at(M.apply_all(pending,rows),slot),S.enumerate_rows(rest,1n+slot,M.apply_all(pending,rows),T.Any{})) : List<&2,T.Row>}
      Equal.cong(List<&2,T.Row>,List<&2,T.Row>,tail => S.query_at(T.Any{},S.at(M.apply_all(pending,rows),slot),tail),S.materialize(rest,1n+slot,rows,pending),S.enumerate_rows(rest,1n+slot,M.apply_all(pending,rows),T.Any{}),materialize_enumeration(rest,1n+slot,rows,pending))


# General pointwise materialization inverse for schedule Barrier composition.
def materialize_inside(+fuel: Nat, +start: Nat, +rows: List<&2,T.Row>, +pending: List<&2,T.Command>, +target: Nat, lo: {True{} == Nat.is_le(start,target) : Bool}, hi: {True{} == Nat.is_lt(target,Nat.add(start,fuel)) : Bool}) -> {S.at(S.materialize(fuel,start,rows,pending),target) == S.replay(pending,target,S.at(rows,target)) : Maybe<&2,T.Row>}:
  Equal.trans(Maybe<&2,T.Row>,S.at(S.materialize(fuel,start,rows,pending),target),S.at(M.apply_all(pending,rows),target),S.replay(pending,target,S.at(rows,target)),Equal.trans(Maybe<&2,T.Row>,S.at(S.materialize(fuel,start,rows,pending),target),S.at(S.enumerate_rows(fuel,start,M.apply_all(pending,rows),T.Any{}),target),S.at(M.apply_all(pending,rows),target),Equal.cong(List<&2,T.Row>,Maybe<&2,T.Row>,source => S.at(source,target),S.materialize(fuel,start,rows,pending),S.enumerate_rows(fuel,start,M.apply_all(pending,rows),T.Any{}),materialize_enumeration(fuel,start,rows,pending)),Equal.sym(Maybe<&2,T.Row>,S.at(M.apply_all(pending,rows),target),S.at(S.enumerate_rows(fuel,start,M.apply_all(pending,rows),T.Any{}),target),E.lookup_inside(fuel,start,M.apply_all(pending,rows),target,lo,hi))),C.mixed_fifo_slot(pending,rows,target))

def materialize_above(+fuel: Nat, +start: Nat, +rows: List<&2,T.Row>, +pending: List<&2,T.Command>, +target: Nat, hi: {True{} == Nat.is_le(Nat.add(start,fuel),target) : Bool}) -> {None{} == S.at(S.materialize(fuel,start,rows,pending),target) : Maybe<&2,T.Row>}:
  Equal.trans(Maybe<&2,T.Row>,None{},S.at(S.enumerate_rows(fuel,start,M.apply_all(pending,rows),T.Any{}),target),S.at(S.materialize(fuel,start,rows,pending),target),E.lookup_above(fuel,start,M.apply_all(pending,rows),target,hi),Equal.sym(Maybe<&2,T.Row>,S.at(S.materialize(fuel,start,rows,pending),target),S.at(S.enumerate_rows(fuel,start,M.apply_all(pending,rows),T.Any{}),target),Equal.cong(List<&2,T.Row>,Maybe<&2,T.Row>,source => S.at(source,target),S.materialize(fuel,start,rows,pending),S.enumerate_rows(fuel,start,M.apply_all(pending,rows),T.Any{}),materialize_enumeration(fuel,start,rows,pending))))

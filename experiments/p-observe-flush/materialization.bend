import Base
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S
import ./coherence.bend as C

# No uniqueness/bounds premise: pointwise FIFO observation connects the oracle's
# per-slot materialization to enumeration of actual whole-list application.
def materialize_enumeration(+fuel: Nat, +slot: Nat, +rows: List<&2,T.Row>, +pending: List<&2,T.Command>) -> {S.materialize(fuel,slot,rows,pending) == S.enumerate_rows(fuel,slot,M.apply_all(pending,rows),T.Any{}) : List<&2,T.Row>}:
  match fuel:
    case 0n: {==}
    case 1n+rest:
      %C.mixed_fifo_slot(pending,rows,slot) : {S.query_at(T.Any{},_,S.materialize(rest,1n+slot,rows,pending)) == S.query_at(T.Any{},S.at(M.apply_all(pending,rows),slot),S.enumerate_rows(rest,1n+slot,M.apply_all(pending,rows),T.Any{})) : List<&2,T.Row>}
      Equal.cong(List<&2,T.Row>,List<&2,T.Row>,tail => S.query_at(T.Any{},S.at(M.apply_all(pending,rows),slot),tail),S.materialize(rest,1n+slot,rows,pending),S.enumerate_rows(rest,1n+slot,M.apply_all(pending,rows),T.Any{}),materialize_enumeration(rest,1n+slot,rows,pending))

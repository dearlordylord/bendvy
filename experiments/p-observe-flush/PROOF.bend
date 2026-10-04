import Base
import ./LAWS.bend as Laws
import ./RESIDUAL.bend as R
import ./prefix.bend as P
import ./materialization.bend as F
import ../p-observe-queries/complete.bend as Q
import ../p-observe-queries/enum-lookup.bend as E
import ../p-observe-queries/helpers.bend as H
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

# Observational, not raw physical-list equality with materialized rows.
def flush_rows(+next: Nat, +rows: List<&2,T.Row>, +pending: List<&2,T.Command>, hr: {True{} == S.rows_valid(rows,rows,next) : Bool}, hp: {True{} == S.pending_valid(pending,pending,rows,next) : Bool}) -> {M.query_rows(T.Any{},M.apply_all(pending,rows)) == S.enumerate_rows(next,0n,S.materialize(next,0n,rows,pending),T.Any{}) : List<&2,T.Row>}:
  %Equal.sym(List<&2,T.Row>,S.materialize(next,0n,rows,pending),S.enumerate_rows(next,0n,M.apply_all(pending,rows),T.Any{}),F.materialize_enumeration(next,0n,rows,pending)) : {M.query_rows(T.Any{},M.apply_all(pending,rows)) == S.enumerate_rows(next,0n,_,T.Any{}) : List<&2,T.Row>}
  Equal.trans(List<&2,T.Row>,M.query_rows(T.Any{},M.apply_all(pending,rows)),S.enumerate_rows(next,0n,M.apply_all(pending,rows),T.Any{}),S.enumerate_rows(next,0n,S.enumerate_rows(next,0n,M.apply_all(pending,rows),T.Any{}),T.Any{}),Q.rows_complete(M.apply_all(pending,rows),next,T.Any{},P.apply_all_rows_valid(pending,rows,next,hr,hp)),E.enumeration_stable(next,0n,M.apply_all(pending,rows),T.Any{}))

# Explicit observations keep the actual M.flush caller linked at the endpoint;
# replacing that caller with identity must break its own filled law section.
def guarded(guard: Bool, +limit: Nat, +id: Nat, +next: Nat, +rows: List<&2,T.Row>, +pending: List<&2,T.Command>, e: {guard == S.admissible(limit,T.World{id,next,rows,pending}) : Bool}) -> S.When(guard,{T.Observation{id,next,M.query_rows(T.Any{},M.apply_all(pending,rows)),[]} == T.Observation{id,next,S.enumerate_rows(next,0n,S.materialize(next,0n,rows,pending),T.Any{}),[]} : T.Observation}):
  match guard:
    case False{}: Unit{}
    case True{}:
      +valid = H.and_right(Nat.is_le(next,limit),Bool.and(S.rows_valid(rows,rows,next),S.pending_valid(pending,pending,rows,next)),e)
      Equal.cong(List<&2,T.Row>,T.Observation,result => T.Observation{id,next,result,[]},M.query_rows(T.Any{},M.apply_all(pending,rows)),S.enumerate_rows(next,0n,S.materialize(next,0n,rows,pending),T.Any{}),flush_rows(next,rows,pending,H.and_left(S.rows_valid(rows,rows,next),S.pending_valid(pending,pending,rows,next),valid),H.and_right(S.rows_valid(rows,rows,next),S.pending_valid(pending,pending,rows,next),valid)))

def Laws.explicit_flush_independent(limit,world):
  match world:
    case T.World{+id,+next,+rows,+pending}:
      guarded(S.admissible(limit,T.World{id,next,rows,pending}),limit,id,next,rows,pending,{==})


# Discharge the earlier endpoint-local residual at its original exact domain.
def guarded_rows(guard: Bool, +limit: Nat, +next: Nat, +rows: List<&2,T.Row>, +pending: List<&2,T.Command>, e: {guard == S.admissible(limit,T.World{0n,next,rows,pending}) : Bool}) -> S.When(guard,{M.query_rows(T.Any{},M.apply_all(pending,rows)) == S.enumerate_rows(next,0n,S.materialize(next,0n,rows,pending),T.Any{}) : List<&2,T.Row>}):
  match guard:
    case False{}: Unit{}
    case True{}:
      +valid = H.and_right(Nat.is_le(next,limit),Bool.and(S.rows_valid(rows,rows,next),S.pending_valid(pending,pending,rows,next)),e)
      flush_rows(next,rows,pending,H.and_left(S.rows_valid(rows,rows,next),S.pending_valid(pending,pending,rows,next),valid),H.and_right(S.rows_valid(rows,rows,next),S.pending_valid(pending,pending,rows,next),valid))

def R.flush_rows_observation(limit,next,rows,pending):
  guarded_rows(S.admissible(limit,T.World{0n,next,rows,pending}),limit,next,rows,pending,{==})

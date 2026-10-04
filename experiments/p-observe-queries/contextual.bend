import Base
import ./helpers.bend as H
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

# All three exact endpoints have this checked implication-shaped decomposition.
# The explicit bridge argument is required evidence, never an axiom or TODO.
def guarded_from_rows(guard: Bool, +limit: Nat, +id: Nat, +next: Nat, +rows: List<&2,T.Row>,
  +pending: List<&2,T.Command>, +selection: T.Selection,
  e: {guard == S.admissible(limit,T.World{id,next,rows,pending}) : Bool},
  bridge: {True{} == S.rows_valid(rows,rows,next) : Bool}
    -> {M.query_rows(selection,rows) == S.enumerate_rows(next,0n,rows,selection) : List<&2,T.Row>})
  -> S.When(guard,{M.query(T.World{id,next,rows,pending},selection) == S.query(T.World{id,next,rows,pending},selection) : List<&2,T.Row>}):
  match guard:
    case False{}: Unit{}
    case True{}:
      bridge(H.and_left(S.rows_valid(rows,rows,next),S.pending_valid(pending,pending,rows,next),
        H.and_right(Nat.is_le(next,limit),Bool.and(S.rows_valid(rows,rows,next),S.pending_valid(pending,pending,rows,next)),e)))

# Universal specialization only: arbitrary namespace/frontier/pending/selection,
# but empty physical rows. It is not a proof of any complete endpoint above.
def empty_world(+limit: Nat, +id: Nat, +next: Nat, +pending: List<&2,T.Command>, +selection: T.Selection)
  -> S.When(S.admissible(limit,T.World{id,next,[],pending}),
    {M.query(T.World{id,next,[],pending},selection) == S.query(T.World{id,next,[],pending},selection) : List<&2,T.Row>}):
  H.when_known(S.admissible(limit,T.World{id,next,[],pending}),
    {M.query(T.World{id,next,[],pending},selection) == S.query(T.World{id,next,[],pending},selection) : List<&2,T.Row>},
    H.enumerate_empty(next,0n,selection))

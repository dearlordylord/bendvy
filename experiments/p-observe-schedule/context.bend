import Base
import ./allocation.bend as A
import ./invariants.bend as I
import ./relation.bend as R
import ../p-observe-queries/helpers.bend as H
import ../p-observe-queries/invariants.bend as Q
import ../p-observe-queries/order.bend as N
import ../p-observe-queries/complete.bend as C
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

# Exact witnesses extracted from the initial/intermediate independent guard.
def frontier_bound(+limit: Nat, +id: Nat, +next: Nat, +rows: List<&2,T.Row>, +pending: List<&2,T.Command>,
  valid: {True{} == S.admissible(limit,T.World{id,next,rows,pending}) : Bool})
  -> {True{} == Nat.is_le(next,limit) : Bool}:
  H.and_left(Nat.is_le(next,limit),Bool.and(S.rows_valid(rows,rows,next),S.pending_valid(pending,pending,rows,next)),valid)

def live_valid(+limit: Nat, +id: Nat, +next: Nat, +rows: List<&2,T.Row>, +pending: List<&2,T.Command>,
  valid: {True{} == S.admissible(limit,T.World{id,next,rows,pending}) : Bool})
  -> {True{} == S.rows_valid(rows,rows,next) : Bool}:
  H.and_left(S.rows_valid(rows,rows,next),S.pending_valid(pending,pending,rows,next),
    H.and_right(Nat.is_le(next,limit),Bool.and(S.rows_valid(rows,rows,next),S.pending_valid(pending,pending,rows,next)),valid))

def queue_valid(+limit: Nat, +id: Nat, +next: Nat, +rows: List<&2,T.Row>, +pending: List<&2,T.Command>,
  valid: {True{} == S.admissible(limit,T.World{id,next,rows,pending}) : Bool})
  -> {True{} == S.pending_valid(pending,pending,rows,next) : Bool}:
  H.and_right(S.rows_valid(rows,rows,next),S.pending_valid(pending,pending,rows,next),
    H.and_right(Nat.is_le(next,limit),Bool.and(S.rows_valid(rows,rows,next),S.pending_valid(pending,pending,rows,next)),valid))

# Successful Reserve only: the decision's strict bound is explicit evidence.
def reserve_success(+limit: Nat, +id: Nat, +next: Nat, +rows: List<&2,T.Row>, +pending: List<&2,T.Command>, +value: Nat,
  +valid: {True{} == S.admissible(limit,T.World{id,next,rows,pending}) : Bool}, accepts: {True{} == Nat.is_lt(next,limit) : Bool})
  -> {True{} == S.admissible(limit,T.World{id,1n+next,rows,List.append(&2,T.Command,pending,[T.Spawn{next,value}])}) : Bool}:
  +live = live_valid(limit,id,next,rows,pending,valid)
  +queue = queue_valid(limit,id,next,rows,pending,valid)
  Q.and_intro(Nat.is_le(1n+next,limit),Bool.and(S.rows_valid(rows,rows,1n+next),S.pending_valid(List.append(&2,T.Command,pending,[T.Spawn{next,value}]),List.append(&2,T.Command,pending,[T.Spawn{next,value}]),rows,1n+next)),
    N.lt_succ_le(next,limit,accepts),
    Q.and_intro(S.rows_valid(rows,rows,1n+next),S.pending_valid(List.append(&2,T.Command,pending,[T.Spawn{next,value}]),List.append(&2,T.Command,pending,[T.Spawn{next,value}]),rows,1n+next),
      A.reserve_rows_bound(rows,rows,next,live),
      A.reserve_pending(pending,pending,rows,next,value,queue,A.count_at_frontier(rows,rows,next,live),A.pending_count_frontier(pending,pending,rows,next,queue))))

# Authorized publication only: appending Target adds no Spawn reservations.
def publish_success(+limit: Nat, +id: Nat, +next: Nat, +rows: List<&2,T.Row>, +pending: List<&2,T.Command>, +target: Nat, +action: T.Action,
  +valid: {True{} == S.admissible(limit,T.World{id,next,rows,pending}) : Bool})
  -> {True{} == S.admissible(limit,T.World{id,next,rows,List.append(&2,T.Command,pending,[T.Target{target,action}])}) : Bool}:
  %A.publish_pending(pending,pending,rows,next,target,action) :
    {True{} == Bool.and(Nat.is_le(next,limit),Bool.and(S.rows_valid(rows,rows,next),_)) : Bool}
  valid

# Value-only Bump branch; no statement over the full Step datatype is filled.
def bump_success(+limit: Nat, +id: Nat, +next: Nat, +rows: List<&2,T.Row>, +pending: List<&2,T.Command>, +target: Nat,
  valid: {True{} == S.admissible(limit,T.World{id,next,rows,pending}) : Bool})
  -> {True{} == S.admissible(limit,T.World{id,next,M.bump_rows(target,rows),pending}) : Bool}:
  %Equal.sym(Bool,S.rows_valid(M.bump_rows(target,rows),M.bump_rows(target,rows),next),S.rows_valid(rows,rows,next),I.rows_valid_bump(rows,rows,target,next)) :
    {True{} == Bool.and(Nat.is_le(next,limit),Bool.and(_,S.pending_valid(pending,pending,M.bump_rows(target,rows),next))) : Bool}
  %Equal.sym(Bool,S.pending_valid(pending,pending,M.bump_rows(target,rows),next),S.pending_valid(pending,pending,rows,next),I.pending_valid_bump(pending,pending,rows,target,next)) :
    {True{} == Bool.and(Nat.is_le(next,limit),Bool.and(S.rows_valid(rows,rows,next),_)) : Bool}
  valid

# Actual terminal observation adequacy from the completed query theorem.
def final_observation(+limit: Nat, +id: Nat, +next: Nat, +left: List<&2,T.Row>, +right: List<&2,T.Row>, +pending: List<&2,T.Command>,
  +valid: {True{} == S.admissible(limit,T.World{id,next,left,pending}) : Bool}, related: R.Slots(limit,0n,left,right))
  -> {M.observe(T.World{id,next,left,pending}) == S.observe(T.World{id,next,right,pending}) : T.Observation}:
  Equal.cong(List<&2,T.Row>,T.Observation,rows => T.Observation{id,next,rows,pending},M.query_rows(T.Any{},left),S.enumerate_rows(next,0n,right,T.Any{}),
    Equal.trans(List<&2,T.Row>,M.query_rows(T.Any{},left),S.enumerate_rows(next,0n,left,T.Any{}),S.enumerate_rows(next,0n,right,T.Any{}),
      C.rows_complete(left,next,T.Any{},live_valid(limit,id,next,left,pending,valid)),
      R.enumerate_related(next,0n,left,right,T.Any{},R.slots_prefix(limit,next,0n,left,right,frontier_bound(limit,id,next,left,pending,valid),related))))

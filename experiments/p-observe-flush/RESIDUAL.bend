import Base
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

# command_slot and mixed_fifo_slot now have universal proofs in coherence.bend.
# The approved flush endpoint remains open until this final bridge is proved.
# Requires valid applied rows, bounded enumeration/sorting, materialized-list
# observation adequacy. This is a narrow bridge for this approved endpoint.
law flush_rows_observation:
  for +limit: Nat
  for +next: Nat
  for +rows: List<&2,T.Row>
  for +pending: List<&2,T.Command>
  S.When(S.admissible(limit,T.World{0n,next,rows,pending}), {M.query_rows(T.Any{},M.apply_all(pending,rows)) == S.enumerate_rows(next,0n,S.materialize(next,0n,rows,pending),T.Any{}) : List<&2,T.Row>})

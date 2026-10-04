import Base
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

# Unfilled contextual links; not completion of the approved flush endpoint.
# target_own_slot/spawn_slot cover parts of this statement, not mixed-slot Target.
law command_slot:
  for +command: T.Command
  for +rows: List<&2,T.Row>
  for +slot: Nat
  {S.at(M.apply(command,rows),slot) == S.one(command,slot,S.at(rows,slot)) : Maybe<&2,T.Row>}
# Requires command_slot for all intermediate physical row lists.
law mixed_fifo_slot:
  for +commands: List<&2,T.Command>
  for +rows: List<&2,T.Row>
  for +slot: Nat
  {S.at(M.apply_all(commands,rows),slot) == S.replay(commands,slot,S.at(rows,slot)) : Maybe<&2,T.Row>}
# Requires valid applied rows, bounded enumeration/sorting, materialized-list
# observation adequacy. This is a narrow bridge for this approved endpoint.
law flush_rows_observation:
  for +limit: Nat
  for +next: Nat
  for +rows: List<&2,T.Row>
  for +pending: List<&2,T.Command>
  S.When(S.admissible(limit,T.World{0n,next,rows,pending}), {M.query_rows(T.Any{},M.apply_all(pending,rows)) == S.enumerate_rows(next,0n,S.materialize(next,0n,rows,pending),T.Any{}) : List<&2,T.Row>})

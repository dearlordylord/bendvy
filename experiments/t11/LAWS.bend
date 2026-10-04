import Base
import ./model.bend as M
import ./spec.bend as S
import ../t08/core.bend as C
import ../t07/streams.bend as E

# Historical candidates: withdrawn as public ECS-law proposal after source audit.
# See ../../docs/reviews/laws-decision.md. No approval or paired proof defs.
law query_any_exact:
  for +rows: List<&2, M.Row>
  {M.query(M.Any{}, rows) == rows : List<&2, M.Row>}
law query_present_exact:
  for +rows: List<&2, M.Row>
  {M.query(M.Present{}, rows) == S.present(rows) : List<&2, M.Row>}
law query_absent_exact:
  for +rows: List<&2, M.Row>
  {M.query(M.Absent{}, rows) == S.absent(rows) : List<&2, M.Row>}
law foreign_lookup_guard:
  for slot: Nat
  for selection: M.Selection
  for rows: List<&2, M.Row>
  {M.lookup_guard(False{}, slot, selection, rows) == M.Missing{} : M.Lookup}
law foreign_command_guard:
  for +id: Nat
  for +next: Nat
  for +rows: List<&2, M.Row>
  for +pending: List<&2, M.Command>
  for command: M.Command
  {M.enqueue_guard(False{}, id, next, rows, pending, command) == M.World{id, next, rows, pending} : M.World}
law reserve_projection:
  for +id: Nat
  for +next: Nat
  for +rows: List<&2, M.Row>
  for +pending: List<&2, M.Command>
  for +value: Nat
  {M.reserve_available(True{}, id, next, rows, pending, value) == M.Reserved{M.World{id, 1n+next, rows, M.Spawn{next, value} <> pending}, M.Handle{id, next}} : M.Reservation}
law reserve_rejection:
  for +id: Nat
  for +next: Nat
  for +rows: List<&2, M.Row>
  for +pending: List<&2, M.Command>
  for +value: Nat
  {M.reserve_available(False{}, id, next, rows, pending, value) == M.Rejected{M.World{id, next, rows, pending}} : M.Reservation}
law bounded_reservation:
  for +limit: Nat
  for +next: Nat
  for id: Nat
  for rows: List<&2, M.Row>
  for pending: List<&2, M.Command>
  for value: Nat
  {Bool.or(Bool.not(Nat.is_le(next, limit)), M.within(limit, M.reserve_until(limit, M.World{id, next, rows, pending}, value))) == True{} : Bool}
law flush_fifo_projection:
  for +id: Nat
  for +next: Nat
  for +rows: List<&2, M.Row>
  for +pending: List<&2, M.Command>
  {M.flush(M.World{id, next, rows, pending}) == M.World{id, next, M.apply_all(List.reverse(&2, M.Command, pending), rows), []} : M.World}
law tick_preserves_pending:
  for +w: M.World
  {M.tick(w) == w : M.World}
law despawn_exact:
  for +slot: Nat
  for +rows: List<&2, M.Row>
  {M.apply(M.Despawn{slot}, rows) == S.erase(slot, rows) : List<&2, M.Row>}

# Executable Data cursor laws; these do not prove the owned runtime wrapper.
law message_failure_position:
  for +c: E.Cursor
  for started: U32
  {E.complete(False{}, c, started) == c : E.Cursor}
law message_skip_position:
  for old: U32
  for +registered: U32
  for +current: U32
  {E.skip(E.Cursor{old, registered}, current) == E.Cursor{current, registered} : E.Cursor}
law lifecycle_failure_position:
  for +c: C.Reader
  for started: U32
  {C.complete(False{}, c, started) == c : C.Reader}

import Base
import ./types.bend as T
import ./model.bend as M
import ./spec.bend as S
import ./bridge.bend as B
import ./runtime.bend as R
import ./owned-spec.bend as O
import ../t07/streams.bend as E
import ../t08/core.bend as C

# OPEN / UNAPPROVED. Exact interfaces/observations are specified in DESIGN.md.
# Conditional propositions use the independently defined S.When. False-domain
# Unit controls are classified separately from true-premise equality instances.
law admissibility_independent:
  for +limit: Nat
  for +world: T.World
  {M.admissible(limit, world) == S.admissible(limit, world) : Bool}
law namespace_creation_exact:
  for +limit: Nat
  for +factory: T.Factory
  {M.create(limit, factory) == S.create(limit, factory) : T.Creation}
law namespace_two_created:
  for +limit: Nat
  for +next: Nat
  S.When(Nat.is_lt(1n+next,limit), {M.two_namespaces(limit,T.Factory{next}) == Some{T.Namespaces{next,1n+next}} : Maybe<&2,T.Namespaces>})
law reservation_exact:
  for +limit: Nat
  for +world: T.World
  for +value: Nat
  {M.reserve(limit, world, value) == S.reserve(limit, world, value) : T.Reservation}
law reservation_pending_lookup:
  for +limit: Nat
  for +world: T.World
  for +value: Nat
  S.When(S.admissible(limit, world), {M.reserved_lookup(M.reserve(limit, world, value)) == T.Missing{} : T.Lookup})
law query_any_complete_ordered:
  for +limit: Nat
  for +world: T.World
  S.When(S.admissible(limit, world), {M.query(world, T.Any{}) == S.query(world, T.Any{}) : List<&2,T.Row>})
law query_present_complete_ordered:
  for +limit: Nat
  for +world: T.World
  S.When(S.admissible(limit, world), {M.query(world, T.Present{}) == S.query(world, T.Present{}) : List<&2,T.Row>})
law query_absent_complete_ordered:
  for +limit: Nat
  for +world: T.World
  S.When(S.admissible(limit, world), {M.query(world, T.Absent{}) == S.query(world, T.Absent{}) : List<&2,T.Row>})
law lookup_full_exact:
  for +world: T.World
  for +handle: T.Handle
  for +selection: T.Selection
  {M.lookup(world, handle, selection) == S.lookup(world, handle, selection) : T.Lookup}
law publication_authorized_target:
  for +world: T.World
  for +handle: T.Handle
  for +action: T.Action
  {M.publish(world, handle, action) == S.publish(world, handle, action) : T.World}
law explicit_flush_independent:
  for +limit: Nat
  for +world: T.World
  S.When(S.admissible(limit, world), {M.observe(M.flush(world)) == S.flush_observation(world) : T.Observation})
law schedule_execution_exact:
  for +limit: Nat
  for +world: T.World
  for +steps: List<&2, T.Step>
  S.When(S.admissible(limit, world), {M.observe(M.tick(steps, limit, world)) == S.schedule_observation(limit, world, steps) : T.Observation})
law admissibility_preserved:
  for +limit: Nat
  for +world: T.World
  for +step: T.Step
  S.When(S.admissible(limit, world), {M.admissible(limit, M.step(limit, world, step)) == True{} : Bool})
law query_independent_physical_order:
  for +limit: Nat
  for +world: T.World
  for +selection: T.Selection
  S.When(S.admissible(limit, world), {M.query(world, selection) == M.query(M.reverse_world(world), selection) : List<&2,T.Row>})
# Erased owners occur only in mathematical propositions; live owner duplication
# is separately rejected. Direct equalities pin actual observations/owner return,
# independently of Boolean certificate/validator helpers (none are used).
law owned_runtime_creation_correspondence:
  for +limit: U32
  for -factory: R.Factory
  {O.creation(R.create(limit, factory)) == S.create(U32.to_nat(limit), O.factory(factory)) : T.Creation}
law owned_runtime_projection_exact:
  for -world: R.World
  {R.snapshot(R.project(world)) == O.snapshot(world) : T.World}
law owned_runtime_projection_preserves_owner:
  for -world: R.World
  {O.snapshot(R.returned_owner(R.project(world))) == O.snapshot(world) : T.World}
law owned_runtime_step_correspondence:
  for +limit: U32
  for -world: R.World
  for +step: R.Step
  S.When(Bool.and(S.admissible(U32.to_nat(limit), O.snapshot(world)), S.step_safe(O.snapshot(world), O.step(step))), {M.observe(R.snapshot(R.project(R.step(limit, world, step)))) == S.observe(S.step(U32.to_nat(limit), O.snapshot(world), O.step(step))) : T.Observation})
# Arithmetic bridge candidates; these do not prove owned-runtime refinement.
law u32_increment_no_wrap:
  for +value: U32
  S.When(U32.is_lt(value,4294967295), {U32.to_nat(B.increment(value)) == 1n+U32.to_nat(value) : Nat})
law u32_comparison_agrees_nat:
  for +left: U32
  for +right: U32
  {B.less(left, right) == Nat.is_lt(U32.to_nat(left), U32.to_nat(right)) : Bool}
# Separate executable Data helpers, not selected-reader wrapper transitions.
law message_failure_helper:
  for +cursor: E.Cursor
  for started: U32
  {E.complete(False{}, cursor, started) == cursor : E.Cursor}
law message_success_helper:
  for old: U32
  for +registered: U32
  for +started: U32
  {E.complete(True{}, E.Cursor{old, registered}, started) == E.Cursor{started, registered} : E.Cursor}
law message_skip_helper:
  for old: U32
  for +registered: U32
  for +current: U32
  {E.skip(E.Cursor{old, registered}, current) == E.Cursor{current, registered} : E.Cursor}
law lifecycle_failure_helper:
  for +reader: C.Reader
  for started: U32
  {C.complete(False{}, reader, started) == reader : C.Reader}
law lifecycle_success_helper:
  for old: U32
  for message: U32
  for +registered: U32
  for +started: U32
  {C.complete(True{}, C.Reader{old, message, registered}, started) == C.Reader{started, started, registered} : C.Reader}
# Pin the conditional Type encoder itself; always-Unit cannot erase obligations.
law conditional_type_true:
  for -claim: Type
  {S.When(True{}, claim) == claim : Type}
law conditional_type_false:
  for -claim: Type
  {S.When(False{}, claim) == Unit : Type}
# Pin actual public callers and their returned observations/owners, not only step.
law owned_runtime_query_result_and_owner:
  for +limit: U32
  for -world: R.World
  for +selection: T.Selection
  S.When(S.admissible(U32.to_nat(limit),O.snapshot(world)), {O.query(R.query(world,selection)) == T.QueryObservation{O.snapshot(world),S.query(O.snapshot(world),selection)} : T.QueryObservation})
law owned_runtime_lookup_result_and_owner:
  for -world: R.World
  for +handle: R.Handle
  for +selection: T.Selection
  {O.lookup(R.lookup(world,handle,selection)) == T.LookupObservation{O.snapshot(world),S.lookup(O.snapshot(world),O.handle(handle),selection)} : T.LookupObservation}
law owned_runtime_reservation_result_and_owner:
  for +limit: U32
  for -world: R.World
  for +value: U32
  {O.reservation(R.reserve(limit,world,value)) == S.reserve(U32.to_nat(limit),O.snapshot(world),U32.to_nat(value)) : T.Reservation}
law owned_runtime_schedule_correspondence:
  for +limit: U32
  for -world: R.World
  for +steps: List<&2,R.Step>
  S.When(S.run_safe(O.steps(steps),U32.to_nat(limit),O.snapshot(world)), {M.observe(R.snapshot(R.project(R.tick(steps,limit,world)))) == S.schedule_observation(U32.to_nat(limit),O.snapshot(world),O.steps(steps)) : T.Observation})

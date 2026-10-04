import Base
import ./PROOF.bend as P
import ./context.bend as C
import ./successor.bend as U
import ./relation.bend as R
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

def active_schedule_premise() -> {True{} == S.admissible(4n,T.World{7n,2n,[],[]}) : Bool}: {==}
def reserved_stays_pending() -> S.When(S.admissible(4n,T.World{7n,2n,[],[]}),
  {M.observe(M.tick([T.Reserve{5n}],4n,T.World{7n,2n,[],[]}))
    == S.schedule_observation(4n,T.World{7n,2n,[],[]},[T.Reserve{5n}]) : T.Observation}): {==}
def reserved_applies_at_barrier() -> S.When(S.admissible(4n,T.World{7n,2n,[],[]}),
  {M.observe(M.tick([T.Reserve{5n},T.Barrier{}],4n,T.World{7n,2n,[],[]}))
    == S.schedule_observation(4n,T.World{7n,2n,[],[]},[T.Reserve{5n},T.Barrier{}]) : T.Observation}): {==}
def nonempty_reserved_context() ->
  {True{} == S.admissible(5n,T.World{7n,4n,[T.Row{1n,8n,True{}}],[T.Spawn{2n,9n},T.Target{99n,T.Remove{}},T.Spawn{3n,6n}]}) : Bool}:
  C.reserve_success(5n,7n,3n,[T.Row{1n,8n,True{}}],[T.Spawn{2n,9n},T.Target{99n,T.Remove{}}],6n,{==},{==})
def bump_keeps_absent_coverage() ->
  R.Slots(5n,0n,M.bump_rows(1n,[T.Row{1n,8n,True{}}]),S.bumped(2n,0n,1n,[T.Row{1n,8n,True{}}])):
  U.bump_slots(5n,0n,2n,1n,[T.Row{1n,8n,True{}}],[T.Row{1n,8n,True{}}],{==},R.slots_refl(5n,0n,[T.Row{1n,8n,True{}}]))
def mixed_schedule() -> S.When(S.admissible(5n,T.World{7n,3n,[T.Row{2n,8n,True{}},T.Row{0n,3n,False{}}],[T.Spawn{1n,9n}]}),
  {M.observe(M.tick([T.Bump{2n},T.Publish{T.Handle{7n,0n},T.Insert{}},T.Publish{T.Handle{8n,2n},T.Despawn{}},T.Barrier{},T.Reserve{6n},T.Bump{1n},T.Publish{T.Handle{7n,2n},T.Remove{}},T.Barrier{},T.Reserve{11n}],5n,T.World{7n,3n,[T.Row{2n,8n,True{}},T.Row{0n,3n,False{}}],[T.Spawn{1n,9n}]}))
    == S.schedule_observation(5n,T.World{7n,3n,[T.Row{2n,8n,True{}},T.Row{0n,3n,False{}}],[T.Spawn{1n,9n}]},[T.Bump{2n},T.Publish{T.Handle{7n,0n},T.Insert{}},T.Publish{T.Handle{8n,2n},T.Despawn{}},T.Barrier{},T.Reserve{6n},T.Bump{1n},T.Publish{T.Handle{7n,2n},T.Remove{}},T.Barrier{},T.Reserve{11n}]) : T.Observation}): {==}
def malformed_outside_domain() -> S.When(S.admissible(4n,T.World{7n,2n,[T.Row{0n,1n,False{}},T.Row{0n,8n,True{}}],[]}),
  {M.observe(M.tick([T.Barrier{}],4n,T.World{7n,2n,[T.Row{0n,1n,False{}},T.Row{0n,8n,True{}}],[]}))
    == S.schedule_observation(4n,T.World{7n,2n,[T.Row{0n,1n,False{}},T.Row{0n,8n,True{}}],[]},[T.Barrier{}]) : T.Observation}): Unit{}

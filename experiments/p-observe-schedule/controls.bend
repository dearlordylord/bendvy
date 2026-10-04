import Base
import ./relation.bend as R
import ./bump.bend as B
import ./invariants.bend as I
import ./transitions.bend as X
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

def reordered() -> R.Slots(2n,0n,[T.Row{1n,8n,True{}},T.Row{0n,3n,False{}}],[T.Row{0n,3n,False{}},T.Row{1n,8n,True{}}]):
  ({==},({==},Unit{}))
def reordered_observation() ->
  {S.observe(T.World{7n,2n,[T.Row{1n,8n,True{}},T.Row{0n,3n,False{}}],[]})
    == S.observe(T.World{7n,2n,[T.Row{0n,3n,False{}},T.Row{1n,8n,True{}}],[]}) : T.Observation}:
  R.observe_related(T.World{7n,2n,[T.Row{1n,8n,True{}},T.Row{0n,3n,False{}}],[]},
    T.World{7n,2n,[T.Row{0n,3n,False{}},T.Row{1n,8n,True{}}],[]},({==},{==},{==},reordered()))
def bump_unknown() ->
  {S.at(M.bump_rows(4n,[T.Row{0n,3n,False{}}]),0n) == Some{T.Row{0n,3n,False{}}} : Maybe<&2,T.Row>}:
  B.bump_point([T.Row{0n,3n,False{}}],4n,0n)
def bump_duplicate() ->
  {S.at(M.bump_rows(0n,[T.Row{0n,3n,False{}},T.Row{0n,9n,True{}}]),0n) == Some{T.Row{0n,4n,False{}}} : Maybe<&2,T.Row>}:
  B.bump_point([T.Row{0n,3n,False{}},T.Row{0n,9n,True{}}],0n,0n)
def bump_pending_count() ->
  {S.pending_valid([T.Spawn{2n,5n}],[T.Spawn{2n,5n}],M.bump_rows(0n,[T.Row{0n,3n,False{}}]),3n) == True{} : Bool}:
  I.pending_valid_bump([T.Spawn{2n,5n}],[T.Spawn{2n,5n}],[T.Row{0n,3n,False{}}],0n,3n)
def reserve_pending() ->
  R.Related(M.step(4n,T.World{7n,2n,[],[]},T.Reserve{5n}),S.step(4n,T.World{7n,2n,[],[]},T.Reserve{5n})):
  X.reserve_related(4n,7n,2n,[],[],[],5n,R.slots_refl(2n,0n,[]),R.slots_refl(3n,0n,[]))
def publish_foreign() ->
  R.Related(M.step(4n,T.World{7n,2n,[],[]},T.Publish{T.Handle{8n,0n},T.Despawn{}}),
    S.step(4n,T.World{7n,2n,[],[]},T.Publish{T.Handle{8n,0n},T.Despawn{}})):
  X.publish_related(4n,7n,2n,[],[],[],8n,0n,T.Despawn{},R.slots_refl(2n,0n,[]))
def reserve_is_pending() -> {M.observe(M.tick([T.Reserve{5n}],4n,T.World{7n,2n,[],[]}))
  == T.Observation{7n,3n,[],[T.Spawn{2n,5n}]} : T.Observation}: {==}
def active_premise() -> {True{} == S.admissible(4n,T.World{7n,2n,[T.Row{1n,8n,True{}},T.Row{0n,3n,False{}}],[]}) : Bool}: {==}

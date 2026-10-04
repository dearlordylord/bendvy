import Base
import ./LAWS.bend as L
import ./PROOF.bend as P
import ../t11-replacement/runtime.bend as R
import ../t11-replacement/owned-spec.bend as O
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

def mixed_world() -> R.World:
  R.World{7,3,[R.Cell{2,ANode{ALeaf{3},ANode{ALeaf{8},ALeaf{9}}},True{}},R.Cell{1,ALeaf{6},False{}}],[]}
def mixed_steps() -> List<&2,R.Step>:
  [R.Bump{2},R.Publish{R.Handle{7,2},T.Remove{}},R.Publish{R.Handle{8,1},T.Despawn{}},R.Barrier{},R.Reserve{8},R.Barrier{},R.Bump{3},R.Reserve{9}]
def mixed_safe() -> {True{} == S.run_safe(O.steps(mixed_steps()),5n,O.snapshot(mixed_world())) : Bool}: {==}
def mixed_endpoint() -> {M.observe(R.snapshot(R.project(R.tick(mixed_steps(),5,mixed_world())))) == S.schedule_observation(5n,O.snapshot(mixed_world()),O.steps(mixed_steps())) : T.Observation}:
  L.owned_runtime_schedule_correspondence(5,mixed_world(),mixed_steps())
def mixed_observation() -> {M.observe(R.snapshot(R.project(R.tick(mixed_steps(),5,mixed_world())))) == T.Observation{7n,5n,[T.Row{1n,6n,False{}},T.Row{2n,4n,False{}},T.Row{3n,9n,False{}}],[T.Spawn{4n,9n}]} : T.Observation}: {==}
def false_guard() -> {False{} == S.run_safe(O.steps([R.Bump{0}]),5n,O.snapshot(R.World{7,6,[],[]})) : Bool}: {==}
def false_endpoint() -> S.When(S.run_safe(O.steps([R.Bump{0}]),5n,O.snapshot(R.World{7,6,[],[]})),{M.observe(R.snapshot(R.project(R.tick([R.Bump{0}],5,R.World{7,6,[],[]})))) == S.schedule_observation(5n,O.snapshot(R.World{7,6,[],[]}),O.steps([R.Bump{0}])) : T.Observation}):
  L.owned_runtime_schedule_correspondence(5,R.World{7,6,[],[]},[R.Bump{0}])

import Base
import ./empty.bend as E
import ../t11-replacement/runtime.bend as R
import ../t11-replacement/owned-spec.bend as O
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

def active() -> {True{} == S.run_safe([],4n,T.World{7n,2n,[],[T.Spawn{1n,9n}]}) : Bool}: {==}

def pending_empty() ->
  S.When(S.run_safe([],4n,O.snapshot(R.World{7,2,[],[R.Spawn{1,9}]})),
    {M.observe(R.snapshot(R.project(R.tick([],4,R.World{7,2,[],[R.Spawn{1,9}]}))))
      == S.schedule_observation(4n,O.snapshot(R.World{7,2,[],[R.Spawn{1,9}]}),[]) : T.Observation}):
  E.empty(4,R.World{7,2,[],[R.Spawn{1,9}]})

def arbitrary_tree() ->
  S.When(S.run_safe([],4n,O.snapshot(R.World{7,2,[R.Cell{1,ANode{ALeaf{3},ANode{ALeaf{8},ALeaf{9}}},True{}}],[]})),
    {M.observe(R.snapshot(R.project(R.tick([],4,R.World{7,2,[R.Cell{1,ANode{ALeaf{3},ANode{ALeaf{8},ALeaf{9}}},True{}}],[]}))))
      == S.schedule_observation(4n,O.snapshot(R.World{7,2,[R.Cell{1,ANode{ALeaf{3},ANode{ALeaf{8},ALeaf{9}}},True{}}],[]}),[]) : T.Observation}):
  E.empty(4,R.World{7,2,[R.Cell{1,ANode{ALeaf{3},ANode{ALeaf{8},ALeaf{9}}},True{}}],[]})

def false_domain() ->
  S.When(S.run_safe([],1n,O.snapshot(R.World{7,2,[],[]})),
    {M.observe(R.snapshot(R.project(R.tick([],1,R.World{7,2,[],[]}))))
      == S.schedule_observation(1n,O.snapshot(R.World{7,2,[],[]}),[]) : T.Observation}):
  E.empty(1,R.World{7,2,[],[]})

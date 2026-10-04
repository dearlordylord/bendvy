import Base
import ../t11-replacement/runtime.bend as R
import ../t11-replacement/owned-spec.bend as O
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

def active() -> {True{} == S.run_safe([],4n,O.snapshot(R.World{7,2,[],[R.Spawn{1,9}]})) : Bool}: {==}

# Complete approved endpoint at steps=[], with an independently true premise.
def equation() -> {M.observe(R.snapshot(R.project(R.tick([],4,R.World{7,2,[],[R.Spawn{1,9}]}))))
  == S.schedule_observation(4n,O.snapshot(R.World{7,2,[],[R.Spawn{1,9}]}),[]) : T.Observation}: {==}

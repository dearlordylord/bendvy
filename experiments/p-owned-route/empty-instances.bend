import Base
import ../t11-replacement/runtime.bend as R
import ../t11-replacement/owned-spec.bend as O
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

def active() -> S.When(S.run_safe(O.steps([]),U32.to_nat(2),O.snapshot(R.World{0,1,[],[]})), {M.observe(R.snapshot(R.project(R.tick([],2,R.World{0,1,[],[]})))) == S.schedule_observation(U32.to_nat(2),O.snapshot(R.World{0,1,[],[]}),O.steps([])) : T.Observation}):
  {==}
def excluded() -> S.When(S.run_safe(O.steps([]),U32.to_nat(2),O.snapshot(R.World{0,3,[],[]})), {M.observe(R.snapshot(R.project(R.tick([],2,R.World{0,3,[],[]})))) == S.schedule_observation(U32.to_nat(2),O.snapshot(R.World{0,3,[],[]}),O.steps([])) : T.Observation}):
  Unit{}

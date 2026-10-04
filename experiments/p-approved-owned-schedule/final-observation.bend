import Base
import ./frames.bend as F
import ./capture.bend as C
import ../t11-replacement/runtime.bend as R
import ../t11-replacement/owned-spec.bend as O
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S
import ../p-observe-schedule/PROOF.bend as D

def projected(-source: R.World, +expected: T.World, observed: {O.snapshot(source) == expected : T.World}, frame: C.WorldFrame<source>)
  -> {M.observe(R.snapshot(R.project(source))) == M.observe(expected) : T.Observation}:
  match frame:
    case C.WorldFrame{owner,+data,exact,observation,_}:
      %exact : {M.observe(R.snapshot(_)) == M.observe(expected) : T.Observation}
      Equal.cong(T.World,T.Observation,w => M.observe(w),data,expected,
        Equal.trans(T.World,data,O.snapshot(source),expected,observation,observed))

def finish(+limit: U32, +steps: List<&2,R.Step>, -source: R.World, +data: T.World,
  valid: {True{} == S.admissible(U32.to_nat(limit),data) : Bool},
  frame: F.WorldResult<R.tick(steps,limit,source),M.tick(O.steps(steps),U32.to_nat(limit),data)>)
  -> {M.observe(R.snapshot(R.project(R.tick(steps,limit,source)))) == S.schedule_observation(U32.to_nat(limit),data,O.steps(steps)) : T.Observation}:
  match frame:
    case F.WorldResult{owner,exact,observed}:
      %exact : {M.observe(R.snapshot(R.project(_))) == S.schedule_observation(U32.to_nat(limit),data,O.steps(steps)) : T.Observation}
      Equal.trans(T.Observation,M.observe(R.snapshot(R.project(owner))),M.observe(M.tick(O.steps(steps),U32.to_nat(limit),data)),S.schedule_observation(U32.to_nat(limit),data,O.steps(steps)),
        projected(owner,M.tick(O.steps(steps),U32.to_nat(limit),data),observed,C.capture_world(owner)),D.start(data,O.steps(steps),U32.to_nat(limit),valid))

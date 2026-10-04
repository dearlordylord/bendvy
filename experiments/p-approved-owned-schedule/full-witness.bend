import Base
import ../t11-replacement/runtime.bend as R
import ../t11-replacement/owned-spec.bend as O
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

# Complete endpoint instances: the independent original premise is separate.
def pending_world() -> R.World: R.World{7,1,[],[]}
def pending_steps() -> List<&2,R.Step>: [R.Reserve{9}]
def pending_safe() -> {True{} == S.run_safe(O.steps(pending_steps()),U32.to_nat(4),O.snapshot(pending_world())) : Bool}: {==}
def pending_equation() -> {M.observe(R.snapshot(R.project(R.tick(pending_steps(),4,pending_world())))) == S.schedule_observation(U32.to_nat(4),O.snapshot(pending_world()),O.steps(pending_steps())) : T.Observation}: {==}

def tail_world() -> R.World: R.World{7,1,[],[]}
def tail_steps() -> List<&2,R.Step>: [R.Reserve{9},R.Barrier{},R.Bump{1}]
def tail_safe() -> {True{} == S.run_safe(O.steps(tail_steps()),U32.to_nat(4),O.snapshot(tail_world())) : Bool}: {==}
def tail_equation() -> {M.observe(R.snapshot(R.project(R.tick(tail_steps(),4,tail_world())))) == S.schedule_observation(U32.to_nat(4),O.snapshot(tail_world()),O.steps(tail_steps())) : T.Observation}: {==}

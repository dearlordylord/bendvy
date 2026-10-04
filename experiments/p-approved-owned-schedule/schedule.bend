import Base
import ./frames.bend as F
import ./advance.bend as A
import ./tick-context.bend as C
import ../p-approved-owned-safety/safety.bend as V
import ../t11-replacement/runtime.bend as R
import ../t11-replacement/owned-spec.bend as O
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M

# Dedicated generalized induction for owned_runtime_schedule_correspondence.
def continue_tick(+operation: R.Step, +tail: List<&2,R.Step>, +limit: U32, -source: R.World, +data: T.World,
  observed: {O.snapshot(source) == data : T.World},
  safe: {True{} == V.ModelSafe(O.steps(tail),U32.to_nat(limit),M.step(U32.to_nat(limit),data,O.step(operation))) : Bool},
  frame: F.WorldResult<R.step(limit,source,operation),M.step(U32.to_nat(limit),O.snapshot(source),O.step(operation))>,
  ih: @owner:R.World -> {O.snapshot(owner) == M.step(U32.to_nat(limit),data,O.step(operation)) : T.World}
    -> {True{} == V.ModelSafe(O.steps(tail),U32.to_nat(limit),M.step(U32.to_nat(limit),data,O.step(operation))) : Bool}
    -> F.WorldResult<R.tick(tail,limit,owner),M.tick(O.steps(tail),U32.to_nat(limit),M.step(U32.to_nat(limit),data,O.step(operation)))>)
  -> F.WorldResult<R.tick(operation <> tail,limit,source),M.tick(O.steps(operation <> tail),U32.to_nat(limit),data)>:
  match frame:
    case F.WorldResult{owner,exact,next}:
      eq = C.next_observed(limit,operation,source,owner,data,observed,next)
      C.finish(limit,operation,tail,source,owner,data,exact,ih(owner,eq,safe))

def tick(+steps: List<&2,R.Step>, +limit: U32, world: R.World, +data: T.World,
  +observed: {O.snapshot(world) == data : T.World},
  +safe: {True{} == V.ModelSafe(O.steps(steps),U32.to_nat(limit),data) : Bool})
  -> F.WorldResult<R.tick(steps,limit,world),M.tick(O.steps(steps),U32.to_nat(limit),data)>:
  match steps:
    case Nil{}: F.WorldResult{world,{==},observed}
    case Con{+operation,+tail}:
      continue_tick(operation,tail,limit,world,data,observed,C.tail_safe(O.step(operation),O.steps(tail),U32.to_nat(limit),data,safe),
        A.step(operation,limit,world,data,observed,C.head_valid(O.step(operation),O.steps(tail),U32.to_nat(limit),data,safe),C.head_safe(O.step(operation),O.steps(tail),U32.to_nat(limit),data,safe)),
        owner => eq => h => tick(tail,limit,owner,M.step(U32.to_nat(limit),data,O.step(operation)),eq,h))

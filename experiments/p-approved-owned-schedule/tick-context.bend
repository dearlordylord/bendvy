import Base
import ./frames.bend as F
import ../t11-replacement/runtime.bend as R
import ../t11-replacement/owned-spec.bend as O
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S
import ../p-approved-owned-safety/safety.bend as V
import ../p-observe-queries/helpers.bend as H

def next_observed(+limit: U32, +operation: R.Step, -source: R.World, -owner: R.World, +data: T.World,
  observed: {O.snapshot(source) == data : T.World},
  next: {O.snapshot(owner) == M.step(U32.to_nat(limit),O.snapshot(source),O.step(operation)) : T.World})
  -> {O.snapshot(owner) == M.step(U32.to_nat(limit),data,O.step(operation)) : T.World}:
  %observed : {O.snapshot(owner) == M.step(U32.to_nat(limit),_,O.step(operation)) : T.World}
  next

def finish(+limit: U32, +operation: R.Step, +tail: List<&2,R.Step>, -source: R.World, -next: R.World, +data: T.World,
  first: {next == R.step(limit,source,operation) : R.World},
  frame: F.WorldResult<R.tick(tail,limit,next),M.tick(O.steps(tail),U32.to_nat(limit),M.step(U32.to_nat(limit),data,O.step(operation)))>)
  -> F.WorldResult<R.tick(tail,limit,R.step(limit,source,operation)),M.tick(O.steps(operation <> tail),U32.to_nat(limit),data)>:
  match frame:
    case F.WorldResult{owner,exact,observed}:
      er = Equal.trans(R.World,owner,R.tick(tail,limit,next),R.tick(tail,limit,R.step(limit,source,operation)),exact,
        Equal.cong(R.World,R.World,w => R.tick(tail,limit,w),next,R.step(limit,source,operation),first))
      F.WorldResult{owner,er,observed}

def head_valid(+operation: T.Step, +tail: List<&2,T.Step>, +limit: Nat, +data: T.World,
  h: {True{} == V.ModelSafe(operation <> tail,limit,data) : Bool})
  -> {True{} == S.admissible(limit,data) : Bool}:
  H.and_left(S.admissible(limit,data),Bool.and(S.step_safe(data,operation),V.ModelSafe(tail,limit,M.step(limit,data,operation))),h)

def head_safe(+operation: T.Step, +tail: List<&2,T.Step>, +limit: Nat, +data: T.World,
  h: {True{} == V.ModelSafe(operation <> tail,limit,data) : Bool})
  -> {True{} == S.step_safe(data,operation) : Bool}:
  H.and_left(S.step_safe(data,operation),V.ModelSafe(tail,limit,M.step(limit,data,operation)),
    H.and_right(S.admissible(limit,data),Bool.and(S.step_safe(data,operation),V.ModelSafe(tail,limit,M.step(limit,data,operation))),h))

def tail_safe(+operation: T.Step, +tail: List<&2,T.Step>, +limit: Nat, +data: T.World,
  h: {True{} == V.ModelSafe(operation <> tail,limit,data) : Bool})
  -> {True{} == V.ModelSafe(tail,limit,M.step(limit,data,operation)) : Bool}:
  H.and_right(S.step_safe(data,operation),V.ModelSafe(tail,limit,M.step(limit,data,operation)),
    H.and_right(S.admissible(limit,data),Bool.and(S.step_safe(data,operation),V.ModelSafe(tail,limit,M.step(limit,data,operation))),h))

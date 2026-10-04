import Base
import ./frames.bend as F
import ./allocation.bend as A
import ./barrier.bend as C
import ./bump-rows.bend as B
import ./bump-world.bend as W
import ../t11-replacement/runtime.bend as R
import ../t11-replacement/owned-spec.bend as O
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

def bump(+limit: U32, world: R.World, +data: T.World, +target: U32,
  observed: {O.snapshot(world) == data : T.World},
  valid: {True{} == S.admissible(U32.to_nat(limit),data) : Bool}, safe: {True{} == S.step_safe(data,T.Bump{U32.to_nat(target)}) : Bool})
  -> F.WorldResult<R.bump(world,target),M.bump(O.snapshot(world),U32.to_nat(target))>:
  match world:
    case R.World{+id,+next,rows,+pending}:
      h = W.member_guard(limit,data,target,id,next,rows,pending,observed,valid,safe)
      W.finish(id,next,pending,target,rows,B.rows(target,rows,h))

def step(+operation: R.Step, +limit: U32, world: R.World, +data: T.World,
  observed: {O.snapshot(world) == data : T.World},
  valid: {True{} == S.admissible(U32.to_nat(limit),data) : Bool}, safe: {True{} == S.step_safe(data,O.step(operation)) : Bool})
  -> F.WorldResult<R.step(limit,world,operation),M.step(U32.to_nat(limit),O.snapshot(world),O.step(operation))>:
  match operation:
    case R.Reserve{+value}: A.reserve(limit,world,value)
    case R.Publish{+handle,+action}: A.publish(limit,world,handle,action)
    case R.Bump{+target}: bump(limit,world,data,target,observed,valid,safe)
    case R.Barrier{}: C.flush(world)

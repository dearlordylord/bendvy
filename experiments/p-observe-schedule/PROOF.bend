import Base
import ./LAWS.bend as L
import ./schedule.bend as D
import ./relation.bend as R
import ./context.bend as C
import ../t11-replacement/types.bend as T
import ../t11-replacement/model.bend as M
import ../t11-replacement/spec.bend as S

# ---- schedule_execution_exact: dedicated induction and endpoint ----
# Authored-list induction on the exact two interpreters, no final implicit flush.
def schedule_related(+steps: List<&2,T.Step>, +limit: Nat, +id: Nat, +next: Nat,
  +left: List<&2,T.Row>, +right: List<&2,T.Row>, +pending: List<&2,T.Command>,
  valid: {True{} == S.admissible(limit,T.World{id,next,left,pending}) : Bool}, related: R.Slots(limit,0n,left,right))
  -> {M.observe(M.tick(steps,limit,T.World{id,next,left,pending}))
    == S.observe(S.run(steps,limit,T.World{id,next,right,pending})) : T.Observation}:
  match steps:
    case Nil{}: C.final_observation(limit,id,next,left,right,pending,valid,related)
    case Con{operation,+tail}:
      D.dispatch(operation,tail,limit,id,next,left,right,pending,valid,related,
        n => l => r => p => h => slots => schedule_related(tail,limit,id,n,l,r,p,h,slots))

# Initial simulation uses reflexive finite lookup evidence at the fixed limit.
def start(+world: T.World, +steps: List<&2,T.Step>, +limit: Nat,
  valid: {True{} == S.admissible(limit,world) : Bool})
  -> {M.observe(M.tick(steps,limit,world)) == S.schedule_observation(limit,world,steps) : T.Observation}:
  match world:
    case T.World{id,next,+rows,pending}:
      schedule_related(steps,limit,id,next,rows,rows,pending,valid,R.slots_refl(limit,0n,rows))

# Preserve both branches of the exact approved independent conditional domain.
def guarded(guard: Bool, +limit: Nat, +world: T.World, +steps: List<&2,T.Step>,
  e: {guard == S.admissible(limit,world) : Bool})
  -> S.When(guard,{M.observe(M.tick(steps,limit,world)) == S.schedule_observation(limit,world,steps) : T.Observation}):
  match guard:
    case False{}: Unit{}
    case True{}: start(world,steps,limit,e)

# ---- schedule_execution_exact ----
def L.schedule_execution_exact(limit,world,steps):
  guarded(S.admissible(limit,world),limit,world,steps,{==})

import Base
import types.bend as T
import motion.bend as F
import motion-driver.bend as Driver
import motion-observe.bend as Observe
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/world-io.bend as WI
import ../../../../src/ecs/ordinary-system.bend as Ordinary

def final_physical(prefix:String,observed:F.World() & String) -> String:
  match observed:
    case (world,text):prefix ++ "afterLogicalRead=" ++ text ++ "\n"
def final_rows(prefix:String,observed:F.World() & String) -> String:
  match observed:
    case (world,text):final_physical(prefix ++ "logicalRows=" ++ text ++ "\n",Observe.world(world))
def final_state(prefix:String,observed:Driver.State & String) -> String:
  match observed:
    case (Driver.State{world,owner,audit,statuses},text):final_rows(prefix ++ "final=" ++ text ++ "\n",Observe.rows(world))
def initial_state(prefix:String,observed:Driver.State & String) -> String:
  match observed:
    case (state,text):final_state(prefix ++ "registered=" ++ text ++ "\n",Observe.state(Driver.loops(64n,state)))
def registered(prefix:String,result:Ordinary.Defined<T.MotionSchema,F.World(),F.Registry()>) -> String:
  match result:
    case Ordinary.Defined{world,owner}:initial_state(prefix,Observe.state(Driver.State{world,owner,[],[]}))
    case Ordinary.Rejected{world}:final_rows(prefix ++ "RegistrationRefused|",Observe.world(world))
def barrier_observed(prefix:String,observed:F.World() & String) -> String:
  match observed:
    case (world,text):registered(prefix ++ "seedApplied=" ++ text ++ "\n",F.define(world))
def pending_observed(prefix:String,observed:F.World() & String) -> String:
  match observed:
    case (world,text):barrier_observed(prefix ++ "seedPending=" ++ text ++ "\n",Observe.world(W.barrier(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,world)))
def seeded(result:F.Seeded) -> String:
  match result:
    case F.Seeded{world,reservations,outcome}:pending_observed("Dense64 Motion\nseedOutcome=" ++ Observe.outcome(outcome) ++ "|reservations=" ++ List.show(&2,W.Reservation<T.MotionSchema>,Observe.reservation,reservations) ++ "\n",Observe.world(world))
def refused(observed:F.Resources() & String) -> String:
  match observed:
    case (resources,text):"WorldCreationRefused|" ++ text ++ "\n"
def created(result:WI.Creation<T.MotionSchema,F.Store(),F.Resources(),Nat>) -> String:
  match result:
    case WI.Created{world}:seeded(F.seed(world))
    case WI.Refused{resource}:refused(Observe.resources(resource))
def main() -> IO(Unit):
  do IO<Unit>:
    result:WI.Creation<T.MotionSchema,F.Store(),F.Resources(),Nat> <- WI.create(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~F.empty,F.initial_resources())
    IO.print(created(result))

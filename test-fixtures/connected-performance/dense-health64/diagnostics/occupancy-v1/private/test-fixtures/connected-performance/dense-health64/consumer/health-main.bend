import Base
import ../../dense-motion64/consumer/s-perf/canonical-api-v1/dense-runtime-v1/types.bend as T
import health.bend as F
import health-driver.bend as Driver
import health-observe.bend as Observe
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/world-io.bend as WI

def final_physical(prefix:String,observed:F.World() & String) -> String:
  match observed:
    case (world,text):prefix ++ "afterLogicalRead=" ++ text ++ "\n"
def final_rows(prefix:String,observed:F.World() & String) -> String:
  match observed:
    case (world,text):final_physical(prefix ++ "logicalRows=" ++ text ++ "\n",Observe.world(world))
def final_physical_view(owner:Driver.Owner(),audit:List<&2,Driver.Audit>,statuses:List<&2,Driver.Status>,prefix:String,observed:F.World() & String) -> Driver.View & String:
  match observed:
    case (world,text):(Driver.View{world,owner,audit,statuses},prefix ++ "afterLogicalRead=" ++ text ++ "\n")
def final_rows_view(owner:Driver.Owner(),audit:List<&2,Driver.Audit>,statuses:List<&2,Driver.Status>,observed:F.World() & String) -> Driver.View & String:
  match observed:
    case (world,text):final_physical_view(owner,audit,statuses,"logicalRows=" ++ text ++ "\n",Observe.world(world))
def final_observe(value:Driver.View) -> Driver.View & String:
  match value:
    case Driver.View{world,owner,audit,statuses}:final_rows_view(owner,audit,statuses,Observe.rows(world))
def final_tail(prefix:String,result:Driver.State & String) -> String:
  match result:
    case (_,text):prefix ++ text
def final_state(prefix:String,observed:Driver.State & String) -> String:
  match observed:
    case (state,text):final_tail(prefix ++ "final=" ++ text ++ "\n",Driver.inspect(~String,final_observe,state))
def initial_state(iterations:U32,prefix:String,observed:Driver.State & String) -> String:
  match observed:
    case (state,text):final_state(prefix ++ "registered=" ++ text ++ "\n",Observe.state(Driver.loops(U32.to_nat(iterations),state)))
def registered(iterations:U32,prefix:String,result:Driver.Defined) -> String:
  match result:
    case Driver.Defined{state}:initial_state(iterations,prefix,Observe.state(state))
    case Driver.Refused{world}:final_rows(prefix ++ "RegistrationRefused|",Observe.world(world))
def barrier_observed(iterations:U32,prefix:String,observed:F.World() & String) -> String:
  match observed:
    case (world,text):registered(iterations,prefix ++ "seedApplied=" ++ text ++ "\n",Driver.define(world))
def pending_observed(iterations:U32,prefix:String,observed:F.World() & String) -> String:
  match observed:
    case (world,text):barrier_observed(iterations,prefix ++ "seedPending=" ++ text ++ "\n",Observe.world(W.barrier(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,world)))
def seeded(+count:U32,+iterations:U32,result:F.Seeded) -> String:
  match result:
    case F.Seeded{world,reservations,outcome,_}:pending_observed(iterations,"DenseRuntime Health\ncount=" ++ U32.show(count) ++ ";iterations=" ++ U32.show(iterations) ++ "\nseedOutcome=" ++ Observe.outcome(outcome) ++ "|reservations=" ++ List.show(&2,W.Reservation<T.HealthSchema>,Observe.reservation,reservations) ++ "\n",Observe.world(world))
def refused(observed:F.Resources() & String) -> String:
  match observed:
    case (resources,text):"WorldCreationRefused|" ++ text ++ "\n"
def created(+count:U32,+iterations:U32,result:WI.Creation<T.HealthSchema,F.Store(),F.Resources(),Nat>) -> String:
  match result:
    case WI.Created{world}:seeded(count,iterations,F.seed(count,world))
    case WI.Refused{resource}:refused(Observe.resources(resource))
def run(+count:U32,+iterations:U32) -> IO(Unit):
  do IO<Unit>:
    result:WI.Creation<T.HealthSchema,F.Store(),F.Resources(),Nat> <- WI.create(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~F.empty,F.initial_resources())
    IO.print(created(count,iterations,result))
def parsed(count:Maybe<&2,U32>,iterations:Maybe<&2,U32>) -> IO(Unit):
  match count iterations:
    case Some{count} Some{iterations}:run(count,iterations)
    case _ _:IO.die(Unit,2,"count iterations must be U32")
def args(values:List<String>) -> IO(Unit):
  match values:
    case _ <> count <> iterations <> _:parsed(U32.read(count),U32.read(iterations))
    case _:IO.die(Unit,2,"count iterations required")
def main() -> IO(Unit):
  do IO<Unit>:
    values:List<String> <- IO.args()
    args(values)

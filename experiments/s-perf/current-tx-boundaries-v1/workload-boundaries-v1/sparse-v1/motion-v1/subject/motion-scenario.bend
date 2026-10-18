import Base
import tx-metrics.bend as Metrics
import types.bend as T
import motion.bend as F
import motion-driver.bend as Driver
import motion-observe.bend as Observe
import ../private/src/ecs/world.bend as W
import ../private/src/ecs/ordinary-system.bend as Ordinary

def final_physical(prefix:String,observed:F.World() & String) -> String:
  match observed:
    case (world,text):prefix ++ "afterLogicalRead=" ++ text ++ "\n"
def final_rows(prefix:String,observed:F.World() & String) -> String:
  match observed:
    case (world,text):final_physical(prefix ++ "logicalRows=" ++ text ++ "\n",Observe.world(world))
type Prepared is Data:
  Prepared{wire:String,samples:List<&2,Metrics.Sample>}
def final_physical_view(samples:List<&2,Metrics.Sample>,owner:F.Owner(),audit:List<&2,Driver.Audit>,statuses:List<&2,Driver.Status>,cumulative:U32,prefix:String,observed:F.World() & String) -> Driver.View & String:
  match observed:
    case (world,text):(Driver.View{world,owner,audit,statuses,cumulative,samples},prefix ++ "afterLogicalRead=" ++ text ++ "\n")
def final_rows_view(samples:List<&2,Metrics.Sample>,owner:F.Owner(),audit:List<&2,Driver.Audit>,statuses:List<&2,Driver.Status>,cumulative:U32,observed:F.World() & String) -> Driver.View & String:
  match observed:
    case (world,text):final_physical_view(samples,owner,audit,statuses,cumulative,"logicalRows=" ++ text ++ "\n",Observe.world(world))
def final_observe(value:Driver.View) -> Driver.View & String:
  match value:
    case Driver.View{world,owner,audit,statuses,cumulative,samples}:final_rows_view(samples,owner,audit,statuses,cumulative,Observe.rows(world))
def final_tail(seed:Metrics.Sample,prefix:String,result:Driver.State & String) -> Prepared:
  match result:
    case (state,text):Prepared{prefix ++ text,seed <> Driver.finish_samples(state)}
def final_state(seed:Metrics.Sample,prefix:String,observed:Driver.State & String) -> Prepared:
  match observed:
    case (state,text):final_tail(seed,prefix ++ "final=" ++ text ++ "\n",Driver.inspect(~final_observe,state))
def initial_state(seed:Metrics.Sample,iterations:U32,prefix:String,observed:Driver.State & String) -> Prepared:
  match observed:
    case (state,text):final_state(seed,prefix ++ "registered=" ++ text ++ "\n",Observe.state(Driver.loops(U32.to_nat(iterations),state)))
def registered(seed:Metrics.Sample,iterations:U32,prefix:String,result:Ordinary.Defined<T.MotionSchema,F.World(),F.Registry()>) -> Prepared:
  match result:
    case Ordinary.Defined{world,owner}:initial_state(seed,iterations,prefix,Observe.state(Driver.start(world,owner)))
    case Ordinary.Rejected{world}:Prepared{final_rows(prefix ++ "RegistrationRefused|",Observe.world(world)),[seed,Metrics.NoTx{"registration-refused"}]}
def barrier_observed(seed:Metrics.Sample,iterations:U32,prefix:String,observed:F.World() & String) -> Prepared:
  match observed:
    case (world,text):registered(seed,iterations,prefix ++ "seedApplied=" ++ text ++ "\n",F.define(world))
def pending_observed(seed:Metrics.Sample,iterations:U32,prefix:String,observed:F.World() & String) -> Prepared:
  match observed:
    case (world,text):barrier_observed(seed,iterations,prefix ++ "seedPending=" ++ text ++ "\n",Observe.world(W.barrier(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,world)))
def seeded(+count:U32,+iterations:U32,result:F.Seeded) -> Prepared:
  match result:
    case F.Seeded{world,reservations,outcome,seed}:pending_observed(seed,iterations,"SparseRuntime Motion\ncount=" ++ U32.show(count) ++ ";iterations=" ++ U32.show(iterations) ++ "\nseedOutcome=" ++ Observe.outcome(outcome) ++ "|reservations=" ++ List.show(&2,W.Reservation<T.MotionSchema>,Observe.reservation,reservations) ++ "\n",Observe.world(world))
def refused(observed:F.Resources() & String) -> String:
  match observed:
    case (resources,text):"WorldCreationRefused|" ++ text ++ "\n"

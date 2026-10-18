import Base
import health.bend as F
import ../dense-runtime-v1/types.bend as T
import health-events.bend as E
import health-family.bend as Family
import health-observe.bend as O
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/ordinary-reader-system.bend as Ordinary
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/ordinary-reader-stream-parameter.bend as SP
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/ordinary-reader-query-parameter.bend as QP
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/reader-parameter.bend as RP
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/event-runtime.bend as Ev
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/event-stream.bend as Leaf
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/event-family-routing.bend as Route
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/event-family-runtime.bend as FR
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/event-notice-runtime.bend as Mixed
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/ordinary-event-declaration.bend as Event
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/system.bend as Sys
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/internal/relation-failures/domains.bend as Domain
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/internal/relation-failures/queue.bend as Queue
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/inspector-query.bend as IQ
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/inspector-query-projection.bend as Projection

def position(value:Ev.Position) -> String:
  match value:
    case Ev.Position{id,cursor,registered}:"id=" ++ U32.show(id) ++ ";cursor=" ++ Nat.show(cursor) ++ ";registered=" ++ Nat.show(registered)
def batch(value:Ev.Batch<E.event_type()>) -> String:
  match value:
    case Ev.Batch{tick,values}:"tick=" ++ Nat.show(tick) ++ ";values=" ++ List.show(&2,E.event_type(),O.event,values)
def pub_batch(value:Ev.Batch<Nat>) -> String:
  match value:
    case Ev.Batch{tick,values}:"tick=" ++ Nat.show(tick) ++ ";values=" ++ List.show(&2,Nat,O.publication,values)
def stream(value:Leaf.Stream<T.HealthSchema,E.event_type()>) -> String:
  match value:
    case Leaf.Stream{Event.Domain{domain},batches,positions,nextReader,frameStart,boundary,capacity,dropped}:"domain=" ++ domain ++ ";batches=" ++ List.show(&2,Ev.Batch<E.event_type()>,batch,batches) ++ ";positions=" ++ List.show(&2,Ev.Position,position,positions) ++ ";nextReader=" ++ U32.show(nextReader) ++ ";frameStart=" ++ Nat.show(frameStart) ++ ";boundary=" ++ Nat.show(boundary) ++ ";capacity=" ++ Nat.show(capacity) ++ ";dropped=" ++ Nat.show(dropped)
def family(value:Family.Family) -> String:
  match value:
    case Family.Family{a}:"ping={" ++ stream(a) ++ "}"
def queue_batch(value:Queue.Batch<E.event_type()>) -> String:
  match value:
    case Queue.Batch{tick,count,values}:"tick=" ++ Nat.show(tick) ++ ";cachedCount=" ++ Nat.show(count) ++ ";values=" ++ List.show(&2,E.event_type(),O.event,values)
def queue(value:Queue.Queue<E.event_type()>) -> String:
  match value:
    case Queue.Queue{front,back,size,dropped}:"front=" ++ List.show(&2,Queue.Batch<E.event_type()>,queue_batch,front) ++ ";back=" ++ List.show(&2,Queue.Batch<E.event_type()>,queue_batch,back) ++ ";size=" ++ Nat.show(size) ++ ";dropped=" ++ Nat.show(dropped)
def domain(value:Domain.Domain<T.HealthSchema,E.event_type()>) -> String:
  match value:
    case Domain.Domain{Domain.DeclaredKey{id},stored,readers}:"id=" ++ U32.show(id) ++ ";queue={" ++ queue(stored) ++ "};readers=" ++ List.show(&2,U32,U32.show,readers)
def failures(value:Mixed.Failures<T.HealthSchema,Nat>) -> String:
  match value:
    case Mixed.Failures{domains,positions,tick,frameStart,boundary,capacity,nextReader}:"domains=" ++ List.show(&2,Domain.Domain<T.HealthSchema,E.event_type()>,domain,domains) ++ ";positions=" ++ List.show(&2,Ev.Position,position,positions) ++ ";tick=" ++ Nat.show(tick) ++ ";frameStart=" ++ Nat.show(frameStart) ++ ";boundary=" ++ Nat.show(boundary) ++ ";capacity=" ++ Nat.show(capacity) ++ ";nextReader=" ++ U32.show(nextReader)
def meta(value:Mixed.State<T.HealthSchema,Nat,Family.Family,Unit>) -> Mixed.State<T.HealthSchema,Nat,Family.Family,Unit> & String:
  match value:
    case Mixed.State{FR.State{+f,unit,+journal,+frameStart},+failed}:(Mixed.State{FR.State{f,unit,journal,frameStart},failed},"typed={family={" ++ family(f) ++ "};owner=Unit;journal=" ++ List.show(&2,Ev.Batch<Nat>,pub_batch,journal) ++ ";frameStart=" ++ Nat.show(frameStart) ++ "};failures={" ++ failures(failed) ++ "}")
def context_join(+tick:Nat,observedWorld:F.World() & String,observedMeta:Mixed.State<T.HealthSchema,Nat,Family.Family,Unit> & String) -> Family.Context() & String:
  (world,sw)=observedWorld
  (meta,sm)=observedMeta
  (Route.Runtime{world,meta,tick},"tick=" ++ Nat.show(tick) ++ ";world={" ++ sw ++ "};meta={" ++ sm ++ "}")
def context(value:Family.Context()) -> Family.Context() & String:
  match value:
    case Route.Runtime{world,stored,tick}:context_join(tick,O.world(world),meta(stored))

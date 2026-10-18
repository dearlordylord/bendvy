import Base
import ../dense-runtime-v1/types.bend as T
import health.bend as F
import health-events.bend as E
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/event-stream.bend as Leaf
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/event-notice-runtime.bend as Mixed
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/event-family-routing.bend as Route
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/ordinary-event-declaration.bend as Event
import ../../../../../../../../../../../../workspace/formal-proofs/bendvy/experiments/s-perf/current-tx-boundaries-v1/workload-boundaries-v1/private/src/ecs/relation-commands.bend as Notice

type Family is Data:
  Family{ping:Leaf.Stream<T.HealthSchema,E.event_type()>}
def Context() -> Type:Route.Runtime<T.HealthSchema,F.Store(),F.Resources(),E.event_type(),Mixed.State<T.HealthSchema,Nat,Family,Unit>>
def ping_declaration() -> Event.Declaration<T.HealthSchema,E.event_type()>:Event.read(~T.HealthSchema,~E.event_type(),Event.domain(~T.HealthSchema,~E.event_type(),"ping"))
def take_ping(value:Family) -> Family & Leaf.Stream<T.HealthSchema,E.event_type()>:
  match value:
    case Family{+ping}:(Family{ping},ping)
def put_ping(_:Family,ping:Leaf.Stream<T.HealthSchema,E.event_type()>) -> Family:Family{ping}
def select(values:List<&2,Nat>) -> List<&2,E.event_type()>:
  match values:
    case []:[]
    case value <> rest:Notice.Original{value} <> select(rest)
def sync(family:Family,tick:Nat,values:List<&2,Nat>) -> Family:
  match family:
    case Family{ping}:Family{Leaf.append(~T.HealthSchema,~E.event_type(),ping,tick,select(values))}
def start(world:F.World()) -> Context():
  Mixed.start(~T.HealthSchema,~F.Store(),~F.Resources(),~Nat,~Family,~Unit,world,Family{Leaf.provision(~T.HealthSchema,~E.event_type(),Event.domain(~T.HealthSchema,~E.event_type(),"ping"),65536n)},Unit{})

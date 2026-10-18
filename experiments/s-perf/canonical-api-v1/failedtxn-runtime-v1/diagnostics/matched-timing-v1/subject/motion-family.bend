import Base
import /tmp/bendvy-failedtxn-matched-method/experiments/s-perf/canonical-api-v1/dense-runtime-v1/types.bend as T
import motion.bend as F
import events.bend as E
import /tmp/bendvy-failedtxn-matched-method/src/ecs/event-stream.bend as Leaf
import /tmp/bendvy-failedtxn-matched-method/src/ecs/event-notice-runtime.bend as Mixed
import /tmp/bendvy-failedtxn-matched-method/src/ecs/event-family-routing.bend as Route
import /tmp/bendvy-failedtxn-matched-method/src/ecs/ordinary-event-declaration.bend as Event
import /tmp/bendvy-failedtxn-matched-method/src/ecs/relation-commands.bend as Notice

type Family is Data:
  Family{ping:Leaf.Stream<T.MotionSchema,E.event_type()>}
def Context() -> Type:Route.Runtime<T.MotionSchema,F.Store(),F.Resources(),E.event_type(),Mixed.State<T.MotionSchema,Nat,Family,Unit>>
def ping_declaration() -> Event.Declaration<T.MotionSchema,E.event_type()>:Event.read(~T.MotionSchema,~E.event_type(),Event.domain(~T.MotionSchema,~E.event_type(),"ping"))
def take_ping(value:Family) -> Family & Leaf.Stream<T.MotionSchema,E.event_type()>:
  match value:
    case Family{+ping}:(Family{ping},ping)
def put_ping(_:Family,ping:Leaf.Stream<T.MotionSchema,E.event_type()>) -> Family:Family{ping}
def select(values:List<&2,Nat>) -> List<&2,E.event_type()>:
  match values:
    case []:[]
    case value <> rest:Notice.Original{value} <> select(rest)
def sync(family:Family,tick:Nat,values:List<&2,Nat>) -> Family:
  match family:
    case Family{ping}:Family{Leaf.append(~T.MotionSchema,~E.event_type(),ping,tick,select(values))}
def start(world:F.World()) -> Context():
  Mixed.start(~T.MotionSchema,~F.Store(),~F.Resources(),~Nat,~Family,~Unit,world,Family{Leaf.provision(~T.MotionSchema,~E.event_type(),Event.domain(~T.MotionSchema,~E.event_type(),"ping"),65536n)},Unit{})

import Base
import types.bend as T
import health-events.bend as E
import health.bend as F
import ../../../../src/ecs/event-stream.bend as Leaf
import ../../../../src/ecs/ordinary-event-declaration.bend as Event
import ../../../../src/ecs/event-notice-runtime.bend as Mixed
import ../../../../src/ecs/event-family-routing.bend as Route
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/relation-commands.bend as Notice

type Family is Data:
  Family{ping:Leaf.Stream<T.HealthSchema,E.event_type()>,removed:Leaf.Stream<T.HealthSchema,E.event_type()>,despawned:Leaf.Stream<T.HealthSchema,E.event_type()>}
def Context() -> Type:Route.Runtime<T.HealthSchema,F.Store(),F.Resources(),E.event_type(),Mixed.State<T.HealthSchema,E.Publication,Family,Unit>>
def ping_declaration() -> Event.Declaration<T.HealthSchema,E.event_type()>:Event.read(~T.HealthSchema,~E.event_type(),Event.domain(~T.HealthSchema,~E.event_type(),"ping"))
def take_ping(family:Family) -> Family & Leaf.Stream<T.HealthSchema,E.event_type()>:
  match family:
    case Family{+a,+b,+c}:(Family{a,b,c},a)
def put_ping(family:Family,value:Leaf.Stream<T.HealthSchema,E.event_type()>) -> Family:
  match family:
    case Family{a,b,c}:Family{value,b,c}
def select_ping_value(+value:E.Publication,rest:List<&2,E.event_type()>) -> List<&2,E.event_type()>:
  match value:
    case E.Ping{_}:Notice.Original{value} <> rest
    case _:rest
def select_ping(values:List<&2,E.Publication>) -> List<&2,E.event_type()>:
  match values:
    case []:[]
    case +value <> rest:select_ping_value(value,select_ping(rest))
def removed_declaration() -> Event.Declaration<T.HealthSchema,E.event_type()>:Event.read(~T.HealthSchema,~E.event_type(),Event.domain(~T.HealthSchema,~E.event_type(),"removed"))
def take_removed(family:Family) -> Family & Leaf.Stream<T.HealthSchema,E.event_type()>:
  match family:
    case Family{+a,+b,+c}:(Family{a,b,c},b)
def put_removed(family:Family,value:Leaf.Stream<T.HealthSchema,E.event_type()>) -> Family:
  match family:
    case Family{a,b,c}:Family{a,value,c}
def select_removed_value(+value:E.Publication,rest:List<&2,E.event_type()>) -> List<&2,E.event_type()>:
  match value:
    case E.Removed{_}:Notice.Original{value} <> rest
    case _:rest
def select_removed(values:List<&2,E.Publication>) -> List<&2,E.event_type()>:
  match values:
    case []:[]
    case +value <> rest:select_removed_value(value,select_removed(rest))
def despawned_declaration() -> Event.Declaration<T.HealthSchema,E.event_type()>:Event.read(~T.HealthSchema,~E.event_type(),Event.domain(~T.HealthSchema,~E.event_type(),"despawned"))
def take_despawned(family:Family) -> Family & Leaf.Stream<T.HealthSchema,E.event_type()>:
  match family:
    case Family{+a,+b,+c}:(Family{a,b,c},c)
def put_despawned(family:Family,value:Leaf.Stream<T.HealthSchema,E.event_type()>) -> Family:
  match family:
    case Family{a,b,c}:Family{a,b,value}
def select_despawned_value(+value:E.Publication,rest:List<&2,E.event_type()>) -> List<&2,E.event_type()>:
  match value:
    case E.Despawned{_}:Notice.Original{value} <> rest
    case _:rest
def select_despawned(values:List<&2,E.Publication>) -> List<&2,E.event_type()>:
  match values:
    case []:[]
    case +value <> rest:select_despawned_value(value,select_despawned(rest))
def sync_copy(family:Family,+tick:Nat,+values:List<&2,E.Publication>) -> Family:
  match family:
    case Family{ping,removed,despawned}:Family{Leaf.append(~T.HealthSchema,~E.event_type(),ping,tick,select_ping(values)),Leaf.append(~T.HealthSchema,~E.event_type(),removed,tick,select_removed(values)),Leaf.append(~T.HealthSchema,~E.event_type(),despawned,tick,select_despawned(values))}
def sync(family:Family,tick:Nat,values:List<&2,E.Publication>) -> Family:sync_copy(family,tick,values)
def synchronize(world:F.World(),family:Mixed.State<T.HealthSchema,E.Publication,Family,Unit>,tick:Nat) -> F.World() & Mixed.State<T.HealthSchema,E.Publication,Family,Unit>:
  Mixed.synchronize(~T.HealthSchema,~F.Store(),~F.Resources(),~E.Publication,~Family,~Unit,~sync,world,family,tick)
def start(world:F.World()) -> Context():
  Mixed.start(~T.HealthSchema,~F.Store(),~F.Resources(),~E.Publication,~Family,~Unit,world,Family{Leaf.provision(~T.HealthSchema,~E.event_type(),Event.domain(~T.HealthSchema,~E.event_type(),"ping"),65536n),Leaf.provision(~T.HealthSchema,~E.event_type(),Event.domain(~T.HealthSchema,~E.event_type(),"removed"),65536n),Leaf.provision(~T.HealthSchema,~E.event_type(),Event.domain(~T.HealthSchema,~E.event_type(),"despawned"),65536n)},Unit{})
def frame_family(family:Family,+tick:Nat) -> Family:
  match family:
    case Family{ping,removed,despawned}:Family{Leaf.frame(~T.HealthSchema,~E.event_type(),ping,tick),Leaf.frame(~T.HealthSchema,~E.event_type(),removed,tick),Leaf.frame(~T.HealthSchema,~E.event_type(),despawned,tick)}
def frame_fn(family:Family,tick:Nat) -> Family:frame_family(family,tick)
def keep_record(+family:Family,tick:Nat,value:E.Publication) -> Bool:
  match family value:
    case Family{ping,_,_} E.Ping{_}:Nat.is_lt(Leaf.dropped(~T.HealthSchema,~E.event_type(),ping),tick)
    case Family{_,removed,_} E.Removed{_}:Nat.is_lt(Leaf.dropped(~T.HealthSchema,~E.event_type(),removed),tick)
    case Family{_,_,despawned} E.Despawned{_}:Nat.is_lt(Leaf.dropped(~T.HealthSchema,~E.event_type(),despawned),tick)
def retained_one(keep:Bool,value:E.Publication,rest:List<&2,E.Publication>) -> List<&2,E.Publication>:
  match keep:
    case True{}:value <> rest
    case False{}:rest
def retain_records(+family:Family,+tick:Nat,values:List<&2,E.Publication>) -> List<&2,E.Publication>:
  match values:
    case []:[]
    case +value <> rest:retained_one(keep_record(family,tick,value),value,retain_records(family,tick,rest))
def retain(family:Family,tick:Nat,values:List<&2,E.Publication>) -> Family & List<&2,E.Publication>:
  +copy=family
  (copy,retain_records(copy,tick,values))
def frame(context:Context()) -> Context():Mixed.frame(~T.HealthSchema,~F.Store(),~F.Resources(),~E.Publication,~Family,~Unit,~frame_fn,~retain,context)

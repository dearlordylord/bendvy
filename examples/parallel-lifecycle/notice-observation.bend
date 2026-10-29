import Base
import ../parallel-query/declarations.bend as D
import ../parallel-query/observation.bend as Observe
import ../../src/ecs/execution-lifecycle-notices.bend as Notice
import ../../src/ecs/world.bend as W
import ../../src/ecs/entity-allocator.bend as A
import ../../src/ecs/clock-state.bend as Clock
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/deferred-command.bend as Deferred

def selector(value:Notice.Selector) -> String:
  match value:
    case Notice.Removed{key}:"removed/" ++ key
    case Notice.Despawned{}:"despawn"
def identity(~S:Data,value:Notice.Identity<S>) -> String:
  match value:
    case Notice.Identity{namespace,key}:U32.show(namespace) ++ ":" ++ Observe.key(key)
def row(~S:Data,value:Notice.Row<S>) -> String:
  match value:
    case Notice.Row{sequence,entity,tick}:Nat.show(sequence) ++ ":" ++ identity(~S,entity) ++ "@" ++ Tick.show(tick)
def channel(~S:Data,value:Notice.Channel<S>) -> String:
  match value:
    case Notice.Channel{kind,next,previous,current,floor}:"{" ++ selector(kind) ++ ",next=" ++ Nat.show(next) ++ ",floor=" ++ Nat.show(floor) ++ ",previous=" ++ List.show(&2,Notice.Row<S>,row(~S),previous) ++ ",current=" ++ List.show(&2,Notice.Row<S>,row(~S),current) ++ "}"
def active(value:Notice.Active) -> String:
  match value:
    case Notice.Active{id,kind}:U32.show(id) ++ ":" ++ selector(kind)
def journal(~S:Data,value:Notice.Journal<S>) -> Notice.Journal<S> & String:
  match value:
    case Notice.Journal{+namespace,+channels,+nextReader,+readers}:(Notice.Journal{namespace,channels,nextReader,readers},"namespace=" ++ U32.show(namespace) ++ ";next-reader=" ++ U32.show(nextReader) ++ ";active=" ++ List.show(&2,Notice.Active,active,readers) ++ ";channels=" ++ List.show(&2,Notice.Channel<S>,channel(~S),channels))
def world_returned(~S:Data,namespace:U32,allocator:A.Allocator,store:D.Store(~S),resource:D.Resources(~S),events:List<&2,Unit>,pending:List<Deferred.Command<W.World<S,D.Store(~S),D.Resources(~S),Unit>>>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:Clock.State,result:Notice.Journal<S> & String) -> String:
  match result:
    case (journal,text):"journal={" ++ text ++ "};state={" ++ Observe.world(~S,W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,journal}) ++ "}"
def world(~S:Data,value:W.World<S,D.Store(~S),D.Resources(~S),Unit>) -> String:
  match value:
    case W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,lifecycle}:world_returned(~S,namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,journal(~S,lifecycle))

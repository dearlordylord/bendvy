import Base
import ../../../src/ecs/entity-key.bend as Key
import ../../../src/ecs/event-runtime.bend as Ev
import ../../../src/ecs/event-stream.bend as Stream

# Independent Data specification. No production equality/position helper calls.
def key_generation(equal:Bool,left:U32,right:U32) -> Bool:
  match equal:
    case False{}:False{}
    case True{}:U32.is_eq(left,right)
def key_equal(left:Key.Key,right:Key.Key) -> Bool:
  match left right:
    case Key.EntityKey{li,lg} Key.EntityKey{ri,rg}:key_generation(U32.is_eq(li,ri),lg,rg)
def has_id(values:List<&2,Ev.Position>,+id:U32) -> Bool:
  match values:
    case []:False{}
    case Ev.Position{actual,_,_} <> rest:Bool.or(U32.is_eq(actual,id),has_id(rest,id))
def activated(present:Bool,values:List<&2,Ev.Position>,id:U32,tick:Nat) -> List<&2,Ev.Position>:
  match present:
    case True{}:values
    case False{}:Ev.Position{id,0n,Nat.sub(tick,1n)} <> values
def selected_position(selected:Bool,cursor:Nat,registered:Nat,actual:U32,old:Nat) -> Ev.Position:
  match selected:
    case False{}:Ev.Position{actual,old,registered}
    case True{}:Ev.Position{actual,cursor,registered}
def updated(values:List<&2,Ev.Position>,+id:U32,+tick:Nat) -> List<&2,Ev.Position>:
  match values:
    case []:[]
    case Ev.Position{+actual,old,registered} <> rest:selected_position(U32.is_eq(actual,id),tick,registered,actual,old) <> updated(rest,id,tick)
def completed_active(success:Bool,values:List<&2,Ev.Position>,id:U32,tick:Nat) -> List<&2,Ev.Position>:
  match success:
    case False{}:values
    case True{}:updated(values,id,tick)
def positions(success:Bool,+values:List<&2,Ev.Position>,+id:U32,+tick:Nat) -> List<&2,Ev.Position>:
  completed_active(success,activated(has_id(values,id),values,id,tick),id,tick)
def completed(~S:Data,~E:Data,value:Stream.Stream<S,E>,id:U32,tick:Nat,success:Bool) -> Stream.Stream<S,E>:
  match value:
    case Stream.Stream{domain,batches,readers,next,frame,boundary,capacity,dropped}:Stream.Stream{domain,batches,positions(success,readers,id,tick),next,frame,boundary,capacity,dropped}
def advanced(~S:Data,~E:Data,value:Stream.Stream<S,E>,id:U32,tick:Nat) -> Stream.Stream<S,E>:
  completed(~S,~E,value,id,tick,True{})

import Base
import ./machine-stream-queue.bend as Queue
import ./change-tick.bend as Tick

# Shared message storage. Sequence numbers are independent of World ticks.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/message/message_cursor.rs#L54-L63
# Behavior: each reader tracks message count, independently of change ticks.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/message/messages.rs#L188-L201
# Behavior: every update removes the older generation and rotates the retained one.
type Store<-E:Data> is Data:
  Store{queue:Queue.Queue<E>,olderThrough:Nat,maintenance:Maybe<&2,Tick.Tick>}
type Reading<E:Data> is Data:
  Read{cursor:Nat,events:List<&2,E>,missed:Nat,tick:Tick.Tick}
  Refused{}
def empty(~E:Data) -> Store<E>:Store{Queue.empty(~E),0n,None{}}
def publish(~E:Data,store:Store<E>,sequence:Nat,event:E) -> Store<E>:
  match store:
    case Store{queue,olderThrough,maintenance}:Store{Queue.publish(~E,queue,sequence,[event]),olderThrough,maintenance}
def push(~E:Data,+sequence:Nat,store:Store<E>,event:E) -> Nat & Store<E>:
  (1n+sequence,publish(~E,store,1n+sequence,event))
def maintained(~E:Data,+sequence:Nat,tick:Tick.Tick,olderThrough:Nat,queue:Queue.Queue<E>) -> Store<E>:
  match queue:
    case Queue.Queue{front,back,size,dropped,+batches}:Store{Queue.past_loop(~E,1n+batches,Queue.Queue{front,back,size,dropped,batches},olderThrough),sequence,Some{tick}}
def maintain(~E:Data,sequence:Nat,tick:Tick.Tick,store:Store<E>) -> Store<E>:
  match store:
    case Store{queue,olderThrough,_}:maintained(~E,sequence,tick,olderThrough,queue)
def missed(~E:Data,queue:Queue.Queue<E>,cursor:Nat) -> Nat:
  match queue:
    case Queue.Queue{_,_,_,dropped,_}:Nat.sub(dropped,cursor)
def reading(~E:Data,+sequence:Nat,tick:Tick.Tick,+cursor:Nat,store:Store<E>) -> Store<E> & Reading<E>:
  match store:
    case Store{+queue,olderThrough,maintenance}:(Store{queue,olderThrough,maintenance},Read{sequence,Queue.read(~E,queue,cursor),missed(~E,queue,cursor),tick})
def checked(~E:Data,allowed:Bool,sequence:Nat,tick:Tick.Tick,cursor:Nat,store:Store<E>) -> Store<E> & Reading<E>:
  match allowed:
    case False{}:(store,Refused{})
    case True{}:reading(~E,sequence,tick,cursor,store)
def read(~E:Data,namespace:Maybe<&2,U32>,actual:U32,sequence:Nat,tick:Tick.Tick,cursor:Nat,store:Store<E>) -> Store<E> & Reading<E>:
  match namespace:
    case None{}:(store,Refused{})
    case Some{namespace}:checked(~E,U32.is_eq(namespace,actual),sequence,tick,cursor,store)

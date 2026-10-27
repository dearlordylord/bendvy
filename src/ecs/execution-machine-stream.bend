import Base
import ./machine.bend as M
import ./machine-stream-queue.bend as Queue
import ./execution-composer-layout.bend as Layout
import ./change-tick.bend as Tick

# Bevy uses monotone message counts, independently of World change ticks:
# https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/message/message_cursor.rs#L54-L63
# olderThrough records the previous/current buffer split. Maintenance clears
# the older generation and makes all retained messages the older generation:
# https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/message/messages.rs#L188-L201
type Store<-V:Data> is Data:
  Store{queue:Queue.Queue<M.Transition<V>>,olderThrough:Nat,maintenance:Maybe<&2,Tick.Tick>}
type Reader<-S:Data,-K:Data,-V:Data,-origin:Layout.Layout,-route:Layout.Route> is Type:
  Reader{namespace:U32,id:U32,cursor:Nat}
type Reading<-S:Data,-K:Data,-V:Data,-origin:Layout.Layout,-route:Layout.Route> is Type:
  Read{reader:Reader<S,K,V,origin,route>,events:List<&2,M.Transition<V>>,missed:Nat,tick:Tick.Tick}
  Refused{reader:Reader<S,K,V,origin,route>}
def empty(~V:Data) -> Store<V>:Store{Queue.empty(~M.Transition<V>),0n,None{}}
def publish(~V:Data,store:Store<V>,sequence:Nat,event:M.Transition<V>) -> Store<V>:
  match store:
    case Store{queue,olderThrough,maintenance}:Store{Queue.publish(~M.Transition<V>,queue,sequence,[event]),olderThrough,maintenance}
def maintained(~V:Data,+sequence:Nat,tick:Tick.Tick,olderThrough:Nat,queue:Queue.Queue<M.Transition<V>>) -> Store<V>:
  match queue:
    case Queue.Queue{front,back,size,dropped,+batches}:Store{Queue.past_loop(~M.Transition<V>,1n+batches,Queue.Queue{front,back,size,dropped,batches},olderThrough),sequence,Some{tick}}
def maintain(~V:Data,sequence:Nat,tick:Tick.Tick,store:Store<V>) -> Store<V>:
  match store:
    case Store{queue,olderThrough,_}:maintained(~V,sequence,tick,olderThrough,queue)
def missed(~V:Data,queue:Queue.Queue<M.Transition<V>>,cursor:Nat) -> Nat:
  match queue:
    case Queue.Queue{_,_,_,dropped,_}:Nat.sub(dropped,cursor)
def reading(~S:Data,~K:Data,~V:Data,~origin:Layout.Layout,~route:Layout.Route,+sequence:Nat,tick:Tick.Tick,reader:Reader<S,K,V,origin,route>,store:Store<V>) -> Store<V> & Reading<S,K,V,origin,route>:
  match reader store:
    case Reader{namespace,id,+cursor} Store{+queue,olderThrough,maintenance}:(Store{queue,olderThrough,maintenance},Read{Reader{namespace,id,sequence},Queue.read(~M.Transition<V>,queue,cursor),missed(~V,queue,cursor),tick})
def checked(~S:Data,~K:Data,~V:Data,~origin:Layout.Layout,~route:Layout.Route,allowed:Bool,sequence:Nat,tick:Tick.Tick,reader:Reader<S,K,V,origin,route>,store:Store<V>) -> Store<V> & Reading<S,K,V,origin,route>:
  match allowed:
    case False{}:(store,Refused{reader})
    case True{}:reading(~S,~K,~V,~origin,~route,sequence,tick,reader,store)
def read(~S:Data,~K:Data,~V:Data,~origin:Layout.Layout,~route:Layout.Route,namespace:Maybe<&2,U32>,sequence:Nat,tick:Tick.Tick,reader:Reader<S,K,V,origin,route>,store:Store<V>) -> Store<V> & Reading<S,K,V,origin,route>:
  match namespace reader:
    case None{} reader:(store,Refused{reader})
    case Some{namespace} Reader{+actual,id,cursor}:checked(~S,~K,~V,~origin,~route,U32.is_eq(namespace,actual),sequence,tick,Reader{actual,id,cursor},store)

import Base
import ./machine.bend as M
import ./machine-stream-queue.bend as Queue
import ./execution-stream-channel.bend as Channel
import ./execution-composer-layout.bend as Layout
import ./change-tick.bend as Tick

# Public machine constructors retain their existing shape. Message sequence,
# namespace checks, reading and two-generation retention use the shared channel.
type Store<-V:Data> is Data:
  Store{queue:Queue.Queue<M.Transition<V>>,olderThrough:Nat,maintenance:Maybe<&2,Tick.Tick>}
type Reader<-S:Data,-K:Data,-V:Data,-origin:Layout.Layout,-route:Layout.Route> is Type:
  Reader{namespace:U32,id:U32,cursor:Nat}
type Reading<-S:Data,-K:Data,-V:Data,-origin:Layout.Layout,-route:Layout.Route> is Type:
  Read{reader:Reader<S,K,V,origin,route>,events:List<&2,M.Transition<V>>,missed:Nat,tick:Tick.Tick}
  Refused{reader:Reader<S,K,V,origin,route>}
def channel(~V:Data,store:Store<V>) -> Channel.Store<M.Transition<V>>:
  match store:
    case Store{queue,olderThrough,maintenance}:Channel.Store{queue,olderThrough,maintenance}
def stored(~V:Data,store:Channel.Store<M.Transition<V>>) -> Store<V>:
  match store:
    case Channel.Store{queue,olderThrough,maintenance}:Store{queue,olderThrough,maintenance}
def empty(~V:Data) -> Store<V>:stored(~V,Channel.empty(~M.Transition<V>))
def publish(~V:Data,store:Store<V>,sequence:Nat,event:M.Transition<V>) -> Store<V>:
  stored(~V,Channel.publish(~M.Transition<V>,channel(~V,store),sequence,event))
def maintained(~V:Data,+sequence:Nat,tick:Tick.Tick,olderThrough:Nat,queue:Queue.Queue<M.Transition<V>>) -> Store<V>:
  stored(~V,Channel.maintained(~M.Transition<V>,sequence,tick,olderThrough,queue))
def maintain(~V:Data,sequence:Nat,tick:Tick.Tick,store:Store<V>) -> Store<V>:
  stored(~V,Channel.maintain(~M.Transition<V>,sequence,tick,channel(~V,store)))
def missed(~V:Data,queue:Queue.Queue<M.Transition<V>>,cursor:Nat) -> Nat:
  Channel.missed(~M.Transition<V>,queue,cursor)
def returned(~S:Data,~K:Data,~V:Data,~origin:Layout.Layout,~route:Layout.Route,reader:Reader<S,K,V,origin,route>,result:Channel.Store<M.Transition<V>> & Channel.Reading<M.Transition<V>>) -> Store<V> & Reading<S,K,V,origin,route>:
  match reader result:
    case reader, (store,Channel.Refused{}):(stored(~V,store),Refused{reader})
    case Reader{namespace,id,_}, (store,Channel.Read{cursor,events,missed,tick}):(stored(~V,store),Read{Reader{namespace,id,cursor},events,missed,tick})
def reading(~S:Data,~K:Data,~V:Data,~origin:Layout.Layout,~route:Layout.Route,+sequence:Nat,tick:Tick.Tick,reader:Reader<S,K,V,origin,route>,store:Store<V>) -> Store<V> & Reading<S,K,V,origin,route>:
  match reader:
    case Reader{namespace,id,+cursor}:returned(~S,~K,~V,~origin,~route,Reader{namespace,id,cursor},Channel.reading(~M.Transition<V>,sequence,tick,cursor,channel(~V,store)))
def checked(~S:Data,~K:Data,~V:Data,~origin:Layout.Layout,~route:Layout.Route,allowed:Bool,sequence:Nat,tick:Tick.Tick,reader:Reader<S,K,V,origin,route>,store:Store<V>) -> Store<V> & Reading<S,K,V,origin,route>:
  match reader:
    case Reader{namespace,id,+cursor}:returned(~S,~K,~V,~origin,~route,Reader{namespace,id,cursor},Channel.checked(~M.Transition<V>,allowed,sequence,tick,cursor,channel(~V,store)))
def read(~S:Data,~K:Data,~V:Data,~origin:Layout.Layout,~route:Layout.Route,namespace:Maybe<&2,U32>,sequence:Nat,tick:Tick.Tick,reader:Reader<S,K,V,origin,route>,store:Store<V>) -> Store<V> & Reading<S,K,V,origin,route>:
  match reader:
    case Reader{+actual,id,+cursor}:returned(~S,~K,~V,~origin,~route,Reader{actual,id,cursor},Channel.read(~M.Transition<V>,namespace,actual,sequence,tick,cursor,channel(~V,store)))

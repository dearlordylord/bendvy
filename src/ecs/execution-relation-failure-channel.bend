import Base
import ./relation-types.bend as T
import ./execution-relation-failure-message.bend as Failure
import ./execution-stream-channel.bend as Channel
import ./execution-composer-layout.bend as Layout
import ./change-tick.bend as Tick

type Reader<-S:Data,-descriptor:T.Descriptor<S>,-origin:Layout.Layout,-route:Layout.Route> is Type:
  Reader{namespace:U32,id:U32,cursor:Nat}
type Reading<-S:Data,-descriptor:T.Descriptor<S>,-origin:Layout.Layout,-route:Layout.Route> is Type:
  Read{reader:Reader<S,descriptor,origin,route>,messages:List<&2,Failure.Message<S,descriptor>>,missed:Nat,tick:Tick.Tick}
  Refused{reader:Reader<S,descriptor,origin,route>}
def returned(~S:Data,~descriptor:T.Descriptor<S>,~origin:Layout.Layout,~route:Layout.Route,reader:Reader<S,descriptor,origin,route>,result:Channel.Store<Failure.Message<S,descriptor>> & Channel.Reading<Failure.Message<S,descriptor>>) -> Channel.Store<Failure.Message<S,descriptor>> & Reading<S,descriptor,origin,route>:
  match reader result:
    case reader, (store,Channel.Refused{}):(store,Refused{reader})
    case Reader{namespace,id,_}, (store,Channel.Read{cursor,messages,missed,tick}):(store,Read{Reader{namespace,id,cursor},messages,missed,tick})
def read(~S:Data,~descriptor:T.Descriptor<S>,~origin:Layout.Layout,~route:Layout.Route,namespace:U32,sequence:Nat,tick:Tick.Tick,reader:Reader<S,descriptor,origin,route>,channel:Channel.Store<Failure.Message<S,descriptor>>) -> Channel.Store<Failure.Message<S,descriptor>> & Reading<S,descriptor,origin,route>:
  match reader:
    case Reader{+actual,id,+cursor}:returned(~S,~descriptor,~origin,~route,Reader{actual,id,cursor},Channel.read(~Failure.Message<S,descriptor>,Some{namespace},actual,sequence,tick,cursor,channel))

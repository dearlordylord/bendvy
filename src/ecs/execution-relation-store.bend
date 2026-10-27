import Base
import ./entity-allocator.bend as A
import ./relation-types.bend as T
import ./execution-relation-operation.bend as O
import ./execution-relation-interpreter.bend as I
import ./execution-relation-failure-message.bend as Failure
import ./execution-relation-failure-channel.bend as Reader
import ./execution-stream-channel.bend as Channel
import ./execution-composer-layout.bend as Layout
import ./change-tick.bend as Tick

# Constructors and mutation functions are trusted provisioning/barrier helpers.
# Gameplay receives only operations over an abstract H, never this owner.
type Store<-S:Data,-descriptor:T.Descriptor<S>> is Type:
  Store{namespace:U32,graph:T.Graph<S>,failures:Channel.Store<Failure.Message<S,descriptor>>,sequence:Nat,nextReader:U32}
type View<-S:Data,-descriptor:T.Descriptor<S>> is Data:
  View{namespace:U32,graph:T.Graph<S>}
type Reason is Data:
  NamespaceMismatch{}
  OperationRefused{reason:O.Reason}
type Receipt<S:Data> is Data:
  Applied{operation:O.Operation<S>}
  Refused{operation:O.Operation<S>,reason:Reason}
type Registration<-S:Data,-descriptor:T.Descriptor<S>,-origin:Layout.Layout,-route:Layout.Route> is Type:
  Registered{store:Store<S,descriptor>,reader:Reader.Reader<S,descriptor,origin,route>}
  RegistrationRefused{store:Store<S,descriptor>}
def fresh(~S:Data,~descriptor:T.Descriptor<S>,namespace:U32) -> Store<S,descriptor>:
  Store{namespace,T.Graph{[],[]},Channel.empty(~Failure.Message<S,descriptor>),0n,1}
def project(~S:Data,~descriptor:T.Descriptor<S>,store:Store<S,descriptor>) -> Store<S,descriptor> & View<S,descriptor>:
  match store:
    case Store{+namespace,+graph,failures,sequence,nextReader}:(Store{namespace,graph,failures,sequence,nextReader},View{namespace,graph})
def published(~S:Data,~descriptor:T.Descriptor<S>,namespace:U32,graph:T.Graph<S>,nextReader:U32,allocator:A.Allocator,operation:O.Operation<S>,reason:O.Reason,result:Nat & Channel.Store<Failure.Message<S,descriptor>>) -> A.Allocator & (Store<S,descriptor> & Receipt<S>):
  match result:
    case (sequence,failures):(allocator,(Store{namespace,graph,failures,sequence,nextReader},Refused{operation,OperationRefused{reason}}))
def publish(~S:Data,~descriptor:T.Descriptor<S>,namespace:U32,graph:T.Graph<S>,failures:Channel.Store<Failure.Message<S,descriptor>>,sequence:Nat,nextReader:U32,allocator:A.Allocator,operation:O.Operation<S>,reason:O.Reason,message:Maybe<&2,Failure.Message<S,descriptor>>) -> A.Allocator & (Store<S,descriptor> & Receipt<S>):
  match message:
    case None{}:(allocator,(Store{namespace,graph,failures,sequence,nextReader},Refused{operation,OperationRefused{reason}}))
    case Some{message}:published(~S,~descriptor,namespace,graph,nextReader,allocator,operation,reason,Channel.push(~Failure.Message<S,descriptor>,sequence,failures,message))
def interpreted(~S:Data,~descriptor:T.Descriptor<S>,namespace:U32,failures:Channel.Store<Failure.Message<S,descriptor>>,sequence:Nat,nextReader:U32,result:A.Allocator & O.Outcome<S>) -> A.Allocator & (Store<S,descriptor> & Receipt<S>):
  match result:
    case (allocator,O.Applied{graph,operation}):(allocator,(Store{namespace,graph,failures,sequence,nextReader},Applied{operation}))
    case (allocator,O.Refused{graph,+operation,+reason}):publish(~S,~descriptor,namespace,graph,failures,sequence,nextReader,allocator,operation,reason,Failure.refused(~S,~descriptor,operation,reason))
def admitted(~S:Data,~descriptor:T.Descriptor<S>,same:Bool,+namespace:U32,allocator:A.Allocator,store:Store<S,descriptor>,operation:O.Operation<S>) -> A.Allocator & (Store<S,descriptor> & Receipt<S>):
  match same store:
    case False{} store:(allocator,(store,Refused{operation,NamespaceMismatch{}}))
    case True{} Store{_,graph,failures,sequence,nextReader}:interpreted(~S,~descriptor,namespace,failures,sequence,nextReader,I.apply(~S,~descriptor,namespace,allocator,graph,operation))
def apply(~S:Data,~descriptor:T.Descriptor<S>,+namespace:U32,allocator:A.Allocator,store:Store<S,descriptor>,operation:O.Operation<S>) -> A.Allocator & (Store<S,descriptor> & Receipt<S>):
  match store:
    case Store{+storedNamespace,graph,failures,sequence,nextReader}:admitted(~S,~descriptor,U32.is_eq(namespace,storedNamespace),namespace,allocator,Store{storedNamespace,graph,failures,sequence,nextReader},operation)
def register_checked(~S:Data,~descriptor:T.Descriptor<S>,~origin:Layout.Layout,~route:Layout.Route,available:Bool,store:Store<S,descriptor>) -> Registration<S,descriptor,origin,route>:
  match available store:
    case False{} store:RegistrationRefused{store}
    case True{} Store{+namespace,graph,failures,sequence,+nextReader}:Registered{Store{namespace,graph,failures,sequence,(nextReader + 1 : U32)},Reader.Reader{namespace,nextReader,0n}}
def register(~S:Data,~descriptor:T.Descriptor<S>,~origin:Layout.Layout,~route:Layout.Route,store:Store<S,descriptor>) -> Registration<S,descriptor,origin,route>:
  match store:
    case Store{namespace,graph,failures,sequence,+nextReader}:register_checked(~S,~descriptor,~origin,~route,U32.is_lt(nextReader,4294967295),Store{namespace,graph,failures,sequence,nextReader})
def maintained(~S:Data,~descriptor:T.Descriptor<S>,tick:Tick.Tick,store:Store<S,descriptor>) -> Store<S,descriptor>:
  match store:
    case Store{namespace,graph,failures,+sequence,nextReader}:Store{namespace,graph,Channel.maintain(~Failure.Message<S,descriptor>,sequence,tick,failures),sequence,nextReader}

import Base
import ./entity-allocator.bend as A
import ./relation-types.bend as T
import ./execution-relation-operation.bend as O
import ./execution-relation-interpreter.bend as I

# Constructors and mutation functions are trusted provisioning/barrier helpers.
# Gameplay receives only operations over an abstract H, never this owner.
type Store<-S:Data,-descriptor:T.Descriptor<S>> is Type:
  Store{namespace:U32,graph:T.Graph<S>}
type View<-S:Data,-descriptor:T.Descriptor<S>> is Data:
  View{namespace:U32,graph:T.Graph<S>}
type Reason is Data:
  NamespaceMismatch{}
  OperationRefused{reason:O.Reason}
type Receipt<S:Data> is Data:
  Applied{operation:O.Operation<S>}
  Refused{operation:O.Operation<S>,reason:Reason}
def fresh(~S:Data,~descriptor:T.Descriptor<S>,namespace:U32) -> Store<S,descriptor>:
  Store{namespace,T.Graph{[],[]}}
def project(~S:Data,~descriptor:T.Descriptor<S>,store:Store<S,descriptor>) -> Store<S,descriptor> & View<S,descriptor>:
  match store:
    case Store{+namespace,+graph}:(Store{namespace,graph},View{namespace,graph})
def interpreted(~S:Data,~descriptor:T.Descriptor<S>,namespace:U32,result:A.Allocator & O.Outcome<S>) -> A.Allocator & (Store<S,descriptor> & Receipt<S>):
  match result:
    case (allocator,O.Applied{graph,operation}):(allocator,(Store{namespace,graph},Applied{operation}))
    case (allocator,O.Refused{graph,operation,reason}):(allocator,(Store{namespace,graph},Refused{operation,OperationRefused{reason}}))
def admitted(~S:Data,~descriptor:T.Descriptor<S>,same:Bool,+namespace:U32,allocator:A.Allocator,store:Store<S,descriptor>,operation:O.Operation<S>) -> A.Allocator & (Store<S,descriptor> & Receipt<S>):
  match same store:
    case False{} store:(allocator,(store,Refused{operation,NamespaceMismatch{}}))
    case True{} Store{_,graph}:interpreted(~S,~descriptor,namespace,I.apply(~S,~descriptor,namespace,allocator,graph,operation))
def apply(~S:Data,~descriptor:T.Descriptor<S>,+namespace:U32,allocator:A.Allocator,store:Store<S,descriptor>,operation:O.Operation<S>) -> A.Allocator & (Store<S,descriptor> & Receipt<S>):
  match store:
    case Store{+storedNamespace,graph}:admitted(~S,~descriptor,U32.is_eq(namespace,storedNamespace),namespace,allocator,Store{storedNamespace,graph},operation)

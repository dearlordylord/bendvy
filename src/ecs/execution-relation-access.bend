import Base
import ./world.bend as W
import ./entity-key.bend as K
import ./relation-types.bend as T
import ./relation-graph.bend as Graph
import ./execution-relation-store.bend as Store
import ./execution-state.bend as State
import ./execution-lifecycle-notices.bend as Notice

type Lookup<V:Data> is Data:
  Value{value:V}
  MissingEntity{}
  NamespaceRefused{}
type Reader<-S:Data,-H:Type> is Type:
  Reader{target:H -> W.Handle<S> -> H & Lookup<Maybe<&2,W.Handle<S>>>,inverse:H -> W.Handle<S> -> H & Lookup<List<&2,W.Handle<S>>>}
def Reads(~S:Data,H:Type) -> Type:Reader<S,H>
def namespace(~S:Data,view:Notice.View<S>) -> U32:
  match view:
    case Notice.View{namespace,_,_}:namespace
def handle(~S:Data,namespace:U32,value:Maybe<&2,K.Key>) -> Maybe<&2,W.Handle<S>>:
  match value:
    case None{}:None{}
    case Some{key}:Some{W.Handle{namespace,key}}
def handles(~S:Data,+namespace:U32,keys:List<&2,K.Key>) -> List<&2,W.Handle<S>>:
  match keys:
    case []:[]
    case key <> rest:W.Handle{namespace,key} <> handles(~S,namespace,rest)
def target_namespace(~S:Data,same:Bool,namespace:U32,value:Maybe<&2,K.Key>) -> Lookup<Maybe<&2,W.Handle<S>>>:
  match same:
    case False{}:NamespaceRefused{}
    case True{}:Value{handle(~S,namespace,value)}
def target_view(~S:Data,~descriptor:T.Descriptor<S>,+expected:U32,source:W.Handle<S>,view:Store.View<S,descriptor>) -> Lookup<Maybe<&2,W.Handle<S>>>:
  match view:
    case Store.View{+actual,graph,_,_,_}:target_namespace(~S,U32.is_eq(expected,actual),actual,Graph.target(~S,graph,descriptor,W.handle_key(~S,source)))
def inverse_namespace(~S:Data,same:Bool,namespace:U32,keys:List<&2,K.Key>) -> Lookup<List<&2,W.Handle<S>>>:
  match same:
    case False{}:NamespaceRefused{}
    case True{}:Value{handles(~S,namespace,keys)}
def inverse_view(~S:Data,~descriptor:T.Descriptor<S>,+expected:U32,target:W.Handle<S>,view:Store.View<S,descriptor>) -> Lookup<List<&2,W.Handle<S>>>:
  match view:
    case Store.View{+actual,graph,_,_,_}:inverse_namespace(~S,U32.is_eq(expected,actual),actual,Graph.inverse(~S,graph,descriptor,W.handle_key(~S,target)))
def target_returned(~S:Data,~descriptor:T.Descriptor<S>,~H:Type,expected:U32,source:W.Handle<S>,result:H & Store.View<S,descriptor>) -> H & Lookup<Maybe<&2,W.Handle<S>>>:
  match result:
    case (owner,view):(owner,target_view(~S,~descriptor,expected,source,view))
def inverse_returned(~S:Data,~descriptor:T.Descriptor<S>,~H:Type,expected:U32,target:W.Handle<S>,result:H & Store.View<S,descriptor>) -> H & Lookup<List<&2,W.Handle<S>>>:
  match result:
    case (owner,view):(owner,inverse_view(~S,~descriptor,expected,target,view))
def target_checked(~S:Data,~descriptor:T.Descriptor<S>,~C:Type,~R:Type,~view:State.Scope<S,C,R> -> State.Scope<S,C,R> & Store.View<S,descriptor>,valid:Bool,expected:U32,scope:State.Scope<S,C,R>,source:W.Handle<S>) -> State.Scope<S,C,R> & Lookup<Maybe<&2,W.Handle<S>>>:
  match valid:
    case False{}:(scope,MissingEntity{})
    case True{}:target_returned(~S,~descriptor,~State.Scope<S,C,R>,expected,source,view(scope))
def inverse_checked(~S:Data,~descriptor:T.Descriptor<S>,~C:Type,~R:Type,~view:State.Scope<S,C,R> -> State.Scope<S,C,R> & Store.View<S,descriptor>,valid:Bool,expected:U32,scope:State.Scope<S,C,R>,target:W.Handle<S>) -> State.Scope<S,C,R> & Lookup<List<&2,W.Handle<S>>>:
  match valid:
    case False{}:(scope,MissingEntity{})
    case True{}:inverse_returned(~S,~descriptor,~State.Scope<S,C,R>,expected,target,view(scope))
def target(~S:Data,~descriptor:T.Descriptor<S>,~C:Type,~R:Type,~view:State.Scope<S,C,R> -> State.Scope<S,C,R> & Store.View<S,descriptor>,scope:State.Scope<S,C,R>,+source:W.Handle<S>) -> State.Scope<S,C,R> & Lookup<Maybe<&2,W.Handle<S>>>:
  match scope:
    case State.Scope{columns,resources,+live,tick,prior,+notice}:target_checked(~S,~descriptor,~C,~R,~view,State.member(~S,source,live),namespace(~S,notice),State.Scope{columns,resources,live,tick,prior,notice},source)
def inverse(~S:Data,~descriptor:T.Descriptor<S>,~C:Type,~R:Type,~view:State.Scope<S,C,R> -> State.Scope<S,C,R> & Store.View<S,descriptor>,scope:State.Scope<S,C,R>,+target:W.Handle<S>) -> State.Scope<S,C,R> & Lookup<List<&2,W.Handle<S>>>:
  match scope:
    case State.Scope{columns,resources,+live,tick,prior,+notice}:inverse_checked(~S,~descriptor,~C,~R,~view,State.member(~S,target,live),namespace(~S,notice),State.Scope{columns,resources,live,tick,prior,notice},target)
# Only the closed provider supplies view. Gameplay receives no store owner,
# graph setter, payload transform, inverse mutation, or concrete Scope type.
def reader(~S:Data,~descriptor:T.Descriptor<S>,~C:Type,~R:Type,~view:State.Scope<S,C,R> -> State.Scope<S,C,R> & Store.View<S,descriptor>) -> Reader<S,State.Scope<S,C,R>>:
  Reader{scope => source => target(~S,~descriptor,~C,~R,~view,scope,source),scope => target => inverse(~S,~descriptor,~C,~R,~view,scope,target)}
def target_field(~S:Data,~H:Type,cap:Reader<S,H>) -> H -> W.Handle<S> -> H & Lookup<Maybe<&2,W.Handle<S>>>:
  match cap:
    case Reader{target,_}:target
def inverse_field(~S:Data,~H:Type,cap:Reader<S,H>) -> H -> W.Handle<S> -> H & Lookup<List<&2,W.Handle<S>>>:
  match cap:
    case Reader{_,inverse}:inverse

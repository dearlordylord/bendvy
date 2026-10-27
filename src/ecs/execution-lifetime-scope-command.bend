import Base
import ./world.bend as W
import ./lifetime-scope.bend as Scope
import ./execution-composer-layout.bend as Layout

type Operation<-S:Data> is Data:
  Assign{scope:Scope.Scope<S>,handle:W.Handle<S>}
  Cleanup{scope:Scope.Scope<S>}
type Commands<-Q:Type,-S:Data> is Type:
  Commands{assign:Q -> Scope.Scope<S> -> W.Handle<S> -> Q,cleanup:Q -> Scope.Scope<S> -> Q}
def provide(~S:Data,~Q:Type,~route:Layout.Route,~enqueue:Q -> Layout.Route -> Operation<S> -> Q) -> Commands<Q,S>:
  Commands{queue => scope => handle => enqueue(queue,route,Assign{scope,handle}),queue => scope => enqueue(queue,route,Cleanup{scope})}
def assign_field(~S:Data,~Q:Type,commands:Commands<Q,S>) -> Q -> Scope.Scope<S> -> W.Handle<S> -> Q:
  match commands:
    case Commands{assign,_}:assign
def cleanup_field(~S:Data,~Q:Type,commands:Commands<Q,S>) -> Q -> Scope.Scope<S> -> Q:
  match commands:
    case Commands{_,cleanup}:cleanup

import Base
import ./execution-access.bend as Access
import ./world.bend as W
import ./state.bend as State
import ./component.bend as Component
import ./capabilities.bend as Cap

# Existing State.observed compares declared endpoints against the immediate
# canonical checked read before deciding whether to invoke a canonical modifier.
# No payload owner or raw replacement operation is returned to an ordinary body.
type Operations<-S:Data,-K:Data,-V:Data,-Move:Data,-H:Type> is Type:
  Operations{move:H -> W.Handle<S> -> Move -> H & State.Outcome<V,Unit>}
def Ops(~S:Data,~K:Data,~V:Data,~Move:Data,Permit:Data,H:Type) -> Type:Operations<S,K,V,Move,H>
def Modifier(~S:Data,~H:Type,~P:Type,~V:Data) -> Type:
  (P -> P & V) -> H -> W.Handle<S> -> H & Maybe<&2,V>
type MoveOwner<-S:Data,-H:Type,-P:Type,-V:Data> is Type:
  MoveOwner{scope:H,handle:W.Handle<S>,modifier:Maybe<&1,Modifier(~S,~H,~P,~V)>}
def write_result(~S:Data,~H:Type,~P:Type,~V:Data,handle:W.Handle<S>,result:H & Maybe<&2,V>) -> MoveOwner<S,H,P,V> & State.WriteStatus<Unit>:
  match result:
    case (scope,None{}):(MoveOwner{scope,handle,None{}},State.WriteRejected{Unit{}})
    case (scope,Some{_}):(MoveOwner{scope,handle,None{}},State.WriteAccepted{})
def write_owner(~S:Data,~H:Type,~P:Type,~V:Data,~update:V -> P -> P & V,owner:MoveOwner<S,H,P,V>,value:V) -> MoveOwner<S,H,P,V> & State.WriteStatus<Unit>:
  match owner:
    case MoveOwner{scope,handle,None{}}:(MoveOwner{scope,handle,None{}},State.WriteRejected{Unit{}})
    case MoveOwner{scope,+handle,Some{modify}}:write_result(~S,~H,~P,~V,handle,modify(update(value),scope,handle))
def completed(~S:Data,~H:Type,~P:Type,~V:Data,result:MoveOwner<S,H,P,V> & State.Outcome<V,Unit>) -> H & State.Outcome<V,Unit>:
  match result:
    case (MoveOwner{scope,_,_},outcome):(scope,outcome)
def endpoints_observed(~S:Data,~H:Type,~P:Type,~V:Data,~equal:V -> V -> Bool,~update:V -> P -> P & V,owner:MoveOwner<S,H,P,V>,actual:Component.Access<V>,endpoints:V & V) -> H & State.Outcome<V,Unit>:
  match endpoints:
    case (expected,target):completed(~S,~H,~P,~V,State.observed(~MoveOwner<S,H,P,V>,~V,~Unit,~equal,~Cap.Request{write_owner(~S,~H,~P,~V,~update)},expected,target,(owner,actual)))
def read_result(~S:Data,~H:Type,~P:Type,~V:Data,~Move:Data,~equal:V -> V -> Bool,~endpoints:Move -> V & V,~update:V -> P -> P & V,modify:Modifier(~S,~H,~P,~V),handle:W.Handle<S>,request:Move,result:H & Component.Access<V>) -> H & State.Outcome<V,Unit>:
  match result:
    case (scope,actual):endpoints_observed(~S,~H,~P,~V,~equal,~update,MoveOwner{scope,handle,Some{modify}},actual,endpoints(request))
def move(~S:Data,~H:Type,~P:Type,~V:Data,~Move:Data,~equal:V -> V -> Bool,~endpoints:Move -> V & V,~update:V -> P -> P & V,get:H -> W.Handle<S> -> H & Component.Access<V>,modify:Modifier(~S,~H,~P,~V),scope:H,handle:W.Handle<S>,request:Move) -> H & State.Outcome<V,Unit>:
  match handle:
    case +handle:read_result(~S,~H,~P,~V,~Move,~equal,~endpoints,~update,modify,handle,request,get(scope,handle))
def narrow(~S:Data,~K:Data,~H:Type,~P:Type,~V:Data,~Move:Data,~equal:V -> V -> Bool,~endpoints:Move -> V & V,~update:V -> P -> P & V,cap:Access.ComponentWrite<S,H,P,V>) -> Operations<S,K,V,Move,H>:
  match cap:
    case Access.ComponentWrite{_,modify,get}:Operations{move(~S,~H,~P,~V,~Move,~equal,~endpoints,~update,get,modify)}
def move_field(~S:Data,~K:Data,~H:Type,~V:Data,~Move:Data,cap:Operations<S,K,V,Move,H>) -> H -> W.Handle<S> -> Move -> H & State.Outcome<V,Unit>:
  match cap:
    case Operations{move}:move

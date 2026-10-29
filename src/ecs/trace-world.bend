import Base
import ./world.bend as W
import ./entity-key-render.bend as KeyRender
import ./trace-facts.bend as Facts

def error(error:W.WorldError) -> String:
  match error:
    case W.MissingEntity{}:"MissingEntity"
    case W.ReservationUnauthorized{}:"ReservationUnauthorized"
    case W.CapacityExceeded{}:"CapacityExceeded"
    case W.NamespaceExhausted{}:"NamespaceExhausted"
    case W.SystemIdExhausted{}:"SystemIdExhausted"
def handle(~S:Data,target:W.Handle<S>) -> String:
  match target:
    case W.Handle{namespace,key}:U32.show(namespace) ++ ":" ++ KeyRender.show(key)
def deferred(~S:Data,state:Facts.State,key:String,operation:Facts.Operation,target:W.Handle<S>,result:Facts.FactResult) -> Facts.State:
  match state:
    case Facts.Off{}:Facts.Off{}
    case Facts.On{facts}:Facts.On{Facts.Fact{Facts.DeferredCommand{},key,operation,Some{handle(~S,target)},Facts.OpaqueValue{},Facts.OpaqueValue{},result} <> facts}
def applied(~S:Data,state:Facts.State,key:String,target:W.Handle<S>,status:W.Status) -> Facts.State:
  match state status:
    case Facts.Off{} _:Facts.Off{}
    case state W.Accepted{}:deferred(~S,state,key,Facts.ApplyOperation{},target,Facts.Applied{})
    case state W.Rejected{why}:deferred(~S,state,key,Facts.ApplyOperation{},target,Facts.Refused{error(why)})

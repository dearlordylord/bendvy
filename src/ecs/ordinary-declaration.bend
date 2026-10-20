import Base
# One nominal ordinary schema declaration shared by component grants and gates.
# No storage/runtime imports and no user debug metadata adapter.
# Schema-scoped component declaration binding a key to payload type P.
# This Data value owns no component instance; keys must remain collision-free
# within a validated schema. It is not a runtime entity/world authority.
type Declaration<-S:Data,-P:Type> is Data:
  Declaration{key:String}
# Declare a component key for payload P in schema S. Does not create storage,
# spawn entities or validate collisions; compose and validate the schema before
# attaching an App. Example: examples/scheduled-health/registration.bend identities.
def component(~S:Data,~P:Type,key:String) -> Declaration<S,P>:
  Declaration{key}
# Return the authored component key without accessing any world or payload.
def key(~S:Data,~P:Type,declaration:Declaration<S,P>) -> String:
  match declaration:
    case Declaration{key}:key

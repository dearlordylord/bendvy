import Base
import ./positive.bend as P
import ../../../src/ecs/execution-command-local.bend as L
import ../../../src/ecs/world.bend as W

type Other is Type:
  Other{owner:Array<U32>}
def bad(~S:Data,~Q:Type,commands:L.Commands<Q,S,P.Token>,queue:Q,handle:W.Handle<S>,payload:Other) -> Q:
  L.insert_field(~Q,~S,~P.Token,commands)(queue,handle,payload)

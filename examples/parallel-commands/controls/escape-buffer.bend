import Base
import ./positive.bend as P
import ../../../src/ecs/execution-command-buffer.bend as B
import ../../../src/ecs/world.bend as W

def bad(~S:Data,~Q:Type,queue:Q,handle:W.Handle<S>,payload:P.Token) -> Q:
  B.insert(~S,~P.Token,queue,handle,payload)

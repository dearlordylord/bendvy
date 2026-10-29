import Base
import ./positive.bend as P
import ./registered.bend as Registered
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/execution-command-local.bend as Local
import ../../../src/ecs/execution-command-permission.bend as Permission

type Schema is Data:Schema{}
# A single-family declaration has no structural entity command capability.
def bad(~Permit:Data,~Q:Type,~commands:Local.Commands<Q,Schema,P.Token>,queue:Q,handle:W.Handle<Schema>) -> Q:
  Permission.despawn_field(~Q,~Schema,~(Registered.layout()),~Permit,commands)(queue,handle)

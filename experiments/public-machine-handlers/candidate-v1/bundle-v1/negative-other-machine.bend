import Base
import types.bend as T
import bundle.bend as B
import application.bend as App
import systems.bend as Systems
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/machine-handlers.bend as H
import ../../../../src/ecs/capabilities.bend as Cap
def denied(value:B.Selector<T.SchemaA,T.OtherMachineKey,T.State>) -> App.Spec<T.SchemaA>:
  App.OneSpec{value,[T.MachineRequirement{}],"wrong"}

import Base
import types.bend as T
import bundle.bend as B
import application.bend as App
import systems.bend as Systems
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/machine-handlers.bend as H
import ../../../../src/ecs/capabilities.bend as Cap
def denied(-F:Type,owner:F) -> F:
  App.frame(~T.SchemaA,owner)

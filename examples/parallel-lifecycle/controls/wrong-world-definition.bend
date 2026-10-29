import Base
import ./authority-case.bend as Case
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/execution-system.bend as Sys
import ../../../src/ecs/execution-parallel-system.bend as Task

def define(world:W.World<Case.Schema,Array<U32>,Unit,Unit>) -> Sys.Defined<W.World<Case.Schema,Unit,Unit,Unit>,Case.Owner(~Unit),Unit>:
  Task.define_framework(~Case.Schema,~Unit,~Unit,~Unit,~Unit,~Case.Ops,~Unit,~String,~Unit,~Case.program(~Unit),~Case.body,~Unit,world,"wrong-world",Unit{})

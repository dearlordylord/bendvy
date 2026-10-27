import Base
import ../../parallel-query/commands-core.bend as Core
import ../notice-readers.bend as Readers
import ../../../src/ecs/execution-declaration.bend as D
import ../../../src/ecs/execution-lifecycle-access.bend as Life
import ../../../src/ecs/execution-lifecycle-notices.bend as Notice

type Schema is Data:Schema{}
def declaration() -> D.Declaration<Schema,Unit,Unit,Life.Ops(~Schema,~Readers.output_origin(),~(Notice.Removed{"output"}))>:
  Life.removed(~Schema,~Core.Store(~Schema),~Unit,~Unit,~Core.layout(~Schema),~Readers.output_route(),~{==},~{==})

import Base
import ../../parallel-query/payloads.bend as P
import ../../../src/ecs/execution-composer-layout.bend as Layout
import ../../../src/ecs/schema-fragments.bend as Fragment
import ../../parallel-query/commands-core.bend as Core
import ../notice-readers.bend as Readers
import ../../../src/ecs/execution-declaration.bend as D
import ../../../src/ecs/execution-lifecycle-access.bend as Life
import ../../../src/ecs/execution-lifecycle-notices.bend as Notice

type Schema is Data:Schema{}
def absent() -> Layout.Route:Layout.InRight{Layout.AtLeaf{}}
def declaration() -> D.Declaration<Schema,Unit,Unit,Life.Ops(~Schema,~Layout.EmptyLayout{},~(Notice.Removed{""}))>:
  Life.removed(~Schema,~Core.Store(~Schema),~Unit,~Unit,~Core.layout(~Schema),~absent(),~{==},~{==})

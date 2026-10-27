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
def alternate(owner:P.Output) -> P.Output & U32:P.output_view(owner)
def different() -> Layout.Layout:Layout.LayoutPair{Layout.LayoutPair{Layout.LayoutPair{Layout.LayoutLeaf{P.Input,U32,P.read,"input"},Layout.ClassifiedLayoutLeaf{P.Output,U32,P.output_view,"output",Fragment.Plain{}}},Layout.EmptyLayout{}},Layout.EmptyLayout{}}
def declaration() -> D.Declaration<Schema,Unit,Unit,Life.Ops(~Schema,~(Layout.origin(different(),Readers.output_route())),~(Notice.Removed{"output"}))>:
  Life.removed(~Schema,~Core.Store(~Schema),~Unit,~Unit,~different(),~Readers.output_route(),~{==},~{==})

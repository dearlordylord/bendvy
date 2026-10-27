import Base
import ../declarations.bend as D
import ../../../src/ecs/execution-machine-access.bend as Machine
import ../../../src/ecs/execution-composer-layout.bend as Layout
import ../../../src/ecs/execution-builder.bend as Build

type First is Data:
  First{}
type Second is Data:
  Second{}
# The real Builder callback is for First. It cannot derive a Second machine
# writer merely because both layouts use the same textual resource key.
def forbidden(~C:Type,~H:Type,~B:Type,~rw:Build.ResourceWrite(~First,~C,~D.Resources(~First),~H,~B),book:B) -> B & Machine.Write<Second,D.Key,D.Mode,H>:
  Machine.select_write(~Second,~D.Key,~D.Mode,~C,~D.Resources(~First),~H,~B,~D.layout(First),~Layout.AtLeaf{},~{==},~{==},~{==},~{==},~D.same,~rw,book)

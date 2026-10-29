import Base
import ../declarations.bend as D
import ../../../src/ecs/execution-machine-access.bend as Machine
import ../../../src/ecs/execution-composer-layout.bend as Layout
import ../../../src/ecs/execution-builder.bend as Build

def unlike(~S:Data) -> Layout.Layout:Machine.leaf(S,D.Key,D.Mode,"other-mode")
# Identical S/K/V and payload/view types do not change the actual resource slot
# origin branded by the closed callback's complete resource layout.
def forbidden(~S:Data,~C:Type,~H:Type,~B:Type,~rw:Build.ResourceWrite(~S,~C,~D.Resources(~S),~H,~B),book:B) -> B & Machine.Write<S,D.Key,D.Mode,H>:
  Machine.select_write(~S,~D.Key,~D.Mode,~C,~D.Resources(~S),~H,~B,~unlike(~S),~Layout.AtLeaf{},~{==},~{==},~{==},~{==},~D.same,~rw,book)

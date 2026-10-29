import Base
import ../../../src/ecs/execution-resource-policy.bend as Policy
import ../declarations.bend as D
import ../payloads.bend as P
import ../../../src/ecs/execution-machine-access.bend as Machine
import ../../../src/ecs/execution-composer-layout.bend as Layout
import ../../../src/ecs/execution-builder.bend as Build

def unlike(~S:Data) -> Layout.Layout:
  Layout.LayoutLeaf{P.PeerActor<S,D.Mode>,D.Mode,P.peer(~S,~D.Mode),"mode",Policy.Ordinary{}}
# A matching textual key and projected Mode do not confer raw payload authority.
def forbidden(~S:Data,~C:Type,~H:Type,~B:Type,~rw:Build.ResourceWrite(~S,~C,~Layout.resources(~S,unlike(~S)),~H,~B),book:B) -> B & Machine.Write<S,D.Key,D.Mode,H>:
  Machine.select_write(~S,~D.Key,~D.Mode,~C,~Layout.resources(~S,unlike(~S)),~H,~B,~unlike(~S),~Layout.AtLeaf{},~{==},~{==},~{==},~{==},~D.same,~rw,book)

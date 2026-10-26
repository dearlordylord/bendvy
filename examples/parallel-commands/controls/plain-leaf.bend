import Base
import ./registered.bend as R
import ./positive.bend as P
import ../../../src/ecs/execution-parallel-scope-registry.bend as Tree
import ../../../src/ecs/execution-composer-layout.bend as Layout
import ../../../src/ecs/execution-command-system.bend as Cmd

def bad(~S:Data,~F:Tree.Family(),~leaf:Tree.Leaf(~S,~(Layout.columns(~S,R.layout())),~(Layout.columns(~S,R.layout())),~Unit,~Unit,~String,~Unit,~F),owner:R.Owner(~S)) -> F(R.Owner(~S)):
  leaf(Cmd.ScopedOps(~S,~R.layout(),~Layout.AtLeaf{},~R.Ops),Cmd.Captures(~S,~R.layout(),~Layout.AtLeaf{},~P.Capture<S>),Cmd.program_for_buffer(~S,~(Layout.columns(~S,R.layout())),~Unit,~R.layout(),~Layout.AtLeaf{},~R.Ops,~R.declaration(~S)),Cmd.runner(~S,~R.layout(),~Layout.AtLeaf{},~R.Ops,~P.Capture<S>,~String,~Unit,~P.body(~S)),owner)

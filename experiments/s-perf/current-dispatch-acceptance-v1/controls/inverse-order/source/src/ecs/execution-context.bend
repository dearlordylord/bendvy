import Base
import ./trace-facts.bend as Facts
# Execution transport, separate from the owned ECS World and gameplay providers.
type Context<W:Type> is Type:
  Context{world:W,trace:Facts.State}
def disabled(~W:Type,world:W) -> Context<W>:
  Context{world,Facts.Off{}}
def enabled(~W:Type,world:W) -> Context<W>:
  Context{world,Facts.On{[]}}

import Base
import ./world.bend as W
import ./execution-composer-layout.bend as Layout
import ./execution-composer-schema.bend as Schema
import ./execution-relation-context.bend as Context

# Trusted schema setup receives only the next namespace of the consumed actual
# Factory and an affine seed. It cannot inspect or mutate a running World.
# Schema rejection returns every constructed resource through Initialization.
def create(~S:Data,~components:Layout.Layout,~resources:Layout.Layout,~E:Data,~Seed:Type,~build:U32 -> Seed -> Layout.resources(~S,resources),factory:W.Factory,seed:Seed) -> Context.Initialization<S,components,resources,E>:
  match factory:
    case W.Factory{+nextNamespace}:Context.from_schema(~S,~components,~resources,~E,Schema.create(~S,~components,~resources,~E,W.Factory{nextNamespace},build(nextNamespace,seed)))

import Base
import ./world.bend as W
import ./execution-composer-layout.bend as Layout
import ./execution-composer-schema.bend as Schema
import ./execution-relation-context.bend as Context
import ./execution-schema-provisioning.bend as Provision

# Trusted schema setup receives only the next namespace of the consumed actual
# Factory and an affine seed. It cannot inspect or mutate a running World.
# Schema rejection returns every constructed resource through Initialization.
def create(~S:Data,~components:Layout.Layout,~resources:Layout.Layout,~E:Data,~Seed:Type,~build:U32 -> Seed -> Layout.resources(~S,resources),factory:W.Factory,seed:Seed) -> Context.Initialization<S,components,resources,E>:
  match factory:
    case W.Factory{+nextNamespace}:Context.from_schema(~S,~components,~resources,~E,Schema.create(~S,~components,~resources,~E,W.Factory{nextNamespace},build(nextNamespace,seed)))
type ProvisionedInitialization<-S:Data,-components:Layout.Layout,-resources:Layout.Layout,-E:Data,-Seed:Type,-blueprint:Provision.Blueprint<S,resources,Seed>> is Type:
  ProvisionedInitialization{result:Context.Initialization<S,components,resources,E>}
def create_provisioned(~S:Data,~components:Layout.Layout,~resources:Layout.Layout,~E:Data,~Seed:Type,~blueprint:Provision.Blueprint<S,resources,Seed>,factory:W.Factory,seed:Seed) -> ProvisionedInitialization<S,components,resources,E,Seed,blueprint>:
  ProvisionedInitialization{create(~S,~components,~resources,~E,~Seed,~Provision.builder(~S,~resources,~Seed,blueprint),factory,seed)}

import Base
import ./components.bend as D
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-resource-policy.bend as Policy
import ../../src/ecs/execution-composer-schema.bend as Setup

# The same nominal schema and component identities used by this example.
type Schema is Data: Schema{}
def health(value:D.Health) -> D.Health & D.Health:
  match value:
    case D.Health{+value}:(D.Health{value},D.Health{value})
def decay(value:D.HealthDecay) -> D.HealthDecay & D.HealthDecay:
  match value:
    case D.HealthDecay{+factor}:(D.HealthDecay{factor},D.HealthDecay{factor})
def components() -> L.Layout:
  L.LayoutPair{L.LayoutLeaf{D.Health,D.Health,health,"health",Policy.Ordinary{}},L.LayoutLeaf{D.HealthDecay,D.HealthDecay,decay,"decay",Policy.Ordinary{}}}
def resources() -> L.Layout:L.EmptyLayout{}
def Columns() -> Type:L.columns(~Schema,components())
def Resources() -> Type:L.resources(~Schema,resources())
def World() -> Type:W.World<Schema,Columns(),Resources(),Unit>
def create(factory:W.Factory) -> Setup.Initialized<Schema,components(),resources(),Unit>:
  Setup.create(~Schema,~components(),~resources(),~Unit,factory,Unit{})

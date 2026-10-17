import Base
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/world.bend as W
import ../../../examples/scheduled-health/schema.bend as S
import ../../../examples/scheduled-health/components.bend as D
type Other is Data:Other{}
def denied(handle:W.Handle<Other>) -> W.Handle<S.Schema>:handle

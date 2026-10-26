import Base
import ../declarations.bend as Declaration
import ../../../src/ecs/execution-state.bend as State

type Schema is Data:
  Schema{}
def escape(~H:Type,scope:H) -> State.Scope<Schema,Declaration.Store(~Schema),Declaration.Resources()>:
  scope

import Base
import ../declarations.bend as D
import ../../../src/ecs/execution-state.bend as State

type Schema is Data:
  Schema{}
def escape(~H:Type,scope:H) -> State.Scope<Schema,D.RightStore(~Schema),D.RightResource(~Schema)>:scope

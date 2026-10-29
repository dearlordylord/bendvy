import Base
import ./positive.bend as P
import ../scenario.bend as D
import ../../../src/ecs/execution-event-ops.bend as Ops
import ../../../src/ecs/execution-state.bend as State

def escape(~H:Type,~cap:Ops.Reader<P.SchemaA,H,Array<U32>,"events",U32>,scope:H) -> State.Scope<P.SchemaA,Unit,D.Resources(~P.SchemaA,~Array<U32>,~P.project)>:scope

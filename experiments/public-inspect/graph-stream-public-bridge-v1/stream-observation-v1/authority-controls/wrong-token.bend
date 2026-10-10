import Base
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import ../transitions.bend as T
import ../failures.bend as Fail
import ../../state.bend as State
def body(~S:Data,~H:Type,~cap:Cap.ValueRead<H,T.TransitionLog<S,State.FlowToken,U32>>,owner:H) -> H & T.TransitionLog<S,State.LevelToken,U32>:
  Cap.value_read(~H,~T.TransitionLog<S,State.LevelToken,U32>,~cap,owner)

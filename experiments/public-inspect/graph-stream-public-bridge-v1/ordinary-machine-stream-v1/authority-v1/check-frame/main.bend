import Base
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import ../../../state.bend as State
def refused(value:Cap.ValueRead<I.Frame<State.Workshop,A.Store<State.Workshop,State.Components<State.Workshop>>,State.Resources<State.Workshop>,A.Notice<State.Workshop,U32>>,M.CurrentView<State.Workshop,State.FlowToken,U32>>) -> Cap.ValueRead<K.Frame<State.Workshop,A.Store<State.Workshop,State.Components<State.Workshop>>,State.Resources<State.Workshop>,A.Notice<State.Workshop,U32>>,M.CurrentView<State.Workshop,State.FlowToken,U32>>:
  value
def main() -> Nat:
  0n

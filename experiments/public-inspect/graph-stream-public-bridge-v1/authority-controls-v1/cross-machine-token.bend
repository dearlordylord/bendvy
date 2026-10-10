import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as IQ
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/relation-query.bend as RQ
import ../state.bend as State

def refused(value:M.CurrentView<State.Workshop,State.LevelToken,U32>) -> M.CurrentView<State.Workshop,State.FlowToken,U32>:
  value

def main() -> Nat:
  0n

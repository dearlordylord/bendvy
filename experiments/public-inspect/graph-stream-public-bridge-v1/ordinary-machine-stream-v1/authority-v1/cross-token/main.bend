import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-declaration.bend as MD
import ../../../state.bend as State
def refused(value:MD.Declaration<State.Workshop,State.LevelToken,U32,State.Resources<State.Workshop>,State.level(~State.Workshop)>) -> MD.Declaration<State.Workshop,State.FlowToken,U32,State.Resources<State.Workshop>,State.flow(~State.Workshop)>:
  value
def main() -> Nat:
  0n

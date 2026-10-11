import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-inspector-relation.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/relation-query.bend as RQ
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as Q
import ../../state.bend as State
import ../../declarations.bend as D

def refused() -> Decl.Declaration<State.Workshop>:
  Decl.required_out(~State.Workshop,"foreign",D.declared_link(~State.Garden))

def main() -> Nat:
  0n

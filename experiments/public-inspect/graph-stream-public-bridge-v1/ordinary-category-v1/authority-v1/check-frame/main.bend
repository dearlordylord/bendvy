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

def refused() -> Query.ComposedReadQuery<K.Frame<State.Workshop,A.Store<State.Workshop,State.Components<State.Workshop>>,State.Resources<State.Workshop>,A.Notice<State.Workshop,U32>>,State.Workshop,Q.Product<Unit,List<&2,RQ.Cell<State.Workshop>>>>:
  Decl.condition(~State.Workshop,~State.Components<State.Workshop>,~State.Resources<State.Workshop>,~U32,~Unit,~Q.empty(~I.Frame<State.Workshop,A.Store<State.Workshop,State.Components<State.Workshop>>,State.Resources<State.Workshop>,A.Notice<State.Workshop,U32>>,~State.Workshop),~Decl.required_out(~State.Workshop,"link",D.declared_link(~State.Workshop)))

def main() -> Nat:
  0n

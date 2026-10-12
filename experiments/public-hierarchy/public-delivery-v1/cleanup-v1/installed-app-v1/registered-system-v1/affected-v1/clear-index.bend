import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-relation.bend as Relation
import ../consumer.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as X
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-linked-cleanup-system.bend as System
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-component-clear-declaration.bend as CD
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-component-despawn.bend as Clear
import ../../owners.bend as O
def different_clear(components:O.Components<C.Alpha>,handle:W.Handle<C.Alpha>) -> O.Components<C.Alpha> & List<&2,A.Notice<C.Alpha,U32>>:
  (components,[])
def rejected(~declaration:CD.Declaration<C.Alpha,O.Components<C.Alpha>,A.Notice<C.Alpha,U32>,different_clear>,app:C.CleanupApp(~C.Alpha)) -> System.Defined<C.CleanupApp(~C.Alpha),System.Owner(~C.Alpha,~O.Components<C.Alpha>,~O.Resources,~U32,~C.declarations(~C.Alpha),~C.clear(~C.Alpha),~C.record(~C.Alpha),~C.Args<C.Alpha>,~U32,~A.QueueStatus,~C.body(~C.Alpha))>:
  System.register_app(~C.Alpha,~O.Components<C.Alpha>,~O.Resources,~U32,~C.declarations(~C.Alpha),~C.clear(~C.Alpha),~C.record(~C.Alpha),~C.Args<C.Alpha>,~U32,~A.QueueStatus,~C.body(~C.Alpha),~Array<U32>,~Relation.ObservedRows(~C.Alpha,~Relation.ObservedRows(~C.Alpha,~String)),~C.observe2(~C.Alpha),~C.folded(~C.Alpha),~declaration,app,"BadClearIndex")
def main() -> IO(Unit):IO.print("UNREACHABLE_TYPED_CONTROL")

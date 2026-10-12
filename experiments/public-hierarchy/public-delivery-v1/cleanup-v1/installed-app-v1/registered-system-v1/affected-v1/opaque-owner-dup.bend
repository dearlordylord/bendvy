import Base
import ../consumer.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as X
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-linked-cleanup-system.bend as System
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-component-clear-declaration.bend as CD
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-component-despawn.bend as Clear
import ../../owners.bend as O
def duplicate(-H:Type,caps:System.Ops<H,C.Alpha>,owner:H,target:W.Handle<C.Alpha>) -> H & H:
  (owner,owner)
def main() -> IO(Unit):IO.print("UNREACHABLE_TYPED_CONTROL")

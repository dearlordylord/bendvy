import Base
import ../public-consumer.bend as C
import ../owners.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as X
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-linked-cleanup.bend as LC
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-relation.bend as Relation
def wrong(app:C.CleanupApp(~C.Alpha),target:W.Handle<C.Beta>) -> C.CleanupApp(~C.Alpha) & String:C.invoke(~C.Alpha,app,target,X.Success{})
def main() -> IO(Unit):IO.print("UNREACHABLE")

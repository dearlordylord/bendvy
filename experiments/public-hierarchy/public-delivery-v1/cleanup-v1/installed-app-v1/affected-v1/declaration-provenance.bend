import Base
import ../public-consumer.bend as C
import ../owners.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as X
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-linked-cleanup.bend as LC
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-relation.bend as Relation
def wrong(~S:Data,app:C.CleanupApp(~S)) -> C.CleanupApp(~S):LC.barrier_app(~S,~O.Components<S>,~O.Resources,~U32,~Array<U32>,~Relation.ObservedRows(~S,~Relation.ObservedRows(~S,~String)),~C.observe2(~S),~C.folded(~S),~[C.parent_declaration(~S)],~C.clear(~S),~C.record(~S),app)
def main() -> IO(Unit):IO.print("UNREACHABLE")

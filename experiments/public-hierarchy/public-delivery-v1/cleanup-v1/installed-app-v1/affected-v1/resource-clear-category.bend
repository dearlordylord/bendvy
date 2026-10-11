import Base
import ../public-consumer.bend as C
import ../owners.bend as O
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as X
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-linked-cleanup.bend as LC
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-relation.bend as Relation
def resource_clear(~S:Data,resources:O.Resources,_:W.Handle<S>) -> O.Resources & List<&2,A.Notice<S,U32>>:(resources,[])
def wrong(~S:Data,app:Build.Registered<S,W.World<S,A.Store<S,O.Components<S>>,O.Resources,A.Notice<S,U32>>,Array<U32>,String,C.physical(~S),C.folded(~S)>) -> Unit:
  _ = LC.empty(~S,~O.Components<S>,~O.Resources,~U32,~Array<U32>,~String,~C.physical(~S),~C.folded(~S),~resource_clear(~S),~C.record(~S),app)
  Unit{}
def main() -> IO(Unit):IO.print("UNREACHABLE")

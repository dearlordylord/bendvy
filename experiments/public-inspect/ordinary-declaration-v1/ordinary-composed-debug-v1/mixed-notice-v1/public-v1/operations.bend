import Base
import ./state.bend as F
import ./event-setup.bend as Events
import /workspace/formal-proofs/bendvy/src/ecs/event-notice-runtime.bend as Mixed
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
import /workspace/formal-proofs/bendvy/src/ecs/commands.bend as Cmd
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as Relation
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy/src/ecs/relation-failure-reader.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/relation-failure-runtime.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/internal/relation-failures/domains.bend as Domains
import /workspace/formal-proofs/bendvy/src/ecs/internal/relation-failures/readings.bend as Read
import /workspace/formal-proofs/bendvy/src/ecs/event-publication.bend as Pub
import /workspace/formal-proofs/bendvy/src/ecs/event-family-runtime.bend as FR
import /workspace/formal-proofs/bendvy/src/ecs/event-family-routing.bend as Route

def classify(notice:F.Events()) -> Maybe<Domains.DescriptorKey<F.S>>:
  match notice:
    case Relation.RelationFailed{G.Failure{G.Descriptor{id,_,_,_},_,_,_,_}}:Some{Domains.DeclaredKey{id}}
    case _:None{}
def runner(world:F.World(),input:K.Input<F.S,F.Events(),Array<U32>>) -> Sys.Outcome<F.World(),Unit,(Array<U32> & List<&2,Read.KeyReading<F.S,F.Events()>>)>:
  match input:
    case K.Input{readings,args}:Sys.Succeeded{world,(args,readings)}
def Reader() -> Type:K.Reader<F.S,F.Store(),F.Resources(),F.Events(),Array<U32>,Unit,(Array<U32> & List<&2,Read.KeyReading<F.S,F.Events()>>),runner>
def noop(world:F.World()) -> F.World():world
def pending(world:F.World()) -> F.World():W.enqueue(~F.S,~F.Store(),~F.Resources(),~F.Events(),world,noop)
def publication_first(value:U32) -> F.Events():Relation.Original{Pub.Publication{[Pub.Publication{[F.FirstEvent{value}],[]}],[]}}
def publication_second(value:Bool) -> F.Events():Relation.Original{Pub.Publication{[Pub.Publication{[],[F.SecondEvent{value}]}],[]}}
def publish_before(world:F.World()) -> F.World():W.event_publish(~F.S,~F.Store(),~F.Resources(),~F.Events(),world,[publication_first(7),Relation.ComponentRemoved{1},publication_second(True{}),Relation.CleanupPaused{[]}])
def publish_after(world:F.World()) -> F.World():W.event_publish(~F.S,~F.Store(),~F.Resources(),~F.Events(),world,[publication_first(8),Relation.ComponentRemoved{2},publication_second(False{}),Relation.CleanupPaused{[]}])
def queued_finished(status:Relation.QueueStatus,result:Tx.Returned<F.World(),Unit>) -> F.World() & Relation.QueueStatus:
  match result:
    case Tx.Returned{world,_}:(world,status)
def queued(result:Tx.Tx<F.World(),F.Events()> & Relation.QueueStatus) -> F.World() & Relation.QueueStatus:
  match result:
    case (tx,status):queued_finished(status,Cmd.tx_finish(~F.S,~F.Store(),~F.Resources(),~F.Events(),~Unit,tx,Tx.Success{}))
def queue_self(world:F.World(),+handle:W.Handle<F.S>) -> F.World() & Relation.QueueStatus:
  queued(Relation.queue_relate(~F.S,~Array<U32>,~F.Resources(),~F.Publications(),Tx.begin(~F.World(),~F.Events(),world),F.descriptor(),handle,handle))

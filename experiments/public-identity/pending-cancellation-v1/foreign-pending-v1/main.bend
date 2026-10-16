import Base
import ../main.bend as F
import /tmp/bendvy-pending-cancellation/src/ecs/world.bend as W
import /tmp/bendvy-pending-cancellation/src/ecs/world-io.bend as WI
import /tmp/bendvy-pending-cancellation/src/ecs/commands.bend as Cmd
import /tmp/bendvy-pending-cancellation/src/ecs/transaction.bend as T

type Scene is Data:Scene{}
def with_event(value:F.Working<Scene>) -> F.Working<Scene>:
  match value:
    case F.Working{tx,rows,handles}:F.Working{T.emit(~F.World(~Scene),~U32,tx,71),rows,handles}
def final(sender:F.Working<Scene>,receiver:F.Session<Scene>) -> String:
  match sender:
    case F.Working{_,rows,handles}:"sender{" ++ List.show(&2,String,x=>x,rows) ++ ";handles=" ++ List.show(&2,W.Handle<Scene>,F.handle(~Scene),handles) ++ "}\nreceiver{" ++ F.render_session(~Scene,receiver) ++ "}"
def cancelled(sender:F.Working<Scene>,receiver:F.Working<Scene>) -> String:
  final(sender,F.barrier(~Scene,F.snapshot(~Scene,"receiver-committed",F.finish(~Scene,F.tx_view(~Scene,"own-pending-cancelled",F.despawn(~Scene,receiver,0n)),T.Success{}))))
def foreign_handle(sender:F.Working<Scene>,receiver:F.Working<Scene>,handle:Maybe<&2,W.Handle<Scene>>) -> String:
  cancelled(F.tx_view(~Scene,"sender-retained",sender),F.tx_view(~Scene,"after-foreign-pending-refusal",F.despawn_selected(~Scene,F.tx_view(~Scene,"before-foreign-pending-refusal",receiver),handle)))
def prepared(sender:F.Working<Scene>,receiver:F.Working<Scene>) -> String:
  match sender:
    case F.Working{tx,rows,+handles}:foreign_handle(F.Working{tx,rows,handles},receiver,F.get(~Scene,0n,handles))
def receiver_created(sender:F.Working<Scene>,value:WI.Creation<Scene,F.Store,Array<U32>,U32>) -> IO(Unit):
  match value:
    case WI.Created{world}:IO.print(prepared(sender,with_event(F.spawn(~Scene,F.begin(~Scene,F.snapshot(~Scene,"receiver-created",F.Session{world,[],[]})),20))))
    case WI.Refused{resource}:IO.print("unexpected receiver creation refusal")
def sender_created(value:WI.Creation<Scene,F.Store,Array<U32>,U32>) -> IO(Unit):
  match value:
    case WI.Created{world}:IO.bind(WI.Creation<Scene,F.Store,Array<U32>,U32>,Unit,WI.create(~Scene,~F.Store,~Array<U32>,~U32,~F.empty,F.pair(900)),receiver_created(F.tx_view(~Scene,"sender-pending",F.spawn(~Scene,F.begin(~Scene,F.snapshot(~Scene,"sender-created",F.Session{world,[],[]})),10))))
    case WI.Refused{resource}:IO.print("unexpected sender creation refusal")
def main() -> IO(Unit):IO.bind(WI.Creation<Scene,F.Store,Array<U32>,U32>,Unit,WI.create(~Scene,~F.Store,~Array<U32>,~U32,~F.empty,F.pair(900)),sender_created)

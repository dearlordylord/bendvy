import Base
import ./world-io.bend as H
import ../public-integration/schema.bend as F
import ../../public-schedule-readers/schema.bend as S
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/commands.bend as Cmd
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/component.bend as C

type Session is Type:
  Session{world:S.World(),handle:W.Handle<S.Schema>}
def Tx() -> Type: T.Tx<S.World(),S.Notice>
def tx_counted(label:String,world:S.World(),undo:List<(S.World()->S.World())>,commands:List<(S.World()->S.World())>,+events:List<&2,S.Notice>,undoCount:U32,count:U32) -> Tx() & String:
  F.bind(~S.World(),~String,~Tx() & String,(world => text => (T.Tx{world,undo,commands,events},text ++ "staged=" ++ U32.show(count) ++ "|undo=" ++ U32.show(undoCount) ++ "|txEvents=" ++ List.show(&2,S.Notice,F.notice,events) ++ "\n")),F.snapshot(world,label))
def tx_commands(label:String,world:S.World(),undo:List<(S.World()->S.World())>,events:List<&2,S.Notice>,undoCount:U32,result:List<(S.World()->S.World())> & U32) -> Tx() & String:
  (commands,count)=result
  tx_counted(label,world,undo,commands,events,undoCount,count)
def tx_undo(label:String,world:S.World(),commands:List<(S.World()->S.World())>,events:List<&2,S.Notice>,result:List<(S.World()->S.World())> & U32) -> Tx() & String:
  (undo,count)=result
  tx_commands(label,world,undo,events,count,W.pending_length(~S.Schema,~S.Store,~Unit,~S.Notice,commands))
def tx_snapshot(tx:Tx(),label:String) -> Tx() & String:
  match tx:
    case T.Tx{world,undo,commands,events}: tx_undo(label,world,commands,events,W.pending_length(~S.Schema,~S.Store,~Unit,~S.Notice,undo))
def finish(sender:S.World(),log:String,result:T.Returned<S.World(),Unit>) -> IO(Unit):
  match result:
    case T.Returned{world,T.Failure{_}}: F.bind(~S.World(),~String,~IO(Unit),(sender => a => F.bind(~S.World(),~String,~IO(Unit),(world => b => IO.print(log ++ a ++ b)),F.snapshot(W.barrier(~S.Schema,~S.Store,~Unit,~S.Notice,world),"receiver-final"))),F.snapshot(sender,"sender-final"))
    case _: IO.print("unexpected transaction outcome")
def refused(sender:S.World(),log:String,result:Tx() & W.Status) -> IO(Unit):
  match result:
    case (tx,status): F.bind(~Tx(),~String,~IO(Unit),(tx => after => finish(sender,log ++ "foreign-queue=" ++ F.status(status) ++ "\n" ++ after,Cmd.tx_finish(~S.Schema,~S.Store,~Unit,~S.Notice,~Unit,tx,T.Failure{Unit{}}))),tx_snapshot(tx,"tx-after"))
def staged(sender:S.World(),+foreign:W.Handle<S.Schema>,+local:W.Handle<S.Schema>,log:String,result:C.SetResult<Tx(),S.Stock>) -> IO(Unit):
  match result:
    case C.Written{tx}: F.bind(~Tx(),~String,~IO(Unit),(tx => before => refused(sender,log ++ before,Cmd.tx_despawn_with(~S.Schema,~S.Store,~Unit,~S.Notice,~S.clear,tx,foreign))),tx_snapshot(T.emit(~S.World(),~S.Notice,T.stage(~S.World(),~S.Notice,tx,(world => S.populate(world,local,F.bundle(33)))),S.Ping{71}),"tx-before"))
    case _: IO.print("unexpected local write refusal")
def lookup(sender:S.World(),+foreign:W.Handle<S.Schema>,+local:W.Handle<S.Schema>,result:S.World() & C.Access<S.StockView>) -> IO(Unit):
  match result:
    case (world,access): staged(sender,foreign,local,"foreign-lookup=" ++ F.view_stock(access) ++ "\n",C.tx_set(~S.Schema,~S.Store,~Unit,~S.Notice,~S.StockRest,~S.Stock,~S.StockView,~S.StockToken,~S.take_stock,~S.put_stock,~S.project_stock,S.stock(),T.begin(~S.World(),~S.Notice,world),local,S.stock_payload(21)))
def receiver_ready(sender:Session,receiver:Session) -> IO(Unit):
  match sender receiver:
    case Session{sender,+foreign} Session{receiver,+local}: lookup(sender,foreign,local,S.get_stock(receiver,foreign))
def seeded(continuation:Session -> IO(Unit),value:U32,result:S.World() & W.Reservation<S.Schema>) -> IO(Unit):
  match result:
    case (world,W.Reserved{+handle}): continuation(Session{Cmd.spawn_apply(~S.Schema,~S.Store,~Unit,~S.Notice,~S.Bundle,~S.populate,world,handle,F.bundle(value)),handle})
    case _: IO.print("unexpected seed refusal")
def created(continuation:Session -> IO(Unit),value:U32,result:H.Creation<S.Schema,S.Store,Unit,S.Notice>) -> IO(Unit):
  match result:
    case H.Created{world}: seeded(continuation,value,W.reserve_id(~S.Schema,~S.Store,~Unit,~S.Notice,world))
    case H.Refused{_}: IO.print("unexpected creation refusal")
def sender_ready(sender:Session) -> IO(Unit):
  IO.bind(H.Creation<S.Schema,S.Store,Unit,S.Notice>,Unit,H.create(~S.Schema,~S.Store,~Unit,~S.Notice,~S.empty_store,Unit{}),(result => created((receiver => receiver_ready(sender,receiver)),20,result)))
def main() -> IO(Unit):
  IO.bind(H.Creation<S.Schema,S.Store,Unit,S.Notice>,Unit,H.create(~S.Schema,~S.Store,~Unit,~S.Notice,~S.empty_store,Unit{}),(result => created(sender_ready,10,result)))

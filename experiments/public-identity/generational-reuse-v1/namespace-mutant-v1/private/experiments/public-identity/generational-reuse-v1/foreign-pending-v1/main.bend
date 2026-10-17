import Base
import ../fixture.bend as F
import ../observe.bend as O
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/world-io.bend as WI
import ../../../../src/ecs/commands.bend as Cmd
import ../../../../src/ecs/transaction.bend as T
import ../../../../src/ecs/bundle-delivery.bend as Delivery

type Working<S:Data> is Type:
  Working{tx:F.Tx(~S),sender:F.World(~S),own:W.Handle<S>,foreign:W.Handle<S>,log:String}
type Session<S:Data> is Type:
  Session{world:F.World(~S),sender:F.World(~S),own:W.Handle<S>,foreign:W.Handle<S>,log:String}
def working_join(~S:Data,label:String,+own:W.Handle<S>,+foreign:W.Handle<S>,log:String,tx:F.Tx(~S) & String,sender:F.World(~S) & String) -> Working<S>:
  (tx,tt)=tx
  (sender,st)=sender
  (Working{tx,sender,own,foreign,log ++ label ++ ":{tx={" ++ tt ++ "};sender={" ++ st ++ "};own=" ++ F.handle_text(~S,own) ++ ";foreign=" ++ F.handle_text(~S,foreign) ++ "}\n"})
def checkpoint_working(~S:Data,label:String,value:Working<S>) -> Working<S>:
  match value:
    case Working{tx,sender,own,foreign,log}:working_join(~S,label,own,foreign,log,O.tx(~S,tx),O.world(~S,sender))
def despawn_result(~S:Data,sender:F.World(~S),own:W.Handle<S>,foreign:W.Handle<S>,log:String,label:String,result:F.Tx(~S) & W.Status) -> Working<S>:
  match result:
    case (tx,status):Working{tx,sender,own,foreign,log ++ label ++ ":" ++ O.status(status) ++ "\n"}
def foreign_despawn(~S:Data,value:Working<S>) -> Working<S>:
  match value:
    case Working{tx,sender,own,+foreign,log}:despawn_result(~S,sender,own,foreign,log,"foreign-despawn",F.despawn(~S,tx,foreign))
def own_despawn(~S:Data,value:Working<S>) -> Working<S>:
  match value:
    case Working{tx,sender,+own,foreign,log}:despawn_result(~S,sender,own,foreign,log,"own-despawn",F.despawn(~S,tx,own))
def committed(~S:Data,value:Working<S>) -> Session<S>:
  match value:
    case Working{tx,sender,own,foreign,log}:Session{F.finish(~S,tx),sender,own,foreign,log}
def session_join(~S:Data,label:String,+own:W.Handle<S>,+foreign:W.Handle<S>,log:String,world:F.World(~S) & String,sender:F.World(~S) & String) -> Session<S>:
  (world,wt)=world
  (sender,st)=sender
  (Session{world,sender,own,foreign,log ++ label ++ ":{world={" ++ wt ++ "};sender={" ++ st ++ "};own=" ++ F.handle_text(~S,own) ++ ";foreign=" ++ F.handle_text(~S,foreign) ++ "}\n"})
def checkpoint(~S:Data,label:String,value:Session<S>) -> Session<S>:
  match value:
    case Session{world,sender,own,foreign,log}:session_join(~S,label,own,foreign,log,O.world(~S,world),O.world(~S,sender))
def barrier(~S:Data,value:Session<S>) -> Session<S>:
  match value:
    case Session{world,sender,own,foreign,log}:Session{W.barrier(~S,~F.Store<S>,~Array<U32>,~F.Notice<S>,world),sender,own,foreign,log}
def sender_barrier(~S:Data,value:Session<S>) -> Session<S>:
  match value:
    case Session{world,sender,own,foreign,log}:Session{world,W.barrier(~S,~F.Store<S>,~Array<U32>,~F.Notice<S>,sender),own,foreign,log}
def rendered(~S:Data,value:Session<S>) -> String:
  match value:
    case Session{_,_,_,_,log}:log
def steps(~S:Data,value:Working<S>) -> String:
  value=checkpoint_working(~S,"both-real-pending-matching-index-generation",value)
  value=checkpoint_working(~S,"foreign-refused-tx-unchanged",foreign_despawn(~S,value))
  value=checkpoint_working(~S,"own-pending-cancel-accepted",own_despawn(~S,value))
  session=checkpoint(~S,"committed-before-barrier",committed(~S,value))
  session=checkpoint(~S,"receiver-fifo-populate-clear",barrier(~S,session))
  rendered(~S,checkpoint(~S,"sender-own-pending-activated",sender_barrier(~S,session)))
def populate(~S:Data,world:F.World(~S),handle:W.Handle<S>,payload:Array<U32>) -> F.World(~S):
  Delivery.deliver(~F.World(~S),~Array<U32>,~F.recover(~S),F.attempt(~S,world,handle,payload))
def reserved(~S:Data,sender:F.World(~S),foreign:W.Handle<S>,result:F.Tx(~S) & W.Reservation<S>) -> String:
  match result:
    case (_,W.ReservationRejected{error}):"receiver-reservation-refused:" ++ O.error(error)
    case (tx,W.Reserved{own}):steps(~S,Working{tx,sender,own,foreign,""})
def started(~S:Data,world:F.World(~S),sender:F.World(~S) & Maybe<&2,W.Handle<S>>) -> String:
  match sender:
    case (_,None{}):"sender-reservation-refused"
    case (sender,Some{foreign}):reserved(~S,sender,foreign,Cmd.tx_spawn(~S,~F.Store<S>,~Array<U32>,~F.Notice<S>,~Array<U32>,~populate(~S),T.begin(~F.World(~S),~F.Notice<S>,world),ANode{ALeaf{100},ALeaf{101}}))
def sender_created(world:F.World(~F.Workshop),result:WI.Creation<F.Workshop,F.Store<F.Workshop>,Array<U32>,F.Notice<F.Workshop>>) -> IO(Unit):
  match result:
    case WI.Refused{_}:IO.print("sender-creation-refused")
    case WI.Created{sender}:IO.print(started(~F.Workshop,world,F.spawn(~F.Workshop,sender,700)))
def receiver_created(result:WI.Creation<F.Workshop,F.Store<F.Workshop>,Array<U32>,F.Notice<F.Workshop>>) -> IO(Unit):
  match result:
    case WI.Refused{_}:IO.print("receiver-creation-refused")
    case WI.Created{world}:IO.bind(WI.Creation<F.Workshop,F.Store<F.Workshop>,Array<U32>,F.Notice<F.Workshop>>,Unit,WI.create(~F.Workshop,~F.Store<F.Workshop>,~Array<U32>,~F.Notice<F.Workshop>,~F.empty(~F.Workshop),ANode{ALeaf{71},ALeaf{72}}),created=>sender_created(world,created))
def main() -> IO(Unit):
  IO.bind(WI.Creation<F.Workshop,F.Store<F.Workshop>,Array<U32>,F.Notice<F.Workshop>>,Unit,WI.create(~F.Workshop,~F.Store<F.Workshop>,~Array<U32>,~F.Notice<F.Workshop>,~F.empty(~F.Workshop),ANode{ALeaf{61},ALeaf{62}}),receiver_created)

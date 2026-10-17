import Base
import fixture.bend as F
import observe.bend as O
import owner-observer.bend as D
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/commands.bend as Cmd
import ../../../src/ecs/component.bend as C
import ../../../src/ecs/bundle-batch.bend as Batch

type Session<S:Data> is Type:
  Session{world:F.World(~S),foreign:F.World(~S),foreignHandle:W.Handle<S>,handles:List<&2,W.Handle<S>>,log:String}
def row(~S:Data,label:String,session:Session<S>,text:String) -> Session<S>:
  match session:
    case Session{world,foreign,foreignHandle,handles,log}:Session{world,foreign,foreignHandle,handles,log ++ label ++ ":" ++ text ++ "\n"}
def checkpoint_join(~S:Data,label:String,+foreignHandle:W.Handle<S>,+handles:List<&2,W.Handle<S>>,log:String,world:F.World(~S) & String,foreign:F.World(~S) & String) -> Session<S>:
  (world,wt)=world
  (foreign,ft)=foreign
  (Session{world,foreign,foreignHandle,handles,log ++ label ++ ":{world={" ++ wt ++ "};foreign={" ++ ft ++ "};foreignHandle=" ++ F.handle_text(~S,foreignHandle) ++ ";handles=" ++ List.show(&2,W.Handle<S>,F.handle_text(~S),handles) ++ "}\n"})
def checkpoint(~S:Data,label:String,session:Session<S>) -> Session<S>:
  match session:
    case Session{world,foreign,foreignHandle,handles,log}:checkpoint_join(~S,label,foreignHandle,handles,log,O.world(~S,world),O.world(~S,foreign))
def spawned(~S:Data,foreign:F.World(~S),foreignHandle:W.Handle<S>,handles:List<&2,W.Handle<S>>,log:String,result:F.World(~S) & Maybe<&2,W.Handle<S>>) -> Session<S>:
  match result:
    case (world,None{}):Session{world,foreign,foreignHandle,handles,log ++ "spawn:refused\n"}
    case (world,Some{+handle}):Session{world,foreign,foreignHandle,List.append(&2,W.Handle<S>,handles,[handle]),log ++ "spawn:" ++ F.handle_text(~S,handle) ++ "\n"}
def spawn(~S:Data,value:U32,session:Session<S>) -> Session<S>:
  match session:
    case Session{world,foreign,foreignHandle,handles,log}:spawned(~S,foreign,foreignHandle,handles,log,F.spawn(~S,world,value))
def barrier(~S:Data,session:Session<S>) -> Session<S>:
  match session:
    case Session{world,foreign,foreignHandle,handles,log}:Session{W.barrier(~S,~F.Store<S>,~Array<U32>,~F.Notice<S>,world),foreign,foreignHandle,handles,log}
def at(~S:Data,index:Nat,handles:List<&2,W.Handle<S>>) -> Maybe<&2,W.Handle<S>>:
  match index handles:
    case _, []:None{}
    case 0n handle <> _:Some{handle}
    case 1n+rest _ <> tail:at(~S,rest,tail)
def despawn_observed(~S:Data,foreign:F.World(~S),foreignHandle:W.Handle<S>,handles:List<&2,W.Handle<S>>,log:String,status:W.Status,result:F.Tx(~S) & String) -> Session<S>:
  match result:
    case (tx,text):Session{F.finish(~S,tx),foreign,foreignHandle,handles,log ++ "despawn:" ++ O.status(status) ++ ";tx={" ++ text ++ "}\n"}
def despawn_result(~S:Data,foreign:F.World(~S),foreignHandle:W.Handle<S>,handles:List<&2,W.Handle<S>>,log:String,result:F.Tx(~S) & W.Status) -> Session<S>:
  match result:
    case (tx,status):despawn_observed(~S,foreign,foreignHandle,handles,log,status,O.tx(~S,tx))
def despawn_target(~S:Data,session:Session<S>,target:Maybe<&2,W.Handle<S>>) -> Session<S>:
  match session target:
    case session None{}:row(~S,"despawn",session,"missing-receipt")
    case Session{world,foreign,foreignHandle,handles,log} Some{handle}:despawn_result(~S,foreign,foreignHandle,handles,log,F.despawn(~S,T.begin(~F.World(~S),~F.Notice<S>,world),handle))
def despawn(~S:Data,index:Nat,session:Session<S>) -> Session<S>:
  match session:
    case Session{world,foreign,foreignHandle,+handles,log}:despawn_target(~S,Session{world,foreign,foreignHandle,handles,log},at(~S,index,handles))
def foreign_despawn(~S:Data,session:Session<S>) -> Session<S>:
  match session:
    case Session{world,foreign,+foreignHandle,handles,log}:despawn_target(~S,Session{world,foreign,foreignHandle,handles,log},Some{foreignHandle})
def read_result(~S:Data,foreign:F.World(~S),foreignHandle:W.Handle<S>,handles:List<&2,W.Handle<S>>,log:String,result:F.World(~S) & C.Access<U32>) -> Session<S>:
  match result:
    case (world,C.MissingEntity{}):Session{world,foreign,foreignHandle,handles,log ++ "read:MissingEntity\n"}
    case (world,C.ComponentAbsent{}):Session{world,foreign,foreignHandle,handles,log ++ "read:Absent\n"}
    case (world,C.Found{value}):Session{world,foreign,foreignHandle,handles,log ++ "read:" ++ U32.show(value) ++ "\n"}
def read_target(~S:Data,session:Session<S>,target:Maybe<&2,W.Handle<S>>) -> Session<S>:
  match session target:
    case session None{}:row(~S,"read",session,"missing-receipt")
    case Session{world,foreign,foreignHandle,handles,log} Some{handle}:read_result(~S,foreign,foreignHandle,handles,log,C.get(~S,~F.Store<S>,~Array<U32>,~F.Notice<S>,~F.Rest,~Array<U32>,~U32,~Unit,~F.take(~S),~F.put(~S),~F.view,F.family(~S),world,handle))
def read(~S:Data,index:Nat,session:Session<S>) -> Session<S>:
  match session:
    case Session{world,foreign,foreignHandle,+handles,log}:read_target(~S,Session{world,foreign,foreignHandle,handles,log},at(~S,index,handles))
def write_observed(~S:Data,foreign:F.World(~S),foreignHandle:W.Handle<S>,handles:List<&2,W.Handle<S>>,log:String,error:String,world:F.World(~S),incoming:Maybe<&1,Array<U32>> & String) -> Session<S>:
  match world incoming:
    case W.World{ns,allocator,F.Store{column,returned,trace},resource,events,pending,regs,sid,clock}, (incoming,text):Session{W.World{ns,allocator,F.Store{column,F.append_owner(incoming,returned),trace},resource,events,pending,regs,sid,clock},foreign,foreignHandle,handles,log ++ "write:" ++ error ++ ";returned=" ++ text ++ "\n"}
def write_result(~S:Data,foreign:F.World(~S),foreignHandle:W.Handle<S>,handles:List<&2,W.Handle<S>>,log:String,result:C.Replacement<F.World(~S),Array<U32>>) -> Session<S>:
  match result:
    case C.Replaced{world,previous}:write_observed(~S,foreign,foreignHandle,handles,log,"Replaced",world,D.optional(~Array<U32>,~D.u32_array,previous))
    case C.ReplaceRejected{world,incoming,error}:write_observed(~S,foreign,foreignHandle,handles,log,O.error(error),world,D.optional(~Array<U32>,~D.u32_array,incoming))
def write_target(~S:Data,session:Session<S>,target:Maybe<&2,W.Handle<S>>) -> Session<S>:
  match session target:
    case session None{}:row(~S,"write",session,"missing-receipt")
    case Session{world,foreign,foreignHandle,handles,log} Some{handle}:write_result(~S,foreign,foreignHandle,handles,log,C.replace(~S,~F.Store<S>,~Array<U32>,~F.Notice<S>,~F.Rest,~Array<U32>,~U32,~Unit,~F.take(~S),~F.put(~S),~F.view,F.family(~S),world,handle,Some{ANode{ALeaf{900},ALeaf{901}}}))
def stale_write(~S:Data,session:Session<S>) -> Session<S>:
  match session:
    case Session{world,foreign,foreignHandle,+handles,log}:write_target(~S,Session{world,foreign,foreignHandle,handles,log},at(~S,0n,handles))
def write_abort_payloads(~S:Data,foreign:F.World(~S),foreignHandle:W.Handle<S>,handles:List<&2,W.Handle<S>>,log:String,world:F.World(~S),observed:List<Array<U32>> & String) -> Session<S>:
  match world observed:
    case W.World{ns,allocator,F.Store{column,returned,trace},resource,events,pending,regs,sid,clock}, (payloads,text):Session{W.World{ns,allocator,F.Store{column,List.append(&1,Array<U32>,returned,payloads),trace},resource,events,pending,regs,sid,clock},foreign,foreignHandle,handles,log ++ "abort:Failure;returned=" ++ text ++ "\n"}
def aborted_result(~S:Data,foreign:F.World(~S),foreignHandle:W.Handle<S>,handles:List<&2,W.Handle<S>>,log:String,result:Batch.Finished<S,F.Store<S>,Array<U32>,F.Notice<S>,Array<U32>,Unit>) -> Session<S>:
  match result:
    case Batch.Committed{world}:Session{world,foreign,foreignHandle,handles,log ++ "abort:unexpected-commit\n"}
    case Batch.Failed{world,payloads,_}:write_abort_payloads(~S,foreign,foreignHandle,handles,log,world,O.arrays(payloads))
def aborted_spawn(~S:Data,foreign:F.World(~S),foreignHandle:W.Handle<S>,handles:List<&2,W.Handle<S>>,log:String,result:Batch.Spawned<S,F.Store<S>,Array<U32>,F.Notice<S>,Array<U32>>) -> Session<S>:
  match result:
    case Batch.Spawned{batch,+target}:aborted_result(~S,foreign,foreignHandle,List.append(&2,W.Handle<S>,handles,[target]),log ++ "abort-reservation:" ++ F.handle_text(~S,target) ++ "\n",Batch.finish(~S,~F.Store<S>,~Array<U32>,~F.Notice<S>,~Array<U32>,~Unit,~F.attempt(~S),~F.recover(~S),batch,T.Failure{Unit{}}))
    case Batch.SpawnRefused{batch,payload,error}:aborted_result(~S,foreign,foreignHandle,handles,log ++ "abort-reservation-refused\n",Batch.finish(~S,~F.Store<S>,~Array<U32>,~F.Notice<S>,~Array<U32>,~Unit,~F.attempt(~S),~F.recover(~S),batch,T.Failure{Unit{}}))
def abort(~S:Data,session:Session<S>) -> Session<S>:
  match session:
    case Session{world,foreign,foreignHandle,handles,log}:aborted_spawn(~S,foreign,foreignHandle,handles,log,Batch.spawn(~S,~F.Store<S>,~Array<U32>,~F.Notice<S>,~Array<U32>,Batch.begin(~S,~F.Store<S>,~Array<U32>,~F.Notice<S>,~Array<U32>,T.begin(~F.World(~S),~F.Notice<S>,world)),ANode{ALeaf{800},ALeaf{801}}))
def dead_result(~S:Data,foreign:F.World(~S),foreignHandle:W.Handle<S>,handles:List<&2,W.Handle<S>>,log:String,result:F.World(~S) & W.Status) -> Session<S>:
  match result:
    case (world,status):Session{world,foreign,foreignHandle,handles,log ++ "plain-deactivate:" ++ O.status(status) ++ "\n"}
def dead_target(~S:Data,session:Session<S>,target:Maybe<&2,W.Handle<S>>) -> Session<S>:
  match session target:
    case session None{}:row(~S,"plain-deactivate",session,"missing-receipt")
    case Session{world,foreign,foreignHandle,handles,log} Some{handle}:dead_result(~S,foreign,foreignHandle,handles,log,W.deactivate(~S,~F.Store<S>,~Array<U32>,~F.Notice<S>,world,handle))
def dead(~S:Data,session:Session<S>) -> Session<S>:
  match session:
    case Session{world,foreign,foreignHandle,+handles,log}:dead_target(~S,Session{world,foreign,foreignHandle,handles,log},at(~S,3n,handles))
def steps(~S:Data,session:Session<S>) -> Session<S>:
  session=checkpoint(~S,"initial",session)
  session=checkpoint(~S,"pending-ab",spawn(~S,200,spawn(~S,100,session)))
  session=checkpoint(~S,"live-ab",barrier(~S,session))
  session=checkpoint(~S,"queued-clear-a-before-c",despawn(~S,0n,session))
  session=checkpoint(~S,"pending-c-before-release-a",spawn(~S,300,session))
  session=checkpoint(~S,"live-bc-a-free",barrier(~S,session))
  session=checkpoint(~S,"pending-d-reuses-a",spawn(~S,400,session))
  session=checkpoint(~S,"live-bcd",barrier(~S,session))
  session=checkpoint(~S,"stale-read",read(~S,0n,session))
  session=checkpoint(~S,"stale-write-returned",stale_write(~S,session))
  session=checkpoint(~S,"stale-despawn",despawn(~S,0n,session))
  session=checkpoint(~S,"foreign-despawn",foreign_despawn(~S,session))
  session=checkpoint(~S,"pending-e",spawn(~S,500,session))
  session=checkpoint(~S,"queued-cancel-e",despawn(~S,4n,session))
  session=checkpoint(~S,"cancel-e-fifo",barrier(~S,session))
  session=checkpoint(~S,"aborted-recycled-reservation",abort(~S,session))
  session=checkpoint(~S,"dead-retained-d",dead(~S,session))
  session=checkpoint(~S,"pending-g-no-consumed-or-retained-reuse",spawn(~S,600,session))
  checkpoint(~S,"final",barrier(~S,session))
def rendered(~S:Data,session:Session<S>) -> String:
  match session:
    case Session{_,_,_,_,log}:log
def start(~S:Data,world:F.World(~S),sender:F.World(~S) & Maybe<&2,W.Handle<S>>) -> String:
  match sender:
    case (foreign,None{}):"sender-spawn-refused"
    case (foreign,Some{foreignHandle}):rendered(~S,steps(~S,Session{world,W.barrier(~S,~F.Store<S>,~Array<U32>,~F.Notice<S>,foreign),foreignHandle,[],""}))

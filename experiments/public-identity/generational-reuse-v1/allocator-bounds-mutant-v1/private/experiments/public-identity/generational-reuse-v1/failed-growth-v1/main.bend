import Base
import ../fixture.bend as F
import ../observe.bend as O
import ../owner-observer.bend as D
import ../../../../src/ecs/entity-key.bend as K
import ../../../../src/ecs/entity-allocator.bend as A
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/world-io.bend as WI
import ../../../../src/ecs/transaction.bend as T
import ../../../../src/ecs/bundle-batch.bend as Batch
import ../../../../src/ecs/component.bend as C

type Working<S:Data> is Type:
  Working{batch:Batch.Batch<S,F.Store<S>,Array<U32>,F.Notice<S>,Array<U32>>,prior:W.Handle<S>,failed:List<&2,W.Handle<S>>,log:String}
type Session<S:Data> is Type:
  Session{world:F.World(~S),prior:W.Handle<S>,failed:List<&2,W.Handle<S>>,returned:List<Array<U32>>,log:String}
def prepared_join(~S:Data,+target:W.Handle<S>,+position:Nat,observed:Array<U32> & String) -> Batch.Prepared<S,Array<U32>> & String:
  match observed:
    case (payload,text):(Batch.Prepared{target,payload,position},"Prepared(" ++ F.handle_text(~S,target) ++ "," ++ Nat.show(position) ++ "," ++ text ++ ")")
def prepared(~S:Data,value:Batch.Prepared<S,Array<U32>>) -> Batch.Prepared<S,Array<U32>> & String:
  match value:
    case Batch.ReservationReceipt{+target}:(Batch.ReservationReceipt{target},"Receipt(" ++ F.handle_text(~S,target) ++ ")")
    case Batch.Prepared{target,payload,position}:prepared_join(~S,target,position,D.u32_array(payload))
def preparations_join(~S:Data,head:Batch.Prepared<S,Array<U32>> & String,tail:List<Batch.Prepared<S,Array<U32>>> & String) -> List<Batch.Prepared<S,Array<U32>>> & String:
  (head,ht)=head
  (tail,tt)=tail
  (head <> tail,ht ++ ";" ++ tt)
def preparations(~S:Data,values:List<Batch.Prepared<S,Array<U32>>>) -> List<Batch.Prepared<S,Array<U32>>> & String:
  match values:
    case []:([],"[]")
    case head <> tail:preparations_join(~S,prepared(~S,head),preparations(~S,tail))
def working_observed(~S:Data,label:String,+prior:W.Handle<S>,+failed:List<&2,W.Handle<S>>,log:String,tx:F.Tx(~S) & String,prepared:List<Batch.Prepared<S,Array<U32>>> & String) -> Working<S>:
  (tx,tt)=tx
  (prepared,pt)=prepared
  (Working{Batch.Batch{tx,prepared},prior,failed,log ++ label ++ ":{tx={" ++ tt ++ "};prepared=" ++ pt ++ ";prior=" ++ F.handle_text(~S,prior) ++ ";failed=" ++ List.show(&2,W.Handle<S>,F.handle_text(~S),failed) ++ "}\n"})
def working(~S:Data,label:String,value:Working<S>) -> Working<S>:
  match value:
    case Working{Batch.Batch{tx,prepared},prior,failed,log}:working_observed(~S,label,prior,failed,log,O.tx(~S,tx),preparations(~S,prepared))
def spawned(~S:Data,prior:W.Handle<S>,failed:List<&2,W.Handle<S>>,log:String,result:Batch.Spawned<S,F.Store<S>,Array<U32>,F.Notice<S>,Array<U32>>) -> Working<S>:
  match result:
    case Batch.Spawned{batch,target}:Working{batch,prior,List.append(&2,W.Handle<S>,failed,[target]),log}
    case Batch.SpawnRefused{batch,_,error}:Working{batch,prior,failed,log ++ "unexpected-batch-refusal:" ++ O.error(error) ++ "\n"}
def spawn_one(~S:Data,+value:U32,owner:Working<S>) -> Working<S>:
  match owner:
    case Working{batch,prior,failed,log}:spawned(~S,prior,failed,log,Batch.spawn(~S,~F.Store<S>,~Array<U32>,~F.Notice<S>,~Array<U32>,batch,ANode{ALeaf{value},ALeaf{U32.add(value,1)}}))
def spawn_many(~S:Data,values:List<&2,U32>,owner:Working<S>) -> Working<S>:
  match values:
    case []:owner
    case value <> rest:spawn_many(~S,rest,spawn_one(~S,value,owner))
def aborted(~S:Data,prior:W.Handle<S>,failed:List<&2,W.Handle<S>>,log:String,result:Batch.Finished<S,F.Store<S>,Array<U32>,F.Notice<S>,Array<U32>,Unit>) -> Session<S>:
  match result:
    case Batch.Failed{world,payloads,_}:Session{world,prior,failed,payloads,log ++ "batch:Failure\n"}
    case Batch.Committed{world}:Session{world,prior,failed,[],log ++ "batch:UnexpectedCommit\n"}
def abort(~S:Data,value:Working<S>) -> Session<S>:
  match value:
    case Working{batch,prior,failed,log}:aborted(~S,prior,failed,log,Batch.finish(~S,~F.Store<S>,~Array<U32>,~F.Notice<S>,~Array<U32>,~Unit,~F.attempt(~S),~F.recover(~S),batch,T.Failure{Unit{}}))
def checkpoint_join(~S:Data,label:String,+prior:W.Handle<S>,+failed:List<&2,W.Handle<S>>,log:String,world:F.World(~S) & String,returned:List<Array<U32>> & String) -> Session<S>:
  (world,wt)=world
  (returned,rt)=returned
  (Session{world,prior,failed,returned,log ++ label ++ ":{world={" ++ wt ++ "};prior=" ++ F.handle_text(~S,prior) ++ ";failed=" ++ List.show(&2,W.Handle<S>,F.handle_text(~S),failed) ++ ";returned=" ++ rt ++ "}\n"})
def checkpoint(~S:Data,label:String,value:Session<S>) -> Session<S>:
  match value:
    case Session{world,prior,failed,returned,log}:checkpoint_join(~S,label,prior,failed,log,O.world(~S,world),O.arrays(returned))
def refused_observed(~S:Data,prior:W.Handle<S>,failed:List<&2,W.Handle<S>>,returned:List<Array<U32>>,log:String,status:W.Status,result:F.Tx(~S) & String) -> Session<S>:
  match result:
    case (tx,text):Session{F.finish(~S,tx),prior,failed,returned,log ++ "failed-id-despawn:" ++ O.status(status) ++ ";tx={" ++ text ++ "}\n"}
def refused(~S:Data,prior:W.Handle<S>,failed:List<&2,W.Handle<S>>,returned:List<Array<U32>>,log:String,result:F.Tx(~S) & W.Status) -> Session<S>:
  match result:
    case (tx,status):refused_observed(~S,prior,failed,returned,log,status,O.tx(~S,tx))
def reject_failed(~S:Data,value:Session<S>) -> Session<S>:
  match value:
    case Session{world,prior,[],returned,log}:Session{world,prior,[],returned,log ++ "missing-failed-receipt\n"}
    case Session{world,prior,+handle <> +rest,returned,log}:refused(~S,prior,handle <> rest,returned,log,F.despawn(~S,T.begin(~F.World(~S),~F.Notice<S>,world),handle))
def read_result(~S:Data,prior:W.Handle<S>,failed:List<&2,W.Handle<S>>,returned:List<Array<U32>>,log:String,result:F.World(~S) & C.Access<U32>) -> Session<S>:
  match result:
    case (world,C.MissingEntity{}):Session{world,prior,failed,returned,log ++ "failed-id-read:MissingEntity\n"}
    case (world,C.ComponentAbsent{}):Session{world,prior,failed,returned,log ++ "failed-id-read:Absent\n"}
    case (world,C.Found{value}):Session{world,prior,failed,returned,log ++ "failed-id-read:" ++ U32.show(value) ++ "\n"}
def read_failed(~S:Data,value:Session<S>) -> Session<S>:
  match value:
    case Session{world,prior,[],returned,log}:Session{world,prior,[],returned,log ++ "missing-failed-receipt\n"}
    case Session{world,prior,+handle <> +rest,returned,log}:read_result(~S,prior,handle <> rest,returned,log,C.get(~S,~F.Store<S>,~Array<U32>,~F.Notice<S>,~F.Rest,~Array<U32>,~U32,~Unit,~F.take(~S),~F.put(~S),~F.view,F.family(~S),world,handle))
def write_observed(~S:Data,world:F.World(~S),prior:W.Handle<S>,failed:List<&2,W.Handle<S>>,returned:List<Array<U32>>,log:String,error:String,observed:Maybe<&1,Array<U32>> & String) -> Session<S>:
  match observed:
    case (incoming,text):Session{world,prior,failed,F.append_owner(incoming,returned),log ++ "failed-id-write:" ++ error ++ ";returned=" ++ text ++ "\n"}
def write_result(~S:Data,prior:W.Handle<S>,failed:List<&2,W.Handle<S>>,returned:List<Array<U32>>,log:String,result:C.Replacement<F.World(~S),Array<U32>>) -> Session<S>:
  match result:
    case C.ReplaceRejected{world,incoming,error}:write_observed(~S,world,prior,failed,returned,log,O.error(error),D.optional(~Array<U32>,~D.u32_array,incoming))
    case C.Replaced{world,previous}:write_observed(~S,world,prior,failed,returned,log,"Replaced",D.optional(~Array<U32>,~D.u32_array,previous))
def write_failed(~S:Data,value:Session<S>) -> Session<S>:
  match value:
    case Session{world,prior,[],returned,log}:Session{world,prior,[],returned,log ++ "missing-failed-receipt\n"}
    case Session{world,prior,+handle <> +rest,returned,log}:write_result(~S,prior,handle <> rest,returned,log,C.replace(~S,~F.Store<S>,~Array<U32>,~F.Notice<S>,~F.Rest,~Array<U32>,~U32,~Unit,~F.take(~S),~F.put(~S),~F.view,F.family(~S),world,handle,Some{ANode{ALeaf{900},ALeaf{901}}}))
def retried(~S:Data,prior:W.Handle<S>,failed:List<&2,W.Handle<S>>,returned:List<Array<U32>>,log:String,result:F.World(~S) & Maybe<&2,W.Handle<S>>) -> Session<S>:
  match result:
    case (world,None{}):Session{world,prior,failed,returned,log ++ "retry:Refused\n"}
    case (world,Some{handle}):Session{world,prior,failed,returned,log ++ "retry:" ++ F.handle_text(~S,handle) ++ "\n"}
def retry(~S:Data,value:Session<S>) -> Session<S>:
  match value:
    case Session{world,prior,failed,returned,log}:retried(~S,prior,failed,returned,log,F.spawn(~S,world,1000))
def barrier(~S:Data,value:Session<S>) -> Session<S>:
  match value:
    case Session{world,prior,failed,returned,log}:Session{W.barrier(~S,~F.Store<S>,~Array<U32>,~F.Notice<S>,world),prior,failed,returned,log}
def rendered(~S:Data,value:Session<S>) -> String:
  match value:
    case Session{_,_,_,_,log}:log
def steps(~S:Data,value:Session<S>) -> String:
  value=checkpoint(~S,"aborted-growth-prior-pending-retained",value)
  value=checkpoint(~S,"failed-id-despawn-refused",reject_failed(~S,value))
  value=checkpoint(~S,"failed-id-read-refused",read_failed(~S,value))
  value=checkpoint(~S,"failed-id-write-returned",write_failed(~S,value))
  value=checkpoint(~S,"retry-pending-fresh-id",retry(~S,value))
  rendered(~S,checkpoint(~S,"prior-and-retry-activated",barrier(~S,value)))
def probe_observed(~S:Data,prepared:List<Batch.Prepared<S,Array<U32>>>,prior:W.Handle<S>,failed:List<&2,W.Handle<S>>,log:String,+probe:W.Handle<S>,status:W.Status,result:F.Tx(~S) & String) -> Working<S>:
  match result:
    case (tx,text):Working{Batch.Batch{tx,prepared},prior,failed,log ++ "trusted-admin-nonreserved-key:" ++ F.handle_text(~S,probe) ++ ";status=" ++ O.status(status) ++ ";tx={" ++ text ++ "}\n"}
def probe_result(~S:Data,prepared:List<Batch.Prepared<S,Array<U32>>>,prior:W.Handle<S>,failed:List<&2,W.Handle<S>>,log:String,probe:W.Handle<S>,result:F.Tx(~S) & W.Status) -> Working<S>:
  match result:
    case (tx,status):probe_observed(~S,prepared,prior,failed,log,probe,status,O.tx(~S,tx))
# Explicit malformed-admin boundary key: same actual namespace/generation and
# index=prior.index+actual.capacity, so Array masking would alias prior Pending.
def probe(~S:Data,value:Working<S>) -> Working<S>:
  match value:
    case Working{Batch.Batch{T.Tx{W.World{+namespace,A.Allocator{next,high,slots,+capacity,depth,free,order},store,resource,events,pending,regs,sid,clock},undo,commands,txevents},prepared},+prior,failed,log}:probe_result(~S,prepared,prior,failed,log,W.Handle{namespace,K.EntityKey{U32.add(W.handle_index(~S,prior),capacity),K.generation(W.handle_key(~S,prior))}},F.despawn(~S,T.Tx{W.World{namespace,A.Allocator{next,high,slots,capacity,depth,free,order},store,resource,events,pending,regs,sid,clock},undo,commands,txevents},W.Handle{namespace,K.EntityKey{U32.add(W.handle_index(~S,prior),capacity),K.generation(W.handle_key(~S,prior))}}))
def started(~S:Data,result:F.World(~S) & Maybe<&2,W.Handle<S>>) -> String:
  match result:
    case (_,None{}):"prior-spawn-refused"
    case (world,Some{prior}):steps(~S,abort(~S,working(~S,"failed-batch-before-abort",spawn_many(~S,[200,300,400,500,600,700,800],probe(~S,working(~S,"initial-prior-pending",Working{Batch.begin(~S,~F.Store<S>,~Array<U32>,~F.Notice<S>,~Array<U32>,T.begin(~F.World(~S),~F.Notice<S>,world)),prior,[],""}))))))
def created(result:WI.Creation<F.Workshop,F.Store<F.Workshop>,Array<U32>,F.Notice<F.Workshop>>) -> IO(Unit):
  match result:
    case WI.Refused{_}:IO.print("creation-refused")
    case WI.Created{world}:IO.print(started(~F.Workshop,F.spawn(~F.Workshop,world,100)))
def main() -> IO(Unit):IO.bind(WI.Creation<F.Workshop,F.Store<F.Workshop>,Array<U32>,F.Notice<F.Workshop>>,Unit,WI.create(~F.Workshop,~F.Store<F.Workshop>,~Array<U32>,~F.Notice<F.Workshop>,~F.empty(~F.Workshop),ANode{ALeaf{61},ALeaf{62}}),created)

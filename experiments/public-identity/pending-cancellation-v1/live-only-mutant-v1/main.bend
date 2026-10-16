import Base
import /tmp/bendvy-pending-cancellation/src/ecs/world.bend as W
import /tmp/bendvy-pending-cancellation/experiments/public-identity/pending-cancellation-v1/live-only-mutant-v1/commands.bend as Cmd
import /tmp/bendvy-pending-cancellation/src/ecs/transaction.bend as T
import /tmp/bendvy-pending-cancellation/src/ecs/bundle-batch.bend as Batch
import /tmp/bendvy-pending-cancellation/src/ecs/bundle-delivery.bend as Delivery

type Workshop is Data:Workshop{}
type Garden is Data:Garden{}
type Store is Type:Store{payload:Maybe<&1,Array<U32>>,returned:List<Array<U32>>,trace:List<&2,U32>}
def World(~S:Data) -> Type:W.World<S,Store,Array<U32>,U32>
def Tx(~S:Data) -> Type:T.Tx<World(~S),U32>
type Session<S:Data> is Type:Session{world:World(~S),rows:List<&2,String>,handles:List<&2,W.Handle<S>>}
type Working<S:Data> is Type:Working{tx:Tx(~S),rows:List<&2,String>,handles:List<&2,W.Handle<S>>}
def empty(_:Unit) -> Store:Store{None{},[],[]}
def pair(+n:U32) -> Array<U32>:ANode{ALeaf{n},ALeaf{(n + 1 : U32)}}
def old_list(value:Maybe<&1,Array<U32>>,returned:List<Array<U32>>) -> List<Array<U32>>:
  match value:
    case None{}:returned
    case Some{value}:List.append(&1,Array<U32>,returned,[value])
def populated(store:Store,+id:U32,payload:Array<U32>) -> Store:
  match store:
    case Store{old,returned,trace}:Store{Some{payload},old_list(old,returned),List.append(&2,U32,trace,[(100 + id : U32)])}
def populated_world(~S:Data,value:World(~S) & Unit) -> World(~S):
  match value:
    case (world,_):world
def populate(~S:Data,world:World(~S),handle:W.Handle<S>,payload:Array<U32>) -> World(~S):
  match handle:
    case W.Handle{_,id}:populated_world(~S,W.with_store(~S,~Store,~Array<U32>,~U32,~Unit,store => (populated(store,id,payload),Unit{}),world))
def clear(~S:Data,store:Store,handle:W.Handle<S>) -> Store:
  match store handle:
    case Store{old,returned,trace} W.Handle{_,id}:Store{None{},old_list(old,returned),List.append(&2,U32,trace,[(200 + id : U32)])}
def leaf(~P:Type,result:P & String) -> Array<P> & String:
  (owner,text)=result
  (ALeaf{owner},"L(" ++ text ++ ")")
def tree_join(~P:Type,a:Array<P> & String,b:Array<P> & String) -> Array<P> & String:
  (a,at)=a
  (b,bt)=b
  (ANode{a,b},"N(" ++ at ++ "," ++ bt ++ ")")
def tree(~P:Type,~show:P -> P & String,value:Array<P>) -> Array<P> & String:
  match value:
    case ALeaf{value}:leaf(~P,show(value))
    case ANode{a,b}:tree_join(~P,tree(~P,~show,a),tree(~P,~show,b))
def u32_value(+value:U32) -> U32 & String:(value,U32.show(value))
def boolean_value(+value:Bool) -> Bool & String:(value,Bool.show(value))
def u32(value:U32) -> U32 & String:u32_value(value)
def boolean(value:Bool) -> Bool & String:boolean_value(value)
def array(value:Array<U32>) -> Array<U32> & String:tree(~U32,~u32,value)
def optional_join(result:Array<U32> & String) -> Maybe<&1,Array<U32>> & String:
  (owner,text)=result
  (Some{owner},"Some{" ++ text ++ "}")
def optional(value:Maybe<&1,Array<U32>>) -> Maybe<&1,Array<U32>> & String:
  match value:
    case None{}:(None{},"None")
    case Some{owner}:optional_join(array(owner))
def items_join(a:Array<U32> & String,b:List<Array<U32>> & String) -> List<Array<U32>> & String:
  (a,at)=a
  (b,bt)=b
  (a <> b,"cons(" ++ at ++ "," ++ bt ++ ")")
def items(values:List<Array<U32>>) -> List<Array<U32>> & String:
  match values:
    case []:([],"[]")
    case head <> tail:items_join(array(head),items(tail))
def store_join(+trace:List<&2,U32>,a:Maybe<&1,Array<U32>> & String,b:List<Array<U32>> & String) -> Store & String:
  (a,at)=a
  (b,bt)=b
  (Store{a,b,trace},"store{payload=" ++ at ++ ";returned=" ++ bt ++ ";trace=" ++ List.show(&2,U32,U32.show,trace) ++ "}")
def store(value:Store) -> Store & String:
  match value:
    case Store{payload,returned,trace}:store_join(trace,optional(payload),items(returned))
def callbacks_join(~P:Type,callback:P -> P,result:List<(P -> P)> & Nat) -> List<(P -> P)> & Nat:
  (values,count)=result
  (callback <> values,1n+count)
def callbacks(~P:Type,values:List<(P -> P)>) -> List<(P -> P)> & Nat:
  match values:
    case []:([],0n)
    case head <> tail:callbacks_join(~P,head,callbacks(~P,tail))
def registration(value:W.RegistrationMeta) -> String:
  match value:
    case W.RegistrationMeta{id,name,access}:"Reg{" ++ U32.show(id) ++ ";name=" ++ name ++ ";access=" ++ List.show(&2,String,x=>x,access) ++ "}"
def handle(~S:Data,value:W.Handle<S>) -> String:
  match value:
    case W.Handle{ns,id}:U32.show(ns) ++ ":" ++ U32.show(id)
def world_join(~S:Data,+ns:U32,+next:U32,+high:U32,+capacity:U32,+depth:Nat,+events:List<&2,U32>,+regs:List<&2,W.RegistrationMeta>,+sid:U32,+clock:U32,a:Array<Bool> & String,b:Store & String,c:Array<U32> & String,d:List<(World(~S) -> World(~S))> & Nat) -> World(~S) & String:
  (live,lt)=a
  (owner,ot)=b
  (resource,rt)=c
  (pending,count)=d
  (W.World{ns,next,high,live,capacity,depth,owner,resource,events,pending,regs,sid,clock},"world{ns=" ++ U32.show(ns) ++ ";next=" ++ U32.show(next) ++ ";high=" ++ U32.show(high) ++ ";physicalLive=" ++ lt ++ ";capacity=" ++ U32.show(capacity) ++ ";depth=" ++ Nat.show(depth) ++ ";" ++ ot ++ ";resource=" ++ rt ++ ";events=" ++ List.show(&2,U32,U32.show,events) ++ ";pending=" ++ Nat.show(count) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,registration,regs) ++ ";nextSystem=" ++ U32.show(sid) ++ ";clock=" ++ U32.show(clock) ++ "}")
def visible_returned(~S:Data,text:String,value:World(~S) & List<&2,W.Handle<S>>) -> World(~S) & String:
  match value:
    case (owner,handles):(owner,text ++ ";visible=" ++ List.show(&2,W.Handle<S>,handle(~S),handles))
def visible(~S:Data,value:World(~S) & String) -> World(~S) & String:
  match value:
    case (owner,text):visible_returned(~S,text,W.handles(~S,~Store,~Array<U32>,~U32,owner))
def world(~S:Data,value:World(~S)) -> World(~S) & String:
  match value:
    case W.World{ns,next,high,live,capacity,depth,owner,resource,events,pending,regs,sid,clock}:visible(~S,world_join(~S,ns,next,high,capacity,depth,events,regs,sid,clock,tree(~Bool,~boolean,live),store(owner),array(resource),callbacks(~World(~S),pending)))
def snapshot_join(~S:Data,label:String,rows:List<&2,String>,handles:List<&2,W.Handle<S>>,value:World(~S) & String) -> Session<S>:
  (owner,text)=value
  Session{owner,List.append(&2,String,rows,[label ++ ":" ++ text]),handles}
def snapshot(~S:Data,label:String,value:Session<S>) -> Session<S>:
  match value:
    case Session{owner,rows,handles}:snapshot_join(~S,label,rows,handles,world(~S,owner))
def begin(~S:Data,value:Session<S>) -> Working<S>:
  match value:
    case Session{owner,rows,handles}:Working{T.begin(~World(~S),~U32,owner),rows,handles}
def tx_view_join(~S:Data,label:String,+rows:List<&2,String>,handles:List<&2,W.Handle<S>>,+events:List<&2,U32>,a:World(~S) & String,b:List<(World(~S) -> World(~S))> & Nat,c:List<(World(~S) -> World(~S))> & Nat) -> Working<S>:
  (owner,text)=a
  (undo,uc)=b
  (commands,cc)=c
  Working{T.Tx{owner,undo,commands,events},List.append(&2,String,rows,[label ++ ":tx{undo=" ++ Nat.show(uc) ++ ";commands=" ++ Nat.show(cc) ++ ";events=" ++ List.show(&2,U32,U32.show,events) ++ ";" ++ text ++ "}"]),handles}
def tx_view(~S:Data,label:String,value:Working<S>) -> Working<S>:
  match value:
    case Working{T.Tx{owner,undo,commands,events},rows,handles}:tx_view_join(~S,label,rows,handles,events,world(~S,owner),callbacks(~World(~S),undo),callbacks(~World(~S),commands))
def spawn_returned(~S:Data,rows:List<&2,String>,handles:List<&2,W.Handle<S>>,value:Tx(~S) & W.Reservation<S>) -> Working<S>:
  match value:
    case (tx,W.Reserved{+h}):Working{tx,List.append(&2,String,rows,["spawn=" ++ handle(~S,h)]),List.append(&2,W.Handle<S>,handles,[h])}
    case (tx,W.ReservationRejected{_}):Working{tx,List.append(&2,String,rows,["unexpected-spawn-refusal"]),handles}
def spawn(~S:Data,value:Working<S>,+seed:U32) -> Working<S>:
  match value:
    case Working{tx,rows,handles}:spawn_returned(~S,List.append(&2,String,rows,["incoming=" ++ U32.show(seed) ++ "," ++ U32.show((seed + 1 : U32))]),handles,Cmd.tx_spawn(~S,~Store,~Array<U32>,~U32,~Array<U32>,~populate(~S),tx,pair(seed)))
def get(~S:Data,index:Nat,values:List<&2,W.Handle<S>>) -> Maybe<&2,W.Handle<S>>:
  match index values:
    case _ Nil{}:None{}
    case 0n Con{h,_}:Some{h}
    case 1n+rest Con{_,tail}:get(~S,rest,tail)
def status(value:W.Status) -> String:
  match value:
    case W.Accepted{}:"Accepted"
    case W.Rejected{W.MissingEntity{}}:"MissingEntity"
    case W.Rejected{_}:"OtherRefusal"
def despawn_returned(~S:Data,rows:List<&2,String>,handles:List<&2,W.Handle<S>>,value:Tx(~S) & W.Status) -> Working<S>:
  match value:
    case (tx,result):Working{tx,List.append(&2,String,rows,["despawn=" ++ status(result)]),handles}
def despawn_selected(~S:Data,value:Working<S>,selected:Maybe<&2,W.Handle<S>>) -> Working<S>:
  match value selected:
    case value None{}:value
    case Working{tx,rows,handles} Some{h}:despawn_returned(~S,rows,handles,Cmd.tx_despawn_with(~S,~Store,~Array<U32>,~U32,~clear(~S),tx,h))
def despawn(~S:Data,value:Working<S>,index:Nat) -> Working<S>:
  match value:
    case Working{tx,rows,+handles}:despawn_selected(~S,Working{tx,rows,handles},get(~S,index,handles))
def finished(~S:Data,rows:List<&2,String>,handles:List<&2,W.Handle<S>>,value:T.Returned<World(~S),Unit>) -> Session<S>:
  match value:
    case T.Returned{owner,T.Success{}}:Session{owner,List.append(&2,String,rows,["finish=Success"]),handles}
    case T.Returned{owner,T.Failure{Unit{}}}:Session{owner,List.append(&2,String,rows,["finish=Failure"]),handles}
def finish(~S:Data,value:Working<S>,outcome:T.Outcome<Unit>) -> Session<S>:
  match value:
    case Working{tx,rows,handles}:finished(~S,rows,handles,Cmd.tx_finish(~S,~Store,~Array<U32>,~U32,~Unit,tx,outcome))
def barrier(~S:Data,value:Session<S>) -> Session<S>:
  match value:
    case Session{owner,rows,handles}:snapshot(~S,"barrier",Session{W.barrier(~S,~Store,~Array<U32>,~U32,owner),rows,handles})
def BatchType(~S:Data) -> Type:Batch.Batch<S,Store,Array<U32>,U32,Array<U32>>
def prepared_join(~S:Data,+target:W.Handle<S>,+position:Nat,value:Array<U32> & String) -> Batch.Prepared<S,Array<U32>> & String:
  (owner,text)=value
  (Batch.Prepared{target,owner,position},"Prepared{target=" ++ handle(~S,target) ++ ";position=" ++ Nat.show(position) ++ ";payload=" ++ text ++ "}")
def prepared(~S:Data,value:Batch.Prepared<S,Array<U32>>) -> Batch.Prepared<S,Array<U32>> & String:
  match value:
    case Batch.Prepared{target,owner,position}:prepared_join(~S,target,position,array(owner))
    case Batch.ReservationReceipt{+target}:(Batch.ReservationReceipt{target},"ReservationReceipt{" ++ handle(~S,target) ++ "}")
def prepareds_join(~S:Data,a:Batch.Prepared<S,Array<U32>> & String,b:List<Batch.Prepared<S,Array<U32>>> & String) -> List<Batch.Prepared<S,Array<U32>>> & String:
  (a,at)=a
  (b,bt)=b
  (a <> b,"cons(" ++ at ++ "," ++ bt ++ ")")
def prepareds(~S:Data,values:List<Batch.Prepared<S,Array<U32>>>) -> List<Batch.Prepared<S,Array<U32>>> & String:
  match values:
    case []:([],"[]")
    case head <> tail:prepareds_join(~S,prepared(~S,head),prepareds(~S,tail))
def attempt(~S:Data,world:World(~S),target:W.Handle<S>,payload:Array<U32>) -> Delivery.Delivery<World(~S),Array<U32>>:Delivery.Delivered{populate(~S,world,target,payload)}
def recover_store(store:Store,payload:Array<U32>) -> Store:
  match store:
    case Store{old,returned,trace}:Store{old,List.append(&1,Array<U32>,returned,[payload]),List.append(&2,U32,trace,[999])}
def recover(~S:Data,world:World(~S),payload:Array<U32>,_:W.WorldError) -> World(~S):populated_world(~S,W.with_store(~S,~Store,~Array<U32>,~U32,~Unit,owner => (recover_store(owner,payload),Unit{}),world))
def batch_finished(~S:Data,rows:List<&2,String>,handles:List<&2,W.Handle<S>>,value:Batch.Finished<S,Store,Array<U32>,U32,Array<U32>,Unit>) -> Session<S>:
  match value:
    case Batch.Committed{owner}:Session{owner,List.append(&2,String,rows,["batch-finish=Committed"]),handles}
    case Batch.Failed{owner,payloads,_}:Session{owner,List.append(&2,String,rows,["unexpected-batch-failure"]),handles}
def batch_cancelled(~S:Data,prepared:List<Batch.Prepared<S,Array<U32>>>,value:Working<S>) -> Session<S>:
  match value:
    case Working{tx,rows,handles}:batch_finished(~S,rows,handles,Batch.finish(~S,~Store,~Array<U32>,~U32,~Array<U32>,~Unit,~attempt(~S),~recover(~S),Batch.Batch{tx,prepared},T.Success{}))
def batch_ready(~S:Data,tx:Tx(~S),rows:List<&2,String>,+handles:List<&2,W.Handle<S>>,+target:W.Handle<S>,value:List<Batch.Prepared<S,Array<U32>>> & String) -> Session<S>:
  (prepared,text)=value
  batch_cancelled(~S,prepared,tx_view(~S,"batch-cancelled",despawn_selected(~S,tx_view(~S,"batch-staged",Working{tx,List.append(&2,String,rows,["batch-prepared=" ++ text]),List.append(&2,W.Handle<S>,handles,[target])}),Some{target})))
def batch_spawned(~S:Data,rows:List<&2,String>,handles:List<&2,W.Handle<S>>,value:Batch.Spawned<S,Store,Array<U32>,U32,Array<U32>>) -> Session<S>:
  match value:
    case Batch.Spawned{Batch.Batch{tx,prepared},target}:batch_ready(~S,tx,rows,handles,target,prepareds(~S,prepared))
    case Batch.SpawnRefused{Batch.Batch{tx,prepared},payload,error}:finish(~S,Working{tx,List.append(&2,String,rows,["unexpected-batch-refusal"]),handles},T.Failure{Unit{}})
def batch_case(~S:Data,value:Session<S>) -> Session<S>:
  match value:
    case Session{owner,rows,handles}:batch_spawned(~S,List.append(&2,String,rows,["batch-incoming=20,21"]),handles,Batch.spawn(~S,~Store,~Array<U32>,~U32,~Array<U32>,Batch.begin(~S,~Store,~Array<U32>,~U32,~Array<U32>,T.begin(~World(~S),~U32,owner)),pair(20)))
def direct_case(~S:Data,value:Session<S>) -> Session<S>:
  barrier(~S,snapshot(~S,"direct-committed",finish(~S,tx_view(~S,"direct-cancelled",despawn(~S,tx_view(~S,"direct-staged",spawn(~S,begin(~S,value),10)),0n)),T.Success{})))
def cross_spawn(~S:Data,value:Session<S>) -> Session<S>:
  snapshot(~S,"cross-pending",finish(~S,tx_view(~S,"cross-staged",spawn(~S,begin(~S,value),30)),T.Success{}))
def cross_cancel(~S:Data,value:Session<S>) -> Session<S>:
  barrier(~S,snapshot(~S,"cross-cancel-committed",finish(~S,tx_view(~S,"cross-cancelled",despawn(~S,begin(~S,value),2n)),T.Success{})))
def prior_spawn(~S:Data,value:Session<S>) -> Session<S>:
  snapshot(~S,"prior-pending",finish(~S,tx_view(~S,"prior-staged",spawn(~S,begin(~S,value),40)),T.Success{}))
def aborted(~S:Data,value:Session<S>) -> Session<S>:
  snapshot(~S,"after-abort-growth",finish(~S,tx_view(~S,"abort-staged",spawn(~S,spawn(~S,spawn(~S,spawn(~S,begin(~S,value),50),60),70),80)),T.Failure{Unit{}}))
def refused_retry(~S:Data,value:Session<S>) -> Session<S>:
  barrier(~S,snapshot(~S,"failed-id-refused",finish(~S,tx_view(~S,"failed-id-refusal",despawn(~S,begin(~S,value),4n)),T.Success{})))
def cleanup_prior(~S:Data,value:Session<S>) -> Session<S>:
  barrier(~S,finish(~S,tx_view(~S,"prior-live-despawn",despawn(~S,begin(~S,value),3n)),T.Success{}))
def run(~S:Data,value:World(~S)) -> Session<S>:
  cleanup_prior(~S,refused_retry(~S,aborted(~S,prior_spawn(~S,cross_cancel(~S,cross_spawn(~S,barrier(~S,snapshot(~S,"batch-committed",batch_case(~S,direct_case(~S,snapshot(~S,"created",Session{value,[],[]})))))))))))
def render_session(~S:Data,value:Session<S>) -> String:
  match value:
    case Session{_,rows,handles}:"rows=" ++ List.show(&2,String,x=>x,rows) ++ ";handles=" ++ List.show(&2,W.Handle<S>,handle(~S),handles)
def created(~S:Data,value:W.Creation<S,Store,Array<U32>,U32>) -> String:
  match value:
    case W.Created{_,owner}:render_session(~S,run(~S,owner))
    case W.CreateRejected{_,_}:"unexpected-creation-refusal"
def scenario(~S:Data) -> String:created(~S,W.create(~S,~Store,~Array<U32>,~U32,~empty,W.factory(),pair(900)))
def main() -> IO(Unit):IO.print("Workshop{" ++ scenario(~Workshop) ++ "}\nGarden{" ++ scenario(~Garden) ++ "}")

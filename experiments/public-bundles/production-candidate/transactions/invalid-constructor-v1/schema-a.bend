import Base
import ../schema-a.bend as Current
import ../../schema-a.bend as Previous
import ../batch.bend as BT
import ../../../combined-control.bend as A
import ../../../constructor-control.bend as K
import ../../../prototype.bend as B
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/transaction.bend as T

# Read actual installed queued Arrays and reconstruct every affine owner.
def queued_result(~Out:Type,next:List<Array<U32>> -> List<&2,String> -> Out,result:List<Array<U32>> & List<&2,String>) -> Out:
  match result:
    case (owners,texts): next(owners,texts)
def installed_result(~Out:Type,next:List<A.Installed> -> List<&2,String> -> Out,result:List<A.Installed> & List<&2,String>) -> Out:
  match result:
    case (owners,texts): next(owners,texts)
def installed_head(head:A.Installed,result:List<A.Installed> & List<&2,String>) -> List<A.Installed> & List<&2,String>:
  match head result:
    case A.Installed{inverse,queued,undo}, (tail,texts): queued_result(~(List<A.Installed> & List<&2,String>),owners => values => (A.Installed{inverse,owners,undo} <> tail,List.show(&2,String,K.string_identity,values) <> texts),K.list_read(queued))
def installed_read(owners:List<A.Installed>) -> List<A.Installed> & List<&2,String>:
  match owners:
    case []: ([],[])
    case head <> tail: installed_head(head,installed_read(tail))
def inspected(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> W.World<A.Schema,A.Store,A.Mail,U32> & String:
  match world:
    case W.World{ns,next,high,live,cap,depth,store,A.Mail{context,items,installed,quarantine,errors},events,pending,regs,system,clock}:
      installed_result(~(W.World<A.Schema,A.Store,A.Mail,U32> & String),owners => texts => (W.World{ns,next,high,live,cap,depth,store,A.Mail{context,items,owners,quarantine,errors},events,pending,regs,system,clock},List.show(&2,String,K.string_identity,texts)),installed_read(installed))
def observed(result:W.World<A.Schema,A.Store,A.Mail,U32> & String) -> String:
  match result:
    case (world,text): A.snapshot(world) ++ "|installed-queues=" ++ text
def world_snapshot(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  observed(inspected(world))
def batch_observed(undo:List<(W.World<A.Schema,A.Store,A.Mail,U32> -> W.World<A.Schema,A.Store,A.Mail,U32>)>,commands:List<(W.World<A.Schema,A.Store,A.Mail,U32> -> W.World<A.Schema,A.Store,A.Mail,U32>)>,events:List<&2,U32>,prepared:List<BT.Prepared<A.Schema,A.Packet>>,result:W.World<A.Schema,A.Store,A.Mail,U32> & String) -> String:
  match result:
    case (world,text): Current.snapshot(BT.Batch{T.Tx{world,undo,commands,events},prepared}) ++ "|installed-queues=" ++ text
def batch_snapshot(batch:BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>) -> String:
  match batch:
    case BT.Batch{T.Tx{world,undo,commands,events},prepared}: batch_observed(undo,commands,events,prepared,inspected(world))

def prepared(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>:
  Current.local(Current.begin(world))
def refused_spawn(batch:BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>) -> BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>:
  Current.call_input(batch,Current.Input{Current.Spawn{},K.input(False{},False{})})
def refused_insert(batch:BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>) -> BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>:
  match batch:
    case BT.Batch{T.Tx{W.World{+ns,next,high,live,cap,depth,store,resource,events,pending,regs,system,clock},undo,commands,emitted},packets}:
      Current.call_input(BT.Batch{T.Tx{W.World{ns,next,high,live,cap,depth,store,resource,events,pending,regs,system,clock},undo,commands,emitted},packets},Current.Input{Current.Insert{W.Handle{ns,1}},K.input(True{},False{})})
# Repair only the fixture's validation flags on the actual returned owners.
def repaired(raw:B.Pack<K.Raw<Array<U32>>,B.Pack<K.Raw<U32>,B.Pack<K.Raw<K.Tag>,B.Pack<K.Raw<K.QueueOwner>,Unit>>>>) -> B.Pack<K.Raw<Array<U32>>,B.Pack<K.Raw<U32>,B.Pack<K.Raw<K.Tag>,B.Pack<K.Raw<K.QueueOwner>,Unit>>>>:
  match raw:
    case B.Pack{K.Raw{_,stock},B.Pack{K.Raw{_,value},B.Pack{K.Raw{_,tag},B.Pack{K.Raw{_,queue},Unit{}}}}}: B.Pack{K.Raw{True{},stock},B.Pack{K.Raw{True{},value},B.Pack{K.Raw{True{},tag},B.Pack{K.Raw{True{},queue},Unit{}}}}}
def retry(spawn:Bool,batch:BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>) -> BT.Batch<A.Schema,A.Store,A.Mail,U32,A.Packet>:
  match spawn batch:
    case True{} BT.Batch{T.Tx{W.World{ns,next,high,live,cap,depth,store,A.Mail{context,A.Original{raw} <> items,installed,quarantine,errors},events,pending,regs,system,clock},undo,commands,emitted},packets}:
      Current.call_input(BT.Batch{T.Tx{W.World{ns,next,high,live,cap,depth,store,A.Mail{context,items,installed,quarantine,errors},events,pending,regs,system,clock},undo,commands,emitted},packets},Current.Input{Current.Spawn{},repaired(raw)})
    case False{} BT.Batch{T.Tx{W.World{+ns,next,high,live,cap,depth,store,A.Mail{context,A.Original{raw} <> items,installed,quarantine,errors},events,pending,regs,system,clock},undo,commands,emitted},packets}:
      Current.call_input(BT.Batch{T.Tx{W.World{ns,next,high,live,cap,depth,store,A.Mail{context,items,installed,quarantine,errors},events,pending,regs,system,clock},undo,commands,emitted},packets},Current.Input{Current.Insert{W.Handle{ns,1}},repaired(raw)})
    case _ batch: batch

def setup_before(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  batch_snapshot(prepared(world))
def spawn_before(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  batch_snapshot(refused_spawn(prepared(world)))
def spawn_after(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  world_snapshot(W.barrier(~A.Schema,~A.Store,~A.Mail,~U32,Current.finish(refused_spawn(prepared(world)),T.Success{})))
def spawn_retry(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  world_snapshot(W.barrier(~A.Schema,~A.Store,~A.Mail,~U32,Current.finish(retry(True{},refused_spawn(prepared(world))),T.Success{})))
def insert_before(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  batch_snapshot(refused_insert(prepared(world)))
def insert_after(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  world_snapshot(W.barrier(~A.Schema,~A.Store,~A.Mail,~U32,Current.finish(refused_insert(prepared(world)),T.Success{})))
def insert_retry(world:W.World<A.Schema,A.Store,A.Mail,U32>) -> String:
  world_snapshot(W.barrier(~A.Schema,~A.Store,~A.Mail,~U32,Current.finish(retry(False{},refused_insert(prepared(world))),T.Success{})))

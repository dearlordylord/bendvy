import Base
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/entity-key.bend as K
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/component.bend as C
import ../../../src/ecs/lifecycle.bend as L
import ../../../src/ecs/commands.bend as Cmd
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/bundle-batch.bend as Batch
import ../../../src/ecs/bundle-delivery.bend as Delivery
import ../../../src/ecs/ordinary-declaration.bend as Identity
import ../../../src/ecs/ordinary-component-binding.bend as Binding
import ../../../src/ecs/ordinary-component-despawn.bend as Despawn

type Workshop is Data:Workshop{}
type Garden is Data:Garden{}
type Store<S:Data> is Type:
  Store{column:Col.Column<S,Array<U32>>,returned:List<Array<U32>>,trace:List<&2,String>}
type Rest is Type:Rest{returned:List<Array<U32>>,trace:List<&2,String>}
type Notice<S:Data> is Data:
  Removed{handle:W.Handle<S>}
  Cleared{handle:W.Handle<S>}
def World(~S:Data) -> Type:W.World<S,Store<S>,Array<U32>,Notice<S>>
def Tx(~S:Data) -> Type:T.Tx<World(~S),Notice<S>>
def empty(~S:Data,_:Unit) -> Store<S>:Store{Col.empty(~S,~Array<U32>),[],[]}
def take(~S:Data,store:Store<S>) -> Rest & Col.Column<S,Array<U32>>:
  match store:
    case Store{column,returned,trace}:(Rest{returned,trace},column)
def put(~S:Data,rest:Rest,column:Col.Column<S,Array<U32>>) -> Store<S>:
  match rest:
    case Rest{returned,trace}:Store{column,returned,trace}
def view(value:Array<U32>) -> Array<U32> & U32:Array.get(U32,value,0)
def binding(~S:Data) -> Binding.Binding<S,Store<S>,Rest,Array<U32>,U32,Unit,take(~S),put(~S),view>:
  Binding.bind(~S,~Store<S>,~Rest,~Array<U32>,~U32,~Unit,~take(~S),~put(~S),~view,Identity.component(~S,~Array<U32>,"payload"))
def family(~S:Data) -> C.Family<S,Store<S>,Rest,Array<U32>,U32,Unit,take(~S),put(~S),view>:
  Binding.family(~S,~Store<S>,~Rest,~Array<U32>,~U32,~Unit,~take(~S),~put(~S),~view,binding(~S))
def key_text(key:K.Key) -> String:
  match key:
    case K.EntityKey{index,generation}:U32.show(index) ++ ":" ++ U32.show(generation)
def handle_text(~S:Data,handle:W.Handle<S>) -> String:
  match handle:
    case W.Handle{namespace,key}:U32.show(namespace) ++ "/" ++ key_text(key)
def append_owner(value:Maybe<&1,Array<U32>>,returned:List<Array<U32>>) -> List<Array<U32>>:
  match value:
    case None{}:returned
    case Some{owner}:List.append(&1,Array<U32>,returned,[owner])
def retained(~S:Data,+label:String,rest:Rest,observed:Col.Column<S,Array<U32>> & Maybe<&1,Array<U32>>) -> Store<S>:
  match rest observed:
    case Rest{returned,trace}, (column,previous):Store{column,append_owner(previous,returned),List.append(&2,String,trace,[label])}
def installed(~S:Data,+handle:W.Handle<S>,result:C.Replacement<World(~S),Array<U32>>) -> Delivery.Delivery<World(~S),Array<U32>>:
  match result:
    case C.Replaced{W.World{namespace,allocator,Store{column,returned,trace},resource,events,pending,regs,sid,clock},previous}:Delivery.Delivered{W.World{namespace,allocator,Store{column,append_owner(previous,returned),List.append(&2,String,trace,["populate:" ++ handle_text(~S,handle)])},resource,events,pending,regs,sid,clock}}
    case C.ReplaceRejected{world,Some{payload},error}:Delivery.Undelivered{world,payload,error}
    case C.ReplaceRejected{world,None{},error}:Delivery.Delivered{world}
def attempt(~S:Data,world:World(~S),handle:W.Handle<S>,payload:Array<U32>) -> Delivery.Delivery<World(~S),Array<U32>>:
  +handle=handle
  installed(~S,handle,C.replace(~S,~Store<S>,~Array<U32>,~Notice<S>,~Rest,~Array<U32>,~U32,~Unit,~take(~S),~put(~S),~view,family(~S),world,handle,Some{payload}))
def recover(~S:Data,world:World(~S),payload:Array<U32>,error:W.WorldError) -> World(~S):
  match world:
    case W.World{namespace,allocator,Store{column,returned,trace},resource,events,pending,regs,sid,clock}:W.World{namespace,allocator,Store{column,List.append(&1,Array<U32>,returned,[payload]),List.append(&2,String,trace,["delivery-refused"])},resource,events,pending,regs,sid,clock}
def finished(~S:Data,target:Maybe<&2,W.Handle<S>>,result:Batch.Finished<S,Store<S>,Array<U32>,Notice<S>,Array<U32>,Unit>) -> World(~S) & Maybe<&2,W.Handle<S>>:
  match result:
    case Batch.Committed{world}:(world,target)
    case Batch.Failed{world,_,_}:(world,target)
def spawned(~S:Data,result:Batch.Spawned<S,Store<S>,Array<U32>,Notice<S>,Array<U32>>) -> World(~S) & Maybe<&2,W.Handle<S>>:
  match result:
    case Batch.Spawned{batch,+target}:finished(~S,Some{target},Batch.finish(~S,~Store<S>,~Array<U32>,~Notice<S>,~Array<U32>,~Unit,~attempt(~S),~recover(~S),batch,T.Success{}))
    case Batch.SpawnRefused{batch,payload,error}:finished(~S,None{},Batch.finish(~S,~Store<S>,~Array<U32>,~Notice<S>,~Array<U32>,~Unit,~attempt(~S),~recover(~S),batch,T.Failure{Unit{}}))
def spawn(~S:Data,world:World(~S),+value:U32) -> World(~S) & Maybe<&2,W.Handle<S>>:
  spawned(~S,Batch.spawn(~S,~Store<S>,~Array<U32>,~Notice<S>,~Array<U32>,Batch.begin(~S,~Store<S>,~Array<U32>,~Notice<S>,~Array<U32>,T.begin(~World(~S),~Notice<S>,world)),ANode{ALeaf{value},ALeaf{(value + 1 : U32)}}))
def clear_returned(~S:Data,+handle:W.Handle<S>,rest:Rest,result:Col.SwapOutcome<S,Array<U32>>) -> Store<S> & List<&2,Notice<S>>:
  match result:
    case Col.Accepted{column,previous}:(retained(~S,"clear:" ++ handle_text(~S,handle),rest,(column,previous)),[Removed{handle}])
    case Col.Rejected{column,previous}:(retained(~S,"clear-refused",rest,(column,previous)),[])
def clear(~S:Data,store:Store<S>,handle:W.Handle<S>) -> Store<S> & List<&2,Notice<S>>:
  match store handle:
    case Store{column,returned,trace} +handle:clear_returned(~S,handle,Rest{returned,trace},Col.clear(~S,~Array<U32>,column,W.handle_index(~S,handle)))
def record(~S:Data,handle:W.Handle<S>) -> Notice<S>:Cleared{handle}
def despawn(~S:Data,tx:Tx(~S),handle:W.Handle<S>) -> Tx(~S) & W.Status:
  Despawn.despawn(~S,~Store<S>,~Array<U32>,~Notice<S>,~clear(~S),~record(~S),tx,handle)
def returned(~S:Data,result:T.Returned<World(~S),Unit>) -> World(~S):
  match result:
    case T.Returned{world,_}:world

def finish(~S:Data,tx:Tx(~S)) -> World(~S):
  returned(~S,Cmd.tx_finish(~S,~Store<S>,~Array<U32>,~Notice<S>,~Unit,tx,T.Success{}))

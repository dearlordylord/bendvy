import Base
import ../fixture.bend as F
import ../observe.bend as O
import ../owner-observer.bend as Dump
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/component.bend as C
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/commands.bend as Cmd
import ../../../../src/ecs/transaction.bend as T
import ../../../../src/ecs/bundle-batch.bend as Batch
import ../../../../src/ecs/bundle-delivery.bend as Delivery
import ../../../../src/ecs/relation-types.bend as G
import ../../../../src/ecs/relation-commands.bend as A
import ../../../../src/ecs/relation-cleanup.bend as Cleanup
import ../../../../src/ecs/ordinary-component-binding.bend as Binding
import ../../../../src/ecs/ordinary-declaration.bend as Identity

def Store(~S:Data) -> Type:A.Store<S,F.Store<S>>
def Notice(~S:Data) -> Data:A.Notice<S,F.Notice<S>>
def World(~S:Data) -> Type:W.World<S,Store(~S),Array<U32>,Notice(~S)>
def Tx(~S:Data) -> Type:T.Tx<World(~S),Notice(~S)>
type Rest<S:Data> is Type:Rest{components:F.Rest,graph:G.Graph<S>}
def empty(~S:Data,unit:Unit) -> Store(~S):A.empty(~S,~F.Store<S>,F.empty(~S,unit))
def taken(~S:Data,graph:G.Graph<S>,result:F.Rest & Col.Column<S,Array<U32>>) -> Rest<S> & Col.Column<S,Array<U32>>:
  match result:
    case (rest,column):(Rest{rest,graph},column)
def take(~S:Data,store:Store(~S)) -> Rest<S> & Col.Column<S,Array<U32>>:
  match store:
    case A.Store{components,graph}:taken(~S,graph,F.take(~S,components))
def put(~S:Data,rest:Rest<S>,column:Col.Column<S,Array<U32>>) -> Store(~S):
  match rest:
    case Rest{rest,graph}:A.Store{F.put(~S,rest,column),graph}
def family(~S:Data) -> C.Family<S,Store(~S),Rest<S>,Array<U32>,U32,Unit,take(~S),put(~S),F.view>:
  Binding.family(~S,~Store(~S),~Rest<S>,~Array<U32>,~U32,~Unit,~take(~S),~put(~S),~F.view,Binding.bind(~S,~Store(~S),~Rest<S>,~Array<U32>,~U32,~Unit,~take(~S),~put(~S),~F.view,Identity.component(~S,~Array<U32>,"payload")))
def installed(~S:Data,+handle:W.Handle<S>,result:C.Replacement<World(~S),Array<U32>>) -> Delivery.Delivery<World(~S),Array<U32>>:
  match result:
    case C.Replaced{W.World{ns,allocator,A.Store{F.Store{column,returned,trace},graph},resource,events,pending,regs,sid,clock},previous}:Delivery.Delivered{W.World{ns,allocator,A.Store{F.Store{column,F.append_owner(previous,returned),List.append(&2,String,trace,["populate:" ++ F.handle_text(~S,handle)])},graph},resource,events,pending,regs,sid,clock}}
    case C.ReplaceRejected{world,Some{payload},error}:Delivery.Undelivered{world,payload,error}
    case C.ReplaceRejected{world,None{},_}:Delivery.Delivered{world}
def attempt(~S:Data,world:World(~S),handle:W.Handle<S>,payload:Array<U32>) -> Delivery.Delivery<World(~S),Array<U32>>:
  +handle=handle
  installed(~S,handle,C.replace(~S,~Store(~S),~Array<U32>,~Notice(~S),~Rest<S>,~Array<U32>,~U32,~Unit,~take(~S),~put(~S),~F.view,family(~S),world,handle,Some{payload}))
def recover(~S:Data,world:World(~S),payload:Array<U32>,error:W.WorldError) -> World(~S):
  match world:
    case W.World{ns,allocator,A.Store{F.Store{column,returned,trace},graph},resource,events,pending,regs,sid,clock}:W.World{ns,allocator,A.Store{F.Store{column,List.append(&1,Array<U32>,returned,[payload]),List.append(&2,String,trace,["delivery-refused"])},graph},resource,events,pending,regs,sid,clock}
def finished(~S:Data,target:Maybe<&2,W.Handle<S>>,result:Batch.Finished<S,Store(~S),Array<U32>,Notice(~S),Array<U32>,Unit>) -> World(~S) & Maybe<&2,W.Handle<S>>:
  match result:
    case Batch.Committed{world}:(world,target)
    case Batch.Failed{world,_,_}:(world,target)
def spawned(~S:Data,result:Batch.Spawned<S,Store(~S),Array<U32>,Notice(~S),Array<U32>>) -> World(~S) & Maybe<&2,W.Handle<S>>:
  match result:
    case Batch.Spawned{batch,+target}:finished(~S,Some{target},Batch.finish(~S,~Store(~S),~Array<U32>,~Notice(~S),~Array<U32>,~Unit,~attempt(~S),~recover(~S),batch,T.Success{}))
    case Batch.SpawnRefused{batch,_,_}:finished(~S,None{},Batch.finish(~S,~Store(~S),~Array<U32>,~Notice(~S),~Array<U32>,~Unit,~attempt(~S),~recover(~S),batch,T.Failure{Unit{}}))
def spawn(~S:Data,world:World(~S),+value:U32) -> World(~S) & Maybe<&2,W.Handle<S>>:
  spawned(~S,Batch.spawn(~S,~Store(~S),~Array<U32>,~Notice(~S),~Array<U32>,Batch.begin(~S,~Store(~S),~Array<U32>,~Notice(~S),~Array<U32>,T.begin(~World(~S),~Notice(~S),world)),ANode{ALeaf{value},ALeaf{(value + 1 : U32)}}))
def notices(~S:Data,values:List<&2,F.Notice<S>>) -> List<&2,Notice(~S)>:
  match values:
    case []:[]
    case value <> rest:A.Original{value} <> notices(~S,rest)
def clear_join(~S:Data,graph:G.Graph<S>,result:F.Store<S> & List<&2,F.Notice<S>>) -> Store(~S) & List<&2,Notice(~S)>:
  match result:
    case (components,records):(A.Store{components,graph},notices(~S,records))
def clear(~S:Data,store:Store(~S),handle:W.Handle<S>) -> Store(~S) & List<&2,Notice(~S)>:
  match store:
    case A.Store{components,graph}:clear_join(~S,graph,F.clear(~S,components,handle))
def record(~S:Data,handle:W.Handle<S>) -> Notice(~S):A.Original{F.Cleared{handle}}
def committed(~S:Data,result:T.Returned<World(~S),Unit>) -> World(~S):
  match result:
    case T.Returned{world,_}:world
def finish(~S:Data,tx:Tx(~S)) -> World(~S):committed(~S,Cmd.tx_finish(~S,~Store(~S),~Array<U32>,~Notice(~S),~Unit,tx,T.Success{}))
def component_cleared(~S:Data,result:F.Store<S> & List<&2,F.Notice<S>>) -> F.Store<S> & List<&2,Notice(~S)>:
  match result:
    case (components,records):(components,notices(~S,records))
def component_clear(~S:Data,components:F.Store<S>,handle:W.Handle<S>) -> F.Store<S> & List<&2,Notice(~S)>:
  component_cleared(~S,F.clear(~S,components,handle))
def cleanup(~S:Data,fuel:Nat,frames:List<&2,G.CleanupFrame<S>>,world:World(~S),namespace:U32) -> Cleanup.CleanupResult<S,F.Store<S>,Array<U32>,F.Notice<S>>:
  Cleanup.drive(~S,~F.Store<S>,~Array<U32>,~F.Notice<S>,~component_clear(~S),~record(~S),fuel,frames,world,namespace,[])

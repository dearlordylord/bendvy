import Base
import ./schema.bend as S
import ./schema-walk.bend as Walk
import ../../src/ecs/execution-query-schema.bend as Schema
import ../../src/ecs/execution-query-store.bend as Store
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/change-tick.bend as Tick

type Local is Type:
  Local{queue:Buffer.Buffer<S.SchemaA,S.Position,Unit>,capture:Array<U32>}
type Body is Type:
  Body{store:Store.stores(~S.SchemaA,S.layout_a()),local:Local,failed:Bool,unused:List<&1,S.Position -> S.Position & Unit>}
def edited(rest:Store.route_rest(~S.SchemaA,S.layout_a(),L.InLeft{L.AtLeaf{}}),local:Local,failed:Bool,result:Store.Edit<S.SchemaA,S.Position,U32,S.positions(),Unit>) -> Body:
  match result:
    case Store.Edited{slot,_}:Body{Store.put(~S.SchemaA,S.layout_a(),L.InLeft{L.AtLeaf{}},rest,slot),local,failed,[]}
    case Store.Unchanged{slot,unused}:Body{Store.put(~S.SchemaA,S.layout_a(),L.InLeft{L.AtLeaf{}},rest,slot),local,failed,[unused]}
def taken(local:Local,failed:Bool,index:U32,tick:Tick.Tick,result:Store.route_rest(~S.SchemaA,S.layout_a(),L.InLeft{L.AtLeaf{}}) & Store.Slot<S.SchemaA,S.Position,U32,S.positions()>) -> Body:
  match result:
    case (rest,slot):edited(rest,local,failed,Store.edit_slot(~S.SchemaA,~S.layout_a(),~L.InLeft{L.AtLeaf{}},Unit,slot,index,tick,S.moved))
def body(store:Store.stores(~S.SchemaA,S.layout_a()),local:Local,failed:Bool,index:U32,tick:Tick.Tick) -> Body:
  taken(local,failed,index,tick,Store.take(~S.SchemaA,S.layout_a(),L.InLeft{L.AtLeaf{}},store))
type Group is Type:
  Original{columns:L.columns(~S.SchemaA,S.layout_a()),left:Local,right:Local}
  Unseparated{inventory:Schema.families(~S.SchemaA,S.layout_a()),left:Local,right:Local}
  Returned{assembly:Schema.Assembly<S.SchemaA,S.layout_a()>,left:Local,right:Local,leftFailed:Bool,rightFailed:Bool,leftUnused:List<&1,S.Position -> S.Position & Unit>,rightUnused:List<&1,S.Position -> S.Position & Unit>,tick:Tick.Tick,prior:Tick.Tick}
def returned(left:Body,right:Body,rest:Store.retained(~S.SchemaA,S.layout_a()),repack:Store.stores(~S.SchemaA,S.layout_a()) -> Store.stores(~S.SchemaA,S.layout_a()) -> Store.retained(~S.SchemaA,S.layout_a()) -> Schema.families(~S.SchemaA,S.layout_a()),tick:Tick.Tick,prior:Tick.Tick) -> Group:
  match left right:
    case Body{l,ll,lf,lu} Body{r,rl,rf,ru}:Returned{Store.reunite(~S.SchemaA,~S.layout_a(),l,r,rest,repack),ll,rl,lf,rf,lu,ru,tick,prior}
def separated(left:Local,right:Local,+tick:Tick.Tick,prior:Tick.Tick,result:Store.Separation<S.SchemaA,S.layout_a()>) -> Group:
  match result:
    case Store.SeparationRefused{tree}:Unseparated{tree,left,right}
    case Store.Separated{l,r,rest,repack}:
      lb rb = body(l,left,True{},0,tick) body(r,right,False{},1,tick)
      returned(lb,rb,rest,repack,tick,prior)
def partitioned(left:Local,right:Local,tick:Tick.Tick,prior:Tick.Tick,result:Schema.Partition<S.SchemaA,S.layout_a()>) -> Group:
  match result:
    case Schema.Refused{columns}:Original{columns,left,right}
    case Schema.PartitionedInventory{tree}:separated(left,right,tick,prior,Store.separate(~S.SchemaA,S.layout_a(),tree))
def concrete(left:Local,right:Local,tick:Tick.Tick,prior:Tick.Tick) -> Group:
  partitioned(left,right,tick,prior,Walk.generic_a())

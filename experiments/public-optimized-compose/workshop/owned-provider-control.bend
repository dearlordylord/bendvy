import Base
import schema.bend as S
import owned-rows.bend as R
import declarations.bend as D
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/component.bend as C
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/lifecycle.bend as L
import ../../../src/ecs/commands.bend as Cmd
import ../../../src/ecs/owned-family.bend as F

def error(value:Maybe<&2,W.WorldError>) -> U32:
  match value:
    case None{}: 0
    case Some{W.MissingEntity{}}: 1
    case Some{_}: 2
def values(value:Maybe<&2,S.StockView>) -> List<&2,U32>:
  match value:
    case None{}: [999]
    case Some{S.StockView{v,xs}}: v <> xs
def observed_last(points:List<&2,U32>,result:Col.Column<S.Schema,S.Stock> & Maybe<&2,S.StockView>) -> List<&2,U32>:
  match result:
    case (_,view): List.append(&2,U32,points,values(view))
def observed_first(points:List<&2,U32>,result:Col.Column<S.Schema,S.Stock> & Maybe<&2,S.StockView>) -> List<&2,U32>:
  match result:
    case (column,view): observed_last(List.append(&2,U32,points,values(view)),Col.view(~S.Schema,~S.Stock,~S.StockView,~S.project_stock,column,2))
def observed_stamp(points:List<&2,U32>,result:Col.Column<S.Schema,S.Stock> & L.Stamp) -> List<&2,U32>:
  match result:
    case (column,L.Stamp{a,b}): observed_first(List.append(&2,U32,points,[a,b]),Col.view(~S.Schema,~S.Stock,~S.StockView,~S.project_stock,Col.recover(~S.Schema,~S.Stock,column),1))
def observe(frame:R.Frame()) -> List<&2,U32>:
  match frame:
    case Q.Frame{T.Tx{W.World{namespace,nextId,high,_,capacity,depth,S.Store{stock,_,_,_,_},_,events,pending,_,system,clock},undo,commands,txEvents},W.Handle{ns,id},err,cursor}: observed_stamp([namespace,nextId,high,capacity,U32.from_nat(depth),system,clock,ns,id,error(err),cursor,U32.from_nat(List.length(&1,(S.World() -> S.World()),undo)),U32.from_nat(List.length(&1,(S.World() -> S.World()),commands)),U32.from_nat(List.length(&2,Unit,txEvents)),U32.from_nat(List.length(&2,Unit,events)),U32.from_nat(List.length(&1,(S.World() -> S.World()),pending))],Col.lifecycle(~S.Schema,~S.Stock,stock,1))
def stock() -> S.Stock:
  S.Stock{41,ANode{ALeaf{43},ALeaf{47}},2n}
def oldset(frame:R.Frame()) -> R.Frame():
  Q.set(~S.Schema,~S.Store,~Unit,~Unit,~S.StockRest,~S.Stock,~S.StockView,~S.StockToken,~S.take_stock,~S.put_stock,~S.project_stock,~S.stock(),frame,stock())
def execute(isnew:Bool,frame:R.Frame()) -> List<&2,U32>:
  match isnew:
    case False{}: observe(oldset(oldset(frame)))
    case True{}: observe(R.leave_work(R.set_work_stock(R.set_work_stock(R.enter_work(frame),stock()),stock())))
def prepare(prepared:Bool,column:Col.Column<S.Schema,S.Stock>) -> Col.Column<S.Schema,S.Stock>:
  match prepared:
    case False{}: column
    case True{}: Col.prepare(~S.Schema,~S.Stock,column)
def frame(prepared:Bool,+ns:U32,+id:U32,alive:Bool,+clock:U32) -> R.Frame():
  Q.Frame{T.Tx{W.World{1,4,3,Array.set(Bool,Array.new(Bool,2n,False{}),id,alive),4,2n,S.Store{prepare(prepared,Col.Column{ALeaf{Some{S.Stock{3,ANode{ALeaf{7},ALeaf{11}},2n}}},[L.Entry{1,L.Stamp{5,9}}]}),Col.empty(~S.Schema,~S.Recipe),Col.empty(~S.Schema,~S.Queue),Col.empty(~S.Schema,~S.Enabled),Col.empty(~S.Schema,~S.Locked)},Unit{},[Unit{},Unit{}],[world => world],[],7,clock},[],[world => world],[Unit{}]},W.Handle{ns,id},None{},13}
def pair(+prepared:Bool,+ns:U32,+id:U32,+alive:Bool,+clock:U32) -> List<&2,List<&2,U32>>:
  [execute(False{},frame(prepared,ns,id,alive,clock)),execute(True{},frame(prepared,ns,id,alive,clock))]
def mutate(owner:S.Stock) -> S.Stock & S.StockView:
  match owner:
    case S.Stock{value,owned,length}: S.project_stock(S.Stock{U32.add(value,1),Array.set(U32,owned,0,111),length})
def old_get(frame:R.Frame()) -> R.Frame() & C.Access<S.StockView>:
  Q.get(~S.Schema,~S.Store,~Unit,~Unit,~S.StockRest,~S.Stock,~S.StockView,~S.StockToken,~S.take_stock,~S.put_stock,~mutate,~C.Family{"stock"},frame)
def bridge_get_result(result:R.Frame() & C.Access<S.StockView>) -> R.WorkRow & C.Access<S.StockView>:
  match result:
    case (frame,value): (R.enter_work(frame),value)
def bridge_get(row:R.WorkRow) -> R.WorkRow & C.Access<S.StockView>:
  bridge_get_result(old_get(R.leave_work(row)))
def get_new(row:R.WorkRow) -> R.WorkRow & C.Access<S.StockView>:
  F.get(~S.Schema,~R.WorkRow,~R.WorkStockRest,~R.WorkStockMetaRest,~S.Stock,~S.StockView,~R.take_work_stock,~R.put_work_stock,~R.header_work_stock,~R.put_header_work_stock,~mutate,~bridge_get,row)
def access(value:C.Access<S.StockView>) -> List<&2,U32>:
  match value:
    case C.Found{S.StockView{v,xs}}: 0 <> v <> xs
    case C.ComponentAbsent{}: [1]
    case C.MissingEntity{}: [2]
def get_old_observed(result:R.Frame() & C.Access<S.StockView>) -> List<&2,U32>:
  match result:
    case (frame,value): List.append(&2,U32,access(value),observe(frame))
def get_new_observed(result:R.WorkRow & C.Access<S.StockView>) -> List<&2,U32>:
  match result:
    case (row,value): get_old_observed((R.leave_work(row),value))
def get_pair(+prepared:Bool,+ns:U32,+id:U32) -> List<&2,List<&2,U32>>:
  [get_old_observed(old_get(frame(prepared,ns,id,True{},13))),get_new_observed(get_new(R.enter_work(frame(prepared,ns,id,True{},13))))]
def restored_finish(handle:W.Handle<S.Schema>,err:Maybe<&2,W.WorldError>,cursor:U32,result:T.Returned<S.World(),Unit>) -> List<&2,U32>:
  match result:
    case T.Returned{world,_}: observe(Q.Frame{T.Tx{world,[],[],[]},handle,err,cursor})
def failed(frame:R.Frame()) -> List<&2,U32>:
  match frame:
    case Q.Frame{tx,handle,err,cursor}: restored_finish(handle,err,cursor,Cmd.tx_finish(~S.Schema,~S.Store,~Unit,~Unit,~Unit,tx,T.Failure{Unit{}}))
def stock_second() -> S.Stock:
  S.Stock{51,ANode{ALeaf{53},ALeaf{59}},2n}
def oldset_second(frame:R.Frame()) -> R.Frame():
  Q.set(~S.Schema,~S.Store,~Unit,~Unit,~S.StockRest,~S.Stock,~S.StockView,~S.StockToken,~S.take_stock,~S.put_stock,~S.project_stock,~S.stock(),frame,stock_second())
def rollback_pair(+prepared:Bool) -> List<&2,List<&2,U32>>:
  [failed(oldset_second(oldset(frame(prepared,1,1,True{},13)))),failed(R.leave_work(R.set_work_stock(R.set_work_stock(R.enter_work(frame(prepared,1,1,True{},13)),stock()),stock_second())))]
def main() -> IO(Unit):
  IO.print(List.show(&2,List<&2,U32>,(xs => List.show(&2,U32,U32.show,xs)),List.append(&2,List<&2,U32>,List.append(&2,List<&2,U32>,rollback_pair(False{}),rollback_pair(True{})),List.append(&2,List<&2,U32>,List.append(&2,List<&2,U32>,get_pair(False{},1,1),List.append(&2,List<&2,U32>,get_pair(True{},1,1),List.append(&2,List<&2,U32>,get_pair(True{},2,1),get_pair(True{},1,2)))),List.append(&2,List<&2,U32>,pair(False{},1,1,True{},13),List.append(&2,List<&2,U32>,pair(True{},1,1,True{},13),List.append(&2,List<&2,U32>,pair(True{},2,1,True{},13),List.append(&2,List<&2,U32>,pair(False{},1,0,True{},13),List.append(&2,List<&2,U32>,pair(True{},1,1,False{},13),List.append(&2,List<&2,U32>,pair(True{},1,2,True{},13),List.append(&2,List<&2,U32>,pair(False{},1,1,True{},4294967295),pair(True{},1,1,True{},4294967294))))))))))))

import Base
import ../../src/ecs/inspector.bend as I
import ../../src/ecs/inspector-query.bend as Query
import ../../src/ecs/inspector-query-projection.bend as Rows
import ../../src/ecs/execution-inspector-component.bend as Modern
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-resource-policy.bend as Policy
import ../../src/ecs/chunk-column.bend as Column
import ../../src/ecs/component.bend as Component
import ../../src/ecs/world.bend as W
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/clock-state.bend as Clock
import ../../src/ecs/execution-query-identity.bend as Identity
import ../../src/ecs/check.bend as Check
import ../../src/ecs/capabilities.bend as Cap

type Schema is Data:Schema{}
def refresh(value:Array<U32>) -> Array<U32> & U32:
  match value:
    case ALeaf{+value}:(ALeaf{value},value)
    case ANode{left,right}:(ANode{left,right},0)
def layout() -> L.Layout:L.LayoutLeaf{Array<U32>,U32,refresh,"component",Policy.Ordinary{}}
def C() -> Type:L.columns(~Schema,layout())
def World() -> Type:W.World<Schema,C(),Unit,Unit>
def Ops(H:Type) -> Type:Query.ReadQuery<H,Schema,U32>
def plan() -> I.Plan<Schema,C(),Unit,Unit,Ops>:
  I.Plan{Modern.query(~Schema,~C(),~Unit,~Unit,~layout(),~L.AtLeaf{},~{==},~{==},~Rows.Required{})}
def rows_text(values:List<&2,Rows.Row<Schema,U32>>) -> String:
  match values:
    case []:""
    case Rows.Row{_,I.Value{Component.Found{value},added,changed}} <> rest:U32.show(value) ++ "/" ++ Bool.show(added) ++ "/" ++ Bool.show(changed) ++ ";" ++ rows_text(rest)
    case _ <> rest:"absent;" ++ rows_text(rest)
def read(~H:Type,result:H & List<&2,Rows.Row<Schema,U32>>) -> H & Result<&2,&2,String,String>:
  match result:
    case (owner,rows):(owner,Done{rows_text(rows)})
def body(~H:Type,~query:Ops(H),_:Unit,owner:H) -> H & Result<&2,&2,String,String>:
  read(~H,Query.each(~H,~Schema,~U32,~query,owner))
def result_text(value:Result<&2,&2,String,String>) -> String:
  match value:
    case Done{value}:value
    case Fail{error}:error
def CheckOps(H:Type) -> Type:Cap.ValueRead<H,List<&2,Check.Row<Schema,U32>>>
def required(world:World()) -> World() & List<&2,String>:(world,[])
def check_plan() -> Check.Plan<Schema,C(),Unit,Unit,CheckOps>:
  Check.Plan{required,Modern.check_query(~Schema,~C(),~Unit,~Unit,~layout(),~L.AtLeaf{},~{==},~{==},~Check.Required{})}
def check_rows(~H:Type,result:H & List<&2,Check.Row<Schema,U32>>) -> H & Bool:
  match result:
    case (owner,[]):(owner,False{})
    case (owner,_ <> _):(owner,True{})
def check_body(~H:Type,~read:CheckOps(H),_:Unit,owner:H) -> H & Bool:
  check_rows(~H,Cap.value_read(~H,~List<&2,Check.Row<Schema,U32>>,~read,owner))
def payload_text(value:Maybe<&1,L.Viewed<Array<U32>,U32>>) -> String:
  match value:
    case Some{L.Viewed{ALeaf{value},_}}:U32.show(value)
    case _:"unexpected-owner"
def taken(first:String,second:String,tick:Tick.Tick,result:Result<&2,&2,Check.Error,Bool>,owner:Column.Column<Schema,L.Viewed<Array<U32>,U32>> & Maybe<&1,L.Viewed<Array<U32>,U32>>) -> IO(Unit):
  match result owner:
    case Done{checked}, (_,owner):IO.print("first=" ++ first ++ ";second=" ++ second ++ ";check=" ++ Bool.show(checked) ++ ";clock=" ++ Tick.show(tick) ++ ";owner=" ++ payload_text(owner))
    case _ _:IO.print("check-refused")
def checked(first:String,second:String,result:Check.Checked<Schema,C(),Unit,Unit>) -> IO(Unit):
  match result:
    case Check.Checked{W.World{_,_,L.ColumnSlot{column},_,_,_,_,_,clock,_},result}:taken(first,second,Clock.current(clock),result,Column.take(Schema,L.Viewed<Array<U32>,U32>,column,0))
def finished(first:String,result:I.Observed<Schema,C(),Unit,Unit,String,String>) -> IO(Unit):
  match result:
    case I.Observed{world,_,value}:checked(first,result_text(value),Check.run(~Schema,~C(),~Unit,~Unit,~CheckOps,~Unit,~check_body,~check_plan(),Unit{},world))
def observed(result:I.Observed<Schema,C(),Unit,Unit,String,String>) -> IO(Unit):
  match result:
    case I.Observed{world,instance,value}:finished(result_text(value),I.passive(~Schema,~C(),~Unit,~Unit,~Ops,~Unit,~String,~String,~plan(),~body,instance,Unit{},world))
def swapped(result:Column.SwapOutcome<Schema,L.Viewed<Array<U32>,U32>>) -> C() & Unit:
  match result:
    case Column.Accepted{column,_}:(L.ColumnSlot{column},Unit{})
    case Column.Rejected{column,_}:(L.ColumnSlot{column},Unit{})
def insert(index:U32,tick:Tick.Tick,column:C()) -> C() & Unit:
  match column:
    case L.ColumnSlot{column}:swapped(Column.swap_at(~Schema,~L.Viewed<Array<U32>,U32>,column,index,Some{L.initialize(layout(),L.AtLeaf{},ALeaf{7})},tick))
def seeded(result:World() & Unit) -> IO(Unit):
  match result:
    case (world,_):observed(I.passive(~Schema,~C(),~Unit,~Unit,~Ops,~Unit,~String,~String,~plan(),~body,I.Fresh{},Unit{},world))
def indexed(target:W.Handle<Schema>,result:World() & Tick.Tick) -> IO(Unit):
  match result:
    case (world,tick):seeded(W.with_store(~Schema,~C(),~Unit,~Unit,~Unit,insert(U32.sub(W.handle_index(~Schema,target),1),tick),world))
def reserved(result:World() & W.Reservation<Schema>) -> IO(Unit):
  match result:
    case (world,W.Reserved{+handle}):indexed(handle,W.execution_clock(~Schema,~C(),~Unit,~Unit,W.discard_status(~Schema,~C(),~Unit,~Unit,W.activate(~Schema,~C(),~Unit,~Unit,world,handle))))
    case (world,_):IO.print("reserve-refused")
def columns(_:Unit) -> C():L.empty_columns(~Schema,layout())
def created(result:W.Creation<Schema,C(),Unit,Unit>) -> IO(Unit):
  match result:
    case W.Created{_,world}:reserved(W.reserve_id(~Schema,~C(),~Unit,~Unit,world))
    case W.CreateRejected{_,_}:IO.print("create-refused")
def main() -> IO(Unit):created(W.create(~Schema,~C(),~Unit,~Unit,~columns,W.factory(),Unit{}))

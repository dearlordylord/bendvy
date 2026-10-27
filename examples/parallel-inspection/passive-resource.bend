import Base
import ../../src/ecs/world.bend as W
import ../../src/ecs/inspector.bend as I
import ../../src/ecs/execution-inspector.bend as Modern
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-resource-policy.bend as Policy
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/clock-state.bend as Clock

type Schema is Data:Schema{}
def refresh(value:Array<U32>) -> Array<U32> & U32:
  match value:
    case ALeaf{+value}:(ALeaf{value},value)
    case ANode{left,right}:(ANode{left,right},0)
def layout() -> L.Layout:L.LayoutLeaf{Array<U32>,U32,refresh,"counter",Policy.Ordinary{}}
def Resources() -> Type:L.resources(~Schema,layout())
def Reads(H:Type) -> Type:Cap.ValueRead<H,U32>
def plan() -> I.Plan<Schema,Unit,Resources(),Unit,Reads>:
  I.Plan{Modern.resource_grant(~I.Frame<Schema,Unit,Resources(),Unit>,~U32,Modern.resource(~Schema,~Unit,~Resources(),~Unit,~layout(),~L.AtLeaf{},~{==},~{==}))}
def body_read(-H:Type,fail:Bool,observed:H & U32) -> H & Result<&2,&2,String,U32>:
  match fail observed:
    case False{}, (owner,value):(owner,Done{value})
    case True{}, (owner,value):(owner,Fail{"read:" ++ U32.show(value)})
def body(~H:Type,~read:Cap.ValueRead<H,U32>,fail:Bool,owner:H) -> H & Result<&2,&2,String,U32>:
  body_read(H,fail,Cap.value_read(~H,~U32,~read,owner))
def result_text(result:Result<&2,&2,String,U32>) -> String:
  match result:
    case Done{value}:"ok:" ++ U32.show(value)
    case Fail{error}:error
def instance_text(instance:I.Instance<Schema>) -> String:
  match instance:
    case I.Fresh{}:"fresh"
    case I.Active{cursor,registered}:Tick.cursor_show(cursor) ++ "/" ++ Tick.show(registered)
def owner_text(value:Array<U32>) -> String:
  match value:
    case ALeaf{value}:U32.show(value)
    case ANode{left,right}:owner_text(left) ++ "," ++ owner_text(right)
def finished(first:String,result:I.Observed<Schema,Unit,Resources(),Unit,String,U32>) -> IO(Unit):
  match result:
    case I.Observed{W.World{_,_,_,L.ResourceSlot{L.Viewed{array,cache},_},_,_,_,_,clock,_},instance,result}:IO.print(first ++ ";error=" ++ result_text(result) ++ ";cursor=" ++ instance_text(instance) ++ ";clock=" ++ Tick.show(Clock.current(clock)) ++ ";cache=" ++ U32.show(cache) ++ ";owner=" ++ owner_text(array))
def observed(result:I.Observed<Schema,Unit,Resources(),Unit,String,U32>) -> IO(Unit):
  match result:
    case I.Observed{world,instance,result}:finished("success=" ++ result_text(result),I.passive(~Schema,~Unit,~Resources(),~Unit,~Reads,~Bool,~String,~U32,~plan(),~body,instance,True{},world))
def columns(_:Unit) -> Unit:Unit{}
def created(result:W.Creation<Schema,Unit,Resources(),Unit>) -> IO(Unit):
  match result:
    case W.Created{_,world}:observed(I.passive(~Schema,~Unit,~Resources(),~Unit,~Reads,~Bool,~String,~U32,~plan(),~body,I.Active{Some{Tick.zero()},Tick.zero()},False{},world))
    case W.CreateRejected{_,_}:IO.print("create-refused")
def main() -> IO(Unit):created(W.create(~Schema,~Unit,~Resources(),~Unit,~columns,W.factory(),L.ResourceSlot{L.initialize(layout(),L.AtLeaf{},ALeaf{71}),L.unknown_stamp()}))

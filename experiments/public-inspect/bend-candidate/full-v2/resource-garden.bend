import Base
import ../query-consumer.bend as A
import ../inspect.bend as I
import optional-resource.bend as Slot
import optional-resource-grant.bend as Grant
import check.bend as Check
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/capabilities.bend as Cap

type Resources is Type:
  Resources{score:Slot.Slot<A.Resource>,neighbor:Array<U32>}
type Reads<H:Type> is Type:
  Reads{score:Cap.ValueRead<H,Maybe<&2,List<&2,U32>>>}
def take(resources:Resources) -> Array<U32> & Slot.Slot<A.Resource>:
  match resources:
    case Resources{score,neighbor}:(neighbor,score)
def put(neighbor:Array<U32>,score:Slot.Slot<A.Resource>) -> Resources:
  Resources{score,neighbor}
def Ops(H:Type) -> Type:
  Reads<H>
def grant() -> Reads<I.Frame<A.Schema,A.Store,Resources,U32>>:
  Reads{Grant.inspect(~A.Schema,~A.Store,~Resources,~U32,~Array<U32>,~A.Resource,~List<&2,U32>,~take,~put,~A.project_resource)}
def plan() -> I.Plan<A.Schema,A.Store,Resources,U32,Ops>:
  I.Plan{grant()}
def score(~H:Type,caps:Reads<H>) -> Cap.ValueRead<H,Maybe<&2,List<&2,U32>>>:
  match caps:
    case Reads{score}:score
def inspected(~H:Type,fail:Bool,result:H & Maybe<&2,List<&2,U32>>) -> H & Result<&2,&2,Maybe<&2,List<&2,U32>>,Maybe<&2,List<&2,U32>>>:
  match fail result:
    case True{},(ctx,value):(ctx,Fail{value})
    case False{},(ctx,value):(ctx,Done{value})
def inspect_body(~H:Type,~caps:Reads<H>,fail:Bool,ctx:H) -> H & Result<&2,&2,Maybe<&2,List<&2,U32>>,Maybe<&2,List<&2,U32>>>:
  inspected(~H,fail,Cap.value_read(~H,~Maybe<&2,List<&2,U32>>,~score(~H,caps),ctx))
def required_value(world:W.World<A.Schema,A.Store,Resources,U32>,present:Bool) -> W.World<A.Schema,A.Store,Resources,U32> & List<&2,String>:
  match present:
    case False{}:(world,["Garden/OptionalScore"])
    case True{}:(world,[])
def requirements(result:W.World<A.Schema,A.Store,Resources,U32> & Bool) -> W.World<A.Schema,A.Store,Resources,U32> & List<&2,String>:
  (world,present)=result
  required_value(world,present)
def required(world:W.World<A.Schema,A.Store,Resources,U32>) -> W.World<A.Schema,A.Store,Resources,U32> & List<&2,String>:
  requirements(W.observe_resource(~A.Schema,~A.Store,~Resources,~U32,~Bool,~(r => Slot.available(~Resources,~Array<U32>,~A.Resource,~take,~put,r)),world))
def check_plan() -> Check.Plan<A.Schema,A.Store,Resources,U32,Ops>:
  Check.Plan{world => required(world),grant()}
def present(value:Maybe<&2,List<&2,U32>>) -> Bool:
  match value:
    case None{}:False{}
    case Some{_}:True{}
def checked_body(~H:Type,result:H & Maybe<&2,List<&2,U32>>) -> H & Bool:
  (ctx,value)=result
  (ctx,present(value))
def check_body(~H:Type,~caps:Reads<H>,args:Unit,ctx:H) -> H & Bool:
  checked_body(~H,Cap.value_read(~H,~Maybe<&2,List<&2,U32>>,~score(~H,caps),ctx))
def show_value(value:Maybe<&2,List<&2,U32>>) -> String:
  match value:
    case None{}:"undefined"
    case Some{values}:List.show(&2,U32,U32.show,values)
def show_result(value:Result<&2,&2,Maybe<&2,List<&2,U32>>,Maybe<&2,List<&2,U32>>>) -> String:
  match value:
    case Fail{value}:"fail:" ++ show_value(value)
    case Done{value}:"success:" ++ show_value(value)
def show_check(value:Result<&2,&2,Check.Error,Bool>) -> String:
  match value:
    case Fail{Check.MissingRuntimeRequirements{names}}:"MissingRuntimeRequirements:" ++ List.show(&2,String,x => x,names)
    case Done{value}:"success:" ++ Bool.show(value)
def neighbor_join(score:Slot.Slot<A.Resource>,result:Array<U32> & List<&2,U32>) -> Resources & List<&2,U32>:
  (neighbor,values)=result
  (Resources{score,neighbor},values)
def neighbor(resources:Resources) -> Resources & List<&2,U32>:
  match resources:
    case Resources{score,neighbor}:neighbor_join(score,A.array_project(neighbor))
def diagnostic_values(label:String,text:String,cursor:U32,clock:U32,result:W.World<A.Schema,A.Store,Resources,U32> & List<&2,U32>) -> W.World<A.Schema,A.Store,Resources,U32> & String:
  (world,values)=result
  (world,label ++ "=" ++ text ++ "|cursor=" ++ U32.show(cursor) ++ "|clock=" ++ U32.show(clock) ++ "|neighbor=" ++ List.show(&2,U32,U32.show,values) ++ "\n")
def diagnostic_clock(label:String,text:String,cursor:U32,result:W.World<A.Schema,A.Store,Resources,U32> & U32) -> W.World<A.Schema,A.Store,Resources,U32> & String:
  (world,clock)=result
  diagnostic_values(label,text,cursor,clock,W.observe_resource(~A.Schema,~A.Store,~Resources,~U32,~List<&2,U32>,~neighbor,world))
def instance_join(instance:I.Instance<A.Schema>,result:W.World<A.Schema,A.Store,Resources,U32> & String) -> W.World<A.Schema,A.Store,Resources,U32> & I.Instance<A.Schema> & String:
  (world,text)=result
  (world,instance,text)
def observed_instance(label:String,world:W.World<A.Schema,A.Store,Resources,U32>,text:String,instance:I.Instance<A.Schema>) -> W.World<A.Schema,A.Store,Resources,U32> & I.Instance<A.Schema> & String:
  match instance:
    case I.Fresh{}:instance_join(I.Fresh{},diagnostic_clock(label,text,0,W.clock(~A.Schema,~A.Store,~Resources,~U32,world)))
    case I.Active{+cursor,+registered}:instance_join(I.Active{cursor,registered},diagnostic_clock(label,text,cursor,W.clock(~A.Schema,~A.Store,~Resources,~U32,world)))
def observed(label:String,result:I.Observed<A.Schema,A.Store,Resources,U32,Maybe<&2,List<&2,U32>>,Maybe<&2,List<&2,U32>>>) -> W.World<A.Schema,A.Store,Resources,U32> & I.Instance<A.Schema> & String:
  match result:
    case I.Observed{world,instance,value}:observed_instance(label,world,show_result(value),instance)
def inspect(instance:I.Instance<A.Schema>,fail:Bool,world:W.World<A.Schema,A.Store,Resources,U32>) -> I.Observed<A.Schema,A.Store,Resources,U32,Maybe<&2,List<&2,U32>>,Maybe<&2,List<&2,U32>>>:
  I.run(~A.Schema,~A.Store,~Resources,~U32,~Ops,~Bool,~Maybe<&2,List<&2,U32>>,~Maybe<&2,List<&2,U32>>,~plan(),~inspect_body,instance,fail,world)
def final(lines:String,result:W.World<A.Schema,A.Store,Resources,U32> & I.Instance<A.Schema> & String) -> String:
  (_,_,text)=result
  lines ++ text
def retry(instance:I.Instance<A.Schema>,lines:String,result:W.World<A.Schema,A.Store,Resources,U32> & String) -> String:
  (world,text)=result
  final(lines ++ text,observed("retry",inspect(instance,False{},world)))
def check_after(instance:I.Instance<A.Schema>,lines:String,result:Check.Checked<A.Schema,A.Store,Resources,U32>) -> String:
  match result:
    case Check.Checked{world,value}:retry(instance,lines,diagnostic_clock("check-after",show_check(value),2,W.clock(~A.Schema,~A.Store,~Resources,~U32,world)))
def failure(lines:String,result:W.World<A.Schema,A.Store,Resources,U32> & I.Instance<A.Schema> & String) -> String:
  (world,instance,text)=result
  check_after(instance,lines ++ text,Check.run(~A.Schema,~A.Store,~Resources,~U32,~Ops,~Unit,~check_body,~check_plan(),Unit{},world))
def check_first_done(instance:I.Instance<A.Schema>,lines:String,result:W.World<A.Schema,A.Store,Resources,U32> & String) -> String:
  (world,text)=result
  failure(lines ++ text,observed("failed",inspect(instance,True{},world)))
def check_first(instance:I.Instance<A.Schema>,lines:String,result:Check.Checked<A.Schema,A.Store,Resources,U32>) -> String:
  match result:
    case Check.Checked{world,value}:check_first_done(instance,lines,diagnostic_clock("check",show_check(value),2,W.clock(~A.Schema,~A.Store,~Resources,~U32,world)))
def repeated(lines:String,result:W.World<A.Schema,A.Store,Resources,U32> & I.Instance<A.Schema> & String) -> String:
  (world,instance,text)=result
  check_first(instance,lines ++ text,Check.run(~A.Schema,~A.Store,~Resources,~U32,~Ops,~Unit,~check_body,~check_plan(),Unit{},world))
def first(result:W.World<A.Schema,A.Store,Resources,U32> & I.Instance<A.Schema> & String) -> String:
  (world,instance,text)=result
  repeated(text,observed("repeat",inspect(instance,False{},world)))
def created(result:W.Creation<A.Schema,A.Store,Resources,U32>) -> String:
  match result:
    case W.Created{_,world}:first(observed("first",inspect(I.Fresh{},False{},world)))
    case W.CreateRejected{_,_}:"creation rejected"
def run(slot:Slot.Slot<A.Resource>) -> String:
  created(W.create(~A.Schema,~A.Store,~Resources,~U32,~A.empty,W.factory(),Resources{slot,Array.set(U32,Array.new(U32,2n,91),3,94)}))
def main() -> String:
  "Absent\n" ++ run(Slot.Absent{}) ++ "Present\n" ++ run(Slot.Present{A.Resource{Array.set(U32,Array.new(U32,2n,21),3,24)}})

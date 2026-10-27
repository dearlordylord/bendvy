import Base
import ../parallel-captures/scheduled.bend as Existing
import ../parallel-captures/declarations.bend as D
import ../parallel-captures/bodies.bend as Body
import ../parallel-captures/reports.bend as Common
import ../../src/ecs/inspector.bend as I
import ../../src/ecs/execution-inspector.bend as Modern
import ../../src/ecs/execution-inspector-application.bend as Inspect
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-parallel-system.bend as Task
import ../../src/ecs/execution-parallel-app.bend as Pair
import ../../src/ecs/execution-parallel-root-application.bend as App
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/dependency-application.bend as State
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/execution-trace.bend as Trace
import ../../src/ecs/execution-trace-report.bend as TraceReport

def Ops(H:Type) -> Type:Cap.Bundle<Cap.ValueRead<H,String>,Cap.ValueRead<H,String>>
def plan(~S:Data) -> I.Plan<S,D.Store(~S),D.Resources(~S),Unit,Ops>:
  I.Plan{Cap.Bundle{Modern.resource_grant(~I.Frame<S,D.Store(~S),D.Resources(~S),Unit>,~String,Modern.resource(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.resources_layout(),~Layout.InLeft{Layout.AtLeaf{}},~{==},~{==})),Modern.resource_grant(~I.Frame<S,D.Store(~S),D.Resources(~S),Unit>,~String,Modern.resource(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.resources_layout(),~Layout.InRight{Layout.AtLeaf{}},~{==},~{==}))}}
def right_read(~H:Type,left:String,result:H & String) -> H & Result<&2,&2,String,String>:
  match result:
    case (owner,right):(owner,Done{left ++ "," ++ right})
def left_read(~H:Type,~right:Cap.ValueRead<H,String>,result:H & String) -> H & Result<&2,&2,String,String>:
  match result:
    case (owner,left):right_read(~H,left,Cap.value_read(~H,~String,~right,owner))
def left_cap(~H:Type,caps:Ops(H)) -> Cap.ValueRead<H,String>:
  match caps:
    case Cap.Bundle{left,_}:left
def right_cap(~H:Type,caps:Ops(H)) -> Cap.ValueRead<H,String>:
  match caps:
    case Cap.Bundle{_,right}:right
def body(~H:Type,~caps:Ops(H),_:Unit,owner:H) -> H & Result<&2,&2,String,String>:
  left_read(~H,~right_cap(~H,caps),Cap.value_read(~H,~String,~left_cap(~H,caps),owner))
def inspected(~S:Data,result:Existing.Application(~S) & (I.Instance<S> & Result<&2,&2,String,String>)) -> Existing.Application(~S):
  match result:
    case (app,(_,_)):app
def passive(~S:Data,app:Existing.Application(~S)) -> Existing.Application(~S):
  inspected(~S,Inspect.passive(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Product.Owner<Existing.LeftTree(~S),Existing.RightOwner(~S)>,~Unit,~Common.Handler,~Ops,~Unit,~String,~String,~plan(~S),~body,app,I.Fresh{},Unit{}))
def run_selected(~S:Data,native:Bool,enabled:Bool,app:Existing.Application(~S)) -> IO(Existing.Application(~S) & State.Report<String,String>):
  match enabled:
    case False{}:Existing.run_selected(~S,native,app)
    case True{}:Existing.run_selected(~S,native,passive(~S,app))
def trace_event(value:Trace.TraceEvent<String>) -> String:
  match value:
    case Trace.SystemOutcome{id,Trace.SystemOk{}}:U32.show(id) ++ "/ok"
    case Trace.SystemOutcome{id,Trace.SystemError{error}}:U32.show(id) ++ "/" ++ error
    case Trace.ScheduleEnded{_}:"end"
    case Trace.DependencyObserved{before,after}:U32.show(before) ++ "<" ++ U32.show(after)
    case _:"other"
def trace_events(values:List<&2,Trace.TraceEvent<String>>) -> String:
  match values:
    case []:""
    case value <> rest:trace_event(value) ++ ";" ++ trace_events(rest)
def trace_batch(value:Trace.Batch<String>) -> String:
  match value:
    case Trace.Disabled{}:"disabled"
    case Trace.BendvyReady{events}:trace_events(events)
def reported(~S:Data,trace:String,app:Existing.Application(~S),result:State.Report<String,String> & Trace.Batch<String>) -> String:
  match result:
    case (status,batch):Existing.observed(~S,trace ++ "|" ++ Common.report(status),app) ++ "|trace=" ++ trace_batch(batch)
def traced(~S:Data,on:Bool,trace:String,app:Existing.Application(~S),status:State.Report<String,String>) -> String:
  match app:
    case App.Scheduled{state,+plan,bindings,rules,deferred}:reported(~S,trace,App.Scheduled{state,plan,bindings,rules,deferred},TraceReport.read(~String,~String,on,plan,status))
def finished(~S:Data,on:Bool,trace:String,result:Existing.Application(~S) & State.Report<String,String>) -> String:
  match result:
    case (app,status):traced(~S,on,trace,app,status)
def second(~S:Data,native:Bool,+enabled:Bool,result:Existing.Application(~S) & State.Report<String,String>) -> IO(String):
  match result:
    case (app,status):IO.bind(Existing.Application(~S) & State.Report<String,String>,String,run_selected(~S,native,enabled,app),next => IO.pure(String,finished(~S,enabled,Common.report(status),next)))
def other_defined(~S:Data,+native:Bool,+enabled:Bool,left:Existing.LeftOwner(~S),right:Existing.RightOwner(~S),result:Sys.Defined<Existing.World(~S),Existing.LeftOwner(~S),Body.LeftLocal()>) -> IO(String):
  match result:
    case Sys.Defined{world,other}:IO.bind(Existing.Application(~S) & State.Report<String,String>,String,run_selected(~S,native,enabled,App.build(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.LeftResource(~S),~D.RightResource(~S),~Unit,~D.resources_layout(),~{==},~String,~String,~Existing.LeftTree(~S),~Existing.RightOwner(~S),~Existing.left_tree(~S),~Existing.right_tree(~S),~Unit,~Common.Handler,~Conditions.empty_dispatch(~Existing.World(~S),~String),~Conditions.empty(~Existing.World(~S),~String),~Common.handle,~Common.available,world,Product.Owner{Product.Owner{left,other},right},Unit{},Common.Handler{ALeaf{701},0},[],[])),next => second(~S,native,enabled,next))
    case Sys.DefinitionRefused{_,_}:IO.pure(String,"other-refused")
def registered(~S:Data,native:Bool,enabled:Bool,result:Pair.Definition<Existing.World(~S),Existing.LeftOwner(~S),Existing.RightOwner(~S),Body.LeftLocal(),Body.RightLocal()>) -> IO(String):
  match result:
    case Pair.Defined{Pair.ParallelApp{world,left,right}}:other_defined(~S,native,enabled,left,right,Task.define(~S,~D.Store(~S),~D.LeftStore(~S),~D.LeftResource(~S),~Unit,~D.LeftOps(~S),~Body.LeftLocal(),~String,~String,~D.left(~S),~Body.left(~S),~D.Resources(~S),world,"other",Body.left_local(801,203)))
    case Pair.LeftRefused{_,_,_}:IO.pure(String,"left-refused")
    case Pair.RightRefused{_,_,_}:IO.pure(String,"right-refused")
def created(~S:Data,native:Bool,enabled:Bool,result:W.Creation<S,D.Store(~S),D.Resources(~S),Unit>) -> IO(String):
  match result:
    case W.Created{_,world}:registered(~S,native,enabled,Pair.define(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.LeftResource(~S),~D.RightResource(~S),~Unit,~Body.LeftLocal(),~Body.RightLocal(),~String,~String,~String,~String,~D.LeftOps(~S),~D.RightOps(~S),~D.left(~S),~D.right(~S),~Body.left(~S),~Body.right(~S),world,"left","right",Body.left_local(501,201),Body.right_local()))
    case W.CreateRejected{_,_}:IO.pure(String,"create-refused")
def run(~S:Data,native:Bool,enabled:Bool) -> IO(String):created(~S,native,enabled,W.create(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.empty(~S),W.factory(),D.resources(~S)))
type SchemaA is Data:SchemaA{}
type SchemaB is Data:SchemaB{}
def main() -> IO(Unit):
  IO.bind(String,Unit,run(~SchemaA,False{},False{}),a => IO.bind(String,Unit,run(~SchemaA,False{},True{}),ai => IO.bind(String,Unit,run(~SchemaB,True{},False{}),b => IO.bind(String,Unit,run(~SchemaB,True{},True{}),bi => IO.print("A=" ++ a ++ "\nA-inspected=" ++ ai ++ "\nB=" ++ b ++ "\nB-inspected=" ++ bi)))))

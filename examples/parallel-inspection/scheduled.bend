import Base
import ../parallel-captures/scheduled.bend as Existing
import ../parallel-captures/declarations.bend as D
import ../parallel-captures/bodies.bend as Body
import ../parallel-captures/reports.bend as Common
import ./scheduled-observation.bend as Observe
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
def inspected_observed(~S:Data,before:String,outcome:Result<&2,&2,String,String>,instance:I.Instance<S> & String,observed:Existing.Application(~S) & String) -> Existing.Application(~S) & String:
  match instance observed:
    case (_,instanceText), (app,after):(app,before ++ "/instanceAfter=" ++ instanceText ++ "/result=" ++ Observe.result(outcome) ++ "/after={" ++ after ++ "}")
def inspected(~S:Data,before:String,result:Existing.Application(~S) & (I.Instance<S> & Result<&2,&2,String,String>)) -> Existing.Application(~S) & String:
  match result:
    case (app,(instance,outcome)):inspected_observed(~S,before,outcome,Observe.instance(~S,instance),Observe.application(~S,app))
def passive_instance(~S:Data,before:String,app:Existing.Application(~S),result:I.Instance<S> & String) -> Existing.Application(~S) & String:
  match result:
    case (instance,text):inspected(~S,"before={" ++ before ++ "}/instanceBefore=" ++ text,Inspect.passive(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Product.Owner<Existing.LeftTree(~S),Existing.RightOwner(~S)>,~Unit,~Common.Handler,~Ops,~Unit,~String,~String,~plan(~S),~body,app,instance,Unit{}))
def passive_before(~S:Data,result:Existing.Application(~S) & String) -> Existing.Application(~S) & String:
  match result:
    case (app,before):passive_instance(~S,before,app,Observe.instance(~S,I.Fresh{}))
def passive(~S:Data,app:Existing.Application(~S)) -> Existing.Application(~S) & String:
  passive_before(~S,Observe.application(~S,app))
def selected_returned(~S:Data,passive:String,result:Existing.Application(~S) & State.Report<String,String>) -> Existing.Application(~S) & (State.Report<String,String> & String):
  match result:
    case (app,status):(app,(status,passive))
def selected(~S:Data,native:Bool,result:Existing.Application(~S) & String) -> IO(Existing.Application(~S) & (State.Report<String,String> & String)):
  match result:
    case (app,passive):IO.bind(Existing.Application(~S) & State.Report<String,String>,Existing.Application(~S) & (State.Report<String,String> & String),Existing.run_selected(~S,native,app),next => IO.pure(Existing.Application(~S) & (State.Report<String,String> & String),selected_returned(~S,passive,next)))
def run_selected(~S:Data,native:Bool,enabled:Bool,app:Existing.Application(~S)) -> IO(Existing.Application(~S) & (State.Report<String,String> & String)):
  match enabled:
    case False{}:selected(~S,native,(app,"passive-disabled"))
    case True{}:selected(~S,native,passive(~S,app))
def reported(~S:Data,trace:String,passive:String,result:State.Report<String,String> & Trace.Batch<String>,observed:Existing.Application(~S) & String) -> String:
  match result observed:
    case (status,batch), (_,app):trace ++ "/passive2={" ++ passive ++ "}/report2=" ++ Observe.report(status) ++ "/after2={" ++ app ++ "}/trace=" ++ Observe.batch(batch)
def traced(~S:Data,on:Bool,trace:String,passive:String,app:Existing.Application(~S),status:State.Report<String,String>) -> String:
  match app:
    case App.Scheduled{state,+plan,bindings,rules,deferred}:reported(~S,trace,passive,TraceReport.read(~String,~String,on,plan,status),Observe.application(~S,App.Scheduled{state,plan,bindings,rules,deferred}))
def finished(~S:Data,on:Bool,trace:String,result:Existing.Application(~S) & (State.Report<String,String> & String)) -> String:
  match result:
    case (app,(status,passive)):traced(~S,on,trace,passive,app,status)
def second_observed(~S:Data,native:Bool,+enabled:Bool,trace:String,status:State.Report<String,String>,passive:String,result:Existing.Application(~S) & String) -> IO(String):
  match result:
    case (app,observed):IO.bind(Existing.Application(~S) & (State.Report<String,String> & String),String,run_selected(~S,native,enabled,app),next => IO.pure(String,finished(~S,enabled,trace ++ "/passive1={" ++ passive ++ "}/report1=" ++ Observe.report(status) ++ "/after1={" ++ observed ++ "}",next)))
def second(~S:Data,native:Bool,enabled:Bool,trace:String,result:Existing.Application(~S) & (State.Report<String,String> & String)) -> IO(String):
  match result:
    case (app,(status,passive)):second_observed(~S,native,enabled,trace,status,passive,Observe.application(~S,app))
def started(~S:Data,+native:Bool,+enabled:Bool,result:Existing.Application(~S) & String) -> IO(String):
  match result:
    case (app,initial):IO.bind(Existing.Application(~S) & (State.Report<String,String> & String),String,run_selected(~S,native,enabled,app),next => second(~S,native,enabled,"initial={" ++ initial ++ "}",next))
def other_defined(~S:Data,+native:Bool,+enabled:Bool,left:Existing.LeftOwner(~S),right:Existing.RightOwner(~S),result:Sys.Defined<Existing.World(~S),Existing.LeftOwner(~S),Body.LeftLocal()>) -> IO(String):
  match result:
    case Sys.Defined{world,other}:started(~S,native,enabled,Observe.application(~S,App.build(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.LeftResource(~S),~D.RightResource(~S),~Unit,~D.resources_layout(),~{==},~String,~String,~Existing.LeftTree(~S),~Existing.RightOwner(~S),~Existing.left_tree(~S),~Existing.right_tree(~S),~Unit,~Common.Handler,~Conditions.empty_dispatch(~Existing.World(~S),~String),~Conditions.empty(~Existing.World(~S),~String),~Common.handle,~Common.available,world,Product.Owner{Product.Owner{left,other},right},Unit{},Common.Handler{ALeaf{701},0},[],[])))
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

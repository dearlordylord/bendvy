import Base
import ../parallel-persistence/declarations.bend as O
import ../parallel-persistence/extended-declarations.bend as D
import ../parallel-persistence/extended-execution.bend as Execution
import ../parallel-persistence/extended-programs.bend as P
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/execution-stream-channel.bend as Channel
import ../../src/ecs/machine-stream-queue.bend as Queue
import ../../src/ecs/execution-relation-failure-message.bend as Message
import ../../src/ecs/world.bend as W
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/execution-parallel-registration.bend as Registration
import ../parallel-persistence/extended-resume.bend as Resume
import ../parallel-persistence/extended-target.bend as Target
import ../../src/ecs/inspector.bend as I
import ../../src/ecs/check.bend as Check
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/execution-inspector.bend as Modern
import ../../src/ecs/execution-inspector-application.bend as Passive
import ../../src/ecs/execution-relation-store.bend as Store
import ../../src/ecs/execution-relation-failure-channel.bend as Failure
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-parallel-root-application.bend as Root
import ../../src/ecs/dependency-application.bend as State
import ../../src/ecs/relation-types.bend as T

def Ops(~S:Data,H:Type) -> Type:Cap.ValueRead<H,Store.View<S,D.hierarchy(~S)>>
def plan(~S:Data) -> I.Plan<S,L.columns(~S,D.components(~S)),D.Resources(~S),Unit,Ops(~S)>:
  I.Plan{Modern.resource_grant(~I.Frame<S,L.columns(~S,D.components(~S)),D.Resources(~S),Unit>,~Store.View<S,D.hierarchy(~S)>,Modern.resource(~S,~L.columns(~S,D.components(~S)),~D.Resources(~S),~Unit,~D.resource_layout(~S),~L.InLeft{L.AtLeaf{}},~{==},~{==}))}
def graph(~S:Data,-H:Type,result:H & Store.View<S,D.hierarchy(~S)>) -> H & Result<&2,&2,String,String>:
  match result:
    case (owner,Store.View{namespace,T.Graph{edges,inverses}}):(owner,Done{U32.show(namespace) ++ "/edges=" ++ Nat.show(List.length(&2,T.Edge<S>,edges)) ++ "/inverse=" ++ Nat.show(List.length(&2,T.Inverse<S>,inverses))})
def body(~S:Data,~H:Type,~cap:Ops(~S,H),_:Unit,owner:H) -> H & Result<&2,&2,String,String>:
  graph(~S,H,Cap.value_read(~H,~Store.View<S,D.hierarchy(~S)>,~cap,owner))
def required(~S:Data,world:D.World(~S)) -> D.World(~S) & List<&2,String>:(world,[])
def check_plan(~S:Data) -> Check.Plan<S,L.columns(~S,D.components(~S)),D.Resources(~S),Unit,Ops(~S)>:
  Check.Plan{required(~S),Modern.resource_grant(~Check.Frame<S,L.columns(~S,D.components(~S)),D.Resources(~S),Unit>,~Store.View<S,D.hierarchy(~S)>,Modern.check_resource(~S,~L.columns(~S,D.components(~S)),~D.Resources(~S),~Unit,~D.resource_layout(~S),~L.InLeft{L.AtLeaf{}},~{==},~{==}))}
def checked_graph(~S:Data,-H:Type,result:H & Store.View<S,D.hierarchy(~S)>) -> H & Bool:
  match result:
    case (owner,Store.View{_,T.Graph{[],_}}):(owner,False{})
    case (owner,_):(owner,True{})
def check_body(~S:Data,~H:Type,~cap:Ops(~S,H),_:Unit,owner:H) -> H & Bool:
  checked_graph(~S,H,Cap.value_read(~H,~Store.View<S,D.hierarchy(~S)>,~cap,owner))
def reader(~S:Data,value:Maybe<&1,Target.Reader(~S)>) -> Maybe<&1,Target.Reader(~S)> & String:
  match value:
    case None{}:(None{},"none")
    case Some{Failure.Reader{+namespace,+id,+cursor}}:(Some{Failure.Reader{namespace,id,cursor}},U32.show(namespace) ++ "/" ++ U32.show(id) ++ "/" ++ Nat.show(cursor))
def handler_returned(~S:Data,capture:Array<U32>,handled:U32,result:Maybe<&1,Target.Reader(~S)> & String) -> Execution.Handler<S> & String:
  match result:
    case (reader,text):(Execution.Handler{capture,handled,reader},text)
def handler(~S:Data,value:Execution.Handler<S>) -> Execution.Handler<S> & String:
  match value:
    case Execution.Handler{capture,handled,retained}:handler_returned(~S,capture,handled,reader(~S,retained))
def channel(~S:Data,value:Channel.Store<Message.Message<S,D.hierarchy(~S)>>) -> String:
  match value:
    case Channel.Store{Queue.Queue{_,_,size,dropped,batches},older,_}:Nat.show(size) ++ ":" ++ Nat.show(dropped) ++ ":" ++ Nat.show(batches) ++ ":" ++ Nat.show(older)
def resources(~S:Data,value:D.Resources(~S)) -> D.Resources(~S) & String:
  match value:
    case Product.Owner{L.ResourceSlot{L.Viewed{Store.Store{+namespace,graph,+failures,+sequence,+nextReader},view},stamp},cell}:(Product.Owner{L.ResourceSlot{L.Viewed{Store.Store{namespace,graph,failures,sequence,nextReader},view},stamp},cell},"channel=" ++ channel(~S,failures) ++ "/sequence=" ++ Nat.show(sequence) ++ "/nextReader=" ++ U32.show(nextReader))
def world_returned(~S:Data,text:String,result:D.World(~S) & Tick.Tick) -> D.World(~S) & String:
  match result:
    case (world,tick):(world,text ++ "/clock=" ++ Tick.show(tick))
def world_resource(~S:Data,result:D.World(~S) & String) -> D.World(~S) & String:
  match result:
    case (world,text):world_returned(~S,text,W.clock(~S,~L.columns(~S,D.components(~S)),~D.Resources(~S),~Unit,world))
def world(~S:Data,value:D.World(~S)) -> D.World(~S) & String:
  world_resource(~S,W.observe_resource(~S,~L.columns(~S,D.components(~S)),~D.Resources(~S),~Unit,~String,~resources(~S),value))
def handler_app_world(~S:Data,owners:Product.Owner<P.Left(~S),P.Right(~S)>,guards:P.Guard(~S),stateBindings:List<&2,State.Binding>,plan:Plan.Build<String>,bindings:List<&2,State.Binding>,rules:Registration.Rules,deferred:Root.Deferred,result:Execution.Handler<S> & String,observed:D.World(~S) & String) -> Execution.Application(~S) & String:
  match result observed:
    case (handlerOwner,text), (world,worldText):(Root.Scheduled{State.State{world,owners,guards,handlerOwner,stateBindings},plan,bindings,rules,deferred},text ++ "/" ++ worldText)
def handler_app_returned(~S:Data,value:D.World(~S),owners:Product.Owner<P.Left(~S),P.Right(~S)>,guards:P.Guard(~S),stateBindings:List<&2,State.Binding>,plan:Plan.Build<String>,bindings:List<&2,State.Binding>,rules:Registration.Rules,deferred:Root.Deferred,result:Execution.Handler<S> & String) -> Execution.Application(~S) & String:
  handler_app_world(~S,owners,guards,stateBindings,plan,bindings,rules,deferred,result,world(~S,value))
def handler_app(~S:Data,app:Execution.Application(~S)) -> Execution.Application(~S) & String:
  match app:
    case Root.Scheduled{State.State{world,owners,guards,handlerOwner,stateBindings},plan,bindings,rules,deferred}:handler_app_returned(~S,world,owners,guards,stateBindings,plan,bindings,rules,deferred,handler(~S,handlerOwner))
def after(~S:Data,text:String,result:Execution.Application(~S) & String) -> Execution.Application(~S) & String:
  match result:
    case (app,reader):(app,text ++ "/reader-after=" ++ reader)
def checked(~S:Data,text:String,result:Execution.Application(~S) & Result<&2,&2,Check.Error,Bool>) -> Execution.Application(~S) & String:
  match result:
    case (app,Done{value}):after(~S,text ++ "/check=" ++ Bool.show(value),handler_app(~S,app))
    case (app,Fail{_}):after(~S,text ++ "/check-refused",handler_app(~S,app))
def inspected(~S:Data,text:String,result:Execution.Application(~S) & (I.Instance<S> & Result<&2,&2,String,String>)) -> Execution.Application(~S) & String:
  match result:
    case (app,(_,Done{view})):checked(~S,text ++ "/passive=" ++ view,Passive.check(~S,~L.columns(~S,D.components(~S)),~D.Resources(~S),~Unit,~Product.Owner<P.Left(~S),P.Right(~S)>,~P.Guard(~S),~Execution.Handler<S>,~Ops(~S),~Unit,~check_plan(~S),~check_body(~S),app,Unit{}))
    case (app,(_,Fail{error})):(app,text ++ "/inspection-error=" ++ error)
def observe(~S:Data,result:Execution.Application(~S) & String) -> Execution.Application(~S) & String:
  match result:
    case (app,reader):inspected(~S,"reader-before=" ++ reader,Passive.passive(~S,~L.columns(~S,D.components(~S)),~D.Resources(~S),~Unit,~Product.Owner<P.Left(~S),P.Right(~S)>,~P.Guard(~S),~Execution.Handler<S>,~Ops(~S),~Unit,~String,~String,~plan(~S),~body(~S),app,I.Fresh{},Unit{}))
def finished(~S:Data,source:Resume.Source<S>,restoration:Resume.Restoration<S>,report:State.Report<String,String>,result:Execution.Application(~S) & String) -> String:
  match result:
    case (app,text):text ++ "/normal=" ++ Resume.observed(~S,Resume.Resumed{source,restoration,app,report})
def resumed(~S:Data,result:Resume.Outcome<S>) -> String:
  match result:
    case Resume.Resumed{source,restoration,app,report}:finished(~S,source,restoration,report,observe(~S,handler_app(~S,app)))
    case _:"resume-refused"
def main() -> IO(Unit):IO.bind(Resume.Outcome<O.Alpha>,Unit,Resume.run(~O.Alpha,False{}),result => IO.print(resumed(~O.Alpha,result)))

import Base
import ./extended-flow.bend as Flow
import ./extended-execution.bend as Execution
import ./extended-resume.bend as Resume
import ./extended-programs.bend as P
import ./extended-declarations.bend as Schema
import ./extended-admission.bend as Admission
import ./extended-main.bend as Observe
import ./declarations.bend as O
import ../../src/ecs/execution-restore-extended-data.bend as Extended
import ../../src/ecs/execution-restore-receiver.bend as Receiver
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/world.bend as W
import ../../src/ecs/clock-state.bend as Clock
import ../../src/ecs/change-tick.bend as Tick

type Outcome<-S:Data> is Type:
  SourceRefused{result:Flow.Outcome<S>}
  DefinitionRefused{source:Resume.Source<S>,schema:Admission.Recipes(~S),input:Extended.Snapshot<S>,result:Execution.Defined<S>}
  Observed{source:Resume.Source<S>,result:Execution.Restoration<S>}
def entered(~S:Data,held:Execution.Held<S>,result:Schema.World(~S) & Tick.Tick) -> Execution.Application(~S):
  match result:
    case (world,_):Execution.rejoin(~S,held,world)
# Trusted bootstrap opens a real canonical execution scope. It does not change
# source data or manufacture a Clock.State. Restore must retain that exact scope.
def active(~S:Data,app:Execution.Application(~S)) -> Execution.Application(~S):
  match app:
    case Schedule.Scheduled{App.State{world,owners,guard,handler,stateBindings},plan,appBindings,rules,deferred}:entered(~S,Execution.Held{owners,guard,handler,stateBindings,plan,appBindings,rules,deferred},W.enter_run(~S,~P.Columns(~S),~Schema.Resources(~S),~Unit,world))
def defined(~S:Data,source:Resume.Source<S>,schema:Admission.Recipes(~S),input:Extended.Snapshot<S>,result:Execution.Defined<S>) -> Outcome<S>:
  match result:
    case Execution.Defined{app}:Observed{source,Execution.restore(~S,schema,input,active(~S,app))}
    case result:DefinitionRefused{source,schema,input,result}
def prepared(~S:Data,result:Flow.Outcome<S>) -> Outcome<S>:
  match result:
    case Flow.Prepared{source,previous,reader,receipt,schema,input,target}:defined(~S,Resume.Source{source,previous,receipt},schema,input,Execution.setup(~S,target,reader))
    case result:SourceRefused{result}
def run(~S:Data) -> IO(Outcome<S>):IO.bind(Flow.Outcome<S>,Outcome<S>,Flow.prepare(~S),result => IO.pure(Outcome<S>,prepared(~S,result)))
def world(~S:Data,value:Schema.World(~S)) -> String:
  match value:
    case W.World{namespace,allocator,columns,resources,events,pending,registrations,nextSystem,Clock.State{+tick,+scopes},lifecycle}:"scopes=" ++ List.show(&2,Tick.Tick,Tick.show,scopes) ++ "/" ++ Observe.owners(~S,W.World{namespace,allocator,columns,resources,events,pending,registrations,nextSystem,Clock.State{tick,scopes},lifecycle})
def observed(~S:Data,result:Outcome<S>) -> String:
  match result:
    case Observed{_,Execution.ReceiverRefused{Schedule.Scheduled{App.State{actual,Product.Owner{Sys.Owner{_,_,_,_,_,left},Sys.Owner{_,_,_,_,_,right}},Sys.Owner{_,_,_,_,_,guard},Execution.Handler{capture,handled,reader},stateBindings},_,appBindings,_,_},_,Receiver.ActiveExecution{}}}:"active-refused/left=" ++ Resume.local(left) ++ "/right=" ++ Resume.local(right) ++ "/guard=" ++ Resume.local(guard) ++ "/handler=" ++ Resume.capture(Array.get(U32,capture,0)) ++ ":" ++ U32.show(handled) ++ "/reader=" ++ Observe.reader(~S,reader) ++ "/stateBindings=" ++ Nat.show(List.length(&2,App.Binding,stateBindings)) ++ "/appBindings=" ++ Nat.show(List.length(&2,App.Binding,appBindings)) ++ "/" ++ world(~S,actual)
    case Observed{_,_}:"unexpected-outcome"
    case SourceRefused{_}:"source-refused"
    case DefinitionRefused{_,_,_,_}:"definition-refused"
def main() -> IO(Unit):IO.bind(Outcome<O.Alpha>,Unit,run(~O.Alpha),a => IO.bind(Unit,Unit,IO.print("alpha " ++ observed(~O.Alpha,a)),u => IO.bind(Outcome<O.Beta>,Unit,run(~O.Beta),b => IO.print("beta " ++ observed(~O.Beta,b)))))

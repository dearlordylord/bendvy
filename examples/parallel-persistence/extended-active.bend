import Base
import ./extended-flow.bend as Flow
import ./extended-execution.bend as Execution
import ./extended-resume.bend as Resume
import ./extended-programs.bend as P
import ./extended-declarations.bend as Schema
import ./extended-admission.bend as Admission
import ./extended-observation.bend as Observe
import ./extended-observation-data.bend as Data
import ./declarations.bend as O
import ../../src/ecs/execution-restore-extended-data.bend as Extended
import ../../src/ecs/execution-restore-receiver.bend as Receiver
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-parallel-scope.bend as Scope
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
def observed(~S:Data,result:Outcome<S>) -> String:
  match result:
    case Observed{source,result}:"source={" ++ Resume.source_observed(~S,source) ++ "}/result=" ++ Observe.execution_restoration(~S,result)
    case SourceRefused{result}:"source-refused/" ++ Observe.flow(~S,result)
    case DefinitionRefused{source,schema,input,result}:"definition-refused/source={" ++ Resume.source_observed(~S,source) ++ "}/schema=" ++ Data.schema(~S,schema) ++ "/input=" ++ Data.snapshot(~S,input) ++ "/result=" ++ Observe.definition(~S,result)
def main() -> IO(Unit):IO.bind(Outcome<O.Alpha>,Unit,run(~O.Alpha),a => IO.bind(Unit,Unit,IO.print("alpha " ++ observed(~O.Alpha,a)),u => IO.bind(Outcome<O.Beta>,Unit,run(~O.Beta),b => IO.print("beta " ++ observed(~O.Beta,b)))))

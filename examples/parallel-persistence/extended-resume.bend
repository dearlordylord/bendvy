import Base
import ./extended-flow.bend as Flow
import ./extended-execution.bend as Execution
import ./extended-programs.bend as P
import ./extended-declarations.bend as Schema
import ./extended-admission.bend as Admission
import ./extended-restore.bend as Restore
import ./extended-population.bend as Population
import ./extended-save.bend as Save
import ./extended-observation.bend as Observe
import ./extended-observation-data.bend as Data
import ./observation.bend as BasicObserve
import ./declarations.bend as O
import ../parallel-machines/reports.bend as Reports
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-parallel-scope.bend as Scope
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-relation-store.bend as Store
import ../../src/ecs/execution-restore-extended-data.bend as Extended
import ../../src/ecs/execution-restore-publication.bend as Publication
import ../../src/ecs/restore-data.bend as R
import ../../src/ecs/relation-types.bend as T
import ./restore.bend as Ordinary

type Source<-S:Data> is Type:Source{world:Schema.World(~S),previous:Population.Previous(~S),receipt:Store.Receipt<S>}
type Restoration<-S:Data> is Type:Restoration{state:Restore.State<S>,removed:List<Ordinary.Receipt(~S)>,mapping:List<&2,R.Binding<S>>,publications:List<Publication.Receipt<S,Schema.components(~S)>>,previous:Restore.Previous<S>}
type Outcome<-S:Data> is Type:
  SourceRefused{result:Flow.Outcome<S>}
  DefinitionRefused{source:Source<S>,schema:Admission.Recipes(~S),input:Extended.Snapshot<S>,result:Execution.Defined<S>}
  RestoreRefused{source:Source<S>,result:Execution.Restoration<S>}
  Resumed{source:Source<S>,restoration:Restoration<S>,app:Execution.Application(~S),report:App.Report<String,String>}
def finished(~S:Data,source:Source<S>,restoration:Restoration<S>,result:Execution.Application(~S) & App.Report<String,String>) -> Outcome<S>:
  match result:
    case (app,report):Resumed{source,restoration,app,report}
def restored(~S:Data,native:Bool,source:Source<S>,result:Execution.Restoration<S>) -> IO(Outcome<S>):
  match native result:
    case False{} Execution.Restored{app,state,removed,mapping,publications,previous}:IO.bind(Execution.Application(~S) & App.Report<String,String>,Outcome<S>,Execution.run_serial(~S,app),result => IO.pure(Outcome<S>,finished(~S,source,Restoration{state,removed,mapping,publications,previous},result)))
    case True{} Execution.Restored{app,state,removed,mapping,publications,previous}:IO.bind(Execution.Application(~S) & App.Report<String,String>,Outcome<S>,Execution.run_native(~S,app),result => IO.pure(Outcome<S>,finished(~S,source,Restoration{state,removed,mapping,publications,previous},result)))
    case _ result:IO.pure(Outcome<S>,RestoreRefused{source,result})
def defined(~S:Data,native:Bool,source:Source<S>,schema:Admission.Recipes(~S),input:Extended.Snapshot<S>,result:Execution.Defined<S>) -> IO(Outcome<S>):
  match result:
    case Execution.Defined{app}:restored(~S,native,source,Execution.restore(~S,schema,input,app))
    case result:IO.pure(Outcome<S>,DefinitionRefused{source,schema,input,result})
def prepared(~S:Data,native:Bool,result:Flow.Outcome<S>) -> IO(Outcome<S>):
  match result:
    case Flow.Prepared{source,previous,reader,receipt,schema,input,target}:defined(~S,native,Source{source,previous,receipt},schema,input,Execution.setup(~S,target,reader))
    case result:IO.pure(Outcome<S>,SourceRefused{result})
def run(~S:Data,native:Bool) -> IO(Outcome<S>):IO.bind(Flow.Outcome<S>,Outcome<S>,Flow.prepare(~S),result => prepared(~S,native,result))
type Repetition<-S:Data> is Type:Repetition{source:Source<S>,restoration:Restoration<S>,first:App.Report<String,String>}
type Repeated<-S:Data> is Type:
  FirstRefused{result:Outcome<S>}
  Repeated{first:App.Report<String,String>,second:Outcome<S>}
def second_finished(~S:Data,held:Repetition<S>,result:Execution.Application(~S) & App.Report<String,String>) -> Repeated<S>:
  match held:
    case Repetition{source,restoration,first}:Repeated{first,finished(~S,source,restoration,result)}
def second_run(~S:Data,native:Bool,held:Repetition<S>,app:Execution.Application(~S)) -> IO(Repeated<S>):
  match native:
    case False{}:IO.bind(Execution.Application(~S) & App.Report<String,String>,Repeated<S>,Execution.run_serial(~S,app),result => IO.pure(Repeated<S>,second_finished(~S,held,result)))
    case True{}:IO.bind(Execution.Application(~S) & App.Report<String,String>,Repeated<S>,Execution.run_native(~S,app),result => IO.pure(Repeated<S>,second_finished(~S,held,result)))
def repeated(~S:Data,native:Bool,result:Outcome<S>) -> IO(Repeated<S>):
  match result:
    case Resumed{source,restoration,app,report}:second_run(~S,native,Repetition{source,restoration,report},app)
    case result:IO.pure(Repeated<S>,FirstRefused{result})
def run_repeated(~S:Data,+native:Bool) -> IO(Repeated<S>):IO.bind(Outcome<S>,Repeated<S>,run(~S,native),result => repeated(~S,native,result))
def capture(result:Array<U32> & U32) -> String:
  match result:
    case (_,value):U32.show(value)
def local(value:P.Local) -> String:
  match value:
    case P.Local{values,runs}:capture(Array.get(U32,values,0)) ++ ":" ++ U32.show(runs)
def source_observed(~S:Data,value:Source<S>) -> String:
  match value:
    case Source{world,previous,receipt}:Observe.source(~S,Observe.Source{world,previous,receipt})
def observed(~S:Data,result:Outcome<S>) -> String:
  match result:
    case Resumed{Source{world,old,receipt},Restoration{state,removed,mapping,publications,previous},app,report}:Observe.resumed(~S,Observe.Source{world,old,receipt},Observe.Restoration{state,removed,mapping,publications,previous},app,report)
    case SourceRefused{result}:"source-refused/" ++ Observe.flow(~S,result)
    case DefinitionRefused{source,schema,input,result}:"definition-refused/source={" ++ source_observed(~S,source) ++ "}/schema=" ++ Data.schema(~S,schema) ++ "/input=" ++ Data.snapshot(~S,input) ++ "/result=" ++ Observe.definition(~S,result)
    case RestoreRefused{source,result}:"restore-refused/source={" ++ source_observed(~S,source) ++ "}/result=" ++ Observe.execution_restoration(~S,result)
def repeated_observed(~S:Data,result:Repeated<S>) -> String:
  match result:
    case FirstRefused{result}:"first-refused/" ++ observed(~S,result)
    case Repeated{first,second}:"first=" ++ BasicObserve.report(first) ++ "/second=" ++ observed(~S,second)
def main() -> IO(Unit):IO.bind(Repeated<O.Alpha>,Unit,run_repeated(~O.Alpha,False{}),a => IO.bind(Unit,Unit,IO.print("alpha-serial " ++ repeated_observed(~O.Alpha,a)),u => IO.bind(Repeated<O.Beta>,Unit,run_repeated(~O.Beta,True{}),b => IO.print("beta-native " ++ repeated_observed(~O.Beta,b)))))

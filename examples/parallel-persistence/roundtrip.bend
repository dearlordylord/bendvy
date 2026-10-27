import Base
import ./declarations.bend as Ordinary
import ./receiver.bend as Receiver
import ./execution.bend as Execution
import ./setup.bend as Setup
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/execution-save-data.bend as Saved
import ../../src/ecs/execution-save-gate.bend as Gate
import ../../src/ecs/execution-save-recipe.bend as Recipe
import ../../src/ecs/dependency-application.bend as App

type Outcome<-S:Data> is Type:
  SetupRefused{result:Setup.Defined<S>}
  SaveRefused{schema:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)>,app:Execution.Application(~S),firstReport:App.Report<String,String>,outcome:Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>}
  Continued{firstReport:App.Report<String,String>,result:Execution.Resumed<S>}
def continued(~S:Data,firstReport:App.Report<String,String>,result:Execution.Resumed<S>) -> Outcome<S>:Continued{firstReport,result}
def saved(~S:Data,native:Bool,firstReport:App.Report<String,String>,result:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)> & (Execution.Application(~S) & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>)) -> IO(Outcome<S>):
  match result:
    case (schema,(app,Gate.Saved{input})):IO.bind(Execution.Resumed<S>,Outcome<S>,Execution.resume(~S,native,Execution.restore(~S,schema,input,app)),result => IO.pure(Outcome<S>,continued(~S,firstReport,result)))
    case (schema,(app,outcome)):IO.pure(Outcome<S>,SaveRefused{schema,app,firstReport,outcome})
def first_completed(~S:Data,native:Bool,result:Execution.Application(~S) & App.Report<String,String>) -> IO(Outcome<S>):
  match result:
    case (app,report):saved(~S,native,report,Execution.save(~S,Ordinary.schema(~S),app))
def defined(~S:Data,+native:Bool,result:Setup.Defined<S>) -> IO(Outcome<S>):
  match native result:
    case _, Setup.ReaderRefused{world,reason}:IO.pure(Outcome<S>,SetupRefused{Setup.ReaderRefused{world,reason}})
    case _, Setup.LeftRefused{world,local,reader}:IO.pure(Outcome<S>,SetupRefused{Setup.LeftRefused{world,local,reader}})
    case _, Setup.RightRefused{world,left,local}:IO.pure(Outcome<S>,SetupRefused{Setup.RightRefused{world,left,local}})
    case True{}, Setup.Defined{app}:IO.bind(Execution.Application(~S) & App.Report<String,String>,Outcome<S>,Execution.run_native(~S,app),result => first_completed(~S,native,result))
    case False{}, Setup.Defined{app}:IO.bind(Execution.Application(~S) & App.Report<String,String>,Outcome<S>,Execution.run_serial(~S,app),result => first_completed(~S,native,result))
# Ordinary consumer flow: run the actual schedule, save its complete fields,
# restore into its retained receiver, then resume only a complete restoration.
# It returns real reports and all recovery owners, not an expected-value oracle.
def roundtrip(~S:Data,native:Bool,world:Receiver.World(~S)) -> IO(Outcome<S>):defined(~S,native,Setup.setup(~S,world))
def alpha_native(world:Receiver.World(~Ordinary.Alpha)) -> IO(Outcome<Ordinary.Alpha>):roundtrip(~Ordinary.Alpha,True{},world)
def alpha_serial(world:Receiver.World(~Ordinary.Alpha)) -> IO(Outcome<Ordinary.Alpha>):roundtrip(~Ordinary.Alpha,False{},world)
def beta_native(world:Receiver.World(~Ordinary.Beta)) -> IO(Outcome<Ordinary.Beta>):roundtrip(~Ordinary.Beta,True{},world)
def beta_serial(world:Receiver.World(~Ordinary.Beta)) -> IO(Outcome<Ordinary.Beta>):roundtrip(~Ordinary.Beta,False{},world)

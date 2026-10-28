import Base
import ./declarations.bend as O
import ./receiver.bend as R
import ./execution.bend as E
import ./scheduled.bend as P
import ./setup.bend as Setup
import ./pending-command.bend as Author
import ./restore-receipt.bend as Receipt
import ./staging.bend as Stage
import ./observation.bend as Observe
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/execution-save-world.bend as Save
import ../../src/ecs/execution-save-data.bend as Saved
import ../../src/ecs/execution-save-gate.bend as Gate
import ../../src/ecs/execution-save-recipe.bend as Recipe
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-command-removed.bend as Removed
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-deferred-settings.bend as Settings
import ../../src/ecs/execution-lifecycle-notices.bend as Notice
import ../../src/ecs/world.bend as W

def Application(~S:Data) -> Type:P.Application(~S,~Product.Owner<Author.Owner(~S),E.Right(~S)>,~Unit,~E.Handler)
type Outcome<-S:Data> is Type:
  Refused{app:Application(~S),receipt:Receipt.Receipt<S>,savePending:Bool}
  SetupRefused{result:Setup.Defined<S>,schema:Plan.Schema<S,O.components(~S),O.resources(~S)>,input:Saved.Snapshot<S>}
  AuthorRefused{world:R.World(~S),local:Cmd.Captures(~S,~R.Components(~S),~Plan.layout(O.resources(~S)),~Author.route(),~Author.Capture<S>),right:E.Right(~S),handler:E.Handler,schema:Plan.Schema<S,O.components(~S),O.resources(~S)>,input:Saved.Snapshot<S>}
  NoHandle{app:E.Application(~S),schema:Plan.Schema<S,O.components(~S),O.resources(~S)>,input:Saved.Snapshot<S>}
  InitialRefused{world:R.World(~S),schema:Plan.Schema<S,O.components(~S),O.resources(~S)>,reason:Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>}
def restored(~S:Data,savePending:Bool,result:Application(~S) & Receipt.Receipt<S>) -> Outcome<S>:
  match result:
    case (app,receipt):Refused{app,receipt,savePending}
def saved(~S:Data,input:Saved.Snapshot<S>,result:Plan.Schema<S,O.components(~S),O.resources(~S)> & (Application(~S) & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>)) -> Outcome<S>:
  match result:
    case (schema,(app,Gate.RefusedPending{})):restored(~S,True{},P.restore(~S,~Author.Owner(~S),~E.Right(~S),~Author.selection(~S),~E.right(~S),~Unit,~E.Handler,~Conditions.empty_dispatch(~R.World(~S),~String),~Conditions.empty(~R.World(~S),~String),~E.handle,schema,input,app))
    case (schema,(app,_)):restored(~S,False{},P.restore(~S,~Author.Owner(~S),~E.Right(~S),~Author.selection(~S),~E.right(~S),~Unit,~E.Handler,~Conditions.empty_dispatch(~R.World(~S),~String),~Conditions.empty(~R.World(~S),~String),~E.handle,schema,input,app))
def ran(~S:Data,schema:Plan.Schema<S,O.components(~S),O.resources(~S)>,input:Saved.Snapshot<S>,result:Application(~S) & App.Report<String,String>) -> Outcome<S>:
  match result:
    case (app,_):saved(~S,input,P.save(~S,~Author.Owner(~S),~E.Right(~S),~Author.selection(~S),~E.right(~S),~Unit,~E.Handler,~Conditions.empty_dispatch(~R.World(~S),~String),~Conditions.empty(~R.World(~S),~String),~E.handle,schema,app))
def built(~S:Data,native:Bool,schema:Plan.Schema<S,O.components(~S),O.resources(~S)>,input:Saved.Snapshot<S>,app:Application(~S)) -> IO(Outcome<S>):
  match native:
    case True{}:IO.bind(Application(~S) & App.Report<String,String>,Outcome<S>,Schedule.run_native(~S,~P.LeftColumn(~S),~P.RightColumn(~S),~P.LeftResource(~S),~P.RightResource(~S),~Unit,~Plan.layout(O.resources(~S)),~{==},~String,~String,~Author.Owner(~S),~E.Right(~S),~Author.selection(~S),~E.right(~S),~Unit,~E.Handler,~Conditions.empty_dispatch(~R.World(~S),~String),~Conditions.empty(~R.World(~S),~String),~E.handle,app),result => IO.pure(Outcome<S>,ran(~S,schema,input,result)))
    case False{}:IO.bind(Application(~S) & App.Report<String,String>,Outcome<S>,Schedule.run_serial(~S,~P.LeftColumn(~S),~P.RightColumn(~S),~P.LeftResource(~S),~P.RightResource(~S),~Unit,~Plan.layout(O.resources(~S)),~{==},~String,~String,~Author.Owner(~S),~E.Right(~S),~Author.selection(~S),~E.right(~S),~Unit,~E.Handler,~Conditions.empty_dispatch(~R.World(~S),~String),~Conditions.empty(~R.World(~S),~String),~E.handle,app),result => IO.pure(Outcome<S>,ran(~S,schema,input,result)))
def defined(~S:Data,native:Bool,right:E.Right(~S),handler:E.Handler,schema:Plan.Schema<S,O.components(~S),O.resources(~S)>,input:Saved.Snapshot<S>,result:Sys.Defined<R.World(~S),Author.Owner(~S),Cmd.Captures(~S,~R.Components(~S),~Plan.layout(O.resources(~S)),~Author.route(),~Author.Capture<S>)>) -> IO(Outcome<S>):
  match result:
    case Sys.DefinitionRefused{world,local}:IO.pure(Outcome<S>,AuthorRefused{world,local,right,handler,schema,input})
    case Sys.Defined{world,author}:built(~S,native,schema,input,Schedule.configure(~App.State<R.World(~S),Product.Owner<Author.Owner(~S),E.Right(~S)>,Unit,E.Handler>,Settings.Settings{False{},False{},[],[]},Schedule.build(~S,~P.LeftColumn(~S),~P.RightColumn(~S),~P.LeftResource(~S),~P.RightResource(~S),~Unit,~Plan.layout(O.resources(~S)),~{==},~String,~String,~Author.Owner(~S),~E.Right(~S),~Author.selection(~S),~E.right(~S),~Unit,~E.Handler,~Conditions.empty_dispatch(~R.World(~S),~String),~Conditions.empty(~R.World(~S),~String),~E.handle,~(name => True{}),world,Product.Owner{author,right},Unit{},handler,[],[])))
def handles(~S:Data,native:Bool,left:E.Left(~S),right:E.Right(~S),handler:E.Handler,schema:Plan.Schema<S,O.components(~S),O.resources(~S)>,input:Saved.Snapshot<S>,result:R.World(~S) & List<&2,W.Handle<S>>) -> IO(Outcome<S>):
  match result:
    case (world,handle <> _):defined(~S,native,right,handler,schema,input,Author.define(~S,world,handle,left))
    case (world,[]):IO.pure(Outcome<S>,NoHandle{E.build(~S,world,left,right,handler),schema,input})
def setup(~S:Data,native:Bool,schema:Plan.Schema<S,O.components(~S),O.resources(~S)>,input:Saved.Snapshot<S>,result:Setup.Defined<S>) -> IO(Outcome<S>):
  match result:
    case Setup.Defined{Schedule.Scheduled{App.State{world,Product.Owner{left,right},_,handler,_},_,_,_,_}}:handles(~S,native,left,right,handler,schema,input,W.handles(~S,~Layout.columns(~S,R.Components(~S)),~R.Resources(~S),~Unit,world))
    case other:IO.pure(Outcome<S>,SetupRefused{other,schema,input})
def initial(~S:Data,native:Bool,result:Plan.Schema<S,O.components(~S),O.resources(~S)> & (R.World(~S) & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>)) -> IO(Outcome<S>):
  match result:
    case (schema,(world,Gate.Saved{input})):setup(~S,native,schema,input,Setup.setup(~S,world))
    case (schema,(world,reason)):IO.pure(Outcome<S>,InitialRefused{world,schema,reason})
def run(~S:Data,native:Bool,world:R.World(~S)) -> IO(Outcome<S>):initial(~S,native,Save.save(~S,~O.components(~S),~O.resources(~S),~Unit,O.schema(~S),world))
def refused_observed(~S:Data,app:Application(~S),savePending:Bool,result:Plan.Schema<S,O.components(~S),O.resources(~S)> & String) -> String:
  match result:
    case (actualSchema,receiptText):"savePending=" ++ Bool.show(savePending) ++ "/receipt=" ++ receiptText ++ "/schema=" ++ Observe.schema(~S,actualSchema) ++ "/application=" ++ Observe.scheduled(~S,~Product.Owner<Author.Owner(~S),E.Right(~S)>,~Observe.pending_owners(~S),app)
def observed(~S:Data,result:Outcome<S>) -> String:
  match result:
    case Refused{app,receipt,savePending}:refused_observed(~S,app,savePending,Observe.receipt_for_save(~S,receipt))
    case SetupRefused{result,schema,input}:"setup-refused/schema=" ++ Observe.schema(~S,schema) ++ "/input=" ++ Observe.snapshot(~S,input) ++ "/result=" ++ Observe.setup(~S,result)
    case AuthorRefused{world,local,right,handler,schema,input}:"author-refused/world=" ++ Observe.world(~S,world) ++ "/local=" ++ Observe.command_local(~S,local) ++ "/right=" ++ Observe.right_owner(~S,right) ++ "/handler=" ++ Observe.handler(handler) ++ "/schema=" ++ Observe.schema(~S,schema) ++ "/input=" ++ Observe.snapshot(~S,input)
    case NoHandle{app,schema,input}:"no-handle/application=" ++ Observe.scheduled(~S,~Product.Owner<E.Left(~S),E.Right(~S)>,~Observe.basic_owners(~S),app) ++ "/schema=" ++ Observe.schema(~S,schema) ++ "/input=" ++ Observe.snapshot(~S,input)
    case InitialRefused{world,schema,reason}:"initial-refused/world=" ++ Observe.world(~S,world) ++ "/schema=" ++ Observe.schema(~S,schema) ++ "/save=" ++ Observe.save_result(~S,reason)

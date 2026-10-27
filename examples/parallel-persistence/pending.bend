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
  AuthorRefused{world:R.World(~S),local:Cmd.Captures(~S,~R.Components(~S),~Author.route(),~Author.Capture<S>),right:E.Right(~S),handler:E.Handler,schema:Plan.Schema<S,O.components(~S),O.resources(~S)>,input:Saved.Snapshot<S>}
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
    case True{}:IO.bind(Application(~S) & App.Report<String,String>,Outcome<S>,Schedule.run_native(~S,~P.LeftColumn(~S),~P.RightColumn(~S),~P.LeftResource(~S),~P.RightResource(~S),~Unit,~String,~String,~Author.Owner(~S),~E.Right(~S),~Author.selection(~S),~E.right(~S),~Unit,~E.Handler,~Conditions.empty_dispatch(~R.World(~S),~String),~Conditions.empty(~R.World(~S),~String),~E.handle,app),result => IO.pure(Outcome<S>,ran(~S,schema,input,result)))
    case False{}:IO.bind(Application(~S) & App.Report<String,String>,Outcome<S>,Schedule.run_serial(~S,~P.LeftColumn(~S),~P.RightColumn(~S),~P.LeftResource(~S),~P.RightResource(~S),~Unit,~String,~String,~Author.Owner(~S),~E.Right(~S),~Author.selection(~S),~E.right(~S),~Unit,~E.Handler,~Conditions.empty_dispatch(~R.World(~S),~String),~Conditions.empty(~R.World(~S),~String),~E.handle,app),result => IO.pure(Outcome<S>,ran(~S,schema,input,result)))
def defined(~S:Data,native:Bool,right:E.Right(~S),handler:E.Handler,schema:Plan.Schema<S,O.components(~S),O.resources(~S)>,input:Saved.Snapshot<S>,result:Sys.Defined<R.World(~S),Author.Owner(~S),Cmd.Captures(~S,~R.Components(~S),~Author.route(),~Author.Capture<S>)>) -> IO(Outcome<S>):
  match result:
    case Sys.DefinitionRefused{world,local}:IO.pure(Outcome<S>,AuthorRefused{world,local,right,handler,schema,input})
    case Sys.Defined{world,author}:built(~S,native,schema,input,Schedule.configure(~App.State<R.World(~S),Product.Owner<Author.Owner(~S),E.Right(~S)>,Unit,E.Handler>,Settings.Settings{False{},False{},[],[]},Schedule.build(~S,~P.LeftColumn(~S),~P.RightColumn(~S),~P.LeftResource(~S),~P.RightResource(~S),~Unit,~String,~String,~Author.Owner(~S),~E.Right(~S),~Author.selection(~S),~E.right(~S),~Unit,~E.Handler,~Conditions.empty_dispatch(~R.World(~S),~String),~Conditions.empty(~R.World(~S),~String),~E.handle,~(name => True{}),world,Product.Owner{author,right},Unit{},handler,[],[])))
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
def entry(~S:Data,value:Buffer.Entry<S,O.Actor<S>,Removed.Removed(R.Components(~S))>) -> String:
  match value:
    case Buffer.Entry{W.Handle{namespace,key},Some{O.Actor{name,energy}}}:"insert/" ++ U32.show(namespace) ++ "/" ++ name ++ "/" ++ Observe.captured(Array.get(U32,energy,0))
    case Buffer.Entry{_,None{}}:"remove"
    case Buffer.Despawn{_}:"despawn"
    case Buffer.Spawn{_,_}:"spawn"
def pending_status(status:Receipt.Status) -> String:
  match status:
    case Receipt.Pending{}:"pending"
    case _:"other"
def world_saved(~S:Data,result:Plan.Schema<S,O.components(~S),O.resources(~S)> & (R.World(~S) & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>)) -> String:
  match result:
    case (_,(_,Gate.Saved{snapshot})):Observe.snapshot(~S,snapshot)
    case _:"observation-refused"
def world_state(~S:Data,state:Stage.State<S>,world:R.World(~S)) -> String:
  match state:
    case Stage.State{schema,_,_}:world_saved(~S,Save.save(~S,~O.components(~S),~O.resources(~S),~Unit,schema,world))
def observed(~S:Data,result:Outcome<S>) -> String:
  match result:
    case Refused{Schedule.Scheduled{App.State{world,Product.Owner{Cmd.Owner{Sys.Owner{_,_,_,_,_,Local.Local{Author.Capture{_,Sys.Owner{_,_,_,_,_,E.Local{original,originalRuns}},capture,runs},Buffer.Buffer{queued,receipts},_}}},Sys.Owner{_,_,_,_,_,E.ReaderLocal{right,rightRuns,Notice.Reader{namespace,id,cursor},notices}}},_,E.Handler{handler,handled},stateBindings},_,appBindings,_,Schedule.Deferred{_,Settings.Settings{automatic,finalApply,_,_},unapplied}},Receipt.Receipt{state,input,removed,rows,mapping,publications,previous,remaining,status},savePending}:"savePending=" ++ Bool.show(savePending) ++ "/restore=" ++ pending_status(status) ++ "/queue=" ++ List.show(&1,Buffer.Entry<S,O.Actor<S>,Removed.Removed(R.Components(~S))>,entry(~S),queued) ++ "/receipts=" ++ Nat.show(List.length(&1,Buffer.Receipt<S,O.Actor<S>,Removed.Removed(R.Components(~S))>,receipts)) ++ "/captures=" ++ Observe.captured(Array.get(U32,original,0)) ++ "," ++ Observe.captured(Array.get(U32,capture,0)) ++ "," ++ Observe.captured(Array.get(U32,right,0)) ++ "," ++ Observe.captured(Array.get(U32,handler,0)) ++ "/runs=" ++ U32.show(originalRuns) ++ "," ++ U32.show(runs) ++ "," ++ U32.show(rightRuns) ++ "/reader=" ++ U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ Nat.show(cursor) ++ "/notices=" ++ U32.show(notices) ++ "/handled=" ++ U32.show(handled) ++ "/automatic=" ++ Bool.show(automatic) ++ "/finalApply=" ++ Bool.show(finalApply) ++ "/bindings=" ++ Nat.show(List.length(&2,App.Binding,stateBindings)) ++ "," ++ Nat.show(List.length(&2,App.Binding,appBindings)) ++ "/unapplied=" ++ List.show(&2,U32,U32.show,unapplied) ++ "/input=" ++ Observe.snapshot(~S,input) ++ "/world=" ++ world_state(~S,state,world)
    case _:"setup-refused"

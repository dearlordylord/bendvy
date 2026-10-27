import Base
import ../parallel-applications/app-b-schema.bend as D
import ../parallel-applications/app-b-commands.bend as Author
import ../parallel-applications/app-b-application.bend as App
import ../parallel-applications/app-b-inspection.bend as View
import ../parallel-applications/app-b-owners.bend as Owners
import ../../src/ecs/execution-inspector-commands.bend as Commands
import ../../src/ecs/execution-inspector-application.bend as Passive
import ../../src/ecs/execution-inspector-component.bend as Columns
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-command-removed.bend as Removed
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-parallel-root-application.bend as Root
import ../../src/ecs/execution-parallel-registration.bend as Registration
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/dependency-application.bend as State
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/check.bend as Check
import ../../src/ecs/world.bend as W

def author_returned(namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:Maybe<&2,Tick.Tick>,user:Author.User,permission:Permission.Permission,result:Buffer.Buffer<D.Scene,Array<U32>,Removed.Removed(D.components())> & Commands.Snapshot<D.Scene>) -> Author.Owner() & Commands.Snapshot<D.Scene>:
  match result:
    case (buffer,view):(Cmd.Owner{Sys.Owner{namespace,id,name,access,cursor,Local.Local{user,buffer,permission}}},view)
def author(owner:Author.Owner()) -> Author.Owner() & Commands.Snapshot<D.Scene>:
  match owner:
    case Cmd.Owner{Sys.Owner{namespace,id,name,access,cursor,Local.Local{user,buffer,permission}}}:author_returned(namespace,id,name,access,cursor,user,permission,Commands.snapshot(D.Scene,Array<U32>,Removed.Removed(D.components()),buffer))
def application_returned(world:App.World(),peer:App.Peer(),guards:Unit,handler:Unit,stateBindings:List<&2,State.Binding>,plan:Plan.Build<String>,bindings:List<&2,State.Binding>,rules:Registration.Rules,deferred:Root.Deferred,result:Author.Owner() & Commands.Snapshot<D.Scene>) -> App.Application() & Commands.Snapshot<D.Scene>:
  match result:
    case (owner,view):(Root.Scheduled{State.State{world,Product.Owner{owner,peer},guards,handler,stateBindings},plan,bindings,rules,deferred},view)
def application(value:App.Application()) -> App.Application() & Commands.Snapshot<D.Scene>:
  match value:
    case Root.Scheduled{State.State{world,Product.Owner{owner,peer},guards,handler,stateBindings},plan,bindings,rules,deferred}:application_returned(world,peer,guards,handler,stateBindings,plan,bindings,rules,deferred,author(owner))
def bound_returned(context:Context.Context<D.Scene,App.Resources(),Author.resources(),{==}>,result:App.Application() & Commands.Snapshot<D.Scene>) -> App.Bound() & Commands.Snapshot<D.Scene>:
  match result:
    case (app,view):(Context.Bound{context,app},view)
def snapshot(value:App.Bound()) -> App.Bound() & Commands.Snapshot<D.Scene>:
  match value:
    case Context.Bound{context,app}:bound_returned(context,application(app))
def pending(value:Commands.Pending<D.Scene>) -> String:
  match value:
    case Commands.Spawn{handle}:"spawn:" ++ View.handle(handle)
    case _:"other-command"
def receipt(value:Commands.Receipt<D.Scene>) -> String:
  match value:
    case Commands.Spawned{handle}:"spawned:" ++ View.handle(handle)
    case _:"other-receipt"
def metadata(value:Commands.Snapshot<D.Scene>) -> String:
  match value:
    case Commands.Snapshot{pendingValues,receipts}:"pending=" ++ List.show(&2,Commands.Pending<D.Scene>,pending,pendingValues) ++ ";receipts=" ++ List.show(&2,Commands.Receipt<D.Scene>,receipt,receipts)
def Ops(H:Type) -> Type:Cap.ValueRead<H,List<&2,Check.Row<D.Scene,List<&2,U32>>>>
def required(world:App.World()) -> App.World() & List<&2,String>:(world,[])
def check_plan() -> Check.Plan<D.Scene,App.Columns(),App.Resources(),Unit,Ops>:
  Check.Plan{required,Columns.check_query(~D.Scene,~App.Columns(),~App.Resources(),~Unit,~D.components(),~L.InLeft{L.AtLeaf{}},~{==},~{==},~Check.Optional{})}
def checked_rows(-H:Type,result:H & List<&2,Check.Row<D.Scene,List<&2,U32>>>) -> H & Bool:
  match result:
    case (owner,[]):(owner,True{})
    case (owner,_):(owner,False{})
def check_body(~H:Type,~cap:Ops(H),_:Unit,owner:H) -> H & Bool:
  checked_rows(H,Cap.value_read(~H,~List<&2,Check.Row<D.Scene,List<&2,U32>>>,~cap,owner))
def check_returned(context:Context.Context<D.Scene,App.Resources(),Author.resources(),{==}>,result:App.Application() & Result<&2,&2,Check.Error,Bool>) -> App.Bound() & String:
  match result:
    case (app,Done{value}):(Context.Bound{context,app},Bool.show(value))
    case (app,Fail{_}):(Context.Bound{context,app},"check-refused")
def check(bound:App.Bound()) -> App.Bound() & String:
  match bound:
    case Context.Bound{context,app}:check_returned(context,Passive.check(~D.Scene,~App.Columns(),~App.Resources(),~Unit,~App.Owners(),~Unit,~Unit,~Ops,~Unit,~check_plan(),~check_body,app,Unit{}))
def finished(text:String,result:App.Bound() & String) -> IO(Unit):
  match result:
    case (_,raw):IO.print(text ++ "|flushed=" ++ raw)
def flushed(text:String,result:App.Bound() & String) -> IO(Unit):
  match result:
    case (bound,view):finished(text ++ "|published=" ++ view,Owners.observed(bound))
def after_raw(text:String,result:App.Bound() & String) -> IO(Unit):
  match result:
    case (bound,raw):flushed(text ++ "|after-raw=" ++ raw,View.observe(App.flush(bound)))
def after_snapshot(text:String,result:App.Bound() & Commands.Snapshot<D.Scene>) -> IO(Unit):
  match result:
    case (bound,view):after_raw(text ++ "|after=" ++ metadata(view),Owners.observed(bound))
def checked(text:String,result:App.Bound() & String) -> IO(Unit):
  match result:
    case (bound,value):after_snapshot(text ++ "|check-no-live-rows=" ++ value,snapshot(bound))
def inspected(text:String,result:App.Bound() & String) -> IO(Unit):
  match result:
    case (bound,view):checked(text ++ "|passive=" ++ view,check(bound))
def before_raw(text:String,result:App.Bound() & String) -> IO(Unit):
  match result:
    case (bound,raw):inspected(text ++ "|before-raw=" ++ raw,View.observe(bound))
def before_snapshot(result:App.Bound() & Commands.Snapshot<D.Scene>) -> IO(Unit):
  match result:
    case (bound,view):before_raw("before=" ++ metadata(view),Owners.observed(bound))
def invoked(result:App.Bound() & Context.RunReport<State.Report<String,String>>) -> IO(Unit):
  match result:
    case (bound,Context.RunReported{State.Finished{_}}):before_snapshot(snapshot(bound))
    case (_,_):IO.print("application-run-refused")
def defined(result:App.Definition) -> IO(Unit):
  match result:
    case App.Ready{bound}:IO.bind(App.Bound() & Context.RunReport<State.Report<String,String>>,Unit,App.invoke(bound),invoked)
    case _:IO.print("registration-refused")
def created(result:Context.Initialization<D.Scene,D.components(),Author.resources(),Unit>) -> IO(Unit):
  match result:
    case Context.ContextCreated{_,world,context}:defined(App.define(context,world))
    case _:IO.print("creation-refused")
def main() -> IO(Unit):created(D.create(~Author.Receipts(),W.factory(),[]))

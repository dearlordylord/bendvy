import Base
import ./guarded-nodes.bend as Nodes
import ./conditions.bend as Cond
import ./declarations.bend as D
import ./bodies.bend as Body
import ./observe.bend as Observe
import ./reports.bend as Common
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-system-lifecycle.bend as Life
import ../../src/ecs/execution-resource-query-lifecycle.bend as NodeLife
import ../../src/ecs/execution-generalized-root-application.bend as General
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-query-schema.bend as QuerySchema
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ../../src/ecs/execution-parallel-registration.bend as Part
import ../../src/ecs/dependency-application.bend as DepApp
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/world.bend as W
import ../../src/ecs/change-tick.bend as Tick

def GuardOwner(~S:Data) -> Type:Sys.Owner<S,D.Store(~S),D.Store(~S),D.Resources(~S),Unit,Cond.Ops(~S),Cond.Local(),String,Bool,Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~Cond.Ops(~S),~Cond.declaration(~S)),Cond.body(~S)>
def World(~S:Data) -> Type:Nodes.World(~S)
def Application(~S:Data) -> Type:Schedule.Scheduled<DepApp.State<General.Storage<S,Nodes.components(),D.resources_layout(),Unit>,Nodes.Nodes(~S),GuardOwner(~S),Common.Handler>>
def report(value:DepApp.Report<String,String>) -> String:Common.report(value)
def text(value:String) -> String:value
def released(~S:Data,trace:String,ll:Body.LeftLocal(),ol:Body.LeftLocal(),lc:Maybe<&2,Tick.Tick>,oc:Maybe<&2,Tick.Tick>,gl:Cond.Local(),gc:Maybe<&2,Tick.Tick>,handler:Common.Handler,world:World(~S),result:Nodes.RightReturned(~S)) -> String:
  match result:
    case NodeLife.Released{_,_,Life.Identity{namespace,id,name,access,rc},rl}:trace ++ "|world=" ++ Observe.world(~S,world) ++ "|locals=" ++ Body.observe_left(ll) ++ "," ++ Body.observe_right(rl) ++ "," ++ Body.observe_left(ol) ++ "|cursors=" ++ Tick.cursor_show(lc) ++ "," ++ Tick.cursor_show(rc) ++ "," ++ Tick.cursor_show(oc) ++ "|handler=" ++ Common.handler(handler) ++ "|guard=" ++ Cond.observed(gl) ++ "|guard-cursor=" ++ Tick.cursor_show(gc) ++ "|released=" ++ U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,text,access)
def cleaned(~S:Data,trace:String,ll:Body.LeftLocal(),ol:Body.LeftLocal(),lc:Maybe<&2,Tick.Tick>,oc:Maybe<&2,Tick.Tick>,gl:Cond.Local(),gc:Maybe<&2,Tick.Tick>,handler:Common.Handler,result:Life.Retirement<World(~S),Nodes.RightNode(~S)>) -> String:
  match result:
    case Life.Retired{world,Life.Detached{right}}:released(~S,trace,ll,ol,lc,oc,gl,gc,handler,world,Nodes.right_returned(~S,right))
    case Life.RetirementRefused{_,_}:"ERROR:cleanup"
def observed_locals(~S:Data,trace:String,world:World(~S),right:Nodes.RightNode(~S),guard:GuardOwner(~S),handler:Common.Handler,left:Nodes.LeftReturned(~S),other:Nodes.LeftReturned(~S)) -> String:
  match guard left other:
    case Sys.Owner{_,_,_,_,gc,gl} NodeLife.Released{_,_,Life.Identity{_,_,_,_,lc},ll} NodeLife.Released{_,_,Life.Identity{_,_,_,_,oc},ol}:cleaned(~S,trace,ll,ol,lc,oc,gl,gc,handler,Nodes.retire(~S,right,world))
def observed(~S:Data,trace:String,app:Application(~S)) -> String:
  match app:
    case Schedule.Scheduled{DepApp.State{General.Present{world,_},Product.Owner{Product.Owner{left,other},right},guard,handler,_},_,_,_,_}:observed_locals(~S,trace,world,right,guard,handler,Nodes.left_returned(~S,left),Nodes.left_returned(~S,other))
    case _:"ERROR:physical-inventory"
def run_mode(~S:Data,~native:Bool,app:Application(~S)) -> IO(Application(~S) & DepApp.Report<String,String>):
  General.run(~S,~Nodes.components(),~D.resources_layout(),~Unit,~Nodes.Nodes(~S),~GuardOwner(~S),~Common.Handler,~String,~String,~Nodes.dispatch(~S,native),~Conditions.leaf_dispatch(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Cond.Ops(~S),~Cond.Local(),~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~Cond.Ops(~S),~Cond.declaration(~S)),~Cond.body(~S)),~Common.handle,~Nodes.publish(~S),app)
def run_selected(~S:Data,native:Bool,app:Application(~S)) -> IO(Application(~S) & DepApp.Report<String,String>):
  match native:
    case False{}:run_mode(~S,~False{},app)
    case True{}:run_mode(~S,~True{},app)
type Remainder<-S:Data> is Type:
  Remainder{left:Nodes.LeftTree(~S),guard:GuardOwner(~S),handler:Common.Handler,stateBindings:List<&2,DepApp.Binding>,plan:Plan.Build<String>,bindings:List<&2,DepApp.Binding>,rules:Part.Rules,deferred:Schedule.Deferred,displaced:List<&1,QuerySchema.displacements(~S,Nodes.components())>}
def rebuild(~S:Data,remainder:Remainder<S>,world:World(~S),right:Nodes.RightNode(~S)) -> Application(~S):
  match remainder:
    case Remainder{left,guard,handler,stateBindings,plan,bindings,rules,deferred,displaced}:Schedule.Scheduled{DepApp.State{General.Present{world,displaced},Product.Owner{left,right},guard,handler,stateBindings},plan,bindings,rules,deferred}
def identity_returned(~S:Data,returned:Nodes.RightReturned(~S)) -> Nodes.RightNode(~S) & String:
  match returned:
    case NodeLife.Released{compilation,cache,Life.Identity{+namespace,+id,+name,+access,+cursor},local}:(Nodes.right_rebuild(~S,NodeLife.Released{compilation,cache,Life.Identity{namespace,id,name,access,cursor},local}),U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,text,access) ++ ":" ++ Tick.cursor_show(cursor))
def identity(~S:Data,right:Nodes.RightNode(~S)) -> Nodes.RightNode(~S) & String:
  identity_returned(~S,Nodes.right_returned(~S,right))
def identified_app(~S:Data,status:String,remainder:Remainder<S>,world:World(~S),result:Nodes.RightNode(~S) & String) -> Application(~S) & String:
  match result:
    case (right,identity):(rebuild(~S,remainder,world,right),status ++ "=" ++ identity)
def retired_app(~S:Data,remainder:Remainder<S>,result:Life.Retirement<World(~S),Nodes.RightNode(~S)>) -> Application(~S) & String:
  match result:
    case Life.Retired{world,Life.Detached{right}}:identified_app(~S,"retired",remainder,world,identity(~S,right))
    case Life.RetirementRefused{world,right}:(rebuild(~S,remainder,world,right),"ERROR:retirement")
def detach(~S:Data,app:Application(~S)) -> Application(~S) & String:
  match app:
    case Schedule.Scheduled{DepApp.State{General.Present{world,displaced},Product.Owner{left,right},guard,handler,stateBindings},plan,bindings,rules,deferred}:retired_app(~S,Remainder{left,guard,handler,stateBindings,plan,bindings,rules,deferred,displaced},Nodes.retire(~S,right,world))
    case app:(app,"ERROR:retirement-inventory")
def restored_app(~S:Data,remainder:Remainder<S>,result:NodeLife.Reregistration<World(~S),Nodes.RightNode(~S),Nodes.RightReturned(~S)>) -> Application(~S) & String:
  match result:
    case NodeLife.Reregistered{world,right}:identified_app(~S,"restored",remainder,world,identity(~S,right))
    case NodeLife.ReregistrationRefused{world,returned}:(rebuild(~S,remainder,world,Nodes.right_rebuild(~S,returned)),"ERROR:restoration")
def restore(~S:Data,app:Application(~S)) -> Application(~S) & String:
  match app:
    case Schedule.Scheduled{DepApp.State{General.Present{world,displaced},Product.Owner{left,right},guard,handler,stateBindings},plan,bindings,rules,deferred}:restored_app(~S,Remainder{left,guard,handler,stateBindings,plan,bindings,rules,deferred,displaced},Nodes.reregister(~S,Nodes.right_returned(~S,right),world))
    case app:(app,"ERROR:restoration-inventory")
def fifth(~S:Data,trace:String,result:Application(~S) & DepApp.Report<String,String>) -> String:
  match result:
    case (app,status):observed(~S,trace ++ "|" ++ report(status),app)
def reregistered(~S:Data,native:Bool,trace:String,result:Application(~S) & String) -> IO(String):
  match result:
    case (app,status):IO.bind(Application(~S) & DepApp.Report<String,String>,String,run_selected(~S,native,app),next => IO.pure(String,fifth(~S,trace ++ "|" ++ status,next)))
def fourth(~S:Data,native:Bool,trace:String,result:Application(~S) & DepApp.Report<String,String>) -> IO(String):
  match result:
    case (app,status):reregistered(~S,native,trace ++ "|" ++ report(status),restore(~S,app))
def detached(~S:Data,+native:Bool,trace:String,result:Application(~S) & String) -> IO(String):
  match result:
    case (app,status):IO.bind(Application(~S) & DepApp.Report<String,String>,String,run_selected(~S,native,app),next => fourth(~S,native,trace ++ "|" ++ status,next))
def third(~S:Data,native:Bool,trace:String,result:Application(~S) & DepApp.Report<String,String>) -> IO(String):
  match result:
    case (app,status):detached(~S,native,trace ++ "|" ++ report(status),detach(~S,app))
def second(~S:Data,+native:Bool,trace:String,result:Application(~S) & DepApp.Report<String,String>) -> IO(String):
  match result:
    case (app,status):IO.bind(Application(~S) & DepApp.Report<String,String>,String,run_selected(~S,native,app),next => third(~S,native,trace ++ "|" ++ report(status),next))
def first(~S:Data,+native:Bool,result:Application(~S) & DepApp.Report<String,String>) -> IO(String):
  match result:
    case (app,status):IO.bind(Application(~S) & DepApp.Report<String,String>,String,run_selected(~S,native,app),next => second(~S,native,report(status),next))
def guard_defined(~S:Data,+native:Bool,left:Nodes.LeftNode(~S),right:Nodes.RightNode(~S),other:Nodes.LeftNode(~S),result:Sys.Defined<World(~S),GuardOwner(~S),Cond.Local()>) -> IO(String):
  match result:
    case Sys.Defined{world,guard}:IO.bind(Application(~S) & DepApp.Report<String,String>,String,run_selected(~S,native,General.build(~S,~Nodes.components(),~D.resources_layout(),~Unit,~Nodes.Nodes(~S),~GuardOwner(~S),~Common.Handler,~String,~Conditions.leaf_dispatch(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Cond.Ops(~S),~Cond.Local(),~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~Cond.Ops(~S),~Cond.declaration(~S)),~Cond.body(~S)),~Common.available,world,Nodes.facts(~S,Product.Owner{Product.Owner{left,other},right}),Conditions.compile_leaf(~String,~S,~D.Store(~S),~D.Resources(~S),~Unit,~Cond.Ops(~S),~Cond.Local(),~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~Cond.Ops(~S),~Cond.declaration(~S)),~Cond.body(~S),guard),Common.Handler{ALeaf{701},0},[Plan.Edge{1,2},Plan.Edge{3,2}],[DepApp.Binding{2,4}])),next => first(~S,native,next))
    case Sys.DefinitionRefused{_,_}:IO.pure(String,"ERROR:guard")
def other_defined(~S:Data,+native:Bool,left:Nodes.LeftNode(~S),right:Nodes.RightNode(~S),result:Nodes.LeftCompilation(~S) & Sys.Defined<World(~S),Nodes.LeftOwner(~S),Body.LeftLocal()>) -> IO(String):
  match result:
    case (compilation,Sys.Defined{world,other}):guard_defined(~S,native,left,right,Nodes.left_node(~S,compilation,other),Sys.define(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Cond.Ops(~S),~Cond.Local(),~String,~Bool,~Cond.declaration(~S),~Cond.body(~S),world,"guard",Cond.local()))
    case (_,Sys.DefinitionRefused{_,_}):IO.pure(String,"ERROR:other")
def right_defined(~S:Data,+native:Bool,left:Nodes.LeftNode(~S),result:Nodes.RightCompilation(~S) & Sys.Defined<World(~S),Nodes.RightOwner(~S),Body.RightLocal()>) -> IO(String):
  match result:
    case (compilation,Sys.Defined{world,right}):other_defined(~S,native,left,Nodes.right_node(~S,compilation,right),Nodes.define_left(~S,world,"other",Body.left_local(801,203)))
    case (_,Sys.DefinitionRefused{_,_}):IO.pure(String,"ERROR:right")
def left_defined(~S:Data,native:Bool,result:Nodes.LeftCompilation(~S) & Sys.Defined<World(~S),Nodes.LeftOwner(~S),Body.LeftLocal()>) -> IO(String):
  match result:
    case (compilation,Sys.Defined{world,left}):right_defined(~S,native,Nodes.left_node(~S,compilation,left),Nodes.define_right(~S,world,"right",Body.right_local()))
    case (_,Sys.DefinitionRefused{_,_}):IO.pure(String,"ERROR:left")
def created(~S:Data,native:Bool,result:W.Creation<S,D.Store(~S),D.Resources(~S),Unit>) -> IO(String):
  match result:
    case W.Created{_,world}:left_defined(~S,native,Nodes.define_left(~S,world,"left",Body.left_local(501,201)))
    case W.CreateRejected{_,_}:IO.pure(String,"ERROR:create")
def run(~S:Data,native:Bool) -> IO(String):
  created(~S,native,W.create(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.empty(~S),W.factory(),D.resources(~S)))
type SchemaA is Data:
  SchemaA{}
type SchemaB is Data:
  SchemaB{}
def main() -> IO(Unit):
  IO.bind(String,Unit,run(~SchemaA,False{}),aSerial => IO.bind(String,Unit,run(~SchemaA,True{}),aNative => IO.bind(String,Unit,run(~SchemaB,False{}),bSerial => IO.bind(String,Unit,run(~SchemaB,True{}),bNative => IO.print("A-serial=" ++ aSerial ++ "\nA-native=" ++ aNative ++ "\nB-serial=" ++ bSerial ++ "\nB-native=" ++ bNative)))))

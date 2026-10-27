import Base
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-system-lifecycle.bend as Life
import ../../src/ecs/execution-parallel-registration.bend as Part
import ./conditions.bend as Cond
import ../../src/ecs/dependency-plan.bend as Plan
import ./declarations.bend as D
import ./bodies.bend as Body
import ./observe.bend as Observe
import ./reports.bend as Common
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-parallel-system.bend as Task
import ../../src/ecs/execution-parallel-app.bend as Pair
import ../../src/ecs/execution-parallel-rootcut.bend as Root
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/execution-parallel-scope-registry.bend as Tree
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ../../src/ecs/dependency-application.bend as DepApp
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/change-tick.bend as Tick
def GuardOwner(~S:Data) -> Type:Sys.Owner<S,D.Store(~S),D.Store(~S),D.Resources(~S),Unit,Cond.Ops(~S),Cond.Local(),String,Bool,Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~Cond.Ops(~S),~Cond.declaration(~S)),Cond.body(~S)>
def World(~S:Data) -> Type:W.World<S,D.Store(~S),D.Resources(~S),Unit>
def LeftOwner(~S:Data) -> Type:Sys.Owner<S,D.Store(~S),D.LeftStore(~S),D.LeftResource(~S),Unit,D.LeftOps(~S),Body.LeftLocal(),String,String,Build.framework_program(~S,~D.Store(~S),~D.LeftStore(~S),~D.LeftResource(~S),~D.LeftOps(~S),~D.left(~S)),Body.left(~S)>
def RightOwner(~S:Data) -> Type:Sys.Owner<S,D.Store(~S),D.RightStore(~S),D.RightResource(~S),Unit,D.RightOps(~S),Body.RightLocal(),String,String,Build.framework_program(~S,~D.Store(~S),~D.RightStore(~S),~D.RightResource(~S),~D.RightOps(~S),~D.right(~S)),Body.right(~S)>
def LeftTree(~S:Data) -> Type:Product.Owner<LeftOwner(~S),LeftOwner(~S)>
def left_tree(~S:Data,~F:Tree.Family(),~leaf:Tree.Leaf(~S,~D.Store(~S),~D.LeftStore(~S),~D.LeftResource(~S),~Unit,~String,~String,~F),~command:Tree.CommandLeaf(~S,~D.Store(~S),~D.LeftStore(~S),~D.LeftResource(~S),~Unit,~String,~String,~F),~join:Tree.Join(~F),owners:LeftTree(~S)) -> F(LeftTree(~S)):
  match owners:
    case Product.Owner{left,other}:join(LeftOwner(~S),LeftOwner(~S),leaf(D.LeftOps(~S),Body.LeftLocal(),Build.framework_program(~S,~D.Store(~S),~D.LeftStore(~S),~D.LeftResource(~S),~D.LeftOps(~S),~D.left(~S)),Body.left(~S),left),leaf(D.LeftOps(~S),Body.LeftLocal(),Build.framework_program(~S,~D.Store(~S),~D.LeftStore(~S),~D.LeftResource(~S),~D.LeftOps(~S),~D.left(~S)),Body.left(~S),other))
def right_tree(~S:Data,~F:Tree.Family(),~leaf:Tree.Leaf(~S,~D.Store(~S),~D.RightStore(~S),~D.RightResource(~S),~Unit,~String,~String,~F),~command:Tree.CommandLeaf(~S,~D.Store(~S),~D.RightStore(~S),~D.RightResource(~S),~Unit,~String,~String,~F),~join:Tree.Join(~F),owner:RightOwner(~S)) -> F(RightOwner(~S)):
  leaf(D.RightOps(~S),Body.RightLocal(),Build.framework_program(~S,~D.Store(~S),~D.RightStore(~S),~D.RightResource(~S),~D.RightOps(~S),~D.right(~S)),Body.right(~S),owner)
def Application(~S:Data) -> Type:Schedule.Scheduled<DepApp.State<World(~S),Product.Owner<LeftTree(~S),RightOwner(~S)>,GuardOwner(~S),Common.Handler>>
def report(value:DepApp.Report<String,String>) -> String:Common.report(value)
def text(value:String) -> String:value
def released(~S:Data,trace:String,ll:Body.LeftLocal(),ol:Body.LeftLocal(),lc:Maybe<&2,Tick.Tick>,oc:Maybe<&2,Tick.Tick>,gl:Cond.Local(),gc:Maybe<&2,Tick.Tick>,handler:Common.Handler,world:World(~S),result:Life.Released<Body.RightLocal()>) -> String:
  match result:
    case Life.Released{Life.Identity{namespace,id,name,access,rc},rl}:trace ++ "|world=" ++ Observe.world(~S,world) ++ "|locals=" ++ Body.observe_left(ll) ++ "," ++ Body.observe_right(rl) ++ "," ++ Body.observe_left(ol) ++ "|cursors=" ++ Tick.cursor_show(lc) ++ "," ++ Tick.cursor_show(rc) ++ "," ++ Tick.cursor_show(oc) ++ "|handler=" ++ Common.handler(handler) ++ "|guard=" ++ Cond.observed(gl) ++ "|guard-cursor=" ++ Tick.cursor_show(gc) ++ "|released=" ++ U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,text,access)
def cleaned(~S:Data,trace:String,ll:Body.LeftLocal(),ol:Body.LeftLocal(),lc:Maybe<&2,Tick.Tick>,oc:Maybe<&2,Tick.Tick>,gl:Cond.Local(),gc:Maybe<&2,Tick.Tick>,handler:Common.Handler,result:Life.Retirement<World(~S),RightOwner(~S)>) -> String:
  match result:
    case Life.Retired{world,detached}:released(~S,trace,ll,ol,lc,oc,gl,gc,handler,world,Life.release(~S,~D.Store(~S),~D.RightStore(~S),~D.RightResource(~S),~Unit,~D.RightOps(~S),~Body.RightLocal(),~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.RightStore(~S),~D.RightResource(~S),~D.RightOps(~S),~D.right(~S)),~Body.right(~S),detached))
    case Life.RetirementRefused{_,_}:"ERROR:cleanup"
def observed(~S:Data,trace:String,app:Application(~S)) -> String:
  match app:
    case Schedule.Scheduled{DepApp.State{world,Product.Owner{Product.Owner{Sys.Owner{_,_,_,_,lc,ll},Sys.Owner{_,_,_,_,oc,ol}},right},Sys.Owner{_,_,_,_,gc,gl},handler,_},_,_,_,_}:cleaned(~S,trace,ll,ol,lc,oc,gl,gc,handler,Life.retire(~S,~D.Store(~S),~D.RightStore(~S),~D.RightResource(~S),~Unit,~D.RightOps(~S),~Body.RightLocal(),~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.RightStore(~S),~D.RightResource(~S),~D.RightOps(~S),~D.right(~S)),~Body.right(~S),~D.Resources(~S),~Unit,right,world))
def run_selected(~S:Data,native:Bool,app:Application(~S)) -> IO(Application(~S) & DepApp.Report<String,String>):
  match native:
    case False{}:Schedule.run_serial(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.LeftResource(~S),~D.RightResource(~S),~Unit,~String,~String,~LeftTree(~S),~RightOwner(~S),~left_tree(~S),~right_tree(~S),~GuardOwner(~S),~Common.Handler,~Conditions.leaf_dispatch(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Cond.Ops(~S),~Cond.Local(),~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~Cond.Ops(~S),~Cond.declaration(~S)),~Cond.body(~S)),~Conditions.leaf(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Cond.Ops(~S),~Cond.Local(),~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~Cond.Ops(~S),~Cond.declaration(~S)),~Cond.body(~S)),~Common.handle,app)
    case True{}:Schedule.run_native(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.LeftResource(~S),~D.RightResource(~S),~Unit,~String,~String,~LeftTree(~S),~RightOwner(~S),~left_tree(~S),~right_tree(~S),~GuardOwner(~S),~Common.Handler,~Conditions.leaf_dispatch(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Cond.Ops(~S),~Cond.Local(),~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~Cond.Ops(~S),~Cond.declaration(~S)),~Cond.body(~S)),~Conditions.leaf(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Cond.Ops(~S),~Cond.Local(),~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~Cond.Ops(~S),~Cond.declaration(~S)),~Cond.body(~S)),~Common.handle,app)
type Remainder<-S:Data> is Type:
  Remainder{left:LeftTree(S),guard:GuardOwner(S),handler:Common.Handler,stateBindings:List<&2,DepApp.Binding>,plan:Plan.Build<String>,bindings:List<&2,DepApp.Binding>,rules:Part.Rules,deferred:Schedule.Deferred}
def rebuild(~S:Data,remainder:Remainder<S>,world:World(~S),right:RightOwner(~S)) -> Application(~S):
  match remainder:
    case Remainder{left,guard,handler,stateBindings,plan,bindings,rules,deferred}:Schedule.Scheduled{DepApp.State{world,Product.Owner{left,right},guard,handler,stateBindings},plan,bindings,rules,deferred}
def identity(~S:Data,right:RightOwner(~S)) -> RightOwner(~S) & String:
  match right:
    case Sys.Owner{+namespace,+id,+name,+access,+cursor,local}:(Sys.Owner{namespace,id,name,access,cursor,local},U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,text,access) ++ ":" ++ Tick.cursor_show(cursor))
def identified_app(~S:Data,status:String,remainder:Remainder<S>,world:World(~S),result:RightOwner(~S) & String) -> Application(~S) & String:
  match result:
    case (right,identity):(rebuild(~S,remainder,world,right),status ++ "=" ++ identity)
def retired_app(~S:Data,remainder:Remainder<S>,result:Life.Retirement<World(~S),RightOwner(~S)>) -> Application(~S) & String:
  match result:
    case Life.Retired{world,Life.Detached{right}}:identified_app(~S,"retired",remainder,world,identity(~S,right))
    case Life.RetirementRefused{world,right}:(rebuild(~S,remainder,world,right),"ERROR:retirement")
def detach(~S:Data,app:Application(~S)) -> Application(~S) & String:
  match app:
    case Schedule.Scheduled{DepApp.State{world,Product.Owner{left,right},guard,handler,stateBindings},plan,bindings,rules,deferred}:retired_app(~S,Remainder{left,guard,handler,stateBindings,plan,bindings,rules,deferred},Life.retire(~S,~D.Store(~S),~D.RightStore(~S),~D.RightResource(~S),~Unit,~D.RightOps(~S),~Body.RightLocal(),~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.RightStore(~S),~D.RightResource(~S),~D.RightOps(~S),~D.right(~S)),~Body.right(~S),~D.Resources(~S),~Unit,right,world))
def restored_app(~S:Data,remainder:Remainder<S>,result:Life.Restoration<World(~S),RightOwner(~S)>) -> Application(~S) & String:
  match result:
    case Life.Restored{world,right}:identified_app(~S,"restored",remainder,world,identity(~S,right))
    case Life.RestorationRefused{world,Life.Detached{right}}:(rebuild(~S,remainder,world,right),"ERROR:restoration")
def restore(~S:Data,app:Application(~S)) -> Application(~S) & String:
  match app:
    case Schedule.Scheduled{DepApp.State{world,Product.Owner{left,right},guard,handler,stateBindings},plan,bindings,rules,deferred}:restored_app(~S,Remainder{left,guard,handler,stateBindings,plan,bindings,rules,deferred},Life.restore(~S,~D.Store(~S),~D.RightStore(~S),~D.RightResource(~S),~Unit,~D.RightOps(~S),~Body.RightLocal(),~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.RightStore(~S),~D.RightResource(~S),~D.RightOps(~S),~D.right(~S)),~Body.right(~S),~D.Resources(~S),~Unit,Life.Detached{right},world))
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
def guard_defined(~S:Data,+native:Bool,left:LeftOwner(~S),right:RightOwner(~S),other:LeftOwner(~S),result:Sys.Defined<World(~S),GuardOwner(~S),Cond.Local()>) -> IO(String):
  match result:
    case Sys.Defined{world,guard}:IO.bind(Application(~S) & DepApp.Report<String,String>,String,run_selected(~S,native,Schedule.build(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.LeftResource(~S),~D.RightResource(~S),~Unit,~String,~String,~LeftTree(~S),~RightOwner(~S),~left_tree(~S),~right_tree(~S),~GuardOwner(~S),~Common.Handler,~Conditions.leaf_dispatch(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Cond.Ops(~S),~Cond.Local(),~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~Cond.Ops(~S),~Cond.declaration(~S)),~Cond.body(~S)),~Conditions.leaf(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Cond.Ops(~S),~Cond.Local(),~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~Cond.Ops(~S),~Cond.declaration(~S)),~Cond.body(~S)),~Common.handle,~Common.available,world,Product.Owner{Product.Owner{left,other},right},guard,Common.Handler{ALeaf{701},0},[Plan.Edge{1,2},Plan.Edge{3,2}],[DepApp.Binding{2,4}])),next => first(~S,native,next))
    case Sys.DefinitionRefused{_,_}:IO.pure(String,"ERROR:guard")
def other_defined(~S:Data,+native:Bool,left:LeftOwner(~S),right:RightOwner(~S),result:Sys.Defined<World(~S),LeftOwner(~S),Body.LeftLocal()>) -> IO(String):
  match result:
    case Sys.Defined{world,other}:guard_defined(~S,native,left,right,other,Sys.define(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Cond.Ops(~S),~Cond.Local(),~String,~Bool,~Cond.declaration(~S),~Cond.body(~S),world,"guard",Cond.local()))
    case Sys.DefinitionRefused{_,_}:IO.pure(String,"ERROR:other")
def registered(~S:Data,native:Bool,result:Pair.Definition<World(~S),LeftOwner(~S),RightOwner(~S),Body.LeftLocal(),Body.RightLocal()>) -> IO(String):
  match result:
    case Pair.Defined{Pair.ParallelApp{world,left,right}}:other_defined(~S,native,left,right,Task.define(~S,~D.Store(~S),~D.LeftStore(~S),~D.LeftResource(~S),~Unit,~D.LeftOps(~S),~Body.LeftLocal(),~String,~String,~D.left(~S),~Body.left(~S),~D.Resources(~S),world,"other",Body.left_local(801,203)))
    case Pair.LeftRefused{_,_,_}:IO.pure(String,"ERROR:left")
    case Pair.RightRefused{_,_,_}:IO.pure(String,"ERROR:right")
def created(~S:Data,native:Bool,result:W.Creation<S,D.Store(~S),D.Resources(~S),Unit>) -> IO(String):
  match result:
    case W.Created{_,world}:registered(~S,native,Pair.define(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.LeftResource(~S),~D.RightResource(~S),~Unit,~Body.LeftLocal(),~Body.RightLocal(),~String,~String,~String,~String,~D.LeftOps(~S),~D.RightOps(~S),~D.left(~S),~D.right(~S),~Body.left(~S),~Body.right(~S),world,"left","right",Body.left_local(501,201),Body.right_local()))
    case W.CreateRejected{_,_}:IO.pure(String,"ERROR:create")
def run(~S:Data,native:Bool) -> IO(String):
  created(~S,native,W.create(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.empty(~S),W.factory(),D.resources(~S)))
type SchemaA is Data:
  SchemaA{}
type SchemaB is Data:
  SchemaB{}
def main() -> IO(Unit):
  IO.bind(String,Unit,run(~SchemaA,False{}),aSerial => IO.bind(String,Unit,run(~SchemaA,True{}),aNative => IO.bind(String,Unit,run(~SchemaB,False{}),bSerial => IO.bind(String,Unit,run(~SchemaB,True{}),bNative => IO.print("A-serial=" ++ aSerial ++ "\nA-native=" ++ aNative ++ "\nB-serial=" ++ bSerial ++ "\nB-native=" ++ bNative)))))

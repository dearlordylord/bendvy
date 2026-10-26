import Base
import ./conditions.bend as Cond
import ./declarations.bend as D
import ./bodies.bend as Body
import ./observe.bend as Observe
import ./scheduled.bend as Common
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-parallel-system.bend as Task
import ../../src/ecs/execution-parallel-app.bend as Pair
import ../../src/ecs/execution-parallel-rootcut.bend as Root
import ../../src/ecs/execution-parallel-root-application.bend as Schedule
import ../../src/ecs/execution-parallel-scope-registry.bend as Tree
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/dependency-registry-program.bend as Prog
import ../../src/ecs/dependency-application.bend as DepApp
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/change-tick.bend as Tick
def GuardOwner(~S:Data) -> Type:Sys.Owner<S,D.Store(~S),D.Resources(~S),Unit,Cond.Ops(~S),Cond.Local<S>,String,Bool,Cond.declaration(~S),Cond.body(~S)>
def World(~S:Data) -> Type:W.World<S,D.Store(~S),D.Resources(~S),Unit>
def LeftOwner(~S:Data) -> Type:Sys.Owner<S,D.LeftStore(~S),D.LeftResource(~S),Unit,D.LeftOps(~S),Body.Local<S>,String,String,D.left(~S),Body.left(~S)>
def RightOwner(~S:Data) -> Type:Sys.Owner<S,D.RightStore(~S),D.RightResource(~S),Unit,D.RightOps(~S),Body.Local<S>,String,String,D.right(~S),Body.right(~S)>
def LeftTree(~S:Data) -> Type:Product.Owner<LeftOwner(~S),LeftOwner(~S)>
def left_tree(~S:Data,~F:Tree.Family(),~leaf:Tree.Leaf(~S,~D.Store(~S),~D.LeftStore(~S),~D.LeftResource(~S),~Unit,~String,~String,~F),~command:Tree.CommandLeaf(~S,~D.Store(~S),~D.LeftStore(~S),~D.LeftResource(~S),~Unit,~String,~String,~F),~join:Tree.Join(~F),owners:LeftTree(~S)) -> F(LeftTree(~S)):
  match owners:
    case Product.Owner{left,other}:join(LeftOwner(~S),LeftOwner(~S),leaf(D.LeftOps(~S),Body.Local<S>,D.left(~S),Body.left(~S),left),leaf(D.LeftOps(~S),Body.Local<S>,D.left(~S),Body.left(~S),other))
def right_tree(~S:Data,~F:Tree.Family(),~leaf:Tree.Leaf(~S,~D.Store(~S),~D.RightStore(~S),~D.RightResource(~S),~Unit,~String,~String,~F),~command:Tree.CommandLeaf(~S,~D.Store(~S),~D.RightStore(~S),~D.RightResource(~S),~Unit,~String,~String,~F),~join:Tree.Join(~F),owner:RightOwner(~S)) -> F(RightOwner(~S)):
  leaf(D.RightOps(~S),Body.Local<S>,D.right(~S),Body.right(~S),owner)
def Application(~S:Data) -> Type:Schedule.Scheduled<DepApp.Application<W.World<S,D.Store(~S),D.Resources(~S),Unit>,Product.Owner<LeftTree(~S),RightOwner(~S)>,GuardOwner(~S),Common.Handler,String,String,Root.dispatch(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.LeftResource(~S),~D.RightResource(~S),~Unit,~String,~String,~LeftTree(~S),~RightOwner(~S),~left_tree(~S),~right_tree(~S)),Reg.leaf_dispatch(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Cond.Ops(~S),~Cond.Local<S>,~String,~Bool,~Cond.declaration(~S),~Cond.body(~S)),Common.handle>>
def report(value:DepApp.Report<String,String>) -> String:
  match value:
    case DepApp.Finished{+events}:"[" ++ Common.event_for(1,events) ++ ", " ++ Common.event_for(2,events) ++ ", " ++ Common.event_for(3,events) ++ "]"
    case DepApp.Stopped{_,events}:"stopped" ++ List.show(&2,Exec.Observation<String,String>,Common.event,events)
    case DepApp.Invalid{_}:"invalid"
def observed(~S:Data,trace:String,app:Application(~S)) -> String:
  match app:
    case Schedule.Scheduled{DepApp.Application{DepApp.State{world,Product.Owner{Product.Owner{Sys.Owner{_,_,_,_,lc,ll},Sys.Owner{_,_,_,_,oc,ol}},Sys.Owner{_,_,_,_,rc,rl}},Sys.Owner{_,_,_,_,gc,gl},handler,_},_,_},_,_}:trace ++ "|world=" ++ Observe.world(~S,world) ++ "|locals=" ++ Observe.local(~S,ll) ++ "," ++ Observe.local(~S,rl) ++ "," ++ Observe.local(~S,ol) ++ "|cursors=" ++ Tick.cursor_show(lc) ++ "," ++ Tick.cursor_show(rc) ++ "," ++ Tick.cursor_show(oc) ++ "|handler=" ++ Common.handler(handler) ++ "|guard=" ++ Cond.observed(~S,gl) ++ "|guard-cursor=" ++ Tick.cursor_show(gc)
def run_selected(~S:Data,native:Bool,app:Application(~S)) -> Application(~S) & DepApp.Report<String,String>:
  match native:
    case False{}:Schedule.run_serial(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.LeftResource(~S),~D.RightResource(~S),~Unit,~String,~String,~LeftTree(~S),~RightOwner(~S),~left_tree(~S),~right_tree(~S),~GuardOwner(~S),~Common.Handler,~Reg.leaf_dispatch(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Cond.Ops(~S),~Cond.Local<S>,~String,~Bool,~Cond.declaration(~S),~Cond.body(~S)),~Prog.leaf(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Cond.Ops(~S),~Cond.Local<S>,~String,~Bool,~Cond.declaration(~S),~Cond.body(~S)),~Common.handle,app)
    case True{}:Schedule.run_native(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.LeftResource(~S),~D.RightResource(~S),~Unit,~String,~String,~LeftTree(~S),~RightOwner(~S),~left_tree(~S),~right_tree(~S),~GuardOwner(~S),~Common.Handler,~Reg.leaf_dispatch(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Cond.Ops(~S),~Cond.Local<S>,~String,~Bool,~Cond.declaration(~S),~Cond.body(~S)),~Prog.leaf(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Cond.Ops(~S),~Cond.Local<S>,~String,~Bool,~Cond.declaration(~S),~Cond.body(~S)),~Common.handle,app)
def third(~S:Data,trace:String,result:Application(~S) & DepApp.Report<String,String>) -> String:
  match result:
    case (app,status):observed(~S,trace ++ "|" ++ report(status),app)
def second(~S:Data,native:Bool,trace:String,result:Application(~S) & DepApp.Report<String,String>) -> String:
  match result:
    case (app,status):third(~S,trace ++ "|" ++ report(status),run_selected(~S,native,app))
def first(~S:Data,+native:Bool,result:Application(~S) & DepApp.Report<String,String>) -> String:
  match result:
    case (app,status):second(~S,native,report(status),run_selected(~S,native,app))
def guard_defined(~S:Data,+native:Bool,left:LeftOwner(~S),right:RightOwner(~S),other:LeftOwner(~S),result:Sys.Defined<World(~S),GuardOwner(~S),Cond.Local<S>>) -> String:
  match result:
    case Sys.Defined{world,guard}:first(~S,native,run_selected(~S,native,Schedule.build(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.LeftResource(~S),~D.RightResource(~S),~Unit,~String,~String,~LeftTree(~S),~RightOwner(~S),~left_tree(~S),~right_tree(~S),~GuardOwner(~S),~Common.Handler,~Reg.leaf_dispatch(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Cond.Ops(~S),~Cond.Local<S>,~String,~Bool,~Cond.declaration(~S),~Cond.body(~S)),~Prog.leaf(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Cond.Ops(~S),~Cond.Local<S>,~String,~Bool,~Cond.declaration(~S),~Cond.body(~S)),~Common.handle,~Common.available,world,Product.Owner{Product.Owner{left,other},right},guard,Common.Handler{ALeaf{701},0},[],[DepApp.Binding{2,4}])))
    case Sys.DefinitionRefused{_,_}:"ERROR:guard"
def other_defined(~S:Data,+native:Bool,handle:W.Handle<S>,left:LeftOwner(~S),right:RightOwner(~S),result:Sys.Defined<World(~S),LeftOwner(~S),Body.Local<S>>) -> String:
  match result:
    case Sys.Defined{world,other}:guard_defined(~S,native,left,right,other,Sys.define(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Cond.Ops(~S),~Cond.Local<S>,~String,~Bool,~Cond.declaration(~S),~Cond.body(~S),world,"guard",Cond.Local{ALeaf{901},0,"unset",handle}))
    case Sys.DefinitionRefused{_,_}:"ERROR:other"
def registered(~S:Data,native:Bool,+handle:W.Handle<S>,result:Pair.Definition<World(~S),LeftOwner(~S),RightOwner(~S),Body.Local<S>,Body.Local<S>>) -> String:
  match result:
    case Pair.Defined{Pair.ParallelApp{world,left,right}}:other_defined(~S,native,handle,left,right,Task.define(~S,~D.LeftStore(~S),~D.LeftResource(~S),~Unit,~D.LeftOps(~S),~Body.Local<S>,~String,~String,~D.left(~S),~Body.left(~S),~D.Store(~S),~D.Resources(~S),world,"other",Body.Local{ALeaf{801},0,handle}))
    case Pair.LeftRefused{_,_,_}:"ERROR:left"
    case Pair.RightRefused{_,_,_}:"ERROR:right"
def activated(~S:Data,native:Bool,+handle:W.Handle<S>,result:World(~S) & W.Status) -> String:
  match result:
    case (world,W.Accepted{}):registered(~S,native,handle,Pair.define(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.LeftResource(~S),~D.RightResource(~S),~Unit,~Body.Local<S>,~Body.Local<S>,~String,~String,~String,~String,~D.LeftOps(~S),~D.RightOps(~S),~D.left(~S),~D.right(~S),~Body.left(~S),~Body.right(~S),world,"left","right",Body.Local{ALeaf{501},0,handle},Body.Local{ALeaf{601},0,handle}))
    case (_,_):"ERROR:activate"
def reserved(~S:Data,native:Bool,result:World(~S) & W.Reservation<S>) -> String:
  match result:
    case (world,W.Reserved{+handle}):activated(~S,native,handle,W.activate(~S,~D.Store(~S),~D.Resources(~S),~Unit,world,handle))
    case (_,_):"ERROR:reserve"
def created(~S:Data,native:Bool,result:W.Creation<S,D.Store(~S),D.Resources(~S),Unit>) -> String:
  match result:
    case W.Created{_,world}:reserved(~S,native,W.reserve_id(~S,~D.Store(~S),~D.Resources(~S),~Unit,world))
    case W.CreateRejected{_,_}:"ERROR:create"
def run(~S:Data,native:Bool) -> String:
  created(~S,native,W.create(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.empty(~S),W.factory(),D.resources(~S)))
def main() -> IO(Unit):
  IO.print("A-serial=" ++ run(~Common.SchemaA,False{}) ++ "\nA-native=" ++ run(~Common.SchemaA,True{}) ++ "\nB-serial=" ++ run(~Common.SchemaB,False{}) ++ "\nB-native=" ++ run(~Common.SchemaB,True{}))

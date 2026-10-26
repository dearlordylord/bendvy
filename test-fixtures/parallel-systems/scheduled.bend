import Base
import ./declarations.bend as D
import ./bodies.bend as Body
import ./observe.bend as Observe
import ../../src/ecs/world.bend as W
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-parallel-app.bend as Pair
import ../../src/ecs/execution-parallel-application.bend as Schedule
import ../../src/ecs/execution-parallel-registration.bend as Part
import ../../src/ecs/dependency-application.bend as DepApp
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/dependency-registry-program.bend as Prog
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/change-tick.bend as Tick

type Handler is Type:
  Handler{token:Array<U32>,errors:U32}
def handle(owner:Handler,_:String) -> Handler & Exec.Handling:
  match owner:
    case Handler{token,errors}:(Handler{token,U32.add(errors,1)},Exec.Continue{})
def available(_:String) -> Bool:True{}
def event(value:Exec.Observation<String,String>) -> String:
  match value:
    case Exec.Ran{id,out}:U32.show(id) ++ "/success/" ++ out
    case Exec.BodyFailed{id,error,out}:U32.show(id) ++ "/error/" ++ error ++ "/" ++ out
    case Exec.Skipped{id}:U32.show(id) ++ "/disabled"
    case Exec.ConditionFailed{id,error}:U32.show(id) ++ "/condition-error/" ++ error
    case Exec.ConditionRejected{id}:U32.show(id) ++ "/condition-refused"
    case Exec.AdmissionRejected{id}:U32.show(id) ++ "/refused"
def event_id(value:Exec.Observation<String,String>) -> U32:
  match value:
    case Exec.Ran{id,_}:id
    case Exec.BodyFailed{id,_,_}:id
    case Exec.Skipped{id}:id
    case Exec.ConditionFailed{id,_}:id
    case Exec.ConditionRejected{id}:id
    case Exec.AdmissionRejected{id}:id
def event_selected(selected:Bool,value:Exec.Observation<String,String>,rest:String) -> String:
  match selected:
    case True{}:event(value)
    case False{}:rest
def event_for(+id:U32,values:List<&2,Exec.Observation<String,String>>) -> String:
  match values:
    case []:"missing"
    case +first <> rest:event_selected(U32.is_eq(id,event_id(first)),first,event_for(id,rest))
def report(value:DepApp.Report<String,String>) -> String:
  match value:
    case DepApp.Finished{+events}:"[" ++ event_for(1,events) ++ ", " ++ event_for(2,events) ++ "]"
    case DepApp.Stopped{_,events}:"stopped" ++ List.show(&2,Exec.Observation<String,String>,event,events)
    case DepApp.Invalid{_}:"invalid"
def handler_observed(errors:U32,result:Array<U32> & U32) -> String:
  match result:
    case (_,id):U32.show(id) ++ ":" ++ U32.show(errors)
def handler(owner:Handler) -> String:
  match owner:
    case Handler{token,errors}:handler_observed(errors,Array.get(U32,token,0))
def observed(~S:Data,trace:String,app:Schedule.Scheduled<DepApp.Application<W.World<S,D.Store(~S),D.Resources(~S),Unit>,Product.Owner<Sys.Owner<S,D.LeftStore(~S),D.LeftResource(~S),Unit,D.LeftOps(~S),Body.Local<S>,String,String,D.left(~S),Body.left(~S)>,Sys.Owner<S,D.RightStore(~S),D.RightResource(~S),Unit,D.RightOps(~S),Body.Local<S>,String,String,D.right(~S),Body.right(~S)>>,Unit,Handler,String,String,Part.dispatch(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.LeftResource(~S),~D.RightResource(~S),~Unit,~Body.Local<S>,~Body.Local<S>,~String,~String,~D.LeftOps(~S),~D.RightOps(~S),~D.left(~S),~D.right(~S),~Body.left(~S),~Body.right(~S)),Reg.empty_dispatch(~W.World<S,D.Store(~S),D.Resources(~S),Unit>,~String,~Bool),handle>>) -> String:
  match app:
    case Schedule.Scheduled{DepApp.Application{DepApp.State{world,Product.Owner{Sys.Owner{_,_,_,_,lc,ll},Sys.Owner{_,_,_,_,rc,lr}},_,errorHandler,_},_,_},_}:trace ++ "|world=" ++ Observe.world(~S,world) ++ "|locals=" ++ Observe.local(~S,ll) ++ "," ++ Observe.local(~S,lr) ++ "|cursors=" ++ Tick.cursor_show(lc) ++ "," ++ Tick.cursor_show(rc) ++ "|handler=" ++ handler(errorHandler)
def run_selected(~S:Data,native:Bool,app:Schedule.Scheduled<DepApp.Application<W.World<S,D.Store(~S),D.Resources(~S),Unit>,Product.Owner<Sys.Owner<S,D.LeftStore(~S),D.LeftResource(~S),Unit,D.LeftOps(~S),Body.Local<S>,String,String,D.left(~S),Body.left(~S)>,Sys.Owner<S,D.RightStore(~S),D.RightResource(~S),Unit,D.RightOps(~S),Body.Local<S>,String,String,D.right(~S),Body.right(~S)>>,Unit,Handler,String,String,Part.dispatch(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.LeftResource(~S),~D.RightResource(~S),~Unit,~Body.Local<S>,~Body.Local<S>,~String,~String,~D.LeftOps(~S),~D.RightOps(~S),~D.left(~S),~D.right(~S),~Body.left(~S),~Body.right(~S)),Reg.empty_dispatch(~W.World<S,D.Store(~S),D.Resources(~S),Unit>,~String,~Bool),handle>>) -> Schedule.Scheduled<DepApp.Application<W.World<S,D.Store(~S),D.Resources(~S),Unit>,Product.Owner<Sys.Owner<S,D.LeftStore(~S),D.LeftResource(~S),Unit,D.LeftOps(~S),Body.Local<S>,String,String,D.left(~S),Body.left(~S)>,Sys.Owner<S,D.RightStore(~S),D.RightResource(~S),Unit,D.RightOps(~S),Body.Local<S>,String,String,D.right(~S),Body.right(~S)>>,Unit,Handler,String,String,Part.dispatch(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.LeftResource(~S),~D.RightResource(~S),~Unit,~Body.Local<S>,~Body.Local<S>,~String,~String,~D.LeftOps(~S),~D.RightOps(~S),~D.left(~S),~D.right(~S),~Body.left(~S),~Body.right(~S)),Reg.empty_dispatch(~W.World<S,D.Store(~S),D.Resources(~S),Unit>,~String,~Bool),handle>> & DepApp.Report<String,String>:
  match native:
    case False{}:Schedule.run_serial(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.LeftResource(~S),~D.RightResource(~S),~Unit,~Body.Local<S>,~Body.Local<S>,~String,~String,~D.LeftOps(~S),~D.RightOps(~S),~D.left(~S),~D.right(~S),~Body.left(~S),~Body.right(~S),~Unit,~Handler,~Reg.empty_dispatch(~W.World<S,D.Store(~S),D.Resources(~S),Unit>,~String,~Bool),~Prog.empty(~W.World<S,D.Store(~S),D.Resources(~S),Unit>,~String,~Bool),~handle,app)
    case True{}:Schedule.run_native(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.LeftResource(~S),~D.RightResource(~S),~Unit,~Body.Local<S>,~Body.Local<S>,~String,~String,~D.LeftOps(~S),~D.RightOps(~S),~D.left(~S),~D.right(~S),~Body.left(~S),~Body.right(~S),~Unit,~Handler,~Reg.empty_dispatch(~W.World<S,D.Store(~S),D.Resources(~S),Unit>,~String,~Bool),~Prog.empty(~W.World<S,D.Store(~S),D.Resources(~S),Unit>,~String,~Bool),~handle,app)
def third(~S:Data,trace:String,result:Schedule.Scheduled<DepApp.Application<W.World<S,D.Store(~S),D.Resources(~S),Unit>,Product.Owner<Sys.Owner<S,D.LeftStore(~S),D.LeftResource(~S),Unit,D.LeftOps(~S),Body.Local<S>,String,String,D.left(~S),Body.left(~S)>,Sys.Owner<S,D.RightStore(~S),D.RightResource(~S),Unit,D.RightOps(~S),Body.Local<S>,String,String,D.right(~S),Body.right(~S)>>,Unit,Handler,String,String,Part.dispatch(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.LeftResource(~S),~D.RightResource(~S),~Unit,~Body.Local<S>,~Body.Local<S>,~String,~String,~D.LeftOps(~S),~D.RightOps(~S),~D.left(~S),~D.right(~S),~Body.left(~S),~Body.right(~S)),Reg.empty_dispatch(~W.World<S,D.Store(~S),D.Resources(~S),Unit>,~String,~Bool),handle>> & DepApp.Report<String,String>) -> String:
  match result:
    case (app,status):observed(~S,trace ++ "|" ++ report(status),app)
def second(~S:Data,native:Bool,trace:String,result:Schedule.Scheduled<DepApp.Application<W.World<S,D.Store(~S),D.Resources(~S),Unit>,Product.Owner<Sys.Owner<S,D.LeftStore(~S),D.LeftResource(~S),Unit,D.LeftOps(~S),Body.Local<S>,String,String,D.left(~S),Body.left(~S)>,Sys.Owner<S,D.RightStore(~S),D.RightResource(~S),Unit,D.RightOps(~S),Body.Local<S>,String,String,D.right(~S),Body.right(~S)>>,Unit,Handler,String,String,Part.dispatch(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.LeftResource(~S),~D.RightResource(~S),~Unit,~Body.Local<S>,~Body.Local<S>,~String,~String,~D.LeftOps(~S),~D.RightOps(~S),~D.left(~S),~D.right(~S),~Body.left(~S),~Body.right(~S)),Reg.empty_dispatch(~W.World<S,D.Store(~S),D.Resources(~S),Unit>,~String,~Bool),handle>> & DepApp.Report<String,String>) -> String:
  match result:
    case (app,status):third(~S,trace ++ "|" ++ report(status),run_selected(~S,native,app))
def first(~S:Data,+native:Bool,result:Schedule.Scheduled<DepApp.Application<W.World<S,D.Store(~S),D.Resources(~S),Unit>,Product.Owner<Sys.Owner<S,D.LeftStore(~S),D.LeftResource(~S),Unit,D.LeftOps(~S),Body.Local<S>,String,String,D.left(~S),Body.left(~S)>,Sys.Owner<S,D.RightStore(~S),D.RightResource(~S),Unit,D.RightOps(~S),Body.Local<S>,String,String,D.right(~S),Body.right(~S)>>,Unit,Handler,String,String,Part.dispatch(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.LeftResource(~S),~D.RightResource(~S),~Unit,~Body.Local<S>,~Body.Local<S>,~String,~String,~D.LeftOps(~S),~D.RightOps(~S),~D.left(~S),~D.right(~S),~Body.left(~S),~Body.right(~S)),Reg.empty_dispatch(~W.World<S,D.Store(~S),D.Resources(~S),Unit>,~String,~Bool),handle>> & DepApp.Report<String,String>) -> String:
  match result:
    case (app,status):second(~S,native,report(status),run_selected(~S,native,app))
def registered(~S:Data,+native:Bool,result:Pair.Definition<W.World<S,D.Store(~S),D.Resources(~S),Unit>,Sys.Owner<S,D.LeftStore(~S),D.LeftResource(~S),Unit,D.LeftOps(~S),Body.Local<S>,String,String,D.left(~S),Body.left(~S)>,Sys.Owner<S,D.RightStore(~S),D.RightResource(~S),Unit,D.RightOps(~S),Body.Local<S>,String,String,D.right(~S),Body.right(~S)>,Body.Local<S>,Body.Local<S>>) -> String:
  match result:
    case Pair.Defined{app}:first(~S,native,run_selected(~S,native,Schedule.build(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.LeftResource(~S),~D.RightResource(~S),~Unit,~Body.Local<S>,~Body.Local<S>,~String,~String,~D.LeftOps(~S),~D.RightOps(~S),~D.left(~S),~D.right(~S),~Body.left(~S),~Body.right(~S),~Unit,~Handler,~Reg.empty_dispatch(~W.World<S,D.Store(~S),D.Resources(~S),Unit>,~String,~Bool),~Prog.empty(~W.World<S,D.Store(~S),D.Resources(~S),Unit>,~String,~Bool),~handle,~available,app,Unit{},Handler{ALeaf{701},0},[],[])))
    case Pair.LeftRefused{_,_,_}:"ERROR:left define"
    case Pair.RightRefused{_,_,_}:"ERROR:right define"
def activated(~S:Data,native:Bool,+handle:W.Handle<S>,result:W.World<S,D.Store(~S),D.Resources(~S),Unit> & W.Status) -> String:
  match result:
    case (world,W.Accepted{}):registered(~S,native,Pair.define(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.LeftResource(~S),~D.RightResource(~S),~Unit,~Body.Local<S>,~Body.Local<S>,~String,~String,~String,~String,~D.LeftOps(~S),~D.RightOps(~S),~D.left(~S),~D.right(~S),~Body.left(~S),~Body.right(~S),world,"left","right",Body.Local{ALeaf{501},0,handle},Body.Local{ALeaf{601},0,handle}))
    case (_,_):"ERROR:activate"
def reserved(~S:Data,native:Bool,result:W.World<S,D.Store(~S),D.Resources(~S),Unit> & W.Reservation<S>) -> String:
  match result:
    case (world,W.Reserved{+handle}):activated(~S,native,handle,W.activate(~S,~D.Store(~S),~D.Resources(~S),~Unit,world,handle))
    case (_,_):"ERROR:reserve"
def created(~S:Data,native:Bool,result:W.Creation<S,D.Store(~S),D.Resources(~S),Unit>) -> String:
  match result:
    case W.Created{_,world}:reserved(~S,native,W.reserve_id(~S,~D.Store(~S),~D.Resources(~S),~Unit,world))
    case W.CreateRejected{_,_}:"ERROR:create"
def run(~S:Data,native:Bool) -> String:
  created(~S,native,W.create(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.empty(~S),W.factory(),D.resources(~S)))

type SchemaA is Data:
  SchemaA{}
type SchemaB is Data:
  SchemaB{}
def main() -> IO(Unit):
  IO.print("A-serial=" ++ run(~SchemaA,False{}) ++ "\nA-native=" ++ run(~SchemaA,True{}) ++ "\nB-serial=" ++ run(~SchemaB,False{}) ++ "\nB-native=" ++ run(~SchemaB,True{}))

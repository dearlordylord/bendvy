import Base
import ./declarations.bend as D
import ./bodies.bend as Body
import ./observe.bend as Observe
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-parallel-app.bend as Execute
import ../../src/ecs/execution-parallel-run.bend as Run
import ../../src/ecs/execution-parallel.bend as Parallel
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/change-tick.bend as Tick

def completion(value:Sys.Completion<String,String>) -> String:
  match value:
    case Sys.Success{out}:"success/" ++ out
    case Sys.BodyError{error,out}:"error/" ++ error ++ "/" ++ out
def status(value:Maybe<&2,Sys.Completion<String,String>>) -> String:
  match value:
    case Some{done}:completion(done)
    case None{}:"refused"
def foreign_finished(~S:Data,original:W.World<S,D.Store(~S),D.Resources(~S),Unit>,trace:String,result:Run.PairResult<W.World<S,D.Store(~S),D.Resources(~S),Unit>,Sys.Owner<S,D.Store(~S),D.LeftStore(~S),D.LeftResource(~S),Unit,D.LeftOps(~S),Body.Local<S>,String,String,D.left(~S),Body.left(~S)>,Sys.Owner<S,D.Store(~S),D.RightStore(~S),D.RightResource(~S),Unit,D.RightOps(~S),Body.Local<S>,String,String,D.right(~S),Body.right(~S)>,String,String,String,String>) -> String:
  match result:
    case Run.Finished{foreign,Sys.Owner{_,_,_,_,lc,ll},Sys.Owner{_,_,_,_,rc,lr},left,right}:trace ++ "|foreign=" ++ status(left) ++ "," ++ status(right) ++ "|world=" ++ Observe.world(~S,original) ++ "|locals=" ++ Observe.local(~S,ll) ++ "," ++ Observe.local(~S,lr) ++ "|cursors=" ++ Tick.cursor_show(lc) ++ "," ++ Tick.cursor_show(rc) ++ "|foreign-world=" ++ Observe.world(~S,foreign)
def foreign_created(~S:Data,mode:Parallel.Mode,original:W.World<S,D.Store(~S),D.Resources(~S),Unit>,left:Sys.Owner<S,D.Store(~S),D.LeftStore(~S),D.LeftResource(~S),Unit,D.LeftOps(~S),Body.Local<S>,String,String,D.left(~S),Body.left(~S)>,right:Sys.Owner<S,D.Store(~S),D.RightStore(~S),D.RightResource(~S),Unit,D.RightOps(~S),Body.Local<S>,String,String,D.right(~S),Body.right(~S)>,trace:String,result:W.Creation<S,D.Store(~S),D.Resources(~S),Unit>) -> String:
  match result:
    case W.Created{_,world}:foreign_finished(~S,original,trace,Execute.run(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.LeftResource(~S),~D.RightResource(~S),~Unit,~Body.Local<S>,~Body.Local<S>,~String,~String,~String,~String,~D.LeftOps(~S),~D.RightOps(~S),~D.left(~S),~D.right(~S),~Body.left(~S),~Body.right(~S),mode,Execute.ParallelApp{world,left,right}))
    case W.CreateRejected{_,_}:"ERROR:create foreign"
def third(~S:Data,mode:Parallel.Mode,factory:W.Factory,trace:String,result:Run.PairResult<W.World<S,D.Store(~S),D.Resources(~S),Unit>,Sys.Owner<S,D.Store(~S),D.LeftStore(~S),D.LeftResource(~S),Unit,D.LeftOps(~S),Body.Local<S>,String,String,D.left(~S),Body.left(~S)>,Sys.Owner<S,D.Store(~S),D.RightStore(~S),D.RightResource(~S),Unit,D.RightOps(~S),Body.Local<S>,String,String,D.right(~S),Body.right(~S)>,String,String,String,String>) -> String:
  match result:
    case Run.Finished{world,left,right,lo,ro}:foreign_created(~S,mode,world,left,right,trace ++ "|" ++ status(lo) ++ "," ++ status(ro),W.create(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.empty(~S),factory,D.resources(~S)))
def second(~S:Data,+mode:Parallel.Mode,factory:W.Factory,trace:String,result:Run.PairResult<W.World<S,D.Store(~S),D.Resources(~S),Unit>,Sys.Owner<S,D.Store(~S),D.LeftStore(~S),D.LeftResource(~S),Unit,D.LeftOps(~S),Body.Local<S>,String,String,D.left(~S),Body.left(~S)>,Sys.Owner<S,D.Store(~S),D.RightStore(~S),D.RightResource(~S),Unit,D.RightOps(~S),Body.Local<S>,String,String,D.right(~S),Body.right(~S)>,String,String,String,String>) -> String:
  match result:
    case Run.Finished{world,left,right,lo,ro}:third(~S,mode,factory,trace ++ "|" ++ status(lo) ++ "," ++ status(ro),Execute.run(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.LeftResource(~S),~D.RightResource(~S),~Unit,~Body.Local<S>,~Body.Local<S>,~String,~String,~String,~String,~D.LeftOps(~S),~D.RightOps(~S),~D.left(~S),~D.right(~S),~Body.left(~S),~Body.right(~S),mode,Execute.ParallelApp{world,left,right}))
def first(~S:Data,+mode:Parallel.Mode,factory:W.Factory,result:Run.PairResult<W.World<S,D.Store(~S),D.Resources(~S),Unit>,Sys.Owner<S,D.Store(~S),D.LeftStore(~S),D.LeftResource(~S),Unit,D.LeftOps(~S),Body.Local<S>,String,String,D.left(~S),Body.left(~S)>,Sys.Owner<S,D.Store(~S),D.RightStore(~S),D.RightResource(~S),Unit,D.RightOps(~S),Body.Local<S>,String,String,D.right(~S),Body.right(~S)>,String,String,String,String>) -> String:
  match result:
    case Run.Finished{world,left,right,lo,ro}:second(~S,mode,factory,status(lo) ++ "," ++ status(ro),Execute.run(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.LeftResource(~S),~D.RightResource(~S),~Unit,~Body.Local<S>,~Body.Local<S>,~String,~String,~String,~String,~D.LeftOps(~S),~D.RightOps(~S),~D.left(~S),~D.right(~S),~Body.left(~S),~Body.right(~S),mode,Execute.ParallelApp{world,left,right}))
def registered(~S:Data,+mode:Parallel.Mode,factory:W.Factory,result:Execute.Definition<W.World<S,D.Store(~S),D.Resources(~S),Unit>,Sys.Owner<S,D.Store(~S),D.LeftStore(~S),D.LeftResource(~S),Unit,D.LeftOps(~S),Body.Local<S>,String,String,D.left(~S),Body.left(~S)>,Sys.Owner<S,D.Store(~S),D.RightStore(~S),D.RightResource(~S),Unit,D.RightOps(~S),Body.Local<S>,String,String,D.right(~S),Body.right(~S)>,Body.Local<S>,Body.Local<S>>) -> String:
  match result:
    case Execute.Defined{app}:first(~S,mode,factory,Execute.run(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.LeftResource(~S),~D.RightResource(~S),~Unit,~Body.Local<S>,~Body.Local<S>,~String,~String,~String,~String,~D.LeftOps(~S),~D.RightOps(~S),~D.left(~S),~D.right(~S),~Body.left(~S),~Body.right(~S),mode,app))
    case Execute.LeftRefused{_,_,_}:"ERROR:left define"
    case Execute.RightRefused{_,_,_}:"ERROR:right define"
def ready(~S:Data,mode:Parallel.Mode,factory:W.Factory,result:W.World<S,D.Store(~S),D.Resources(~S),Unit> & W.Handle<S>) -> String:
  match result:
    case (world,+handle):registered(~S,mode,factory,Execute.define(~S,~D.LeftStore(~S),~D.RightStore(~S),~D.LeftResource(~S),~D.RightResource(~S),~Unit,~Body.Local<S>,~Body.Local<S>,~String,~String,~String,~String,~D.LeftOps(~S),~D.RightOps(~S),~D.left(~S),~D.right(~S),~Body.left(~S),~Body.right(~S),world,"left","right",Body.Local{ALeaf{501},0,handle},Body.Local{ALeaf{601},0,handle}))
def more_activated(~S:Data,first:W.Handle<S>,result:W.World<S,D.Store(~S),D.Resources(~S),Unit> & W.Status) -> W.World<S,D.Store(~S),D.Resources(~S),Unit> & W.Handle<S>:
  match result:
    case (world,_):(world,first)
def more_reserved(~S:Data,first:W.Handle<S>,result:W.World<S,D.Store(~S),D.Resources(~S),Unit> & W.Reservation<S>) -> W.World<S,D.Store(~S),D.Resources(~S),Unit> & W.Handle<S>:
  match result:
    case (world,W.Reserved{handle}):more_activated(~S,first,W.activate(~S,~D.Store(~S),~D.Resources(~S),~Unit,world,handle))
    case (world,W.ReservationRejected{_}):(world,first)
def spawn_more(~S:Data,fuel:Nat,result:W.World<S,D.Store(~S),D.Resources(~S),Unit> & W.Handle<S>) -> W.World<S,D.Store(~S),D.Resources(~S),Unit> & W.Handle<S>:
  match fuel result:
    case 0n result:result
    case 1n++rest, (world,first):spawn_more(~S,rest,more_reserved(~S,first,W.reserve_id(~S,~D.Store(~S),~D.Resources(~S),~Unit,world)))
def activated(~S:Data,mode:Parallel.Mode,factory:W.Factory,first:W.Handle<S>,result:W.World<S,D.Store(~S),D.Resources(~S),Unit> & W.Status) -> String:
  match result:
    case (world,W.Accepted{}):ready(~S,mode,factory,spawn_more(~S,16n,(world,first)))
    case (_,_):"ERROR:activate"
def reserved(~S:Data,mode:Parallel.Mode,factory:W.Factory,result:W.World<S,D.Store(~S),D.Resources(~S),Unit> & W.Reservation<S>) -> String:
  match result:
    case (world,W.Reserved{+handle}):activated(~S,mode,factory,handle,W.activate(~S,~D.Store(~S),~D.Resources(~S),~Unit,world,handle))
    case (_,_):"ERROR:reserve"
def created(~S:Data,mode:Parallel.Mode,result:W.Creation<S,D.Store(~S),D.Resources(~S),Unit>) -> String:
  match result:
    case W.Created{factory,world}:reserved(~S,mode,factory,W.reserve_id(~S,~D.Store(~S),~D.Resources(~S),~Unit,world))
    case W.CreateRejected{_,_}:"ERROR:create"
def run(~S:Data,mode:Parallel.Mode) -> String:
  created(~S,mode,W.create(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.empty(~S),W.factory(),D.resources(~S)))

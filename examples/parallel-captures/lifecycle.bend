import Base
import ./contexts.bend as Context
import ../../src/ecs/execution-capture.bend as Capture
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-system-lifecycle.bend as Life
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/world.bend as W
import ../../src/ecs/change-tick.bend as Tick

type S is Data:
  S{}
def Ops(H:Type) -> Type:Unit
def Local() -> Type:Capture.Local<Array<U32>,Context.Count()>
def World() -> Type:W.World<S,Unit,Unit,Unit>
def Owner() -> Type:Sys.Owner<S,Unit,Unit,Unit,Ops,Local(),String,U32,declaration,body>
def selection(~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~Unit,~Unit,~H,~B),~cw:Build.ComponentWrite(~S,~Unit,~Unit,~H,~B),~rr:Build.ResourceRead(~S,~Unit,~Unit,~H,~B),~rw:Build.ResourceWrite(~S,~Unit,~Unit,~H,~B),~q:Build.Query(~S,~Unit,~Unit,~H,~B),book:B) -> B & Unit:(book,Unit{})
def declaration(~H:Type,~B:Type,~builder:Build.Builder(~S,~Unit,~Unit,~H,~B),book:B) -> B & Unit:
  builder(Ops,selection(~H,~B),book)
def completed(count:U32,failed:Bool) -> Sys.Completion<String,U32>:
  match failed:
    case True{}:Sys.BodyError{"after-capture",count}
    case False{}:Sys.Success{count}
def completion(+count:U32) -> Sys.Completion<String,U32>:
  completed(count,U32.is_eq(count,4))
def captured(~H:Type,scope:H,state:Array<U32>,result:Context.Count() & U32) -> H & (Local() & Sys.Completion<String,U32>):
  match result:
    case (capture,+count):(scope,(Capture.Local{Array.set(U32,state,1,count),capture},completion(count)))
def body(~H:Type,~caps:Unit,scope:H,local:Local()) -> H & (Local() & Sys.Completion<String,U32>):
  match local:
    case Capture.Local{state,capture}:captured(~H,scope,state,Capture.invoke(~Array<U32>,~U32,~U32,~Context.count_step,capture,2))
def empty(_:Unit) -> Unit:Unit{}
def observed_capture(trace:String,state:String,capture:String,identity:Life.Identity) -> String:
  match identity:
    case Life.Identity{namespace,id,name,_,cursor}:trace ++ "|identity=" ++ U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ Tick.cursor_show(cursor) ++ "|local=" ++ state ++ "|capture=" ++ capture
def observe_capture(trace:String,identity:Life.Identity,state:String,result:Context.Count() & String) -> String:
  match result:
    case (_,capture):observed_capture(trace,state,capture,identity)
def local_observed(trace:String,identity:Life.Identity,capture:Context.Count(),result:Array<U32> & String) -> String:
  match result:
    case (_,state):observe_capture(trace,identity,state,Capture.observe(~Array<U32>,~U32,~U32,~Context.count_step,~String,~Context.count_snapshot,capture))
def released(trace:String,result:Life.Released<Local()>) -> String:
  match result:
    case Life.Released{identity,Capture.Local{state,capture}}:local_observed(trace,identity,capture,Context.count_snapshot(state))
def final_retired(trace:String,result:Life.Retirement<World(),Owner()>) -> String:
  match result:
    case Life.Retired{W.World{_,_,_,_,_,_,registrations,nextId,_},detached}:released(trace ++ "|registrations=" ++ Nat.show(List.length(&2,W.RegistrationMeta,registrations)) ++ "|nextId=" ++ U32.show(nextId),Life.release(~S,~Unit,~Unit,~Unit,~Ops,~Local(),~String,~U32,~declaration,~body,detached))
    case Life.RetirementRefused{_,_}:"ERROR:final-retire"
def final_run(trace:String,result:Sys.RunResult<World(),Owner(),String,U32>) -> String:
  match result:
    case Sys.Executed{world,owner,Sys.Success{count}}:final_retired(trace ++ "|restored-run=" ++ U32.show(count),Life.retire(~S,~Unit,~Unit,~Unit,~Ops,~Local(),~String,~U32,~declaration,~body,~Unit,~Unit,~Unit,owner,world))
    case _:"ERROR:final-run"
def restored(trace:String,result:Life.Restoration<World(),Owner()>) -> String:
  match result:
    case Life.Restored{world,owner}:final_run(trace ++ "|restored",Sys.run(~S,~Unit,~Unit,~Unit,~Ops,~Local(),~String,~U32,~declaration,~body,owner,world))
    case Life.RestorationRefused{_,_}:"ERROR:restore"
def foreign_refused(trace:String,world:World(),result:Life.Restoration<World(),Owner()>) -> String:
  match result:
    case Life.RestorationRefused{_,detached}:restored(trace ++ "|foreign-refused",Life.restore(~S,~Unit,~Unit,~Unit,~Ops,~Local(),~String,~U32,~declaration,~body,~Unit,~Unit,~Unit,detached,world))
    case Life.Restored{_,_}:"ERROR:foreign-accepted"
def foreign_created(trace:String,world:World(),detached:Life.Detached<Owner()>,result:W.Creation<S,Unit,Unit,Unit>) -> String:
  match result:
    case W.Created{_,foreign}:foreign_refused(trace,world,Life.restore(~S,~Unit,~Unit,~Unit,~Ops,~Local(),~String,~U32,~declaration,~body,~Unit,~Unit,~Unit,detached,foreign))
    case W.CreateRejected{_,_}:"ERROR:foreign-create"
def unregistered(trace:String,factory:W.Factory,result:Sys.RunResult<World(),Owner(),String,U32>) -> String:
  match result:
    case Sys.Refused{world,owner}:foreign_created(trace ++ "|unregistered-refused",world,Life.Detached{owner},W.create(~S,~Unit,~Unit,~Unit,~empty,factory,Unit{}))
    case Sys.Executed{_,_,_}:"ERROR:unregistered-executed"
def retired(trace:String,factory:W.Factory,result:Life.Retirement<World(),Owner()>) -> String:
  match result:
    case Life.Retired{world,Life.Detached{owner}}:unregistered(trace ++ "|retired",factory,Sys.run(~S,~Unit,~Unit,~Unit,~Ops,~Local(),~String,~U32,~declaration,~body,owner,world))
    case Life.RetirementRefused{_,_}:"ERROR:retire"
def second(factory:W.Factory,result:Sys.RunResult<World(),Owner(),String,U32>) -> String:
  match result:
    case Sys.Executed{world,owner,Sys.BodyError{error,count}}:retired("error=" ++ error ++ ":" ++ U32.show(count),factory,Life.retire(~S,~Unit,~Unit,~Unit,~Ops,~Local(),~String,~U32,~declaration,~body,~Unit,~Unit,~Unit,owner,world))
    case _:"ERROR:second"
def first(factory:W.Factory,result:Sys.RunResult<World(),Owner(),String,U32>) -> String:
  match result:
    case Sys.Executed{world,owner,Sys.Success{_}}:second(factory,Sys.run(~S,~Unit,~Unit,~Unit,~Ops,~Local(),~String,~U32,~declaration,~body,owner,world))
    case _:"ERROR:first"
def collision(factory:W.Factory,result:Life.Restoration<World(),Owner()>) -> String:
  match result:
    case Life.RestorationRefused{world,Life.Detached{owner}}:first(factory,Sys.run(~S,~Unit,~Unit,~Unit,~Ops,~Local(),~String,~U32,~declaration,~body,owner,world))
    case Life.Restored{_,_}:"ERROR:collision-accepted"
def defined(factory:W.Factory,result:Sys.Defined<World(),Owner(),Local()>) -> String:
  match result:
    case Sys.Defined{world,owner}:collision(factory,Life.restore(~S,~Unit,~Unit,~Unit,~Ops,~Local(),~String,~U32,~declaration,~body,~Unit,~Unit,~Unit,Life.Detached{owner},world))
    case Sys.DefinitionRefused{_,_}:"ERROR:define"
def created(result:W.Creation<S,Unit,Unit,Unit>) -> String:
  match result:
    case W.Created{factory,world}:defined(factory,Sys.define(~S,~Unit,~Unit,~Unit,~Ops,~Local(),~String,~U32,~declaration,~body,world,"captured",Capture.Local{ANode{ALeaf{101},ALeaf{0}},Context.count()}))
    case W.CreateRejected{_,_}:"ERROR:create"
def main() -> IO(Unit):
  IO.print(created(W.create(~S,~Unit,~Unit,~Unit,~empty,W.factory(),Unit{})))

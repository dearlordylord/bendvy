import Base
import ../../src/ecs/execution-reservation-task.bend as Effect
import ./declarations.bend as D
import ../../src/ecs/execution-machine-access.bend as Machine
import ../../src/ecs/execution-machine-state.bend as State
import ../../src/ecs/machine.bend as M
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-capture.bend as Capture
import ../../src/ecs/change-tick.bend as Tick

type Context is Type:
  Context{identity:Array<U32>,history:Array<String>}
def captured_text(identity:Array<U32>,result:Array<String> & String) -> Context & String:
  match result:
    case (history,+prior):(Context{identity,Array.set(String,history,0,prior ++ "x")},prior)
def append(context:Context,_:Unit) -> Context & String:
  match context:
    case Context{identity,history}:captured_text(identity,Array.get(String,history,0))
def Captured() -> Type:Capture.Captured<Context,Unit,String,append>
def Local() -> Type:Capture.Local<Array<U32>,Captured()>
def local(id:U32,captureId:U32) -> Local():
  Capture.Local{ANode{ALeaf{id},ALeaf{0}},Capture.bind(~Context,~Unit,~String,~append,Context{ALeaf{captureId},ALeaf{""}})}
def advanced(result:Array<U32> & U32) -> Array<U32> & U32:
  match result:
    case (state,+count):(Array.set(U32,state,1,U32.add(count,1)),U32.add(count,1))
def advance(state:Array<U32>) -> Array<U32> & U32:advanced(Array.get(U32,state,1))
def intent(value:State.Intent<D.Mode>) -> String:
  match value:
    case State.Idle{}:"idle"
    case State.Initial{_}:"initial"
    case State.Transition{_,_,True{}}:"transition/hooks"
    case State.Transition{_,_,False{}}:"transition/no-hooks"
def mode_value(value:D.Mode) -> String:
  match value:
    case D.Waiting{}:"waiting"
    case D.Running{}:"running"
def mode(~S:Data,value:M.CurrentView<S,D.Key,D.Mode>) -> String:
  match value:
    case M.Unavailable{}:"missing"
    case M.Current{value}:mode_value(value)
def pending(~S:Data,value:M.NextView<S,D.Key,D.Mode>) -> String:
  match value:
    case M.NoNext{}:"none"
    case M.Next{value}:mode_value(value)
def view(~S:Data,value:State.View<S,D.Key,D.Mode>) -> String:
  match value:
    case State.View{current,next,revision,stamp,nextStamp,event}:mode(~S,current) ++ "/next=" ++ pending(~S,next) ++ "/revision=" ++ Nat.show(revision) ++ "/stamp=" ++ Tick.cursor_show(stamp) ++ "/next-stamp=" ++ Tick.cursor_show(nextStamp) ++ "/" ++ intent(event)
def apply_viewed(~S:Data,~H:Type,local:Local(),result:H & State.View<S,D.Key,D.Mode>) -> H & (Local() & Sys.Completion<String,String>):
  match result:
    case (scope,value):(scope,(local,Sys.Success{view(~S,value)}))
def applied(~S:Data,~Permit:Data,~H:Type,~caps:D.apply_ops(~S)(Permit,H),local:Local(),result:H & State.Intent<D.Mode>) -> H & (Local() & Sys.Completion<String,String>):
  match result:
    case (scope,_):apply_viewed(~S,~H,local,Machine.apply_read_field(~S,~D.Key,~D.Mode,~H,caps)(scope))
def apply_sync(~S:Data,~Permit:Data,~H:Type,~caps:D.apply_ops(~S)(Permit,H),scope:H,local:Local()) -> H & (Local() & Sys.Completion<String,String>):
  applied(~S,~Permit,~H,~caps,local,Machine.apply_field(~S,~D.Key,~D.Mode,~H,caps)(scope))
def request_viewed(~S:Data,~H:Type,state:Array<U32>,capture:Captured(),runs:U32,text:String,result:H & State.View<S,D.Key,D.Mode>) -> H & (Local() & Sys.Completion<String,String>):
  match result:
    case (scope,value):(scope,(Capture.Local{state,capture},Sys.Success{"request/" ++ U32.show(runs) ++ "/" ++ text ++ "/" ++ view(~S,value)}))
def requested(~S:Data,~Permit:Data,~H:Type,~caps:D.request_ops(~S)(Permit,H),state:Array<U32>,capture:Captured(),runs:U32,text:String,result:H & Unit) -> H & (Local() & Sys.Completion<String,String>):
  match result:
    case (scope,_):request_viewed(~S,~H,state,capture,runs,text,Machine.write_read_field(~S,~D.Key,~D.Mode,~H,caps)(scope))
def captured(~S:Data,~Permit:Data,~H:Type,~caps:D.request_ops(~S)(Permit,H),scope:H,state:Array<U32>,runs:U32,result:Captured() & String) -> H & (Local() & Sys.Completion<String,String>):
  match result:
    case (capture,text):requested(~S,~Permit,~H,~caps,state,capture,runs,text,Machine.request_field(~S,~D.Key,~D.Mode,~H,caps)(M.Set{D.Running{},True{}},scope))
def requesting(~S:Data,~Permit:Data,~H:Type,~caps:D.request_ops(~S)(Permit,H),scope:H,capture:Captured(),result:Array<U32> & U32) -> H & (Local() & Sys.Completion<String,String>):
  match result:
    case (state,runs):captured(~S,~Permit,~H,~caps,scope,state,runs,Capture.invoke(~Context,~Unit,~String,~append,capture,Unit{}))
def request_sync(~S:Data,~Permit:Data,~H:Type,~caps:D.request_ops(~S)(Permit,H),scope:H,local:Local()) -> H & (Local() & Sys.Completion<String,String>):
  match local:
    case Capture.Local{state,capture}:requesting(~S,~Permit,~H,~caps,scope,capture,advance(state))
def read_captured(~H:Type,scope:H,state:Array<U32>,runs:U32,value:String,result:Captured() & String) -> H & (Local() & Sys.Completion<String,String>):
  match result:
    case (capture,text):(scope,(Capture.Local{state,capture},Sys.Success{value ++ "/runs=" ++ U32.show(runs) ++ "/capture=" ++ text}))
def read_advanced(~H:Type,scope:H,capture:Captured(),value:String,result:Array<U32> & U32) -> H & (Local() & Sys.Completion<String,String>):
  match result:
    case (state,runs):read_captured(~H,scope,state,runs,value,Capture.invoke(~Context,~Unit,~String,~append,capture,Unit{}))
def read_result(~S:Data,~H:Type,local:Local(),result:H & State.View<S,D.Key,D.Mode>) -> H & (Local() & Sys.Completion<String,String>):
  match local result:
    case Capture.Local{state,capture}, (scope,State.View{current,next,revision,stamp,nextStamp,event}):read_advanced(~H,scope,capture,view(~S,State.View{current,next,revision,stamp,nextStamp,event}),advance(state))
def read_sync(~S:Data,~Permit:Data,~H:Type,~caps:D.read_ops(~S)(Permit,H),scope:H,local:Local()) -> H & (Local() & Sys.Completion<String,String>):
  read_result(~S,~H,local,Machine.read_field(~S,~D.Key,~D.Mode,~H,caps)(scope))

# A handled ordinary body error retains the returned Scope and affine Local:
# https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/executor/single_threaded.rs#L138-L166
# No transition rollback or pending-request requeue is performed by this body.
def failed(~H:Type,result:H & (Local() & Sys.Completion<String,String>)) -> H & (Local() & Sys.Completion<String,String>):
  match result:
    case (scope,(local,Sys.Success{out})):(scope,(local,Sys.BodyError{"exit-after-request",out}))
    case (scope,(local,Sys.BodyError{error,out})):(scope,(local,Sys.BodyError{error,out}))
def exit_sync(~S:Data,~Permit:Data,~H:Type,~caps:D.request_ops(~S)(Permit,H),scope:H,local:Local()) -> H & (Local() & Sys.Completion<String,String>):
  failed(~H,request_sync(~S,~Permit,~H,~caps,scope,local))

def apply(~S:Data,~Permit:Data,~H:Type,~caps:D.apply_ops(~S)(Permit,H),scope:H,local:Local()) -> Effect.Task<S,Permit,H & (Local() & Sys.Completion<String,String>)>:
  Effect.TDone{apply_sync(~S,~Permit,~H,~caps,scope,local)}
def request(~S:Data,~Permit:Data,~H:Type,~caps:D.request_ops(~S)(Permit,H),scope:H,local:Local()) -> Effect.Task<S,Permit,H & (Local() & Sys.Completion<String,String>)>:
  Effect.TDone{request_sync(~S,~Permit,~H,~caps,scope,local)}
def read(~S:Data,~Permit:Data,~H:Type,~caps:D.read_ops(~S)(Permit,H),scope:H,local:Local()) -> Effect.Task<S,Permit,H & (Local() & Sys.Completion<String,String>)>:
  Effect.TDone{read_sync(~S,~Permit,~H,~caps,scope,local)}
def exit(~S:Data,~Permit:Data,~H:Type,~caps:D.request_ops(~S)(Permit,H),scope:H,local:Local()) -> Effect.Task<S,Permit,H & (Local() & Sys.Completion<String,String>)>:
  Effect.TDone{exit_sync(~S,~Permit,~H,~caps,scope,local)}

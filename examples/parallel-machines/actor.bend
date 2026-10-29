import Base
import ../../src/ecs/execution-reservation-task.bend as Effect
import ./declarations.bend as D
import ./payloads.bend as P
import ./bodies.bend as Body
import ../../src/ecs/execution-machine-component.bend as StateOps
import ../../src/ecs/execution-access.bend as Access
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/state.bend as State
import ../../src/ecs/component.bend as Component
import ../../src/ecs/execution-capture.bend as Capture
import ../../src/ecs/world.bend as W

type Key is Data:
  ActorState{}
type Move is Data:
  Start{}
  Stop{}
def endpoints(move:Move) -> D.Mode & D.Mode:
  match move:
    case Start{}:(D.Waiting{},D.Running{})
    case Stop{}:(D.Running{},D.Waiting{})
def update(~S:Data,mode:D.Mode,owner:P.Actor<S,D.Mode>) -> P.Actor<S,D.Mode> & D.Mode:
  match mode owner:
    case +mode P.Actor{identity,_,history}:(P.Actor{identity,mode,Array.set(String,history,0,"state-moved")},mode)
def Ops(~S:Data,Permit:Data,H:Type) -> Type:StateOps.Operations<S,Key,D.Mode,Move,H>
def selected(~S:Data,~Permit:Data,~H:Type,~B:Type,result:B & Access.ComponentWrite<S,H,P.Actor<S,D.Mode>,D.Mode>) -> B & Ops(~S,Permit,H):
  match result:
    case (book,cap):(book,StateOps.narrow(~S,~Key,~H,~P.Actor<S,D.Mode>,~D.Mode,~Move,~D.same,~endpoints,~update(~S),cap))
def selection(~S:Data,~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~D.LeftStore(~S),~D.Resources(~S),~H,~B),~cw:Build.ComponentWrite(~S,~D.LeftStore(~S),~D.Resources(~S),~H,~B),~rr:Build.ResourceRead(~S,~D.LeftStore(~S),~D.Resources(~S),~H,~B),~rw:Build.ResourceWrite(~S,~D.LeftStore(~S),~D.Resources(~S),~H,~B),~q:Build.Query(~S,~D.Store(~S),~D.LeftStore(~S),~D.Resources(~S),~H,~B),~lifecycle:Build.Lifecycle(~S,~D.Store(~S),~D.LeftStore(~S),~D.Resources(~S),~H,~B),book:B) -> B & Ops(~S,Permit,H):
  selected(~S,~Permit,~H,~B,cw(D.actor_layout(~S),Layout.AtLeaf{},{==},{==},book))
def declaration(~S:Data,~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~D.Store(~S),~D.LeftStore(~S),~D.Resources(~S),~Permit,~H,~B),book:B) -> B & Ops(~S,Permit,H):
  builder(Ops(~S),selection(~S,~Permit,~H,~B),book)
type Local<-S:Data> is Type:
  Local{handle:W.Handle<S>,retained:Body.Local()}
def outcome(value:State.Outcome<D.Mode,Unit>) -> String:
  match value:
    case State.StateMoved{}:"moved"
    case State.StateMismatch{_,_}:"mismatch"
    case State.StateAccessRejected{Component.MissingEntity{}}:"missing-entity"
    case State.StateAccessRejected{Component.ComponentAbsent{}}:"component-absent"
    case State.StateAccessRejected{Component.Found{_}}:"unexpected-access"
    case State.StateWriteRejected{_}:"write-rejected"
def captured(~S:Data,~H:Type,scope:H,handle:W.Handle<S>,state:Array<U32>,runs:U32,value:String,result:Body.Captured() & String) -> H & (Local<S> & Sys.Completion<String,String>):
  match result:
    case (capture,text):(scope,(Local{handle,Capture.Local{state,capture}},Sys.Success{value ++ "/runs=" ++ U32.show(runs) ++ "/capture=" ++ text}))
def advanced(~S:Data,~H:Type,scope:H,handle:W.Handle<S>,capture:Body.Captured(),value:String,result:Array<U32> & U32) -> H & (Local<S> & Sys.Completion<String,String>):
  match result:
    case (state,runs):captured(~S,~H,scope,handle,state,runs,value,Capture.invoke(~Body.Context,~Unit,~String,~Body.append,capture,Unit{}))
def completed(~S:Data,~H:Type,handle:W.Handle<S>,retained:Body.Local(),result:H & State.Outcome<D.Mode,Unit>) -> H & (Local<S> & Sys.Completion<String,String>):
  match retained result:
    case Capture.Local{state,capture}, (scope,value):advanced(~S,~H,scope,handle,capture,outcome(value),Body.advance(state))
def body_sync(~S:Data,~Permit:Data,~H:Type,~caps:Ops(~S,Permit,H),scope:H,local:Local<S>) -> H & (Local<S> & Sys.Completion<String,String>):
  match local:
    case Local{+handle,retained}:completed(~S,~H,handle,retained,StateOps.move_field(~S,~Key,~H,~D.Mode,~Move,caps)(scope,handle,Start{}))

def body(~S:Data,~Permit:Data,~H:Type,~caps:Ops(~S,Permit,H),scope:H,local:Local<S>) -> Effect.Task<S,Permit,H & (Local<S> & Sys.Completion<String,String>)>:
  Effect.TDone{body_sync(~S,~Permit,~H,~caps,scope,local)}

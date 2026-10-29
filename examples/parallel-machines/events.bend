import Base
import ../../src/ecs/execution-reservation-task.bend as Effect
import ./declarations.bend as D
import ./bodies.bend as Body
import ../../src/ecs/execution-machine-events.bend as Events
import ../../src/ecs/execution-machine-stream.bend as Stream
import ../../src/ecs/machine.bend as M
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-capture.bend as Capture
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-parallel-system.bend as Task
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/world.bend as W

def Reader(~S:Data) -> Type:Stream.Reader<S,D.Key,D.Mode,D.layout(S),Layout.AtLeaf{}>
def Ops(~S:Data) -> Data -> Type -> Type:Events.Ops(~S,~D.Key,~D.Mode,~D.layout(S),~Layout.AtLeaf{})
def selection(~S:Data,~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~D.LeftStore(~S),~D.Resources(~S),~H,~B),~cw:Build.ComponentWrite(~S,~D.LeftStore(~S),~D.Resources(~S),~H,~B),~rr:Build.ResourceRead(~S,~D.LeftStore(~S),~D.Resources(~S),~H,~B),~rw:Build.ResourceWrite(~S,~D.LeftStore(~S),~D.Resources(~S),~H,~B),~q:Build.Query(~S,~D.Store(~S),~D.LeftStore(~S),~D.Resources(~S),~H,~B),~lifecycle:Build.Lifecycle(~S,~D.Store(~S),~D.LeftStore(~S),~D.Resources(~S),~H,~B),book:B) -> B & Ops(~S)(Permit,H):
  Events.select(~S,~D.Key,~D.Mode,~D.LeftStore(~S),~D.Resources(~S),~H,~B,~D.layout(S),~Layout.AtLeaf{},~{==},~{==},~D.payload_proof(~S),~D.view_proof(~S),~rw,book)
def declaration(~S:Data,~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~D.Store(~S),~D.LeftStore(~S),~D.Resources(~S),~Permit,~H,~B),book:B) -> B & Ops(~S)(Permit,H):
  builder(Ops(~S),selection(~S,~Permit,~H,~B),book)
type Local<-S:Data> is Type:
  Local{reader:Maybe<&1,Reader(~S)>,retained:Body.Local()}
def event(value:M.Transition<D.Mode>) -> String:
  match value:
    case M.Initial{value}:"initial:" ++ Body.mode_value(value)
    case M.Transition{from,to}:Body.mode_value(from) ++ ">" ++ Body.mode_value(to)
def cursor(~S:Data,reader:Reader(~S)) -> Reader(~S) & String:
  match reader:
    case Stream.Reader{+namespace,+id,+cursor}:(Stream.Reader{namespace,id,cursor},U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ Nat.show(cursor))
def completion_failed(failed:Bool,value:String) -> Sys.Completion<String,String>:
  match failed:
    case True{}:Sys.BodyError{"reader-after-consume",value}
    case False{}:Sys.Success{value}
def completion(runs:U32,value:String) -> Sys.Completion<String,String>:completion_failed(U32.is_eq(runs,2),value)
def captured(~S:Data,~H:Type,scope:H,reader:Reader(~S),state:Array<U32>,+runs:U32,value:String,result:Body.Captured() & String) -> H & (Local<S> & Sys.Completion<String,String>):
  match result:
    case (capture,text):(scope,(Local{Some{reader},Capture.Local{state,capture}},completion(runs,value ++ "/runs=" ++ U32.show(runs) ++ "/capture=" ++ text)))
def advanced(~S:Data,~H:Type,scope:H,reader:Reader(~S),capture:Body.Captured(),value:String,result:Array<U32> & U32) -> H & (Local<S> & Sys.Completion<String,String>):
  match result:
    case (state,runs):captured(~S,~H,scope,reader,state,runs,value,Capture.invoke(~Body.Context,~Unit,~String,~Body.append,capture,Unit{}))
def read(~S:Data,~H:Type,retained:Body.Local(),result:H & Stream.Reading<S,D.Key,D.Mode,D.layout(S),Layout.AtLeaf{}>) -> H & (Local<S> & Sys.Completion<String,String>):
  match retained result:
    case retained, (scope,Stream.Refused{reader}):(scope,(Local{Some{reader},retained},Sys.BodyError{"foreign-reader","refused"}))
    case Capture.Local{state,capture}, (scope,Stream.Read{reader,events,missed,tick}):advanced(~S,~H,scope,reader,capture,"events=" ++ List.show(&2,M.Transition<D.Mode>,event,events) ++ "/missed=" ++ Nat.show(missed) ++ "/tick=" ++ Tick.show(tick),Body.advance(state))
def body_sync(~S:Data,~Permit:Data,~H:Type,~caps:Ops(~S)(Permit,H),scope:H,local:Local<S>) -> H & (Local<S> & Sys.Completion<String,String>):
  match local:
    case Local{None{},retained}:(scope,(Local{None{},retained},Sys.BodyError{"unbound-reader","not-read"}))
    case Local{Some{reader},retained}:read(~S,~H,retained,Events.read_field(~S,~D.Key,~D.Mode,~D.layout(S),~Layout.AtLeaf{},~H,caps)(reader,scope))

def body(~S:Data,~Permit:Data,~H:Type,~caps:Ops(~S)(Permit,H),scope:H,local:Local<S>) -> Effect.Task<S,Permit,H & (Local<S> & Sys.Completion<String,String>)>:
  Effect.TDone{body_sync(~S,~Permit,~H,~caps,scope,local)}

def Owner(~S:Data) -> Type:Sys.Owner<S,D.Store(~S),D.LeftStore(~S),D.Resources(~S),Unit,Ops(~S),Local<S>,String,String,Build.framework_program(~S,~D.Store(~S),~D.LeftStore(~S),~D.Resources(~S),~Ops(~S),~declaration(~S)),body(~S)>
def bound_local(~S:Data,namespace:U32,id:U32,local:Local<S>) -> Local<S>:
  match local:
    case Local{None{},retained}:Local{Some{Stream.Reader{namespace,id,0n}},retained}
    case local:local
# One Reader is bound once from this ordinary owner's actual registration.
# Its id is a stable label; origin+namespace and the actual system grant govern use.
def bound(~S:Data,owner:Owner(~S)) -> Owner(~S):
  match owner:
    case Sys.Owner{+namespace,+id,name,access,cursor,local}:Sys.Owner{namespace,id,name,access,cursor,bound_local(~S,namespace,id,local)}
def defined(~S:Data,~WR:Type,result:Sys.Defined<W.World<S,D.Store(~S),WR,Unit>,Owner(~S),Local<S>>) -> Sys.Defined<W.World<S,D.Store(~S),WR,Unit>,Owner(~S),Local<S>>:
  match result:
    case Sys.Defined{world,owner}:Sys.Defined{world,bound(~S,owner)}
    case Sys.DefinitionRefused{world,local}:Sys.DefinitionRefused{world,local}
def define(~S:Data,~WR:Type,world:W.World<S,D.Store(~S),WR,Unit>,name:String,retained:Body.Local()) -> Sys.Defined<W.World<S,D.Store(~S),WR,Unit>,Owner(~S),Local<S>>:
  defined(~S,~WR,Task.define(~S,~D.Store(~S),~D.LeftStore(~S),~D.Resources(~S),~Unit,~Ops(~S),~Local<S>,~String,~String,~declaration(~S),~body(~S),~WR,world,name,Local{None{},retained}))

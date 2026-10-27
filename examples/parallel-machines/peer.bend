import Base
import ../../src/ecs/execution-reservation-task.bend as Effect
import ./declarations.bend as D
import ./bodies.bend as Body
import ../../src/ecs/execution-capture.bend as Capture
import ../../src/ecs/execution-access.bend as Access
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/world.bend as W

def Ops(~S:Data,Permit:Data,H:Type) -> Type:Access.ComponentRead<S,H,D.Mode>
def selection(~S:Data,~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~D.RightStore(~S),~Unit,~H,~B),~cw:Build.ComponentWrite(~S,~D.RightStore(~S),~Unit,~H,~B),~rr:Build.ResourceRead(~S,~D.RightStore(~S),~Unit,~H,~B),~rw:Build.ResourceWrite(~S,~D.RightStore(~S),~Unit,~H,~B),~q:Build.Query(~S,~D.Store(~S),~D.RightStore(~S),~Unit,~H,~B),~lifecycle:Build.Lifecycle(~S,~D.Store(~S),~D.RightStore(~S),~Unit,~H,~B),book:B) -> B & Ops(~S,Permit,H):
  cr(D.peer_layout(~S),Layout.AtLeaf{},{==},{==},book)
def declaration(~S:Data,~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~D.Store(~S),~D.RightStore(~S),~Unit,~Permit,~H,~B),book:B) -> B & Ops(~S,Permit,H):
  builder(Ops(~S),selection(~S,~Permit,~H,~B),book)
type Local<-S:Data> is Type:
  Local{handle:W.Handle<S>,retained:Body.Local()}
def completed(~S:Data,~H:Type,scope:H,handle:W.Handle<S>,capture:Body.Captured(),value:String,result:Array<U32> & U32) -> H & (Local<S> & Sys.Completion<String,String>):
  match result:
    case (state,runs):(scope,(Local{handle,Capture.Local{state,capture}},Sys.Success{"peer/" ++ value ++ "/runs=" ++ U32.show(runs)}))
def read(~S:Data,~H:Type,handle:W.Handle<S>,retained:Body.Local(),result:H & Maybe<&2,D.Mode>) -> H & (Local<S> & Sys.Completion<String,String>):
  match retained result:
    case Capture.Local{state,capture}, (scope,None{}):completed(~S,~H,scope,handle,capture,"absent",Body.advance(state))
    case Capture.Local{state,capture}, (scope,Some{mode}):completed(~S,~H,scope,handle,capture,Body.mode_value(mode),Body.advance(state))
def body_sync(~S:Data,~Permit:Data,~H:Type,~caps:Ops(~S,Permit,H),scope:H,local:Local<S>) -> H & (Local<S> & Sys.Completion<String,String>):
  match local:
    case Local{+handle,retained}:read(~S,~H,handle,retained,Access.component_read_field(~S,~H,~D.Mode,caps)(scope,handle))


def body(~S:Data,~Permit:Data,~H:Type,~caps:Ops(~S,Permit,H),scope:H,local:Local<S>) -> Effect.Task<S,Permit,H & (Local<S> & Sys.Completion<String,String>)>:
  Effect.TDone{body_sync(~S,~Permit,~H,~caps,scope,local)}

def Owner(~S:Data) -> Type:Sys.Owner<S,D.Store(~S),D.RightStore(~S),Unit,Unit,Ops(~S),Local<S>,String,String,Build.framework_program(~S,~D.Store(~S),~D.RightStore(~S),~Unit,~Ops(~S),~declaration(~S)),body(~S)>

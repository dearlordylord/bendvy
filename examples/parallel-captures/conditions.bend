import Base
import ./declarations.bend as D
import ./bodies.bend as Body
import ./contexts.bend as Context
import ../../src/ecs/execution-capture.bend as Capture
import ../../src/ecs/execution-access.bend as A
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-system.bend as Sys

def layout() -> Layout.Layout:Layout.LayoutPair{D.left_layout(),D.right_layout()}
def Ops(~S:Data) -> Type -> Type:A.ResourceReads(~String)
def selection(~S:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~cw:Build.ComponentWrite(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~rr:Build.ResourceRead(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~rw:Build.ResourceWrite(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~q:Build.Query(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~lifecycle:Build.Lifecycle(~S,~D.Store(~S),~D.Resources(~S),~H,~B),book:B) -> B & Ops(~S)(H):
  rr(layout(),Layout.InLeft{Layout.AtLeaf{}},{==},{==},book)
def declaration(~S:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~D.Store(~S),~D.Resources(~S),~H,~B),book:B) -> B & Ops(~S)(H):
  builder(Ops(~S),selection(~S,~H,~B),book)
type Context is Type:
  Context{counter:Array<U32>,seen:Array<String>}
def captured_step(seen:Array<String>,value:String,result:Array<U32> & U32) -> Context & U32:
  match result:
    case (counter,count):(Context{counter,Array.set(String,seen,0,value)},count)
def step(context:Context,value:String) -> Context & U32:
  match context:
    case Context{counter,seen}:captured_step(seen,value,Context.count_step(counter,1))
def Captured() -> Type:Capture.Captured<Context,String,U32,step>
def Local() -> Type:Capture.Local<Array<U32>,Captured()>
def local() -> Local():Capture.Local{ANode{ALeaf{901},ALeaf{0}},Capture.bind(~Context,~String,~U32,~step,Context{ANode{ALeaf{902},ALeaf{0}},ALeaf{"unset"}})}
def status_selected(failed:Bool,runs:U32) -> Sys.Completion<String,Bool>:
  match failed:
    case True{}:Sys.BodyError{"condition-after-capture",False{}}
    case False{}:Sys.Success{U32.is_lt(1,runs)}
def status(+runs:U32) -> Sys.Completion<String,Bool>:status_selected(U32.is_eq(runs,2),runs)
def captured(~H:Type,scope:H,state:Array<U32>,result:Captured() & U32) -> H & (Local() & Sys.Completion<String,Bool>):
  match result:
    case (capture,runs):(scope,(Capture.Local{state,capture},status(runs)))
def advanced(~H:Type,scope:H,capture:Captured(),value:String,result:Array<U32> & U32) -> H & (Local() & Sys.Completion<String,Bool>):
  match result:
    case (state,_):captured(~H,scope,state,Capture.invoke(~Context,~String,~U32,~step,capture,value))
def read(~H:Type,state:Array<U32>,capture:Captured(),result:H & String) -> H & (Local() & Sys.Completion<String,Bool>):
  match result:
    case (scope,value):advanced(~H,scope,capture,value,Body.advance(state))
def body(~S:Data,~H:Type,~caps:Ops(~S)(H),scope:H,local:Local()) -> H & (Local() & Sys.Completion<String,Bool>):
  match local:
    case Capture.Local{state,capture}:read(~H,state,capture,A.resource_read_field(~H,~String,caps)(scope))
def observed_seen(state:String,counter:String,result:Array<String> & String) -> String:
  match result:
    case (_,seen):state ++ "/" ++ counter ++ "/seen=" ++ seen
def observed_counter(state:String,seen:Array<String>,result:Array<U32> & String) -> String:
  match result:
    case (_,counter):observed_seen(state,counter,Array.get(String,seen,0))
def observed_state(result:Array<U32> & String,capture:Captured()) -> String:
  match result capture:
    case (_,state) Capture.Captured{Context{counter,seen}}:observed_counter(state,seen,Context.count_snapshot(counter))
def observed(local:Local()) -> String:
  match local:
    case Capture.Local{state,capture}:observed_state(Context.count_snapshot(state),capture)

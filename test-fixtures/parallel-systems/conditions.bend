import Base
import ./declarations.bend as D
import ./payloads.bend as P
import ../../src/ecs/execution-access.bend as A
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/world.bend as W

def layout() -> Layout.Layout:Layout.LayoutPair{D.left_layout(),D.right_layout()}
def Ops(~S:Data) -> Type -> Type:A.ComponentReads(~S,~String)
def selection(~S:Data,~H:Type,~B:Type,~read:Build.ComponentRead(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~write:Build.ComponentWrite(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~resourceRead:Build.ResourceRead(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~resourceWrite:Build.ResourceWrite(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~query:Build.Query(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~lifecycle:Build.Lifecycle(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~H,~B),book:B) -> B & Ops(~S)(H):
  read(layout(),Layout.InLeft{Layout.AtLeaf{}},{==},{==},book)
def declaration(~S:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~H,~B),book:B) -> B & Ops(~S)(H):
  builder(Ops(~S),selection(~S,~H,~B),book)
type Local<-S:Data> is Type:
  Local{token:Array<U32>,runs:U32,last:String,handle:W.Handle<S>}
def status_selected(failed:Bool,runs:U32) -> Sys.Completion<String,Bool>:
  match failed:
    case True{}:Sys.BodyError{"condition-after-read",False{}}
    case False{}:Sys.Success{Bool.not(U32.is_eq(runs,2))}
def status(+runs:U32) -> Sys.Completion<String,Bool>:
  status_selected(U32.is_eq(runs,3),runs)
def value(observed:Maybe<&2,String>) -> String:
  match observed:
    case None{}:"absent"
    case Some{observed}:observed
def counted(~S:Data,~H:Type,token:Array<U32>,+runs:U32,handle:W.Handle<S>,result:H & Maybe<&2,String>) -> H & (Local<S> & Sys.Completion<String,Bool>):
  match result:
    case (scope,observed):(scope,(Local{token,runs,value(observed),handle},status(runs)))
def body(~S:Data,~H:Type,~caps:Ops(~S)(H),scope:H,local:Local<S>) -> H & (Local<S> & Sys.Completion<String,Bool>):
  match local:
    case Local{token,runs,_,+handle}:counted(~S,~H,token,U32.add(runs,1),handle,A.component_read_field(~S,~H,~String,caps)(scope,handle))
def observed_counted(runs:U32,last:String,result:Array<U32> & U32) -> String:
  match result:
    case (_,token):U32.show(token) ++ ":" ++ U32.show(runs) ++ ":" ++ last
def observed(~S:Data,local:Local<S>) -> String:
  match local:
    case Local{token,runs,last,_}:observed_counted(runs,last,Array.get(U32,token,0))

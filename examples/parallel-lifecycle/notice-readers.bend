import Base
import ./notice-observation.bend as Observe
import ../parallel-query/commands-core.bend as Core
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-lifecycle-access.bend as Life
import ../../src/ecs/execution-lifecycle-notices.bend as Notice
import ../../src/ecs/execution-system.bend as Sys

def output_route() -> Layout.Route:Layout.InLeft{Layout.InLeft{Layout.InRight{Layout.AtLeaf{}}}}
def input_route() -> Layout.Route:Layout.InLeft{Layout.InLeft{Layout.InLeft{Layout.AtLeaf{}}}}
def output_origin() -> Layout.Layout:Layout.origin(Core.layout(~Unit),output_route())
def input_origin() -> Layout.Layout:Layout.origin(Core.layout(~Unit),input_route())
def OutputReader(~S:Data) -> Type:Notice.Reader<S,output_origin(),Notice.Removed{"output"}>
def InputReader(~S:Data) -> Type:Notice.Reader<S,input_origin(),Notice.Removed{"input"}>
def DespawnReader(~S:Data) -> Type:Notice.Reader<S,Layout.EmptyLayout{},Notice.Despawned{}>
type Captures<-S:Data> is Type:
  Captures{token:Array<U32>,runs:U32,fast:OutputReader(~S),slow:OutputReader(~S),input:InputReader(~S),despawn:DespawnReader(~S),history:String}
def OutputOps(~S:Data,H:Type) -> Type:Life.Next<S,H,output_origin(),Notice.Removed{"output"}>
def InputOps(~S:Data,H:Type) -> Type:Life.Next<S,H,input_origin(),Notice.Removed{"input"}>
def DespawnOps(~S:Data,H:Type) -> Type:Life.Next<S,H,Layout.EmptyLayout{},Notice.Despawned{}>
type Caps<-S:Data,-H:Type> is Type:
  Caps{output:OutputOps(~S,H),input:InputOps(~S,H),despawn:DespawnOps(~S,H)}
def Ops(~S:Data,H:Type) -> Type:Caps<S,H>
def output_cap(~S:Data,~H:Type,cap:Caps<S,H>) -> OutputOps(~S,H):
  match cap:
    case Caps{output,_,_}:output
def input_cap(~S:Data,~H:Type,cap:Caps<S,H>) -> InputOps(~S,H):
  match cap:
    case Caps{_,input,_}:input
def despawn_cap(~S:Data,~H:Type,cap:Caps<S,H>) -> DespawnOps(~S,H):
  match cap:
    case Caps{_,_,despawn}:despawn
def output_selection(~S:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~Unit,~Unit,~H,~B),~cw:Build.ComponentWrite(~S,~Unit,~Unit,~H,~B),~rr:Build.ResourceRead(~S,~Unit,~Unit,~H,~B),~rw:Build.ResourceWrite(~S,~Unit,~Unit,~H,~B),~query:Build.Query(~S,~Unit,~Unit,~H,~B),~lifecycle:Build.Lifecycle(~S,~Core.Store(~S),~Unit,~Unit,~H,~B),book:B) -> B & OutputOps(~S,H):
  Build.removed_lifecycle(~S,~Core.Store(~S),~Unit,~Unit,~Core.layout(~S),~output_route(),~{==},~{==},~H,~B,~lifecycle,book)
def input_selection(~S:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~Unit,~Unit,~H,~B),~cw:Build.ComponentWrite(~S,~Unit,~Unit,~H,~B),~rr:Build.ResourceRead(~S,~Unit,~Unit,~H,~B),~rw:Build.ResourceWrite(~S,~Unit,~Unit,~H,~B),~query:Build.Query(~S,~Unit,~Unit,~H,~B),~lifecycle:Build.Lifecycle(~S,~Core.Store(~S),~Unit,~Unit,~H,~B),book:B) -> B & InputOps(~S,H):
  Build.removed_lifecycle(~S,~Core.Store(~S),~Unit,~Unit,~Core.layout(~S),~input_route(),~{==},~{==},~H,~B,~lifecycle,book)
def despawn_selection(~S:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~Unit,~Unit,~H,~B),~cw:Build.ComponentWrite(~S,~Unit,~Unit,~H,~B),~rr:Build.ResourceRead(~S,~Unit,~Unit,~H,~B),~rw:Build.ResourceWrite(~S,~Unit,~Unit,~H,~B),~query:Build.Query(~S,~Unit,~Unit,~H,~B),~lifecycle:Build.Lifecycle(~S,~Core.Store(~S),~Unit,~Unit,~H,~B),book:B) -> B & DespawnOps(~S,H):
  Build.despawn_lifecycle(~S,~Core.Store(~S),~Unit,~Unit,~H,~B,~lifecycle,book)

def despawn_declared(~S:Data,~H:Type,~B:Type,output:OutputOps(~S,H),input:InputOps(~S,H),result:B & DespawnOps(~S,H)) -> B & Ops(~S,H):
  match result:
    case (book,despawn):(book,Caps{output,input,despawn})
def input_declared(~S:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~Core.Store(~S),~Unit,~Unit,~H,~B),output:OutputOps(~S,H),result:B & InputOps(~S,H)) -> B & Ops(~S,H):
  match result:
    case (book,input):despawn_declared(~S,~H,~B,output,input,builder(DespawnOps(~S),despawn_selection(~S,~H,~B),book))
def output_declared(~S:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~Core.Store(~S),~Unit,~Unit,~H,~B),result:B & OutputOps(~S,H)) -> B & Ops(~S,H):
  match result:
    case (book,output):input_declared(~S,~H,~B,~builder,output,builder(InputOps(~S),input_selection(~S,~H,~B),book))
def declaration(~S:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~Core.Store(~S),~Unit,~Unit,~H,~B),book:B) -> B & Ops(~S,H):
  output_declared(~S,~H,~B,~builder,builder(OutputOps(~S),output_selection(~S,~H,~B),book))
def reason(value:Notice.Refusal) -> String:
  match value:
    case Notice.ForeignWorld{}:"foreign-world"
    case Notice.Inactive{}:"inactive"
    case Notice.ReaderLimit{}:"reader-limit"
def reading(~S:Data,~origin:Layout.Layout,~selector:Notice.Selector,~H:Type,result:H & Notice.Reading<S,origin,selector>) -> H & (Notice.Reader<S,origin,selector> & String):
  match result:
    case (scope,Notice.Empty{reader,missed}):(scope,(reader,"empty/missed=" ++ Nat.show(missed)))
    case (scope,Notice.Item{reader,row,missed}):(scope,(reader,"item=" ++ Observe.row(~S,row) ++ "/missed=" ++ Nat.show(missed)))
    case (scope,Notice.ReadRefused{reader,error}):(scope,(reader,"refused/" ++ reason(error)))
def slow_read(~S:Data,~H:Type,~cap:OutputOps(~S,H),scope:H,reader:OutputReader(~S),enabled:Bool) -> H & (OutputReader(~S) & String):
  match enabled:
    case False{}:(scope,(reader,"dormant"))
    case True{}:reading(~S,~output_origin(),~(Notice.Removed{"output"}),~H,Life.next(~S,~H,~output_origin(),~(Notice.Removed{"output"}),cap,scope,reader))
def completion(runs:U32,text:String) -> Sys.Completion<String,String>:
  match runs:
    case 0:Sys.BodyError{"after-reader-yield",text}
    case _:Sys.Success{text}
def finished_token(~S:Data,~H:Type,scope:H,+runs:U32,fast:OutputReader(~S),slow:OutputReader(~S),input:InputReader(~S),despawn:DespawnReader(~S),+history:String,result:Array<U32> & U32) -> H & (Captures<S> & Sys.Completion<String,String>):
  match result:
    case (token,value):(scope,(Captures{Array.set(U32,token,0,U32.add(value,1)),U32.add(runs,1),fast,slow,input,despawn,history},completion(runs,history)))
def despawn_read(~S:Data,~H:Type,token:Array<U32>,runs:U32,fast:OutputReader(~S),slow:OutputReader(~S),input:InputReader(~S),history:String,result:H & (DespawnReader(~S) & String)) -> H & (Captures<S> & Sys.Completion<String,String>):
  match result:
    case (scope,(despawn,text)):finished_token(~S,~H,scope,runs,fast,slow,input,despawn,history ++ "/despawn=" ++ text ++ ";",Array.get(U32,token,0))
def input_read(~S:Data,~H:Type,~caps:Ops(~S,H),token:Array<U32>,runs:U32,fast:OutputReader(~S),slow:OutputReader(~S),despawn:DespawnReader(~S),history:String,result:H & (InputReader(~S) & String)) -> H & (Captures<S> & Sys.Completion<String,String>):
  match result:
    case (scope,(input,text)):despawn_read(~S,~H,token,runs,fast,slow,input,history ++ "/input=" ++ text,reading(~S,~Layout.EmptyLayout{},~Notice.Despawned{},~H,Life.next(~S,~H,~Layout.EmptyLayout{},~Notice.Despawned{},despawn_cap(~S,~H,caps),scope,despawn)))
def slow_returned(~S:Data,~H:Type,~caps:Ops(~S,H),token:Array<U32>,runs:U32,fast:OutputReader(~S),input:InputReader(~S),despawn:DespawnReader(~S),history:String,result:H & (OutputReader(~S) & String)) -> H & (Captures<S> & Sys.Completion<String,String>):
  match result:
    case (scope,(slow,text)):input_read(~S,~H,~caps,token,runs,fast,slow,despawn,history ++ "/slow=" ++ text,reading(~S,~input_origin(),~(Notice.Removed{"input"}),~H,Life.next(~S,~H,~input_origin(),~(Notice.Removed{"input"}),input_cap(~S,~H,caps),scope,input)))
def fast_read(~S:Data,~H:Type,~caps:Ops(~S,H),token:Array<U32>,+runs:U32,slow:OutputReader(~S),input:InputReader(~S),despawn:DespawnReader(~S),history:String,result:H & (OutputReader(~S) & String)) -> H & (Captures<S> & Sys.Completion<String,String>):
  match result:
    case (scope,(fast,text)):slow_returned(~S,~H,~caps,token,runs,fast,input,despawn,history ++ "update=" ++ U32.show(runs) ++ "/fast=" ++ text,slow_read(~S,~H,~(output_cap(~S,~H,caps)),scope,slow,U32.is_le(2,runs)))
def body(~S:Data,~H:Type,~caps:Ops(~S,H),scope:H,local:Captures<S>) -> H & (Captures<S> & Sys.Completion<String,String>):
  match local:
    case Captures{token,runs,fast,slow,input,despawn,history}:fast_read(~S,~H,~caps,token,runs,slow,input,despawn,history,reading(~S,~output_origin(),~(Notice.Removed{"output"}),~H,Life.next(~S,~H,~output_origin(),~(Notice.Removed{"output"}),output_cap(~S,~H,caps),scope,fast)))
def reader_text(~S:Data,~origin:Layout.Layout,~selector:Notice.Selector,value:Notice.Reader<S,origin,selector>) -> String:
  match value:
    case Notice.Reader{namespace,id,cursor}:U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ Nat.show(cursor)
def token_text(result:Array<U32> & U32) -> String:
  match result:
    case (_,value):U32.show(value)
def observed(~S:Data,local:Captures<S>) -> String:
  match local:
    case Captures{token,runs,fast,slow,input,despawn,history}:"token=" ++ token_text(Array.get(U32,token,0)) ++ ";runs=" ++ U32.show(runs) ++ ";fast=" ++ reader_text(~S,~output_origin(),~(Notice.Removed{"output"}),fast) ++ ";slow=" ++ reader_text(~S,~output_origin(),~(Notice.Removed{"output"}),slow) ++ ";input=" ++ reader_text(~S,~input_origin(),~(Notice.Removed{"input"}),input) ++ ";despawn=" ++ reader_text(~S,~Layout.EmptyLayout{},~Notice.Despawned{},despawn) ++ ";history=" ++ history

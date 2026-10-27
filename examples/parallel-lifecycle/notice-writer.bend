import Base
import ../parallel-query/payloads.bend as P
import ../parallel-query/commands-core.bend as Core
import ../parallel-query/command-row.bend as Row
import ../parallel-query/body.bend as Body
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-command-local.bend as Local
import ../parallel-query/declarations.bend as D
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/execution-composer-layout.bend as Layout

def row_returned(~S:Data,~O:Type,output:O,index:U32,result:P.Output & Maybe<&2,String>) -> P.Output & (O & Maybe<&2,String>):
  match result:
    case (owner,_):(owner,(output,Row.command_error(index)))
def row_indexed(~S:Data,~O:Type,step:U32,owner:P.Output,output:O,result:W.Handle<S> & U32) -> P.Output & (O & Maybe<&2,String>):
  match result:
    case (_, +index):row_returned(~S,~O,output,index,P.update(index,step,owner))
def row(~S:Data,~O:Type,handle:W.Handle<S>,step:U32,owner:P.Output,output:O) -> P.Output & (O & Maybe<&2,String>):
  row_indexed(~S,~O,step,owner,output,Row.indexed(~S,handle))
def route() -> Layout.Route:Layout.InLeft{Layout.AtLeaf{}}
def QueryOps(~S:Data,H:Type,O:Type) -> Type:Q.OutputEach<S,H,O,String>
def selection(~S:Data,~WC:Type,~mode:Q.Mode,~H:Type,~O:Type,~commands:Local.Commands<O,S,P.Output>,~B:Type,~component_read:Build.ComponentRead(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~component_write:Build.ComponentWrite(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~resource_read:Build.ResourceRead(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~resource_write:Build.ResourceWrite(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~query:Build.Query(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~lifecycle:Build.Lifecycle(~S,~WC,~D.Store(~S),~D.Resources(~S),~H,~B),book:B) -> B & QueryOps(~S,H,O):
  Build.output_query(~S,~D.Store(~S),~D.Resources(~S),~D.layout(),~route(),~{==},~{==},~{==},~O,~String,~Local.split_field(~O,~S,~P.Output,commands),~Local.merge_field(~O,~S,~P.Output,commands),~row(~S,~O),~mode,~H,~B,~query,book)
def declaration(~S:Data,~WC:Type,~mode:Q.Mode,~H:Type,~O:Type,~commands:Local.Commands<O,S,P.Output>,~B:Type,~builder:Build.Builder(~S,~WC,~D.Store(~S),~D.Resources(~S),~H,~B),book:B) -> B & QueryOps(~S,H,O):
  builder(Q.OutputOps(~S,~O,~String),selection(~S,~WC,~mode,~H,~O,~commands,~B),book)
type Caps<-S:Data,-H:Type,-O:Type> is Type:
  Caps{entity:Permission.EntityCommands<O,S,Core.layout(~S)>,query:QueryOps(~S,H,O)}
def Ops(~S:Data,H:Type,O:Type) -> Type:Caps<S,H,O>
def entity_cap(~S:Data,~H:Type,~O:Type,caps:Ops(~S,H,O)) -> Permission.EntityCommands<O,S,Core.layout(~S)>:
  match caps:
    case Caps{entity,_}:entity
def query_cap(~S:Data,~H:Type,~O:Type,caps:Ops(~S,H,O)) -> QueryOps(~S,H,O):
  match caps:
    case Caps{_,query}:query
def granted(~S:Data,~H:Type,~O:Type,~B:Type,~K:Type,query:QueryOps(~S,H,O),book:B,result:K & Permission.EntityCommands<O,S,Core.layout(~S)>) -> B & (K & Ops(~S,H,O)):
  match result:
    case (permission,entity):(book,(permission,Caps{entity,query}))
def declared(~S:Data,~H:Type,~O:Type,~B:Type,~K:Type,~entity:Permission.Grant(~S,~Core.layout(~S),~O,~K),permission:K,result:B & QueryOps(~S,H,O)) -> B & (K & Ops(~S,H,O)):
  match result:
    case (book,query):granted(~S,~H,~O,~B,~K,query,book,entity(permission))
def author_declaration(~S:Data,~mode:Q.Mode,~H:Type,~O:Type,~commands:Local.Commands<O,S,P.Output>,~B:Type,~builder:Build.Builder(~S,~Core.Store(~S),~Core.Left(~S),~D.Resources(~S),~H,~B),~K:Type,~entity:Permission.Grant(~S,~Core.layout(~S),~O,~K),book:B,permission:K) -> B & (K & Ops(~S,H,O)):
  declared(~S,~H,~O,~B,~K,~entity,permission,declaration(~S,~Core.Store(~S),~mode,~H,~O,~commands,~B,~builder,book))
type User<-S:Data> is Type:
  User{token:Array<U32>,runs:U32,handles:List<&2,W.Handle<S>>}
def queue_chosen(~S:Data,~O:Type,~commands:Local.Commands<O,S,P.Output>,~entity:Permission.EntityCommands<O,S,Core.layout(~S)>,handle:W.Handle<S>,output:O,index:U32) -> O:
  match index:
    case 1:Local.remove_field(~O,~S,~P.Output,commands)(output,handle)
    case 17:Permission.despawn_field(~O,~S,~Core.layout(~S),entity)(output,handle)
    case _:output
def queue(~S:Data,~O:Type,~commands:Local.Commands<O,S,P.Output>,~entity:Permission.EntityCommands<O,S,Core.layout(~S)>,handles:List<&2,W.Handle<S>>,output:O) -> O:
  match handles:
    case []:output
    case +handle <> rest:queue(~S,~O,~commands,~entity,rest,queue_chosen(~S,~O,~commands,~entity,handle,output,W.handle_index(~S,handle)))
def queued(~S:Data,~O:Type,~commands:Local.Commands<O,S,P.Output>,~entity:Permission.EntityCommands<O,S,Core.layout(~S)>,handles:List<&2,W.Handle<S>>,output:O,runs:U32) -> O:
  match runs:
    case 0:queue(~S,~O,~commands,~entity,handles,output)
    case _:output
def completed(~S:Data,~H:Type,~O:Type,user:User<S>,result:H & (O & Q.Report<String>)) -> H & (O & (User<S> & Sys.Completion<String,String>)):
  match result:
    case (scope,(output,Q.Completed{errors})):(scope,(output,(user,Body.completion(errors))))
    case (scope,(output,Q.LayoutRefused{})):(scope,(output,(user,Sys.BodyError{"query-refused","not-invoked"})))
def counted(~S:Data,~H:Type,~O:Type,~caps:Ops(~S,H,O),~commands:Local.Commands<O,S,P.Output>,scope:H,output:O,+runs:U32,+handles:List<&2,W.Handle<S>>,result:Array<U32> & U32) -> H & (O & (User<S> & Sys.Completion<String,String>)):
  match result:
    case (token,value):completed(~S,~H,~O,User{Array.set(U32,token,0,U32.add(value,1)),U32.add(runs,1),handles},Q.each_output(~S,~H,~O,~String,query_cap(~S,~H,~O,caps))(scope,queued(~S,~O,~commands,~(entity_cap(~S,~H,~O,caps)),handles,output,runs)))
def body(~S:Data,~H:Type,~O:Type,~caps:Ops(~S,H,O),~commands:Local.Commands<O,S,P.Output>,scope:H,output:O,user:User<S>) -> H & (O & (User<S> & Sys.Completion<String,String>)):
  match user:
    case User{token,runs,handles}:counted(~S,~H,~O,~caps,~commands,scope,output,runs,handles,Array.get(U32,token,0))

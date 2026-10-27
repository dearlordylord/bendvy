import Base
import ../../src/ecs/execution-inspector-commands.bend as Passive
import ../../src/ecs/execution-lifetime-scope-description.bend as LinkedText
import ../../src/ecs/execution-lifetime-scope-command.bend as ScopeCommands
import ../../src/ecs/relation-types.bend as RelationTypes
import ./app-b-schema.bend as D
import ./app-b-commands.bend as Author
import ./app-b-application.bend as App
import ./app-b-inspection.bend as Inspect
import ../../src/ecs/world.bend as W
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-command-removed.bend as Removed
import ../../src/ecs/execution-relation-operation.bend as Operation
import ../../src/ecs/execution-relation-store.bend as Store
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-parallel-root-application.bend as Root
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/dependency-application.bend as State
import ../../src/ecs/chunk-column.bend as Column
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/execution-reservation-bundle.bend as Bundle
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/execution-parallel-registration.bend as Registration
import ../../src/ecs/execution-query-identity.bend as Identity

def value_text(result:Array<U32> & List<&2,U32>) -> Array<U32> & String:
  match result:
    case (owner,values):(owner,Inspect.values(values))
def array(owner:Array<U32>) -> Array<U32> & String:value_text(D.project(owner))
def maybe_array_returned(result:Array<U32> & String) -> Maybe<&1,Array<U32>> & String:
  match result:
    case (owner,text):(Some{owner},text)
def maybe_array(owner:Maybe<&1,Array<U32>>) -> Maybe<&1,Array<U32>> & String:
  match owner:
    case None{}:(None{},"none")
    case Some{owner}:maybe_array_returned(array(owner))
def bundle_returned(scalar:Maybe<&1,U32>,result:Maybe<&1,Array<U32>> & String) -> Removed.Removed(D.components()) & String:
  match scalar result:
    case None{}, (owner,text):(Product.Owner{owner,None{}},text ++ "/none")
    case Some{+value}, (owner,text):(Product.Owner{owner,Some{value}},text ++ "/" ++ U32.show(value))
def bundle(owner:Removed.Removed(D.components())) -> Removed.Removed(D.components()) & String:
  match owner:
    case Product.Owner{values,scalar}:bundle_returned(scalar,maybe_array(values))
def operation(value:Operation.Operation<D.Scene>) -> String:
  match value:
    case Operation.Relate{source,target}:"relate(" ++ Inspect.handle(source) ++ "," ++ Inspect.handle(target) ++ ")"
    case Operation.Unrelate{source}:"unrelate(" ++ Inspect.handle(source) ++ ")"
    case Operation.Reorder{parent,children}:"reorder(" ++ Inspect.handle(parent) ++ "," ++ List.show(&2,W.Handle<D.Scene>,Inspect.handle,children) ++ ")"
def entry_spawn(+handle:W.Handle<D.Scene>,result:Removed.Removed(D.components()) & String) -> Buffer.Entry<D.Scene,Array<U32>,Removed.Removed(D.components())> & String:
  match result:
    case (owner,text):(Buffer.Spawn{handle,owner},"spawn:" ++ Inspect.handle(handle) ++ "/" ++ text)
def entry_component(+handle:W.Handle<D.Scene>,result:Maybe<&1,Array<U32>> & String) -> Buffer.Entry<D.Scene,Array<U32>,Removed.Removed(D.components())> & String:
  match result:
    case (owner,text):(Buffer.Entry{handle,owner},"component:" ++ Inspect.handle(handle) ++ "/" ++ text)
def entry(owner:Buffer.Entry<D.Scene,Array<U32>,Removed.Removed(D.components())>) -> Buffer.Entry<D.Scene,Array<U32>,Removed.Removed(D.components())> & String:
  match owner:
    case Buffer.Spawn{+handle,payload}:entry_spawn(handle,bundle(payload))
    case Buffer.Entry{+handle,payload}:entry_component(handle,maybe_array(payload))
    case Buffer.Despawn{+handle}:(Buffer.Despawn{handle},"despawn:" ++ Inspect.handle(handle))
    case Buffer.Relation{+route,+value}:(Buffer.Relation{route,value},operation(value))
    case Buffer.LifetimeScope{+route,+value}:(Buffer.LifetimeScope{route,value},"lifetime-scope:" ++ LinkedText.operation(~D.Scene,value))
def receipt_bundle(+handle:W.Handle<D.Scene>,kind:Bool,result:Removed.Removed(D.components()) & String) -> Buffer.Receipt<D.Scene,Array<U32>,Removed.Removed(D.components())> & String:
  match kind result:
    case True{}, (owner,text):(Buffer.Spawned{handle,owner},"spawned:" ++ Inspect.handle(handle) ++ "/previous=" ++ text)
    case False{}, (owner,text):(Buffer.Despawned{handle,owner},"despawned:" ++ Inspect.handle(handle) ++ "/removed=" ++ text)
def receipt_component(+handle:W.Handle<D.Scene>,kind:Bool,result:Maybe<&1,Array<U32>> & String) -> Buffer.Receipt<D.Scene,Array<U32>,Removed.Removed(D.components())> & String:
  match kind result:
    case True{}, (owner,text):(Buffer.Applied{handle,owner},"applied:" ++ Inspect.handle(handle) ++ "/previous=" ++ text)
    case False{}, (owner,text):(Buffer.Refused{handle,owner},"refused:" ++ Inspect.handle(handle) ++ "/incoming=" ++ text)
def spawn_refused(+handle:W.Handle<D.Scene>,+reason:Bundle.Refusal,result:Removed.Removed(D.components()) & String) -> Buffer.Receipt<D.Scene,Array<U32>,Removed.Removed(D.components())> & String:
  match result:
    case (owner,text):(Buffer.SpawnRefused{handle,owner,reason},"spawn-refused:" ++ Inspect.handle(handle) ++ "/" ++ text)
def relation_receipt(value:Store.Receipt<D.Scene>) -> String:
  match value:
    case Store.Applied{value}:"relation-applied:" ++ operation(value)
    case Store.Refused{value,_}:"relation-refused:" ++ operation(value)
def linked_seen(+handle:W.Handle<D.Scene>,+status:Buffer.LinkedStatus,+frames:List<&2,RelationTypes.CleanupFrame<D.Scene>>,result:List<Buffer.Receipt<D.Scene,Array<U32>,Removed.Removed(D.components())>> & List<&2,Passive.Receipt<D.Scene>>) -> Buffer.Receipt<D.Scene,Array<U32>,Removed.Removed(D.components())> & String:
  match result:
    case (actual,facts):(Buffer.LinkedDespawn{handle,status,actual,frames},"linked-despawn:" ++ Inspect.handle(handle) ++ ":" ++ LinkedText.linked_status(status) ++ ":nested=" ++ Nat.show(List.length(&2,Passive.Receipt<D.Scene>,facts)))
def rows_join(~P:Type,head:P & String,tail:List<P> & List<&2,String>) -> List<P> & List<&2,String>:
  match head tail:
    case (head,text), (tail,texts):(head <> tail,text <> texts)
def rows(~P:Type,~observe:P -> P & String,owners:List<P>) -> List<P> & List<&2,String>:
  match owners:
    case []:([],[])
    case head <> tail:rows_join(~P,observe(head),rows(~P,~observe,tail))
def scoped_seen(+route:L.Route,+operation:ScopeCommands.Operation<D.Scene>,+status:Buffer.ScopeStatus,+frames:List<&2,RelationTypes.CleanupFrame<D.Scene>>,result:List<Buffer.Receipt<D.Scene,Array<U32>,Removed.Removed(D.components())>> & List<&2,String>) -> Buffer.Receipt<D.Scene,Array<U32>,Removed.Removed(D.components())> & String:
  match result:
    case (actual,texts):(Buffer.ScopePublished{route,operation,status,actual,frames},"scope-published:" ++ LinkedText.operation(~D.Scene,operation) ++ ":" ++ LinkedText.status(status) ++ ":nested=" ++ List.show(&2,String,text => text,texts) ++ ":frames=" ++ Nat.show(List.length(&2,RelationTypes.CleanupFrame<D.Scene>,frames)))
def receipt(owner:Buffer.Receipt<D.Scene,Array<U32>,Removed.Removed(D.components())>) -> Buffer.Receipt<D.Scene,Array<U32>,Removed.Removed(D.components())> & String:
  match owner:
    case Buffer.Spawned{handle,previous}:receipt_bundle(handle,True{},bundle(previous))
    case Buffer.Despawned{handle,removed}:receipt_bundle(handle,False{},bundle(removed))
    case Buffer.Applied{handle,previous}:receipt_component(handle,True{},maybe_array(previous))
    case Buffer.Refused{handle,incoming}:receipt_component(handle,False{},maybe_array(incoming))
    case Buffer.SpawnRefused{handle,incoming,reason}:spawn_refused(handle,reason,bundle(incoming))
    case Buffer.DespawnRefused{+handle}:(Buffer.DespawnRefused{handle},"despawn-refused:" ++ Inspect.handle(handle))
    case Buffer.LinkedDespawn{handle,status,children,frames}:linked_seen(handle,status,frames,Passive.receipts(D.Scene,Array<U32>,Removed.Removed(D.components()),children))
    case Buffer.RelationPublished{+route,+value}:(Buffer.RelationPublished{route,value},relation_receipt(value))
    case Buffer.RelationUndeclared{+route,+value}:(Buffer.RelationUndeclared{route,value},"relation-undeclared:" ++ operation(value))
    case Buffer.ScopePublished{route,operation,status,children,frames}:scoped_seen(route,operation,status,frames,rows(~Buffer.Receipt<D.Scene,Array<U32>,Removed.Removed(D.components())>,~receipt,children))
    case Buffer.ScopeStoreApplied{+route,+request,+result}:(Buffer.ScopeStoreApplied{route,request,result},"scope-store:" ++ LinkedText.request(~D.Scene,request) ++ ":" ++ LinkedText.outcome(~D.Scene,result))
def identity(value:String) -> String:value
def strings(values:List<&2,String>) -> String:List.show(&2,String,identity,values)
def buffer_returned(pending:List<Buffer.Entry<D.Scene,Array<U32>,Removed.Removed(D.components())>> & List<&2,String>,receipts:Author.Receipts() & List<&2,String>) -> Buffer.Buffer<D.Scene,Array<U32>,Removed.Removed(D.components())> & String:
  match pending receipts:
    case (pending,texts), (receipts,results):(Buffer.Buffer{pending,receipts},"pending=" ++ strings(List.reverse(&2,String,texts)) ++ ";receipts=" ++ strings(List.reverse(&2,String,results)))
def buffer(owner:Buffer.Buffer<D.Scene,Array<U32>,Removed.Removed(D.components())>) -> Buffer.Buffer<D.Scene,Array<U32>,Removed.Removed(D.components())> & String:
  match owner:
    case Buffer.Buffer{pending,receipts}:buffer_returned(rows(~Buffer.Entry<D.Scene,Array<U32>,Removed.Removed(D.components())>,~entry,pending),rows(~Buffer.Receipt<D.Scene,Array<U32>,Removed.Removed(D.components())>,~receipt,receipts))
def viewed_again(+cache:List<&2,U32>,first:String,result:Array<U32> & String) -> L.Viewed<Array<U32>,List<&2,U32>> & String:
  match result:
    case (owner,text):(L.Viewed{owner,cache},"raw=" ++ first ++ "/again=" ++ text ++ "/cache=" ++ Inspect.values(cache))
def viewed_first(cache:List<&2,U32>,result:Array<U32> & String) -> L.Viewed<Array<U32>,List<&2,U32>> & String:
  match result:
    case (owner,text):viewed_again(cache,text,array(owner))
def viewed(owner:L.Viewed<Array<U32>,List<&2,U32>>) -> L.Viewed<Array<U32>,List<&2,U32>> & String:
  match owner:
    case L.Viewed{owner,cache}:viewed_first(cache,array(owner))
def column_seen(continue:Column.Column<D.Scene,L.Viewed<Array<U32>,List<&2,U32>>> -> List<&2,String> -> Column.Column<D.Scene,L.Viewed<Array<U32>,List<&2,U32>>> & String,texts:List<&2,String>,result:Column.Column<D.Scene,L.Viewed<Array<U32>,List<&2,U32>>> & Maybe<&2,String>) -> Column.Column<D.Scene,L.Viewed<Array<U32>,List<&2,U32>>> & String:
  match result:
    case (column,None{}):continue(column,"absent" <> texts)
    case (column,Some{text}):continue(column,text <> texts)
def column_rows(offsets:List<&2,Identity.Offset<D.Scene>>,column:Column.Column<D.Scene,L.Viewed<Array<U32>,List<&2,U32>>>,texts:List<&2,String>) -> Column.Column<D.Scene,L.Viewed<Array<U32>,List<&2,U32>>> & String:
  match offsets:
    case []:(column,strings(List.reverse(&2,String,texts)))
    case Identity.Physical{_,index} <> tail:column_seen(column=>texts=>column_rows(tail,column,texts),texts,Column.view(~D.Scene,~L.Viewed<Array<U32>,List<&2,U32>>,~String,~viewed,column,index))
    case _ <> tail:column_rows(tail,column,"not-live" <> texts)
def columns_returned(scalars:App.CR(),result:Column.Column<D.Scene,L.Viewed<Array<U32>,List<&2,U32>>> & String) -> App.Columns() & String:
  match result:
    case (column,text):(Product.Owner{L.ColumnSlot{column},scalars},text)
def offsets(+namespace:U32,+live:List<&2,W.Handle<D.Scene>>,handles:List<&2,W.Handle<D.Scene>>) -> List<&2,Identity.Offset<D.Scene>>:
  match handles:
    case []:[]
    case handle <> rest:Identity.checked_offset(~D.Scene,namespace,live,Column.maximum_capacity(),handle) <> offsets(namespace,live,rest)
def columns(offsets:List<&2,Identity.Offset<D.Scene>>,columns:App.Columns()) -> App.Columns() & String:
  match columns:
    case Product.Owner{L.ColumnSlot{arrays},scalars}:columns_returned(scalars,column_rows(offsets,arrays,[]))
def world_live(namespace:U32,handles:List<&2,W.Handle<D.Scene>>,result:App.World() & List<&2,W.Handle<D.Scene>>) -> App.World() & String:
  match result:
    case (world,live):W.with_store(~D.Scene,~App.Columns(),~App.Resources(),~Unit,~String,columns(offsets(namespace,live,handles)),world)
def world_namespace(handles:List<&2,W.Handle<D.Scene>>,result:App.World() & U32) -> App.World() & String:
  match result:
    case (world,namespace):world_live(namespace,handles,W.handles(~D.Scene,~App.Columns(),~App.Resources(),~Unit,world))
def world_owners(handles:List<&2,W.Handle<D.Scene>>,world:App.World()) -> App.World() & String:
  world_namespace(handles,W.namespace(~D.Scene,~App.Columns(),~App.Resources(),~Unit,world))
def author_returned(+namespace:U32,+id:U32,+name:String,+access:List<&2,String>,+cursor:Maybe<&2,Tick.Tick>,user:Author.User,permission:Permission.Permission,result:Buffer.Buffer<D.Scene,Array<U32>,Removed.Removed(D.components())> & String) -> Author.Owner() & String:
  match result:
    case (commands,text):(Cmd.Owner{Sys.Owner{namespace,id,name,access,cursor,Local.Local{user,commands,permission}}},text ++ ";author=" ++ U32.show(namespace) ++ "/" ++ U32.show(id) ++ "/cursor=" ++ Tick.cursor_show(cursor))
def author(owner:Author.Owner()) -> Author.Owner() & String:
  match owner:
    case Cmd.Owner{Sys.Owner{namespace,id,name,access,cursor,Local.Local{user,commands,permission}}}:author_returned(namespace,id,name,access,cursor,user,permission,buffer(commands))
def finished(context:Context.Context<D.Scene,App.Resources(),Author.resources(),{==}>,peer:App.Peer(),guards:Unit,handler:Unit,stateBindings:List<&2,State.Binding>,plan:Plan.Build<String>,bindings:List<&2,State.Binding>,rules:Registration.Rules,deferred:Root.Deferred,text:String,result:App.World() & String,observed:Author.Owner() & String) -> App.Bound() & String:
  match result observed:
    case (world,raw), (author,queue):(Context.Bound{context,Root.Scheduled{State.State{world,Product.Owner{author,peer},guards,handler,stateBindings},plan,bindings,rules,deferred}},text ++ ";raw-owners=" ++ raw ++ ";" ++ queue)
def observed(bound:App.Bound()) -> App.Bound() & String:
  match bound:
    case Context.Bound{context,Root.Scheduled{State.State{world,Product.Owner{Cmd.Owner{Sys.Owner{namespace,id,name,access,cursor,Local.Local{Author.User{stage,+handles,returned,errors},commands,permission}}},peer},guards,handler,stateBindings},plan,bindings,rules,deferred}}:finished(context,peer,guards,handler,stateBindings,plan,bindings,rules,deferred,"handles=" ++ List.show(&2,W.Handle<D.Scene>,Inspect.handle,handles),world_owners(handles,world),author(Cmd.Owner{Sys.Owner{namespace,id,name,access,cursor,Local.Local{Author.User{stage,handles,returned,errors},commands,permission}}}))

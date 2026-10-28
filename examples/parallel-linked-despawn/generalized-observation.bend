import Base
import ../../src/ecs/lifecycle.bend as Life
import ../../src/ecs/execution-reservation-bundle.bend as Bundle
import ../../src/ecs/execution-lifetime-scope-command.bend as ScopeCommands
import ../parallel-relations/failure-message-text.bend as FailureText
import ../../src/ecs/execution-relation-failure-message.bend as Message
import ./actor.bend as Actor
import ./generalized-observation-data.bend as Data
import ./generalized-application.bend as Application
import ./generalized-actors.bend as Actors
import ./generalized-readers.bend as Readers
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-resource-query-leaf.bend as Leaf
import ../../src/ecs/execution-parallel-scope.bend as ParallelScope
import ../../src/ecs/execution-declaration.bend as D
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-resource-query-execution.bend as Execution
import ../../src/ecs/execution-compiled-binding.bend as Binding
import ../../src/ecs/execution-prepared.bend as Prep
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/execution-schema-provisioning.bend as Provision
import ../../src/ecs/execution-parallel-root-application.bend as Root
import ../../src/ecs/execution-generalized-root-application.bend as General
import ../../src/ecs/execution-relation-failure-local.bend as FailureLocal
import ../../src/ecs/execution-relation-failure-channel.bend as FailureReader
import ../../src/ecs/execution-lifecycle-notices.bend as Notice
import ../../src/ecs/execution-resource-store.bend as Resource
import ../../src/ecs/deferred-command.bend as Deferred
import ../../src/ecs/execution-query-schema.bend as QuerySchema
import ../../src/ecs/chunk-partition.bend as Part
import ../../src/ecs/execution-resource-admission.bend as Admission
import ../../src/ecs/entity-allocator.bend as Allocator
import ../../src/ecs/execution-resource-description.bend as Description
import ../../src/ecs/execution-query-admission.bend as QueryAdmission
import ./setup.bend as Setup
import ./scheduled.bend as Scheduled
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-command-removed.bend as Removed
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/world.bend as W
import ../../src/ecs/chunk-column.bend as Column
import ../../src/ecs/execution-relation-store.bend as Store
import ../../src/ecs/relation-types.bend as T
import ../../src/ecs/execution-lifetime-scope-store.bend as ScopeStore
import ../../src/ecs/execution-lifetime-scope-description.bend as ScopeText
import ../../src/ecs/lifetime-scope.bend as Scope
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/execution-owner-continuation.bend as Continuation

def with_pair(-A:Type,-R:Type,result:A & String,next:A -> String -> R) -> R:
  match result:
    case (owner,text):next(owner,text)
def session(owner:Actor.Session) -> Actor.Session & String:
  match owner:
    case Actor.Session{+value}:(Actor.Session{value},U32.show(value))
def some(result:Actor.Session & String) -> Maybe<&1,Actor.Session> & String:
  match result:
    case (owner,text):(Some{owner},text)
def maybe(owner:Maybe<&1,Actor.Session>) -> Maybe<&1,Actor.Session> & String:
  match owner:
    case None{}:(None{},"none")
    case Some{owner}:some(session(owner))
def removed_returned(other:Unit,result:Maybe<&1,Actor.Session> & String) -> Removed.Removed(Actor.components()) & String:
  match result:
    case (owner,text):(Product.Owner{owner,other},text)
def removed(owner:Removed.Removed(Actor.components())) -> Removed.Removed(Actor.components()) & String:
  match owner:
    case Product.Owner{owner,other}:removed_returned(other,maybe(owner))
def rows_join(-P:Type,head:P & String,tail:List<P> & List<&2,String>) -> List<P> & List<&2,String>:
  match head tail:
    case (head,text), (tail,texts):(head <> tail,text <> texts)
def rows(~P:Type,~observe:P -> P & String,owners:List<P>) -> List<P> & List<&2,String>:
  match owners:
    case []:([],[])
    case head <> tail:rows_join(P,observe(head),rows(~P,~observe,tail))
def identity(value:String) -> String:value
def strings(texts:List<&2,String>) -> String:List.show(&2,String,identity,texts)
def rendered_rows(~P:Type,result:List<P> & List<&2,String>) -> List<P> & String:
  match result:
    case (owners,texts):(owners,strings(texts))
def observe_rows(~P:Type,~inspect:P -> P & String,owners:List<P>) -> List<P> & String:rendered_rows(~P,rows(~P,~inspect,owners))
def component_receipt(~S:Data,+handle:W.Handle<S>,kind:Bool,result:Maybe<&1,Actor.Session> & String) -> Buffer.Receipt<S,Actor.Session,Removed.Removed(Actor.components())> & String:
  match kind result:
    case True{}, (owner,text):(Buffer.Applied{handle,owner},"component-applied:" ++ Data.handle(~S,handle) ++ "/previous=" ++ text)
    case False{}, (owner,text):(Buffer.Refused{handle,owner},"component-refused:" ++ Data.handle(~S,handle) ++ "/incoming=" ++ text)
def removed_receipt(~S:Data,+handle:W.Handle<S>,kind:Bool,result:Removed.Removed(Actor.components()) & String) -> Buffer.Receipt<S,Actor.Session,Removed.Removed(Actor.components())> & String:
  match kind result:
    case True{}, (owner,text):(Buffer.Despawned{handle,owner},"despawned:" ++ Data.handle(~S,handle) ++ "/owner=" ++ text)
    case False{}, (owner,text):(Buffer.Spawned{handle,owner},"spawned:" ++ Data.handle(~S,handle) ++ "/previous=" ++ text)
def receipt_join(~S:Data,head:Buffer.Receipt<S,Actor.Session,Removed.Removed(Actor.components())> & String,tail:List<Buffer.Receipt<S,Actor.Session,Removed.Removed(Actor.components())>> & String) -> List<Buffer.Receipt<S,Actor.Session,Removed.Removed(Actor.components())>> & String:
  match head tail:
    case (head,text), (tail,texts):(head <> tail,text ++ ";" ++ texts)
def spawn_refused(~S:Data,+handle:W.Handle<S>,+reason:Bundle.Refusal,result:Removed.Removed(Actor.components()) & String) -> Buffer.Receipt<S,Actor.Session,Removed.Removed(Actor.components())> & String:
  match result:
    case (owner,text):(Buffer.SpawnRefused{handle,owner,reason},"spawn-refused:" ++ Data.handle(~S,handle) ++ "/incoming=" ++ text ++ "/reason=" ++ Data.bundle_refusal(reason))
def linked_receipt(~S:Data,+handle:W.Handle<S>,+status:Buffer.LinkedStatus,+frames:List<&2,T.CleanupFrame<S>>,result:List<Buffer.Receipt<S,Actor.Session,Removed.Removed(Actor.components())>> & String) -> Buffer.Receipt<S,Actor.Session,Removed.Removed(Actor.components())> & String:
  match result:
    case (nested,text):(Buffer.LinkedDespawn{handle,status,nested,frames},"linked-despawn:" ++ Data.handle(~S,handle) ++ ":" ++ ScopeText.linked_status(status) ++ "{" ++ text ++ "}/frames=" ++ Data.frames(~S,frames))
def scope_receipt(~S:Data,+route:L.Route,+operation:ScopeCommands.Operation<S>,+status:Buffer.ScopeStatus,+frames:List<&2,T.CleanupFrame<S>>,result:List<Buffer.Receipt<S,Actor.Session,Removed.Removed(Actor.components())>> & String) -> Buffer.Receipt<S,Actor.Session,Removed.Removed(Actor.components())> & String:
  match result:
    case (nested,text):(Buffer.ScopePublished{route,operation,status,nested,frames},"scope:" ++ Data.route(route) ++ "/" ++ ScopeText.operation(~S,operation) ++ ":" ++ ScopeText.status(status) ++ "{" ++ text ++ "}/frames=" ++ Data.frames(~S,frames))
def receipts(~S:Data,owners:List<Buffer.Receipt<S,Actor.Session,Removed.Removed(Actor.components())>>) -> List<Buffer.Receipt<S,Actor.Session,Removed.Removed(Actor.components())>> & String:
  match owners:
    case []:([],"[]")
    case Buffer.Applied{handle,previous} <> rest:receipt_join(~S,component_receipt(~S,handle,True{},maybe(previous)),receipts(~S,rest))
    case Buffer.Refused{handle,incoming} <> rest:receipt_join(~S,component_receipt(~S,handle,False{},maybe(incoming)),receipts(~S,rest))
    case Buffer.Despawned{handle,owner} <> rest:receipt_join(~S,removed_receipt(~S,handle,True{},removed(owner)),receipts(~S,rest))
    case Buffer.Spawned{handle,owner} <> rest:receipt_join(~S,removed_receipt(~S,handle,False{},removed(owner)),receipts(~S,rest))
    case Buffer.SpawnRefused{handle,owner,reason} <> rest:receipt_join(~S,spawn_refused(~S,handle,reason,removed(owner)),receipts(~S,rest))
    case Buffer.DespawnRefused{+handle} <> rest:receipt_join(~S,(Buffer.DespawnRefused{handle},"despawn-refused:" ++ Data.handle(~S,handle)),receipts(~S,rest))
    case Buffer.RelationPublished{+route,+value} <> rest:receipt_join(~S,(Buffer.RelationPublished{route,value},"relation:" ++ Data.route(route) ++ "/" ++ Data.relation_receipt(~S,value)),receipts(~S,rest))
    case Buffer.RelationUndeclared{+route,+value} <> rest:receipt_join(~S,(Buffer.RelationUndeclared{route,value},"undeclared:" ++ Data.route(route) ++ "/" ++ FailureText.operation(S,value)),receipts(~S,rest))
    case Buffer.LinkedDespawn{handle,status,children,frames} <> rest:receipt_join(~S,linked_receipt(~S,handle,status,frames,receipts(~S,children)),receipts(~S,rest))
    case Buffer.ScopePublished{route,operation,status,children,frames} <> rest:receipt_join(~S,scope_receipt(~S,route,operation,status,frames,receipts(~S,children)),receipts(~S,rest))
    case Buffer.ScopeStoreApplied{+route,+request,+result} <> rest:receipt_join(~S,(Buffer.ScopeStoreApplied{route,request,result},"scope-store:" ++ Data.route(route) ++ "/" ++ ScopeText.request(~S,request) ++ ":" ++ ScopeText.outcome(~S,result)),receipts(~S,rest))
def component_entry(~S:Data,+handle:W.Handle<S>,result:Maybe<&1,Actor.Session> & String) -> Buffer.Entry<S,Actor.Session,Removed.Removed(Actor.components())> & String:
  match result:
    case (owner,text):(Buffer.Entry{handle,owner},"component:" ++ Data.handle(~S,handle) ++ "/incoming=" ++ text)
def spawn_entry(~S:Data,+handle:W.Handle<S>,result:Removed.Removed(Actor.components()) & String) -> Buffer.Entry<S,Actor.Session,Removed.Removed(Actor.components())> & String:
  match result:
    case (owner,text):(Buffer.Spawn{handle,owner},"spawn:" ++ Data.handle(~S,handle) ++ "/incoming=" ++ text)
def entry(~S:Data,owner:Buffer.Entry<S,Actor.Session,Removed.Removed(Actor.components())>) -> Buffer.Entry<S,Actor.Session,Removed.Removed(Actor.components())> & String:
  match owner:
    case Buffer.Entry{handle,owner}:component_entry(~S,handle,maybe(owner))
    case Buffer.Spawn{handle,owner}:spawn_entry(~S,handle,removed(owner))
    case Buffer.Despawn{+handle}:(Buffer.Despawn{handle},"despawn:" ++ Data.handle(~S,handle))
    case Buffer.Relation{+route,+operation}:(Buffer.Relation{route,operation},"relation:" ++ Data.route(route) ++ "/" ++ FailureText.operation(S,operation))
    case Buffer.LifetimeScope{+route,+operation}:(Buffer.LifetimeScope{route,operation},"scope:" ++ Data.route(route) ++ "/" ++ ScopeText.operation(~S,operation))
def buffer_returned(~S:Data,pending:List<Buffer.Entry<S,Actor.Session,Removed.Removed(Actor.components())>> & List<&2,String>,values:List<Buffer.Receipt<S,Actor.Session,Removed.Removed(Actor.components())>> & String) -> Buffer.Buffer<S,Actor.Session,Removed.Removed(Actor.components())> & String:
  match pending values:
    case (pending,texts), (values,text):(Buffer.Buffer{pending,values},"pending=" ++ strings(List.reverse(&2,String,texts)) ++ ",receipts-storage=[" ++ text ++ "]")
def buffer(~S:Data,owner:Buffer.Buffer<S,Actor.Session,Removed.Removed(Actor.components())>) -> Buffer.Buffer<S,Actor.Session,Removed.Removed(Actor.components())> & String:
  match owner:
    case Buffer.Buffer{pending,values}:buffer_returned(~S,rows(~Buffer.Entry<S,Actor.Session,Removed.Removed(Actor.components())>,~entry(~S),pending),receipts(~S,values))
def viewed_returned(+cache:U32,result:Actor.Session & String) -> L.Viewed<Actor.Session,U32> & String:
  match result:
    case (owner,text):(L.Viewed{owner,cache},text ++ "/" ++ U32.show(cache))
def viewed(owner:L.Viewed<Actor.Session,U32>) -> L.Viewed<Actor.Session,U32> & String:
  match owner:
    case L.Viewed{owner,cache}:viewed_returned(cache,session(owner))
def cell_returned(result:L.Viewed<Actor.Session,U32> & String) -> Maybe<&1,L.Viewed<Actor.Session,U32>> & String:
  match result:
    case (owner,text):(Some{owner},text)
def cell(owner:Maybe<&1,L.Viewed<Actor.Session,U32>>) -> Maybe<&1,L.Viewed<Actor.Session,U32>> & String:
  match owner:
    case None{}:(None{},"none")
    case Some{owner}:cell_returned(viewed(owner))
def cells_leaf(result:Maybe<&1,L.Viewed<Actor.Session,U32>> & String) -> Array<Maybe<&1,L.Viewed<Actor.Session,U32>>> & String:
  match result:
    case (owner,text):(ALeaf{owner},text)
def cells_branch(left:Array<Maybe<&1,L.Viewed<Actor.Session,U32>>> & String,right:Array<Maybe<&1,L.Viewed<Actor.Session,U32>>> & String) -> Array<Maybe<&1,L.Viewed<Actor.Session,U32>>> & String:
  match left right:
    case (left,a), (right,b):(ANode{left,right},"[" ++ a ++ "," ++ b ++ "]")
def cells(owners:Array<Maybe<&1,L.Viewed<Actor.Session,U32>>>) -> Array<Maybe<&1,L.Viewed<Actor.Session,U32>>> & String:
  match owners:
    case ALeaf{owner}:cells_leaf(cell(owner))
    case ANode{left,right}:cells_branch(cells(left),cells(right))
def stamps_join(left:Array<Life.Stamp> & String,right:Array<Life.Stamp> & String) -> Array<Life.Stamp> & String:
  match left right:
    case (left,a), (right,b):(ANode{left,right},"[" ++ a ++ "," ++ b ++ "]")
def stamp_array(values:Array<Life.Stamp>) -> Array<Life.Stamp> & String:
  match values:
    case ALeaf{+value}:(ALeaf{value},Data.stamp(value))
    case ANode{left,right}:stamps_join(stamp_array(left),stamp_array(right))
def column_leaf(~S:Data,stamps:Array<Life.Stamp>,result:Array<Maybe<&1,L.Viewed<Actor.Session,U32>>> & String) -> Column.Column<S,L.Viewed<Actor.Session,U32>> & String:
  match result:
    case (values,text):with_pair(Array<Life.Stamp>,Column.Column<S,L.Viewed<Actor.Session,U32>> & String,stamp_array(stamps),stamps => stampText => (Column.Leaf{values,stamps},"values=" ++ text ++ "/stamps=" ++ stampText))
def column_branch(~S:Data,+size:U32,left:Column.Column<S,L.Viewed<Actor.Session,U32>> & String,right:Column.Column<S,L.Viewed<Actor.Session,U32>> & String) -> Column.Column<S,L.Viewed<Actor.Session,U32>> & String:
  match left right:
    case (left,a), (right,b):(Column.Branch{size,left,right},"size=" ++ U32.show(size) ++ "[" ++ a ++ "," ++ b ++ "]")
def column(~S:Data,owner:Column.Column<S,L.Viewed<Actor.Session,U32>>) -> Column.Column<S,L.Viewed<Actor.Session,U32>> & String:
  match owner:
    case Column.Leaf{values,stamps}:column_leaf(~S,stamps,cells(values))
    case Column.Branch{size,left,right}:column_branch(~S,size,column(~S,left),column(~S,right))
def components_returned(~S:Data,other:Unit,result:Column.Column<S,L.Viewed<Actor.Session,U32>> & String) -> Scheduled.Columns(~S) & String:
  match result:
    case (values,text):(Product.Owner{L.ColumnSlot{values},other},text)
def components(~S:Data,owner:Scheduled.Columns(~S)) -> Scheduled.Columns(~S) & String:
  match owner:
    case Product.Owner{L.ColumnSlot{values},other}:components_returned(~S,other,column(~S,values))
def graph_cache(~S:Data,~family:T.Descriptor<S>,cache:Store.View<S,family>) -> String:
  match cache:
    case Store.View{namespace,T.Graph{edges,inverses},failures,sequence,nextReader}:"descriptor=" ++ Data.descriptor(~S,family) ++ ",namespace=" ++ U32.show(namespace) ++ ",edges=" ++ List.show(&2,T.Edge<S>,Data.edge(~S),edges) ++ ",inverse=" ++ List.show(&2,T.Inverse<S>,Data.inverse(~S),inverses) ++ ",failures=" ++ Data.channel(~S,~family,failures) ++ ",sequence=" ++ Nat.show(sequence) ++ ",nextReader=" ++ U32.show(nextReader)
def graph_data(~S:Data,~family:T.Descriptor<S>,value:T.Graph<S>,cache:Store.View<S,family>) -> String:
  match value:
    case T.Graph{edges,inverses}:"descriptor=" ++ Data.descriptor(~S,family) ++ ",edges=" ++ List.show(&2,T.Edge<S>,Data.edge(~S),edges) ++ ",inverse=" ++ List.show(&2,T.Inverse<S>,Data.inverse(~S),inverses) ++ ",cache={" ++ graph_cache(~S,~family,cache) ++ "}"
def graph(~S:Data,~family:T.Descriptor<S>,owner:Store.Store<S,family>,+cache:Store.View<S,family>) -> Store.Store<S,family> & String:
  match owner:
    case Store.Store{+namespace,+value,+failures,+sequence,+nextReader}:(Store.Store{namespace,value,failures,sequence,nextReader},"namespace=" ++ U32.show(namespace) ++ "," ++ graph_data(~S,~family,value,cache) ++ ",failure-sequence=" ++ Nat.show(sequence) ++ ",failures=" ++ Data.channel(~S,~family,failures) ++ ",nextReader=" ++ U32.show(nextReader))
def scope_view(~S:Data,value:ScopeStore.View<S>) -> String:
  match value:
    case ScopeStore.View{namespace,members}:U32.show(namespace) ++ "/" ++ List.show(&2,Scope.Member,Data.member,members)
def resources_returned(~S:Data,parentCache:Store.View<S,Setup.hierarchy(~S)>,linkCache:Store.View<S,Setup.link(~S)>,+parentStamp:Life.Stamp,+linkStamp:Life.Stamp,+namespace:U32,+members:List<&2,Scope.Member>,+scopeCache:ScopeStore.View<S>,+scopeStamp:Life.Stamp,+stateStamp:Life.Stamp,parentResult:Store.Store<S,Setup.hierarchy(~S)> & String,linkResult:Store.Store<S,Setup.link(~S)> & String,stateResult:L.Viewed<Actor.Session,U32> & String) -> Scheduled.Resources(~S) & String:
  match parentResult linkResult stateResult:
    case (parent,parentText), (link,linkText), (state,stateText):(Product.Owner{Product.Owner{L.ResourceSlot{L.Viewed{parent,parentCache},parentStamp},L.ResourceSlot{L.Viewed{link,linkCache},linkStamp}},Product.Owner{L.ResourceSlot{L.Viewed{ScopeStore.Store{namespace,members},scopeCache},scopeStamp},L.ResourceSlot{state,stateStamp}}},"parent={" ++ parentText ++ ",stamp=" ++ Data.stamp(parentStamp) ++ "},link={" ++ linkText ++ ",stamp=" ++ Data.stamp(linkStamp) ++ "},scope=" ++ U32.show(namespace) ++ "/" ++ List.show(&2,Scope.Member,Data.member,members) ++ ",scope-cache=" ++ scope_view(~S,scopeCache) ++ ",scope-stamp=" ++ Data.stamp(scopeStamp) ++ ",resource=" ++ stateText ++ ",resource-stamp=" ++ Data.stamp(stateStamp))
def resources(~S:Data,owner:Scheduled.Resources(~S)) -> Scheduled.Resources(~S) & String:
  match owner:
    case Product.Owner{Product.Owner{L.ResourceSlot{L.Viewed{parent,+parentCache},parentStamp},L.ResourceSlot{L.Viewed{link,+linkCache},linkStamp}},Product.Owner{L.ResourceSlot{L.Viewed{ScopeStore.Store{namespace,members},scopeCache},scopeStamp},L.ResourceSlot{state,stateStamp}}}:resources_returned(~S,parentCache,linkCache,parentStamp,linkStamp,namespace,members,scopeCache,scopeStamp,stateStamp,graph(~S,~Setup.hierarchy(~S),parent,parentCache),graph(~S,~Setup.link(~S),link,linkCache),viewed(state))

def run_report(~S:Data,report:Context.RunReport<App.Report<String,String>>) -> String:Data.report(report)
def graph_user(~S:Data,value:Actors.GraphUser<S>) -> Actors.GraphUser<S> & String:
  match value:
    case Actors.GraphUser{Actor.User{+child,+parent,+replacement,owner},+scoped,+authored,+calls}:with_pair(Actor.Session,Actors.GraphUser<S> & String,session(owner),owner => text => (Actors.GraphUser{Actor.User{child,parent,replacement,owner},scoped,authored,calls},"child=" ++ Data.handle(~S,child) ++ ",parent=" ++ Data.handle(~S,parent) ++ ",replacement=" ++ Data.handle(~S,replacement) ++ ",scoped=" ++ Data.handle(~S,scoped) ++ ",session=" ++ text ++ ",authored=" ++ Data.bool(authored) ++ ",calls=" ++ U32.show(calls)))
def link_user(~S:Data,value:Actors.LinkUser<S>) -> Actors.LinkUser<S> & String:
  match value:
    case Actors.LinkUser{+source,+target,owner,+authored,+calls}:with_pair(Actor.Session,Actors.LinkUser<S> & String,session(owner),owner => text => (Actors.LinkUser{source,target,owner,authored,calls},"source=" ++ Data.handle(~S,source) ++ ",target=" ++ Data.handle(~S,target) ++ ",session=" ++ text ++ ",authored=" ++ Data.bool(authored) ++ ",calls=" ++ U32.show(calls)))
def removal_user(~S:Data,value:Actors.RemovalUser<S>) -> Actors.RemovalUser<S> & String:
  match value:
    case Actors.RemovalUser{+handle,+authored,+calls}:(Actors.RemovalUser{handle,authored,calls},"handle=" ++ Data.handle(~S,handle) ++ ",authored=" ++ Data.bool(authored) ++ ",calls=" ++ U32.show(calls))
def updater_user(~S:Data,value:Actors.UpdaterUser<S>) -> Actors.UpdaterUser<S> & String:
  match value:
    case Actors.UpdaterUser{+handle,incoming,following,+calls}:with_pair(Maybe<&1,Actor.Session>,Actors.UpdaterUser<S> & String,maybe(incoming),incoming => a => with_pair(Maybe<&1,Actor.Session>,Actors.UpdaterUser<S> & String,maybe(following),following => b => (Actors.UpdaterUser{handle,incoming,following,calls},"handle=" ++ Data.handle(~S,handle) ++ ",incoming=" ++ a ++ ",following=" ++ b ++ ",calls=" ++ U32.show(calls))))
def graph_view(~S:Data,~family:T.Descriptor<S>,value:Resource.Lookup<Store.View<S,family>>) -> String:
  match value:
    case Resource.LookupRefused{}:"lookup-refused"
    case Resource.Viewed{cache,stamp}:graph_cache(~S,~family,cache) ++ ",lookup-stamp=" ++ Data.stamp(stamp)
def scope_lookup(~S:Data,value:Resource.Lookup<ScopeStore.View<S>>) -> String:
  match value:
    case Resource.LookupRefused{}:"lookup-refused"
    case Resource.Viewed{cache,stamp}:scope_view(~S,cache) ++ ",lookup-stamp=" ++ Data.stamp(stamp)
def views(~S:Data,value:Readers.Views<S>) -> String:
  match value:
    case Readers.Views{hierarchy,link,scope}:"hierarchy={" ++ graph_view(~S,~Setup.hierarchy(~S),hierarchy) ++ "},link={" ++ graph_view(~S,~Setup.link(~S),link) ++ "},scope={" ++ scope_lookup(~S,scope) ++ "}"
def failure_user(~S:Data,value:Readers.FailureUser<S>) -> Readers.FailureUser<S> & String:
  match value:
    case Readers.FailureUser{owner,+calls,+received,+missed,+messages,+snapshots}:with_pair(Actor.Session,Readers.FailureUser<S> & String,session(owner),owner => text => (Readers.FailureUser{owner,calls,received,missed,messages,snapshots},"session=" ++ text ++ ",calls=" ++ Nat.show(calls) ++ ",received=" ++ Nat.show(received) ++ ",missed=" ++ Nat.show(missed) ++ ",messages=" ++ List.show(&2,Message.Message<S,Setup.hierarchy(~S)>,message => FailureText.message(S,Setup.hierarchy(~S),message),messages) ++ ",views=" ++ List.show(&2,Readers.Views<S>,views(~S),snapshots)))
def failure_local(~S:Data,value:Readers.FailureState(~S)) -> Readers.FailureState(~S) & String:
  match value:
    case FailureLocal.Local{FailureReader.Reader{+namespace,+id,+cursor},user}:with_pair(Readers.FailureUser<S>,Readers.FailureState(~S) & String,failure_user(~S,user),user => text => (FailureLocal.Local{FailureReader.Reader{namespace,id,cursor},user},"reader=" ++ U32.show(namespace) ++ "/" ++ U32.show(id) ++ "/" ++ Nat.show(cursor) ++ "," ++ text))
def lifecycle_user(~S:Data,value:Readers.LifecycleUser<S>) -> Readers.LifecycleUser<S> & String:
  match value:
    case Readers.LifecycleUser{owner,Notice.Reader{+rn,+ri,+rc},Notice.Reader{+dn,+di,+dc},+calls,+removedRows,+despawnedRows,+removedMissed,+despawnedMissed,+removedEmpty,+despawnedEmpty}:with_pair(Actor.Session,Readers.LifecycleUser<S> & String,session(owner),owner => text => (Readers.LifecycleUser{owner,Notice.Reader{rn,ri,rc},Notice.Reader{dn,di,dc},calls,removedRows,despawnedRows,removedMissed,despawnedMissed,removedEmpty,despawnedEmpty},"session=" ++ text ++ ",removed-reader=" ++ U32.show(rn) ++ "/" ++ U32.show(ri) ++ "/" ++ Nat.show(rc) ++ ",despawned-reader=" ++ U32.show(dn) ++ "/" ++ U32.show(di) ++ "/" ++ Nat.show(dc) ++ ",calls=" ++ U32.show(calls) ++ ",removed=" ++ List.show(&2,Notice.Row<S>,Data.row(~S),removedRows) ++ ",despawned=" ++ List.show(&2,Notice.Row<S>,Data.row(~S),despawnedRows) ++ ",removed-missed=" ++ Nat.show(removedMissed) ++ ",despawned-missed=" ++ Nat.show(despawnedMissed) ++ ",removed-empty=" ++ Data.bool(removedEmpty) ++ ",despawned-empty=" ++ Data.bool(despawnedEmpty)))
def permission(value:Permission.Permission) -> String:
  match value:
    case Permission.FamilyOnly{}:"family-only"
    case Permission.EntityStructural{}:"entity-structural"
def command_local(~S:Data,~User:Type,~inspect:User -> User & String,value:Local.Local<S,Actor.Session,Removed.Removed(Actor.components()),User>) -> Local.Local<S,Actor.Session,Removed.Removed(Actor.components()),User> & String:
  match value:
    case Local.Local{user,queue,+grant}:with_pair(User,Local.Local<S,Actor.Session,Removed.Removed(Actor.components()),User> & String,inspect(user),user => text => with_pair(Buffer.Buffer<S,Actor.Session,Removed.Removed(Actor.components())>,Local.Local<S,Actor.Session,Removed.Removed(Actor.components()),User> & String,buffer(~S,queue),queue => queueText => (Local.Local{user,queue,grant},text ++ ",permission=" ++ permission(grant) ++ "," ++ queueText)))
def Compilation(~S:Data,~Ops:Data -> Type -> Type) -> Type:D.Compilation<S,L.columns(~S,Actor.components()),Actors.C(~S),Actors.R(~S),Ops>
def compilation(~S:Data,~Ops:Data -> Type -> Type,value:Compilation(~S,~Ops)) -> Compilation(~S,~Ops) & String:
  match value:
    case D.Supported{D.Declaration{caps,+access},+recipes}:(D.Supported{D.Declaration{caps,access},recipes},"supported/access=" ++ List.show(&2,D.Access,Data.access,access) ++ "/" ++ Data.recipes(~S,~L.columns(~S,Actor.components()),recipes) ++ "/opaque=D.Declaration.caps")
    case D.Unsupported{caps,+access,+recipes}:(D.Unsupported{caps,access,recipes},"unsupported/access=" ++ List.show(&2,D.Access,Data.access,access) ++ "/" ++ Data.recipes(~S,~L.columns(~S,Actor.components()),recipes) ++ "/opaque=D.Unsupported.caps")
def System(~S:Data,~Ops:Data -> Type -> Type,~User:Type,~program:Build.FrameworkProgram(~S,~L.columns(~S,Actor.components()),~Actors.C(~S),~Actors.R(~S),~Ops),~body:Sys.Body(~S,~Ops,~User,~String,~String)) -> Type:Sys.Owner<S,L.columns(~S,Actor.components()),Actors.C(~S),Actors.R(~S),Unit,Ops,User,String,String,program,body>
def system(~S:Data,~Ops:Data -> Type -> Type,~User:Type,~program:Build.FrameworkProgram(~S,~L.columns(~S,Actor.components()),~Actors.C(~S),~Actors.R(~S),~Ops),~body:Sys.Body(~S,~Ops,~User,~String,~String),~inspect:User -> User & String,value:System(~S,~Ops,~User,~program,~body)) -> System(~S,~Ops,~User,~program,~body) & String:
  match value:
    case Sys.Owner{+namespace,+id,+name,+access,+cursor,user}:with_pair(User,System(~S,~Ops,~User,~program,~body) & String,inspect(user),user => text => (Sys.Owner{namespace,id,name,access,cursor,user},"namespace=" ++ U32.show(namespace) ++ ",id=" ++ U32.show(id) ++ ",name=" ++ name ++ ",access=" ++ Data.strings(access) ++ ",cursor=" ++ Data.maybe_tick(cursor) ++ ",local={" ++ text ++ "}"))

def evidence(~S:Data,~Ops:Data -> Type -> Type,~program:Build.FrameworkProgram(~S,~L.columns(~S,Actor.components()),~Actors.C(~S),~Actors.R(~S),~Ops),value:Admission.Evidence<S,Actor.components(),Actor.resources(~S),Actors.C(~S),Actors.R(~S),Ops,program>) -> String:
  match value:
    case Admission.Evidence{namespace,handles,queries,resources,componentInfo,resourceInfo,grants,queryBook,resourceBook}:"namespace=" ++ U32.show(namespace) ++ ",handles=" ++ List.show(&2,W.Handle<S>,Data.handle(~S),handles) ++ ",recipes={" ++ Data.recipes(~S,~L.columns(~S,Actor.components()),D.Recipes{queries,resources}) ++ "},component-info=" ++ List.show(&2,QuerySchema.Info,Data.component_info,componentInfo) ++ ",resource-info=" ++ List.show(&2,Description.Info,Data.resource_info,resourceInfo) ++ ",grants=" ++ List.show(&2,QueryAdmission.Granted<S,L.columns(~S,Actor.components())>,Data.granted(~S,~L.columns(~S,Actor.components())),grants) ++ ",query-book=" ++ Data.query_book(~S,~Actor.components(),queryBook) ++ ",resource-book=" ++ Data.resource_book(~S,~Actor.resources(~S),resourceBook)
def maybe_evidence(-E:Data,show:E -> String,value:Maybe<&2,E>) -> String:
  match value:
    case None{}:"none"
    case Some{value}:"some{" ++ show(value) ++ "}"
def provenance(~P:Data,~show:P -> String,value:Prep.Provenance<P>) -> String:
  match value:
    case Prep.Unprepared{}:"unprepared"
    case Prep.Leaf{namespace,permits}:"leaf:" ++ U32.show(namespace) ++ "/" ++ List.show(&2,P,show,permits)
    case Prep.Pair{left,right}:"pair(" ++ provenance(~P,~show,left) ++ "," ++ provenance(~P,~show,right) ++ ")"
def held(~P:Data,~show:P -> String,-C:Type,-World:Type,-Owner:Type,-Evidence:Data,inspectC:C -> C & String,inspect:Owner -> Owner & String,showE:Evidence -> String,value:Execution.Held<C,World,Owner,Evidence,P>) -> Execution.Held<C,World,Owner,Evidence,P> & String:
  match value:
    case Execution.HeldReady{Binding.Binding{actualCompilation,Prep.Prepared{+namespace,owner,+permits,+origin},+evidence}}:with_pair(C,Execution.Held<C,World,Owner,Evidence,P> & String,inspectC(actualCompilation),actualCompilation => ctext => with_pair(Owner,Execution.Held<C,World,Owner,Evidence,P> & String,inspect(owner),owner => text => (Execution.HeldReady{Binding.Binding{actualCompilation,Prep.Prepared{namespace,owner,permits,origin},evidence}},"held-ready/{" ++ ctext ++ "}/namespace=" ++ U32.show(namespace) ++ ",permits=" ++ List.show(&2,P,show,permits) ++ ",provenance=" ++ provenance(~P,~show,origin) ++ ",owner={" ++ text ++ "},evidence={" ++ showE(evidence) ++ "}")))
    case Execution.HeldInventory{actualCompilation,Prep.Inventory{owner,+origin},+evidence}:with_pair(C,Execution.Held<C,World,Owner,Evidence,P> & String,inspectC(actualCompilation),actualCompilation => ctext => with_pair(Owner,Execution.Held<C,World,Owner,Evidence,P> & String,inspect(owner),owner => text => (Execution.HeldInventory{actualCompilation,Prep.Inventory{owner,origin},evidence},"held-inventory/{" ++ ctext ++ "}/provenance=" ++ provenance(~P,~show,origin) ++ ",owner={" ++ text ++ "},evidence={" ++ showE(evidence) ++ "}")))
def retained(~P:Data,~show:P -> String,-C:Type,-World:Type,-Owner:Type,-Evidence:Data,inspectC:C -> C & String,inspect:Owner -> Owner & String,showE:Evidence -> String,value:Leaf.Node<C,World,Owner,Evidence,P>) -> Leaf.Node<C,World,Owner,Evidence,P> & String:
  match value:
    case Leaf.Uninspected{ParallelScope.CompiledBinding{actualCompilation,owner}}:with_pair(C,Leaf.Node<C,World,Owner,Evidence,P> & String,inspectC(actualCompilation),actualCompilation => ctext => with_pair(Owner,Leaf.Node<C,World,Owner,Evidence,P> & String,inspect(owner),owner => text => (Leaf.Uninspected{ParallelScope.CompiledBinding{actualCompilation,owner}},"uninspected/{" ++ ctext ++ "}/" ++ text)))
    case Leaf.Inspected{ParallelScope.CompiledBinding{actualCompilation,owner},+evidence,+id,+valid}:with_pair(C,Leaf.Node<C,World,Owner,Evidence,P> & String,inspectC(actualCompilation),actualCompilation => ctext => with_pair(Owner,Leaf.Node<C,World,Owner,Evidence,P> & String,inspect(owner),owner => text => (Leaf.Inspected{ParallelScope.CompiledBinding{actualCompilation,owner},evidence,id,valid},"inspected/{" ++ ctext ++ "}/id=" ++ U32.show(id) ++ ",valid=" ++ Data.bool(valid) ++ "," ++ text ++ ",evidence={" ++ maybe_evidence(Evidence,showE,evidence) ++ "}")))
    case Leaf.Prepared{value}:with_pair(Execution.Held<C,World,Owner,Maybe<&2,Evidence>,P>,Leaf.Node<C,World,Owner,Evidence,P> & String,held(~P,~show,C,World,Owner,Maybe<&2,Evidence>,inspectC,inspect,maybe_evidence(Evidence,showE),value),value => text => (Leaf.Prepared{value},"prepared/" ++ text))
def permit(~S:Data,value:Prep.Permit<S,L.columns(~S,Actor.components())>) -> String:
  match value:
    case Prep.Permit{namespace,id,allowed,tick}:U32.show(namespace) ++ "/" ++ U32.show(id) ++ "/" ++ Data.bool(allowed) ++ "/" ++ Data.tick(tick)
def ordinary_node(~S:Data,~Ops:Data -> Type -> Type,~User:Type,~program:Build.FrameworkProgram(~S,~L.columns(~S,Actor.components()),~Actors.C(~S),~Actors.R(~S),~Ops),~body:Sys.Body(~S,~Ops,~User,~String,~String),~inspect:User -> User & String,value:Leaf.node_type(~S,~Actor.components(),~Actor.resources(~S),~Unit,~String,~String,~Ops,~User,~program,~body)) -> Leaf.node_type(~S,~Actor.components(),~Actor.resources(~S),~Unit,~String,~String,~Ops,~User,~program,~body) & String:
  retained(~Prep.Permit<S,L.columns(~S,Actor.components())>,~permit(~S),Compilation(~S,~Ops),Application.World(~S),System(~S,~Ops,~User,~program,~body),Admission.Evidence<S,Actor.components(),Actor.resources(~S),Actors.C(~S),Actors.R(~S),Ops,program>,compilation(~S,~Ops),system(~S,~Ops,~User,~program,~body,~inspect),evidence(~S,~Ops,~program),value)
def command_node(~S:Data,~Ops:Data -> Type -> Type -> Type,~User:Type,~declaration:Cmd.Program(~S,~Actors.C(~S),~Actors.R(~S),~Actor.components(),~Actor.resources(~S),~Actor.route(),~Ops),~body:Cmd.Body(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Ops,~User,~String,~String),~inspect:User -> User & String,value:Leaf.node_type(~S,~Actor.components(),~Actor.resources(~S),~Unit,~String,~String,~Cmd.ScopedOps(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Ops),~Cmd.Captures(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~User),~Cmd.program_for_buffer(~S,~Actors.C(~S),~Actors.R(~S),~Actor.components(),~Actor.resources(~S),~Actor.route(),~Ops,~declaration),~Cmd.runner(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Ops,~User,~String,~String,~body))) -> Leaf.node_type(~S,~Actor.components(),~Actor.resources(~S),~Unit,~String,~String,~Cmd.ScopedOps(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Ops),~Cmd.Captures(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~User),~Cmd.program_for_buffer(~S,~Actors.C(~S),~Actors.R(~S),~Actor.components(),~Actor.resources(~S),~Actor.route(),~Ops,~declaration),~Cmd.runner(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Ops,~User,~String,~String,~body)) & String:
  ordinary_node(~S,~Cmd.ScopedOps(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Ops),~Cmd.Captures(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~User),~Cmd.program_for_buffer(~S,~Actors.C(~S),~Actors.R(~S),~Actor.components(),~Actor.resources(~S),~Actor.route(),~Ops,~declaration),~Cmd.runner(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Ops,~User,~String,~String,~body),~command_local(~S,~User,~inspect),value)
def graph_node(~S:Data,value:Actors.GraphNode(~S)) -> Actors.GraphNode(~S) & String:command_node(~S,~Actors.GraphOps(~S),~Actors.GraphUser<S>,~Actors.graph_declaration(~S),~Actors.graph_body(~S),~graph_user(~S),value)
def link_node(~S:Data,value:Actors.LinkNode(~S)) -> Actors.LinkNode(~S) & String:command_node(~S,~Actors.LinkOps(~S),~Actors.LinkUser<S>,~Actors.link_declaration(~S),~Actors.link_body(~S),~link_user(~S),value)
def editor_node(~S:Data,value:Actors.EditorNode(~S)) -> Actors.EditorNode(~S) & String:command_node(~S,~Actors.LinkOps(~S),~Actors.LinkUser<S>,~Actors.link_declaration(~S),~Actors.editor_body(~S),~link_user(~S),value)
def removal_node(~S:Data,value:Actors.RemovalNode(~S)) -> Actors.RemovalNode(~S) & String:command_node(~S,~Actors.RemovalOps(~S),~Actors.RemovalUser<S>,~Actors.removal_declaration(~S),~Actors.removal_body(~S),~removal_user(~S),value)
def updater_node(~S:Data,value:Actors.UpdaterNode(~S)) -> Actors.UpdaterNode(~S) & String:command_node(~S,~Actors.UpdaterOps(~S),~Actors.UpdaterUser<S>,~Actors.updater_declaration(~S),~Actors.updater_body(~S),~updater_user(~S),value)
def failure_node(~S:Data,value:Readers.FailureNode(~S)) -> Readers.FailureNode(~S) & String:ordinary_node(~S,~Readers.FailureOps(~S),~Readers.FailureState(~S),~Readers.failure_kernel(~S),~Readers.failure_body(~S),~failure_local(~S),value)
def lifecycle_node(~S:Data,value:Readers.LifecycleNode(~S)) -> Readers.LifecycleNode(~S) & String:ordinary_node(~S,~Readers.LifecycleOps(~S),~Readers.LifecycleUser<S>,~Readers.lifecycle_kernel(~S),~Readers.lifecycle_body(~S),~lifecycle_user(~S),value)
def owner_text(-Owner:Type,pair:Owner & String) -> Owner & String:pair
def pair_observed(-Left:Type,-Right:Type,left:Left & String,right:Right & String) -> Product.Owner<Left,Right> & String:
  match left right:
    case (left,a), (right,b):
      continuation:Continuation.PairedHeader<String,(Product.Owner<Left,Right> & String)> = Continuation.PairedHeader{Product.Owner<Left,Right>,Product.Owner{left,right},owner_text(Product.Owner<Left,Right>)}
      Continuation.paired_returned(String,Product.Owner<Left,Right> & String,continuation,"[" ++ a ++ "," ++ b ++ "]")
def pair_results(-Left:Type,-Right:Type,pair:(Left & String) & (Right & String)) -> Product.Owner<Left,Right> & String:
  match pair:
    case (left,right):pair_observed(Left,Right,left,right)
def pair_left(-Left:Type,-Right:Type,pair:((Right -> Right & String) & Right) & (Left & String)) -> Product.Owner<Left,Right> & String:
  match pair:
    case ((inspect,right),left):
      continuation:Continuation.PairedHeader<(Right & String),(Product.Owner<Left,Right> & String)> = Continuation.PairedHeader{Left & String,left,pair_results(Left,Right)}
      Continuation.paired_returned(Right & String,Product.Owner<Left,Right> & String,continuation,inspect(right))
def observe_pair(-Left:Type,-Right:Type,inspectLeft:Left -> Left & String,inspectRight:Right -> Right & String,value:Product.Owner<Left,Right>) -> Product.Owner<Left,Right> & String:
  match value:
    case Product.Owner{left,right}:
      continuation:Continuation.PairedHeader<(Left & String),(Product.Owner<Left,Right> & String)> = Continuation.PairedHeader{(Right -> Right & String) & Right,(inspectRight,right),pair_left(Left,Right)}
      Continuation.paired_returned(Left & String,Product.Owner<Left,Right> & String,continuation,inspectLeft(left))
def tail(~S:Data,value:Application.Tail(~S)) -> Application.Tail(~S) & String:
  observe_pair(Readers.LifecycleNode(~S),Actors.UpdaterNode(~S),lifecycle_node(~S),updater_node(~S),value)
def removal_tail(~S:Data,value:Application.RemovalTail(~S)) -> Application.RemovalTail(~S) & String:
  observe_pair(Actors.RemovalNode(~S),Application.Tail(~S),removal_node(~S),tail(~S),value)
def editor_readers(~S:Data,value:Application.EditorReaders(~S)) -> Application.EditorReaders(~S) & String:
  observe_pair(Actors.EditorNode(~S),Readers.FailureNode(~S),editor_node(~S),failure_node(~S),value)
def authors(~S:Data,value:Application.Authors(~S)) -> Application.Authors(~S) & String:
  observe_pair(Actors.GraphNode(~S),Actors.LinkNode(~S),graph_node(~S),link_node(~S),value)
def first_four(~S:Data,value:Application.FirstFour(~S)) -> Application.FirstFour(~S) & String:
  observe_pair(Application.Authors(~S),Application.EditorReaders(~S),authors(~S),editor_readers(~S),value)
def nodes(~S:Data,value:Application.Nodes(~S)) -> Application.Nodes(~S) & String:
  observe_pair(Application.FirstFour(~S),Application.RemovalTail(~S),first_four(~S),removal_tail(~S),value)
def world_command(~S:Data,value:Deferred.Command<Application.World(~S)>) -> Deferred.Command<Application.World(~S)> & String:
  match value:
    case Deferred.Raw{apply}:(Deferred.Raw{apply},"raw{opaque=Deferred.Command.Raw.apply}")
    case Deferred.Observed{apply}:(Deferred.Observed{apply},"observed{opaque=Deferred.Command.Observed.apply}")
def world(~S:Data,value:Application.World(~S)) -> Application.World(~S) & String:
  match value:
    case W.World{+namespace,allocator,columns,owners,+events,pending,+registrations,+nextSystemId,+clock,lifecycle}:with_pair(Allocator.Allocator,Application.World(~S) & String,Data.allocator(allocator),allocator => allocation => with_pair(Scheduled.Columns(~S),Application.World(~S) & String,components(~S,columns),columns => componentText => with_pair(Scheduled.Resources(~S),Application.World(~S) & String,resources(~S,owners),owners => resourceText => with_pair(Notice.Journal<S>,Application.World(~S) & String,Data.journal(~S,lifecycle),lifecycle => journalText => with_pair(List<Deferred.Command<Application.World(~S)>>,Application.World(~S) & String,observe_rows(~Deferred.Command<Application.World(~S)>,~world_command(~S),pending),pending => pendingText => (W.World{namespace,allocator,columns,owners,events,pending,registrations,nextSystemId,clock,lifecycle},"namespace=" ++ U32.show(namespace) ++ ",allocator={" ++ allocation ++ "},components={" ++ componentText ++ "},resources={" ++ resourceText ++ "},events=" ++ List.show(&2,Unit,_ => "unit",events) ++ ",pending=" ++ pendingText ++ ",registrations=" ++ List.show(&2,W.RegistrationMeta,Data.registration,registrations) ++ ",nextSystemId=" ++ U32.show(nextSystemId) ++ ",clock=" ++ Data.clock(clock) ++ ",journal={" ++ journalText ++ "}"))))))
def displaced_cell(value:Part.Cell<L.Viewed<Actor.Session,U32>>) -> Part.Cell<L.Viewed<Actor.Session,U32>> & String:
  match value:
    case Part.Cell{+offset,owner,+stamp}:with_pair(Maybe<&1,L.Viewed<Actor.Session,U32>>,Part.Cell<L.Viewed<Actor.Session,U32>> & String,cell(owner),owner => text => (Part.Cell{offset,owner,stamp},"offset=" ++ U32.show(offset) ++ "/" ++ text ++ "/" ++ Data.stamp(stamp)))
def displaced_set(~S:Data,value:QuerySchema.displacements(~S,Actor.components())) -> QuerySchema.displacements(~S,Actor.components()) & String:
  match value:
    case Product.Owner{cells,other}:with_pair(List<Part.Cell<L.Viewed<Actor.Session,U32>>>,QuerySchema.displacements(~S,Actor.components()) & String,observe_rows(~Part.Cell<L.Viewed<Actor.Session,U32>>,~displaced_cell,cells),cells => texts => (Product.Owner{cells,other},texts))
def context_text(~S:Data,value:Context.Context<S,L.resources(~S,Actor.resources(~S)),Actor.resources(~S),{==}>) -> String:
  match value:
    case Context.Context{namespace}:U32.show(namespace)
def snapshot(~S:Data,value:Application.Bound(~S)) -> Application.Bound(~S) & String:
  match value:
    case Provision.Bound{Context.Bound{+context,Root.Scheduled{App.State{General.Present{actual,displaced},actualNodes,guards,handler,+stateBindings},+plan,+bindings,+rules,+deferred}}}:with_pair(Application.World(~S),Application.Bound(~S) & String,world(~S,actual),actual => worldText => with_pair(Application.Nodes(~S),Application.Bound(~S) & String,nodes(~S,actualNodes),actualNodes => nodeText => with_pair(List<QuerySchema.displacements(~S,Actor.components())>,Application.Bound(~S) & String,observe_rows(~QuerySchema.displacements(~S,Actor.components()),~displaced_set(~S),displaced),displaced => displacedTexts => (Provision.Bound{Context.Bound{context,Root.Scheduled{App.State{General.Present{actual,displaced},actualNodes,guards,handler,stateBindings},plan,bindings,rules,deferred}}},"context=" ++ context_text(~S,context) ++ "|world={" ++ worldText ++ "}|nodes=" ++ nodeText ++ "|displaced=" ++ displacedTexts ++ "|plan={" ++ Data.plan(plan) ++ "}|state-bindings=" ++ List.show(&2,App.Binding,Data.binding,stateBindings) ++ "|bindings=" ++ List.show(&2,App.Binding,Data.binding,bindings) ++ "|rules=" ++ Data.rules(rules) ++ "|deferred={" ++ Data.deferred(deferred) ++ "}|guards=unit|handler=unit|opaque=Setup.blueprint callbacks/proof terms"))))
    case value:(value,"retained-physical-inventory-refusal;opaque=General.Storage refused inventory")

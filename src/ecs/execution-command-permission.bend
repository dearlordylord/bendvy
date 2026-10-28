import Base
import ./execution-reservation-task.bend as Task
import ./execution-command-buffer.bend as Buffer
import ./execution-command-removed.bend as Removed
import ./world.bend as W
import ./execution-composer-layout.bend as Layout
import ./execution-resource-policy.bend as Policy
import ./execution-relation-store.bend as RelationStore
import ./relation-types.bend as Relation
import ./execution-relation-command.bend as RelationCommands
import ./execution-relation-operation.bend as Operation
import ./string-equality.bend as StringEquality
import ./execution-relation-resource-dispatch.bend as Dispatch
import ./execution-relation-resource-snapshot.bend as Snapshot
import ./execution-lifetime-scope-resource-dispatch.bend as ScopeDispatch
import ./execution-lifetime-scope-store.bend as ScopeStore
import ./execution-lifetime-scope-command.bend as ScopeCommands

# This closed algebra retains schema evidence supplied by the same declaration.
# A route selects a grant; it never creates any of these type equalities.
type Relations<-S:Data,-resources:Layout.Layout> is Data:
  NoRelations{}
  RelationAllowed{route:Layout.Route,valid:{Layout.grant_valid(~resources,~route) == True{} : Bool},descriptor:Relation.Descriptor<S>,payload:{Layout.payload(resources,route) == RelationStore.Store<S,descriptor> : Type},view:{Layout.view(resources,route) == RelationStore.View<S,descriptor> : Data},protected:{Layout.policy(resources,route) == Policy.ProtectedRelation{S,descriptor} : Policy.Policy},rest:Relations<S,resources>}
  ScopeAllowed{route:Layout.Route,valid:{Layout.grant_valid(~resources,~route) == True{} : Bool},payload:{Layout.payload(resources,route) == ScopeStore.Store<S> : Type},view:{Layout.view(resources,route) == ScopeStore.View<S> : Data},protected:{Layout.policy(resources,route) == Policy.ProtectedLifetimeScope{S} : Policy.Policy},rest:Relations<S,resources>}
type DeferredRelation<-S:Data> is Data:
  DeferredRelation{route:Layout.Route,key:String,descriptor:Relation.Descriptor<S>}
  DeferredScope{route:Layout.Route,key:String}
type Selection<-S:Data,-resources:Layout.Layout> is Type:
  Selection{program:Dispatch.Program(~S,~resources),snapshot:Snapshot.Program(~S,~resources),scopes:ScopeDispatch.Program(~S,~resources),cleanup:CleanupSelection<S,resources>}
type CleanupSelection<-S:Data,-resources:Layout.Layout> is Type:
  Unprovisioned{}
  CleanupActive{graphs:List<&2,Layout.Route>,scopeRoutes:List<&2,Layout.Route>}
  Provisioned{program:Dispatch.Program(~S,~resources),snapshot:Snapshot.Program(~S,~resources),scopes:ScopeDispatch.Program(~S,~resources),graphs:List<&2,Layout.Route>,scopeRoutes:List<&2,Layout.Route>}
def RelationSelection(~S:Data,~resources:Layout.Layout) -> Type:Selection<S,resources>
def selection_field(-S:Data,-resources:Layout.Layout,value:Selection<S,resources>) -> Dispatch.Program(~S,~resources):
  match value:
    case Selection{program,_,_,_}:program
def snapshot_field(-S:Data,-resources:Layout.Layout,value:Selection<S,resources>) -> Snapshot.Program(~S,~resources):
  match value:
    case Selection{_,snapshot,_,_}:snapshot
def scopes_field(-S:Data,-resources:Layout.Layout,value:Selection<S,resources>) -> ScopeDispatch.Program(~S,~resources):
  match value:
    case Selection{_,_,scopes,_}:scopes
def no_selection(~S:Data,~resources:Layout.Layout) -> Selection<S,resources>:
  Selection{Dispatch.empty(~S,~resources),Snapshot.empty(~S,~resources),ScopeDispatch.empty(~S,~resources),Unprovisioned{}}
def extend_selection(~S:Data,~resources:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~resources,~route) == True{} : Bool},~descriptor:Relation.Descriptor<S>,~payload:{Layout.payload(resources,route) == RelationStore.Store<S,descriptor> : Type},~view:{Layout.view(resources,route) == RelationStore.View<S,descriptor> : Data},~protected:{Layout.policy(resources,route) == Policy.ProtectedRelation{S,descriptor} : Policy.Policy},selection:Selection<S,resources>) -> Selection<S,resources>:
  match selection:
    case Selection{program,snapshot,scopes,cleanup}:Selection{Dispatch.extend(~S,~resources,~route,~valid,~descriptor,~payload,~view,~protected,program),Snapshot.extend(~S,~resources,~route,~descriptor,~payload,~view,~protected,snapshot),scopes,cleanup}
def extend_scope_selection(~S:Data,~resources:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~resources,~route) == True{} : Bool},~payload:{Layout.payload(resources,route) == ScopeStore.Store<S> : Type},~view:{Layout.view(resources,route) == ScopeStore.View<S> : Data},~protected:{Layout.policy(resources,route) == Policy.ProtectedLifetimeScope{S} : Policy.Policy},selection:Selection<S,resources>) -> Selection<S,resources>:
  match selection:
    case Selection{program,snapshot,scopes,cleanup}:Selection{program,snapshot,ScopeDispatch.extend(~S,~resources,~route,~valid,~payload,~view,~protected,scopes),cleanup}
def attach_cleanup(-S:Data,-resources:Layout.Layout,gameplay:Selection<S,resources>,cleanup:CleanupSelection<S,resources>) -> Selection<S,resources>:
  match gameplay:
    case Selection{program,snapshot,scopes,_}:Selection{program,snapshot,scopes,cleanup}
def cleanup_selection(-S:Data,-resources:Layout.Layout,value:Selection<S,resources>) -> Selection<S,resources>:
  match value:
    case Selection{program,snapshot,scopes,Unprovisioned{}}:Selection{program,snapshot,scopes,Unprovisioned{}}
    case Selection{program,snapshot,scopes,CleanupActive{graphs,routes}}:Selection{program,snapshot,scopes,CleanupActive{graphs,routes}}
    case Selection{_,_,_,Provisioned{program,snapshot,scopes,graphs,routes}}:Selection{program,snapshot,scopes,CleanupActive{graphs,routes}}
type CleanupRoutes is Data:
  CleanupRoutes{graphs:List<&2,Layout.Route>,scopes:List<&2,Layout.Route>}
def cleanup_routes(-S:Data,-resources:Layout.Layout,value:Selection<S,resources>) -> Maybe<&2,CleanupRoutes>:
  match value:
    case Selection{_,_,_,Unprovisioned{}}:None{}
    case Selection{_,_,_,CleanupActive{graphs,scopes}}:Some{CleanupRoutes{graphs,scopes}}
    case Selection{_,_,_,Provisioned{_,_,_,graphs,scopes}}:Some{CleanupRoutes{graphs,scopes}}
# Deferred graph writes are descriptions of barrier effects, not immediate body
# resource-write grants or resource extraction recipes.
def deferred_descriptions(~S:Data,~resources:Layout.Layout,relations:Relations<S,resources>) -> List<&2,DeferredRelation<S>>:
  match relations:
    case NoRelations{}:[]
    case RelationAllowed{+route,_,descriptor,_,_,_,rest}:DeferredRelation{route,Layout.key(resources,route),descriptor} <> deferred_descriptions(~S,~resources,rest)
    case ScopeAllowed{+route,_,_,_,_,rest}:DeferredScope{route,Layout.key(resources,route)} <> deferred_descriptions(~S,~resources,rest)
def same_route(left:Layout.Route,right:Layout.Route) -> Bool:
  match left right:
    case Layout.AtLeaf{} Layout.AtLeaf{}:True{}
    case Layout.InLeft{left} Layout.InLeft{right}:same_route(left,right)
    case Layout.InRight{left} Layout.InRight{right}:same_route(left,right)
    case _ _:False{}
def same_kind(left:Relation.RelationKind,right:Relation.RelationKind) -> Bool:
  match left right:
    case Relation.Ordinary{} Relation.Ordinary{}:True{}
    case Relation.Hierarchy{} Relation.Hierarchy{}:True{}
    case _ _:False{}
def same_descriptor(-S:Data,left:Relation.Descriptor<S>,right:Relation.Descriptor<S>) -> Bool:
  match left right:
    case Relation.Descriptor{lk,ln,li,lt} Relation.Descriptor{rk,rn,ri,rt}:Bool.and(U32.is_eq(lk,rk),Bool.and(StringEquality.equal(ln,rn),Bool.and(StringEquality.equal(li,ri),same_kind(lt,rt))))
def relations_agree(~S:Data,~resources:Layout.Layout,left:Relations<S,resources>,right:Relations<S,resources>) -> Bool:
  match left right:
    case NoRelations{} NoRelations{}:True{}
    case RelationAllowed{lr,_,ld,_,_,_,left} RelationAllowed{rr,_,rd,_,_,_,right}:Bool.and(same_route(lr,rr),Bool.and(same_descriptor(S,ld,rd),relations_agree(~S,~resources,left,right)))
    case ScopeAllowed{lr,_,_,_,_,left} ScopeAllowed{rr,_,_,_,_,right}:Bool.and(same_route(lr,rr),relations_agree(~S,~resources,left,right))
    case _ _:False{}

# Registration supplies an abstract affine K. A declaration can obtain entity
# commands only by returning the book advanced by this explicit grant. Physical
# scope access remains in the existing independent Builder book.
type Book<-S:Data,-layout:Layout.Layout,-resources:Layout.Layout> is Type:
  Book{permission:Permission,relations:Relations<S,resources>,selection:RelationSelection(~S,~resources)}
type Permission is Data:
  FamilyOnly{}
  EntityStructural{}
type EntityCommands<-Q:Type,-S:Data,-layout:Layout.Layout,-Permit:Data> is Type:
  EntityCommands{despawn:Q -> W.Handle<S> -> Q,spawn:Q -> Removed.Removed(layout) -> Task.Task<S,Permit,Q & Buffer.SpawnAdmission<S,Removed.Removed(layout)>>}
def EntitySelection(~S:Data,~layout:Layout.Layout,~Permit:Data,~Q:Type,~Ops:Type) -> Type:
  @-commands:EntityCommands<Q,S,layout,Permit> -> Ops
def Grant(~S:Data,~layout:Layout.Layout,~Permit:Data,~Q:Type,~K:Type) -> Type:
  @-Ops:Type -> @-selection:EntitySelection(~S,~layout,~Permit,~Q,~Ops) -> K -> K & Ops
def entity_identity(~S:Data,~layout:Layout.Layout,~Permit:Data,~Q:Type,~commands:EntityCommands<Q,S,layout,Permit>) -> EntityCommands<Q,S,layout,Permit>:commands
def entity(~S:Data,~layout:Layout.Layout,~Permit:Data,~Q:Type,~K:Type,~grant:Grant(~S,~layout,~Permit,~Q,~K),book:K) -> K & EntityCommands<Q,S,layout,Permit>:
  grant(EntityCommands<Q,S,layout,Permit>,entity_identity(~S,~layout,~Permit,~Q),book)
def fresh(~S:Data,~layout:Layout.Layout,~resources:Layout.Layout) -> Book<S,layout,resources>:Book{FamilyOnly{},NoRelations{},no_selection(~S,~resources)}
def grant(~S:Data,~layout:Layout.Layout,~resources:Layout.Layout,~Permit:Data,~Q:Type,~despawn:Q -> W.Handle<S> -> Q,~spawn:Q -> Removed.Removed(layout) -> Task.Task<S,Permit,Q & Buffer.SpawnAdmission<S,Removed.Removed(layout)>>,~Ops:Type,~choose:EntitySelection(~S,~layout,~Permit,~Q,~Ops),book:Book<S,layout,resources>) -> Book<S,layout,resources> & Ops:
  match book:
    case Book{_,relations,selection}:(Book{EntityStructural{},relations,selection},choose(EntityCommands{despawn,spawn}))
def RelationGrant(~S:Data,~resources:Layout.Layout,~Q:Type,~K:Type) -> Type:
  @-route:Layout.Route -> @-valid:{Layout.grant_valid(~resources,~route) == True{} : Bool} -> @-descriptor:Relation.Descriptor<S> -> @-payload:{Layout.payload(resources,route) == RelationStore.Store<S,descriptor> : Type} -> @-view:{Layout.view(resources,route) == RelationStore.View<S,descriptor> : Data} -> @-protected:{Layout.policy(resources,route) == Policy.ProtectedRelation{S,descriptor} : Policy.Policy} -> K -> K & RelationCommands.HierarchyCommands<Q,S>
def relation_grant(~S:Data,~layout:Layout.Layout,~resources:Layout.Layout,~Q:Type,~enqueue:Q -> Layout.Route -> Operation.Operation<S> -> Q,~route:Layout.Route,~valid:{Layout.grant_valid(~resources,~route) == True{} : Bool},~descriptor:Relation.Descriptor<S>,~payload:{Layout.payload(resources,route) == RelationStore.Store<S,descriptor> : Type},~view:{Layout.view(resources,route) == RelationStore.View<S,descriptor> : Data},~protected:{Layout.policy(resources,route) == Policy.ProtectedRelation{S,descriptor} : Policy.Policy},book:Book<S,layout,resources>) -> Book<S,layout,resources> & RelationCommands.HierarchyCommands<Q,S>:
  match book:
    case Book{permission,relations,selection}:(Book{permission,RelationAllowed{route,valid,descriptor,payload,view,protected,relations},extend_selection(~S,~resources,~route,~valid,~descriptor,~payload,~view,~protected,selection)},RelationCommands.hierarchy(~S,~Q,~route,~enqueue))
def ScopeGrant(~S:Data,~resources:Layout.Layout,~Q:Type,~K:Type) -> Type:
  @-route:Layout.Route -> @-valid:{Layout.grant_valid(~resources,~route) == True{} : Bool} -> @-payload:{Layout.payload(resources,route) == ScopeStore.Store<S> : Type} -> @-view:{Layout.view(resources,route) == ScopeStore.View<S> : Data} -> @-protected:{Layout.policy(resources,route) == Policy.ProtectedLifetimeScope{S} : Policy.Policy} -> K -> K & ScopeCommands.Commands<Q,S>
def scope_grant(~S:Data,~layout:Layout.Layout,~resources:Layout.Layout,~Q:Type,~enqueue:Q -> Layout.Route -> ScopeCommands.Operation<S> -> Q,~route:Layout.Route,~valid:{Layout.grant_valid(~resources,~route) == True{} : Bool},~payload:{Layout.payload(resources,route) == ScopeStore.Store<S> : Type},~view:{Layout.view(resources,route) == ScopeStore.View<S> : Data},~protected:{Layout.policy(resources,route) == Policy.ProtectedLifetimeScope{S} : Policy.Policy},book:Book<S,layout,resources>) -> Book<S,layout,resources> & ScopeCommands.Commands<Q,S>:
  match book:
    case Book{_,relations,selection}:(Book{EntityStructural{},ScopeAllowed{route,valid,payload,view,protected,relations},extend_scope_selection(~S,~resources,~route,~valid,~payload,~view,~protected,selection)},ScopeCommands.provide(~S,~Q,~route,~enqueue))
def despawn_field(~Q:Type,~S:Data,~layout:Layout.Layout,~Permit:Data,commands:EntityCommands<Q,S,layout,Permit>) -> Q -> W.Handle<S> -> Q:
  match commands:
    case EntityCommands{despawn,_}:despawn
type Prepared<-Ops:Type,-S:Data,-resources:Layout.Layout> is Type:
  Prepared{permission:Permission,relations:Relations<S,resources>,selection:RelationSelection(~S,~resources),ops:Ops}
def prepared(~S:Data,~layout:Layout.Layout,~resources:Layout.Layout,-B:Type,-Ops:Type,result:B & (Book<S,layout,resources> & Ops)) -> B & Prepared<Ops,S,resources>:
  match result:
    case (book,(Book{permission,relations,selection},ops)):(book,Prepared{permission,relations,selection,ops})
def agrees(left:Permission,right:Permission) -> Bool:
  match left right:
    case FamilyOnly{} FamilyOnly{}:True{}
    case EntityStructural{} EntityStructural{}:True{}
    case _ _:False{}
def ops_field(-Ops:Type,-S:Data,-resources:Layout.Layout,value:Prepared<Ops,S,resources>) -> Ops:
  match value:
    case Prepared{_,_,_,ops}:ops

# Only a declaration that consumed the structural grant can obtain this field.
def spawn_field(~Q:Type,~S:Data,~layout:Layout.Layout,~Permit:Data,commands:EntityCommands<Q,S,layout,Permit>) -> Q -> Removed.Removed(layout) -> Task.Task<S,Permit,Q & Buffer.SpawnAdmission<S,Removed.Removed(layout)>>:
  match commands:
    case EntityCommands{_,spawn}:spawn

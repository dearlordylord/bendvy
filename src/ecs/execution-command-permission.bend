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

# This closed algebra retains schema evidence supplied by the same declaration.
# A route selects a grant; it never creates any of these type equalities.
type Relations<-S:Data,-resources:Layout.Layout> is Data:
  NoRelations{}
  RelationAllowed{route:Layout.Route,valid:{Layout.grant_valid(~resources,~route) == True{} : Bool},descriptor:Relation.Descriptor<S>,payload:{Layout.payload(resources,route) == RelationStore.Store<S,descriptor> : Type},view:{Layout.view(resources,route) == RelationStore.View<S,descriptor> : Data},protected:{Layout.policy(resources,route) == Policy.ProtectedRelation{S,descriptor} : Policy.Policy},rest:Relations<S,resources>}
type DeferredRelation<-S:Data> is Data:
  DeferredRelation{route:Layout.Route,key:String,descriptor:Relation.Descriptor<S>}
# Deferred graph writes are descriptions of barrier effects, not immediate body
# resource-write grants or resource extraction recipes.
def deferred_descriptions(~S:Data,~resources:Layout.Layout,relations:Relations<S,resources>) -> List<&2,DeferredRelation<S>>:
  match relations:
    case NoRelations{}:[]
    case RelationAllowed{+route,_,descriptor,_,_,_,rest}:DeferredRelation{route,Layout.key(resources,route),descriptor} <> deferred_descriptions(~S,~resources,rest)

# Registration supplies an abstract affine K. A declaration can obtain entity
# commands only by returning the book advanced by this explicit grant. Physical
# scope access remains in the existing independent Builder book.
type Book<-S:Data,-layout:Layout.Layout,-resources:Layout.Layout> is Type:
  Book{permission:Permission,relations:Relations<S,resources>}
type Permission is Data:
  FamilyOnly{}
  EntityStructural{}
type EntityCommands<-Q:Type,-S:Data,-layout:Layout.Layout,-Permit:Data> is Type:
  EntityCommands{despawn:Q -> W.Handle<S> -> Q,spawn:Q -> Removed.Removed(layout) -> Task.Task<S,Permit,Q & Buffer.SpawnAdmission<S,Removed.Removed(layout)>>}
def Grant(~S:Data,~layout:Layout.Layout,~Permit:Data,~Q:Type,~K:Type) -> Type:
  K -> K & EntityCommands<Q,S,layout,Permit>
def fresh(~S:Data,~layout:Layout.Layout,~resources:Layout.Layout) -> Book<S,layout,resources>:Book{FamilyOnly{},NoRelations{}}
def grant(~S:Data,~layout:Layout.Layout,~resources:Layout.Layout,~Permit:Data,~Q:Type,~despawn:Q -> W.Handle<S> -> Q,~spawn:Q -> Removed.Removed(layout) -> Task.Task<S,Permit,Q & Buffer.SpawnAdmission<S,Removed.Removed(layout)>>,book:Book<S,layout,resources>) -> Book<S,layout,resources> & EntityCommands<Q,S,layout,Permit>:
  match book:
    case Book{_,relations}:(Book{EntityStructural{},relations},EntityCommands{despawn,spawn})
def RelationGrant(~S:Data,~resources:Layout.Layout,~Q:Type,~K:Type) -> Type:
  @-route:Layout.Route -> @-valid:{Layout.grant_valid(~resources,~route) == True{} : Bool} -> @-descriptor:Relation.Descriptor<S> -> @-payload:{Layout.payload(resources,route) == RelationStore.Store<S,descriptor> : Type} -> @-view:{Layout.view(resources,route) == RelationStore.View<S,descriptor> : Data} -> @-protected:{Layout.policy(resources,route) == Policy.ProtectedRelation{S,descriptor} : Policy.Policy} -> K -> K & RelationCommands.HierarchyCommands<Q,S>
def relation_grant(~S:Data,~layout:Layout.Layout,~resources:Layout.Layout,~Q:Type,~enqueue:Q -> Layout.Route -> Operation.Operation<S> -> Q,~route:Layout.Route,~valid:{Layout.grant_valid(~resources,~route) == True{} : Bool},~descriptor:Relation.Descriptor<S>,~payload:{Layout.payload(resources,route) == RelationStore.Store<S,descriptor> : Type},~view:{Layout.view(resources,route) == RelationStore.View<S,descriptor> : Data},~protected:{Layout.policy(resources,route) == Policy.ProtectedRelation{S,descriptor} : Policy.Policy},book:Book<S,layout,resources>) -> Book<S,layout,resources> & RelationCommands.HierarchyCommands<Q,S>:
  match book:
    case Book{permission,relations}:(Book{permission,RelationAllowed{route,valid,descriptor,payload,view,protected,relations}},RelationCommands.hierarchy(~S,~Q,~route,~enqueue))
def despawn_field(~Q:Type,~S:Data,~layout:Layout.Layout,~Permit:Data,commands:EntityCommands<Q,S,layout,Permit>) -> Q -> W.Handle<S> -> Q:
  match commands:
    case EntityCommands{despawn,_}:despawn
type Prepared<-Ops:Type,-S:Data,-resources:Layout.Layout> is Type:
  Prepared{permission:Permission,relations:Relations<S,resources>,ops:Ops}
def prepared(~S:Data,~layout:Layout.Layout,~resources:Layout.Layout,-B:Type,-Ops:Type,result:B & (Book<S,layout,resources> & Ops)) -> B & Prepared<Ops,S,resources>:
  match result:
    case (book,(Book{permission,relations},ops)):(book,Prepared{permission,relations,ops})
def agrees(left:Permission,right:Permission) -> Bool:
  match left right:
    case FamilyOnly{} FamilyOnly{}:True{}
    case EntityStructural{} EntityStructural{}:True{}
    case _ _:False{}
def ops_field(-Ops:Type,-S:Data,-resources:Layout.Layout,value:Prepared<Ops,S,resources>) -> Ops:
  match value:
    case Prepared{_,_,ops}:ops

# Only a declaration that consumed the structural grant can obtain this field.
def spawn_field(~Q:Type,~S:Data,~layout:Layout.Layout,~Permit:Data,commands:EntityCommands<Q,S,layout,Permit>) -> Q -> Removed.Removed(layout) -> Task.Task<S,Permit,Q & Buffer.SpawnAdmission<S,Removed.Removed(layout)>>:
  match commands:
    case EntityCommands{_,spawn}:spawn

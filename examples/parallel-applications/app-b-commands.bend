import Base
import ./app-b-schema.bend as D
import ../../src/ecs/world.bend as W
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-command-removed.bend as Removed
import ../../src/ecs/execution-relation-command.bend as Relation
import ../../src/ecs/execution-reservation-task.bend as Task
import ../../src/ecs/execution-system.bend as Sys

def Receipts() -> Type:List<Buffer.Receipt<D.Scene,Array<U32>,Removed.Removed(D.components())>>
def resources() -> L.Layout:D.resources(~Receipts())
def route() -> L.Route:L.InLeft{L.AtLeaf{}}
def C() -> Type:L.columns(~D.Scene,L.origin(D.components(),route()))
def R() -> Type:L.resources(~D.Scene,D.parent_layout())
def Columns() -> Type:L.columns(~D.Scene,D.components())
type Caps<-Permit:Data,-Q:Type> is Type:
  Caps{entities:Permission.EntityCommands<Q,D.Scene,D.components(),Permit>,parent:Relation.HierarchyCommands<Q,D.Scene>,link:Relation.HierarchyCommands<Q,D.Scene>}
def Ops(Permit:Data,H:Type,Q:Type) -> Type:Caps<Permit,Q>
type Stage is Data:
  Seed{}
  Link{}
  Reparent{}
  Idle{}
  Refused{}
type User is Type:
  User{stage:Stage,handles:List<&2,W.Handle<D.Scene>>,returned:List<Removed.Removed(D.components())>,errors:List<&2,W.WorldError>}
def initial() -> User:User{Seed{},[],[],[]}
def declared_link(~Permit:Data,~H:Type,~Q:Type,-B:Type,-K:Type,book:B,entities:Permission.EntityCommands<Q,D.Scene,D.components(),Permit>,parent:Relation.HierarchyCommands<Q,D.Scene>,result:K & Relation.HierarchyCommands<Q,D.Scene>) -> B & (K & Ops(Permit,H,Q)):
  match result:
    case (permissions,link):(book,(permissions,Caps{entities,parent,link}))
def declared_parent(~Permit:Data,~H:Type,~Q:Type,~B:Type,~K:Type,~relations:Permission.RelationGrant(~D.Scene,~resources(),~Q,~K),book:B,entities:Permission.EntityCommands<Q,D.Scene,D.components(),Permit>,result:K & Relation.HierarchyCommands<Q,D.Scene>) -> B & (K & Ops(Permit,H,Q)):
  match result:
    case (permissions,parent):declared_link(~Permit,~H,~Q,B,K,book,entities,parent,relations(L.InRight{L.InLeft{L.AtLeaf{}}},{==},D.link(),{==},{==},{==},permissions))
def declared_entities(~Permit:Data,~H:Type,~Q:Type,~B:Type,~K:Type,~relations:Permission.RelationGrant(~D.Scene,~resources(),~Q,~K),book:B,result:K & Permission.EntityCommands<Q,D.Scene,D.components(),Permit>) -> B & (K & Ops(Permit,H,Q)):
  match result:
    case (permissions,entities):declared_parent(~Permit,~H,~Q,~B,~K,~relations,book,entities,relations(L.InLeft{L.AtLeaf{}},{==},D.parent(),{==},{==},{==},permissions))
def declaration(~Permit:Data,~H:Type,~Q:Type,~commands:Local.Commands<Q,D.Scene,Array<U32>>,~B:Type,~builder:Build.Builder(~D.Scene,~Columns(),~C(),~R(),~Permit,~H,~B),~K:Type,~entity:Permission.Grant(~D.Scene,~D.components(),~Permit,~Q,~K),~relations:Permission.RelationGrant(~D.Scene,~resources(),~Q,~K),~scopes:Permission.ScopeGrant(~D.Scene,~resources(),~Q,~K),book:B,permissions:K) -> B & (K & Ops(Permit,H,Q)):
  declared_entities(~Permit,~H,~Q,~B,~K,~relations,book,entity(permissions))
def entities(~Permit:Data,~Q:Type,caps:Caps<Permit,Q>) -> Permission.EntityCommands<Q,D.Scene,D.components(),Permit>:
  match caps:
    case Caps{entities,_,_}:entities
def parent(~Permit:Data,~Q:Type,caps:Caps<Permit,Q>) -> Relation.HierarchyCommands<Q,D.Scene>:
  match caps:
    case Caps{_,parent,_}:parent
def link(~Permit:Data,~Q:Type,caps:Caps<Permit,Q>) -> Relation.HierarchyCommands<Q,D.Scene>:
  match caps:
    case Caps{_,_,link}:link
def bundle() -> Removed.Removed(D.components()):
  Product.Owner{Some{D.sample_array()},Some{D.sample_scalar()}}
def child_seeded(~Permit:Data,~H:Type,~Q:Type,scope:H,+root:W.Handle<D.Scene>,+other:W.Handle<D.Scene>,result:Q & Buffer.SpawnAdmission<D.Scene,Removed.Removed(D.components())>) -> Task.Task<D.Scene,Permit,H & (Q & (User & Sys.Completion<String,String>))>:
  match result:
    case (queue,Buffer.SpawnQueued{child}):Task.TDone{(scope,(queue,(User{Link{},[root,other,child],[],[]},Sys.Success{"three bundles queued"})))}
    case (queue,Buffer.SpawnRejected{bundle,error}):Task.TDone{(scope,(queue,(User{Refused{},[root,other],[bundle],[error]},Sys.BodyError{"child reservation refused","two bundles queued"})))}
def other_seeded(~Permit:Data,~H:Type,~Q:Type,~spawn:Q -> Removed.Removed(D.components()) -> Task.Task<D.Scene,Permit,Q & Buffer.SpawnAdmission<D.Scene,Removed.Removed(D.components())>>,scope:H,+root:W.Handle<D.Scene>,result:Q & Buffer.SpawnAdmission<D.Scene,Removed.Removed(D.components())>) -> Task.Task<D.Scene,Permit,H & (Q & (User & Sys.Completion<String,String>))>:
  match result:
    case (queue,Buffer.SpawnQueued{+other}):Task.bind(D.Scene,Permit,Q & Buffer.SpawnAdmission<D.Scene,Removed.Removed(D.components())>,H & (Q & (User & Sys.Completion<String,String>)),spawn(queue,bundle()),result => child_seeded(~Permit,~H,~Q,scope,root,other,result))
    case (queue,Buffer.SpawnRejected{bundle,error}):Task.TDone{(scope,(queue,(User{Refused{},[root],[bundle],[error]},Sys.BodyError{"other reservation refused","one bundle queued"})))}
def root_seeded(~Permit:Data,~H:Type,~Q:Type,~spawn:Q -> Removed.Removed(D.components()) -> Task.Task<D.Scene,Permit,Q & Buffer.SpawnAdmission<D.Scene,Removed.Removed(D.components())>>,scope:H,result:Q & Buffer.SpawnAdmission<D.Scene,Removed.Removed(D.components())>) -> Task.Task<D.Scene,Permit,H & (Q & (User & Sys.Completion<String,String>))>:
  match result:
    case (queue,Buffer.SpawnQueued{+root}):Task.bind(D.Scene,Permit,Q & Buffer.SpawnAdmission<D.Scene,Removed.Removed(D.components())>,H & (Q & (User & Sys.Completion<String,String>)),spawn(queue,bundle()),result => other_seeded(~Permit,~H,~Q,~spawn,scope,root,result))
    case (queue,Buffer.SpawnRejected{bundle,error}):Task.TDone{(scope,(queue,(User{Refused{},[],[bundle],[error]},Sys.BodyError{"root reservation refused","no bundle queued"})))}
def body(~Permit:Data,~H:Type,~Q:Type,~caps:Ops(Permit,H,Q),~commands:Local.Commands<Q,D.Scene,Array<U32>>,scope:H,queue:Q,user:User) -> Task.Task<D.Scene,Permit,H & (Q & (User & Sys.Completion<String,String>))>:
  match user:
    case User{Seed{},[],[],[]}:Task.bind(D.Scene,Permit,Q & Buffer.SpawnAdmission<D.Scene,Removed.Removed(D.components())>,H & (Q & (User & Sys.Completion<String,String>)),Permission.spawn_field(~Q,~D.Scene,~D.components(),~Permit,entities(~Permit,~Q,caps))(queue,bundle()),result => root_seeded(~Permit,~H,~Q,~Permission.spawn_field(~Q,~D.Scene,~D.components(),~Permit,entities(~Permit,~Q,caps)),scope,result))
    case User{Link{},+root <> +other <> +child <> [],returned,errors}:Task.TDone{(scope,(Relation.relate_field(~D.Scene,~Q,Relation.relations_field(~D.Scene,~Q,link(~Permit,~Q,caps)))(Relation.relate_field(~D.Scene,~Q,Relation.relations_field(~D.Scene,~Q,parent(~Permit,~Q,caps)))(queue,child,root),child,other),(User{Reparent{},[root,other,child],returned,errors},Sys.Success{"Parent and Link queued"})))}
    case User{Reparent{},+root <> +other <> +child <> [],returned,errors}:Task.TDone{(scope,(Relation.relate_field(~D.Scene,~Q,Relation.relations_field(~D.Scene,~Q,parent(~Permit,~Q,caps)))(queue,child,other),(User{Idle{},[root,other,child],returned,errors},Sys.Success{"reparent queued"})))}
    case user:Task.TDone{(scope,(queue,(user,Sys.Success{"no command authored"})))}
def Owner() -> Type:Cmd.Owner<D.Scene,C(),R(),Unit,D.components(),resources(),route(),Ops,User,String,String,declaration,body>

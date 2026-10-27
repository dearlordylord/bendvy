import Base
import ./execution-reservation-task.bend as Task
import ./execution-command-buffer.bend as Buffer
import ./execution-command-removed.bend as Removed
import ./world.bend as W
import ./execution-composer-layout.bend as Layout

# Registration supplies an abstract affine K. A declaration can obtain entity
# commands only by returning the book advanced by this explicit grant. Physical
# scope access remains in the existing independent Builder book.
type Book<-layout:Layout.Layout> is Type:
  Ungranted{}
  EntityGranted{}
type Permission is Data:
  FamilyOnly{}
  EntityStructural{}
type EntityCommands<-Q:Type,-S:Data,-layout:Layout.Layout,-Permit:Data> is Type:
  EntityCommands{despawn:Q -> W.Handle<S> -> Q,spawn:Q -> Removed.Removed(layout) -> Task.Task<S,Permit,Q & Buffer.SpawnAdmission<S,Removed.Removed(layout)>>}
def Grant(~S:Data,~layout:Layout.Layout,~Permit:Data,~Q:Type,~K:Type) -> Type:
  K -> K & EntityCommands<Q,S,layout,Permit>
def fresh(~layout:Layout.Layout) -> Book<layout>:Ungranted{}
def grant(~S:Data,~layout:Layout.Layout,~Permit:Data,~Q:Type,~despawn:Q -> W.Handle<S> -> Q,~spawn:Q -> Removed.Removed(layout) -> Task.Task<S,Permit,Q & Buffer.SpawnAdmission<S,Removed.Removed(layout)>>,book:Book<layout>) -> Book<layout> & EntityCommands<Q,S,layout,Permit>:
  match book:
    case Ungranted{}:(EntityGranted{},EntityCommands{despawn,spawn})
    case EntityGranted{}:(EntityGranted{},EntityCommands{despawn,spawn})
def kind(~layout:Layout.Layout,book:Book<layout>) -> Permission:
  match book:
    case Ungranted{}:FamilyOnly{}
    case EntityGranted{}:EntityStructural{}
def despawn_field(~Q:Type,~S:Data,~layout:Layout.Layout,~Permit:Data,commands:EntityCommands<Q,S,layout,Permit>) -> Q -> W.Handle<S> -> Q:
  match commands:
    case EntityCommands{despawn,_}:despawn
type Prepared<-Ops:Type> is Type:
  Prepared{permission:Permission,ops:Ops}
def prepared(~layout:Layout.Layout,-B:Type,-Ops:Type,result:B & (Book<layout> & Ops)) -> B & Prepared<Ops>:
  match result:
    case (book,(permission,ops)):(book,Prepared{kind(~layout,permission),ops})
def agrees(left:Permission,right:Permission) -> Bool:
  match left right:
    case FamilyOnly{} FamilyOnly{}:True{}
    case EntityStructural{} EntityStructural{}:True{}
    case _ _:False{}
def ops_field(-Ops:Type,value:Prepared<Ops>) -> Ops:
  match value:
    case Prepared{_,ops}:ops

# Only a declaration that consumed the structural grant can obtain this field.
def spawn_field(~Q:Type,~S:Data,~layout:Layout.Layout,~Permit:Data,commands:EntityCommands<Q,S,layout,Permit>) -> Q -> Removed.Removed(layout) -> Task.Task<S,Permit,Q & Buffer.SpawnAdmission<S,Removed.Removed(layout)>>:
  match commands:
    case EntityCommands{_,spawn}:spawn

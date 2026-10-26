import Base
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
type EntityCommands<-Q:Type,-S:Data,-layout:Layout.Layout> is Type:
  EntityCommands{despawn:Q -> W.Handle<S> -> Q}
def Grant(~S:Data,~layout:Layout.Layout,~Q:Type,~K:Type) -> Type:
  K -> K & EntityCommands<Q,S,layout>
def fresh(~layout:Layout.Layout) -> Book<layout>:Ungranted{}
def grant(~S:Data,~layout:Layout.Layout,~Q:Type,~despawn:Q -> W.Handle<S> -> Q,book:Book<layout>) -> Book<layout> & EntityCommands<Q,S,layout>:
  match book:
    case Ungranted{}:(EntityGranted{},EntityCommands{despawn})
    case EntityGranted{}:(EntityGranted{},EntityCommands{despawn})
def kind(~layout:Layout.Layout,book:Book<layout>) -> Permission:
  match book:
    case Ungranted{}:FamilyOnly{}
    case EntityGranted{}:EntityStructural{}
def despawn_field(~Q:Type,~S:Data,~layout:Layout.Layout,commands:EntityCommands<Q,S,layout>) -> Q -> W.Handle<S> -> Q:
  match commands:
    case EntityCommands{despawn}:despawn
type Prepared<-Ops:Type> is Type:
  Prepared{permission:Permission,ops:Ops}
def prepared(~layout:Layout.Layout,-B:Type,-Ops:Type,result:B & (Book<layout> & Ops)) -> B & Prepared<Ops>:
  match result:
    case (book,(permission,ops)):(book,Prepared{kind(~layout,permission),ops})

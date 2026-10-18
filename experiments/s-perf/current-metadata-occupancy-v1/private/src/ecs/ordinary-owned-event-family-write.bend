import Base
import ./world.bend as W
import ./owner-product.bend as Product
import ./owned-event-log.bend as Log
import ./ordinary-owned-event.bend as Pub
import ./ordinary-owned-event-binding.bend as Binding
import ./ordinary-owned-event-declaration.bend as D
import ./owned-event-journal.bend as Journal
# Normal setup receives a canonical binding; all executable log/receipt paths
# remain erased until the declaration is specialized at its full recovery tree.
def Ops(~S:Data,~P:Type,~identity:Pub.Domain<S,P>,H:Type) -> Type:Pub.Write<S,P,identity,H>
def empty(~P:Type,unit:Unit) -> List<P>:[]
def emit_named(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~E:Data,~path:Product.Lens<R,Log.Log<P>,Rest>,~inject:Nat -> E,~identity:Pub.Domain<S,P>,~All:Type,~RecoveryRest:Type,~recovery:Product.Lens<All,List<P>,RecoveryRest>,stage:Journal.Stage<W.World<S,C,R,E>,All>,payload:P) -> Journal.Stage<W.World<S,C,R,E>,All>:
  Journal.emit(~S,~C,~R,~P,~Rest,~E,~path,~inject,~All,~RecoveryRest,~recovery,Journal.record_named(~W.World<S,C,R,E>,~All,Pub.name(~S,~P,identity),stage),payload)
def grant(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~E:Data,~path:Product.Lens<R,Log.Log<P>,Rest>,~inject:Nat -> E,~identity:Pub.Domain<S,P>,~All:Type,~RecoveryRest:Type,~recovery:Product.Lens<All,List<P>,RecoveryRest>,unit:Unit) -> Pub.Write<S,P,identity,Journal.Stage<W.World<S,C,R,E>,All>>:
  Pub.Write{emit_named(~S,~C,~R,~P,~Rest,~E,~path,~inject,~identity,~All,~RecoveryRest,~recovery)}
def declaration(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~E:Data,~path:Product.Lens<R,Log.Log<P>,Rest>,~inject:Nat -> E,~select:List<&2,E> -> List<&2,Nat>,~identity:Pub.Domain<S,P>,~binding:Binding.Binding<S,R,P,Rest,E,path,inject,select,identity>) -> D.Declaration<S,W.World<S,C,R,E>,List<P>,Ops(~S,~P,~identity),grant(~S,~C,~R,~P,~Rest,~E,~path,~inject,~identity)>:
  D.Described{empty(~P),[Pub.access(~S,~P,identity,":write")],D.Description{[Pub.name(~S,~P,identity)],False{}}}

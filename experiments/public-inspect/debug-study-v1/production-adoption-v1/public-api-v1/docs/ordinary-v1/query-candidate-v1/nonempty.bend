import Base
import ./plain-transient-application.bend as Plain
import ./registered-application.bend as Registered
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Cmp
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/ordinary-declaration.bend as Identity
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/persistence-declaration.bend as Recipe
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/public-adoption-v1/core-promotion-v1/library/snapshot-leaf.bend as Leaf

type Seed<-S:Data,C:Type,R:Type,P:Type> is Type:
  Seeded{factory:W.Factory,world:W.World<S,C,R,Unit>,accepted:Bool,returned:Maybe<P>}
  CreationRejected{factory:W.Factory,resource:R,incoming:P}
def plain_empty(_:Unit) -> Plain.Plain:
  Plain.Plain{Col.ensure(~Plain.Schema,~Plain.Payload,Col.empty(~Plain.Schema,~Plain.Payload),1),Recipe.plain(~Plain.Schema,~Plain.Payload,~Plain.plain_identity())}
def transient_empty(_:Unit) -> Plain.Transient():
  Leaf.TransientComponent{Col.ensure(~Plain.Schema,~Plain.Payload,Col.empty(~Plain.Schema,~Plain.Payload),1),Recipe.transient(~Plain.Schema,~Plain.Payload,~Plain.transient_identity())}
def replaced(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~identity:Identity.Declaration<S,P>,~view:P -> P & V,~take:C -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> C,factory:W.Factory,result:Cmp.Replacement<W.World<S,C,R,Unit>,P>) -> Seed<S,C,R,P>:
  match result:
    case Cmp.Replaced{world,previous}:Seeded{factory,world,True{},previous}
    case Cmp.ReplaceRejected{world,incoming,_}:Seeded{factory,world,False{},incoming}
def activated(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~identity:Identity.Declaration<S,P>,~view:P -> P & V,~take:C -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> C,factory:W.Factory,incoming:P,+handle:W.Handle<S>,observed:W.World<S,C,R,Unit> & W.Status) -> Seed<S,C,R,P>:
  match observed:
    case (world,W.Rejected{_}):Seeded{factory,world,False{},Some{incoming}}
    case (world,W.Accepted{}):replaced(~S,~C,~R,~P,~Rest,~V,~identity,~view,~take,~put,factory,Cmp.replace(~S,~C,~R,~Unit,~Rest,~P,~V,~S,~take,~put,~view,Cmp.Family{Identity.key(~S,~P,identity)},world,handle,Some{incoming}))
def reserved(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~identity:Identity.Declaration<S,P>,~view:P -> P & V,~take:C -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> C,factory:W.Factory,incoming:P,observed:W.World<S,C,R,Unit> & W.Reservation<S>) -> Seed<S,C,R,P>:
  match observed:
    case (world,W.ReservationRejected{_}):Seeded{factory,world,False{},Some{incoming}}
    case (world,W.Reserved{+handle}):activated(~S,~C,~R,~P,~Rest,~V,~identity,~view,~take,~put,factory,incoming,handle,W.activate(~S,~C,~R,~Unit,world,handle))
def created(~S:Data,~C:Type,~R:Type,~P:Type,~Rest:Type,~V:Data,~identity:Identity.Declaration<S,P>,~view:P -> P & V,~take:C -> Rest & Col.Column<S,P>,~put:Rest -> Col.Column<S,P> -> C,incoming:P,result:W.Creation<S,C,R,Unit>) -> Seed<S,C,R,P>:
  match result:
    case W.CreateRejected{factory,resource}:CreationRejected{factory,resource,incoming}
    case W.Created{factory,world}:reserved(~S,~C,~R,~P,~Rest,~V,~identity,~view,~take,~put,factory,incoming,W.reserve_id(~S,~C,~R,~Unit,world))
def plain() -> Seed<Plain.Schema,Plain.Plain,Unit,Plain.Payload>:
  created(~Plain.Schema,~Plain.Plain,~Unit,~Plain.Payload,~Recipe.Plain<Plain.Schema,Plain.Payload,Plain.plain_identity()>,~U32,~Plain.plain_identity(),~Plain.view,~Plain.plain_take,~Plain.plain_put,Plain.Payload{Array.new(U32,1n,7)},W.create(~Plain.Schema,~Plain.Plain,~Unit,~Unit,~plain_empty,W.factory(),Unit{}))
def transient() -> Seed<Plain.Schema,Plain.Transient(),Unit,Plain.Payload>:
  created(~Plain.Schema,~Plain.Transient(),~Unit,~Plain.Payload,~Recipe.Transient<Plain.Schema,Plain.Payload,Plain.transient_identity()>,~U32,~Plain.transient_identity(),~Plain.view,~Plain.transient_take,~Plain.transient_put,Plain.Payload{Array.new(U32,1n,11)},W.create(~Plain.Schema,~Plain.Transient(),~Unit,~Unit,~transient_empty,W.factory(),Unit{}))

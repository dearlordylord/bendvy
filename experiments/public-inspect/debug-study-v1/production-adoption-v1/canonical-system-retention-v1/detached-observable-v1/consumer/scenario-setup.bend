import Base
import ./scenario-schema.bend as S
import ./scenario-queries.bend as Q
import ../../../../../../../src/ecs/world.bend as W
import ../../../../../../../src/ecs/component.bend as C
import ../../../../../../../src/ecs/column.bend as Col
import ../dependencies/experiments/public-simulation/bend-v1/owner-view.bend as View
import ../../../../../../../src/ecs/persistence-declaration.bend as R
import ../../../../../../../src/ecs/snapshot-leaf.bend as Leaf
import ../../../../../../../src/ecs/decode-data.bend as D
import ../../../../../../../src/ecs/ordinary-declaration.bend as I

type Seed<Store:Type> is Type:
  Seeded{factory:W.Factory,world:W.World<S.Schema,Store,Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>}
  AllocationShapeRefused{factory:W.Factory,world:W.World<S.Schema,Store,Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>}
  CreateRefused{factory:W.Factory,resource:Unit}
  ReserveRefused{factory:W.Factory,world:W.World<S.Schema,Store,Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,error:W.WorldError}
  ActivateRefused{factory:W.Factory,world:W.World<S.Schema,Store,Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,error:W.WorldError}
  ReplaceRefused{factory:W.Factory,world:W.World<S.Schema,Store,Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>,incoming:Maybe<&1,Array<U32>>,error:W.WorldError}
def payload(value:U32,tail:U32) -> Array<U32>:
  ANode{ALeaf{value},ALeaf{tail}}
def reserve_activated(~Store:Type,next:W.Factory -> W.World<S.Schema,Store,Unit,Unit> -> List<&2,W.Handle<S.Schema>> -> Seed<Store>,factory:W.Factory,handles:List<&2,W.Handle<S.Schema>>,handle:W.Handle<S.Schema>,got:W.World<S.Schema,Store,Unit,Unit> & W.Status) -> Seed<Store>:
  match got:
    case (world,W.Accepted{}):next(factory,world,List.append(&2,W.Handle<S.Schema>,handles,[handle]))
    case (world,W.Rejected{error}):ActivateRefused{factory,world,List.append(&2,W.Handle<S.Schema>,handles,[handle]),error}
def reserve_got(~Store:Type,next:W.Factory -> W.World<S.Schema,Store,Unit,Unit> -> List<&2,W.Handle<S.Schema>> -> Seed<Store>,factory:W.Factory,handles:List<&2,W.Handle<S.Schema>>,got:W.World<S.Schema,Store,Unit,Unit> & W.Reservation<S.Schema>) -> Seed<Store>:
  match got:
    case (world,W.ReservationRejected{error}):ReserveRefused{factory,world,handles,error}
    case (world,W.Reserved{+handle}):reserve_activated(~Store,next,factory,handles,handle,W.activate(~S.Schema,~Store,~Unit,~Unit,world,handle))
def allocate(~Store:Type,next:W.Factory -> W.World<S.Schema,Store,Unit,Unit> -> List<&2,W.Handle<S.Schema>> -> Seed<Store>,count:Nat,factory:W.Factory,world:W.World<S.Schema,Store,Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>) -> Seed<Store>:
  match count:
    case 0n:next(factory,world,handles)
    case 1n+rest:reserve_got(~Store,(factory => world => handles => allocate(~Store,next,rest,factory,world,handles)),factory,handles,W.reserve_id(~S.Schema,~Store,~Unit,~Unit,world))
def created(~Store:Type,next:W.Factory -> W.World<S.Schema,Store,Unit,Unit> -> List<&2,W.Handle<S.Schema>> -> Seed<Store>,got:W.Creation<S.Schema,Store,Unit,Unit>) -> Seed<Store>:
  match got:
    case W.CreateRejected{factory,resource}:CreateRefused{factory,resource}
    case W.Created{factory,world}:allocate(~Store,next,3n,factory,world,[])
def replaced(~Store:Type,next:W.Factory -> W.World<S.Schema,Store,Unit,Unit> -> List<&2,W.Handle<S.Schema>> -> List<Maybe<&1,Array<U32>>> -> Seed<Store>,factory:W.Factory,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>,got:C.Replacement<W.World<S.Schema,Store,Unit,Unit>,Array<U32>>) -> Seed<Store>:
  match got:
    case C.Replaced{world,old}:next(factory,world,handles,old <> previous)
    case C.ReplaceRejected{world,incoming,error}:ReplaceRefused{factory,world,handles,previous,incoming,error}
def finish(~Store:Type,factory:W.Factory,world:W.World<S.Schema,Store,Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>) -> Seed<Store>:
  Seeded{factory,world,handles,previous}
def plain_empty(unit:Unit) -> S.plain_store():
  S.Store{S.PlainSlot{Col.ensure(~S.Schema,~Array<U32>,Col.empty(~S.Schema,~Array<U32>),3),R.plain(~S.Schema,~Array<U32>,~S.identity("Position"))},S.PlainSlot{Col.ensure(~S.Schema,~Array<U32>,Col.empty(~S.Schema,~Array<U32>),3),R.plain(~S.Schema,~Array<U32>,~S.identity("Velocity"))},S.PlainSlot{Col.ensure(~S.Schema,~Array<U32>,Col.empty(~S.Schema,~Array<U32>),3),R.plain(~S.Schema,~Array<U32>,~S.identity("Health"))}}
def plain_position_replace(world:W.World<S.Schema,S.plain_store(),Unit,Unit>,handle:W.Handle<S.Schema>,incoming:Array<U32>) -> C.Replacement<W.World<S.Schema,S.plain_store(),Unit,Unit>,Array<U32>>:
  C.replace(~S.Schema,~S.plain_store(),~Unit,~Unit,~Q.plain_position_rest(),~Array<U32>,~View.FullCell,~Unit,~Q.plain_position_take,~Q.plain_position_put,~View.view,C.define(~S.Schema,~S.plain_store(),~Unit,~Unit,~Q.plain_position_rest(),~Array<U32>,~View.FullCell,~Unit,~Q.plain_position_take,~Q.plain_position_put,~View.view,I.key(~S.Schema,~Array<U32>,S.identity("Position"))),world,handle,Some{incoming})
def plain_velocity_replace(world:W.World<S.Schema,S.plain_store(),Unit,Unit>,handle:W.Handle<S.Schema>,incoming:Array<U32>) -> C.Replacement<W.World<S.Schema,S.plain_store(),Unit,Unit>,Array<U32>>:
  C.replace(~S.Schema,~S.plain_store(),~Unit,~Unit,~Q.plain_velocity_rest(),~Array<U32>,~View.FullCell,~Unit,~Q.plain_velocity_take,~Q.plain_velocity_put,~View.view,C.define(~S.Schema,~S.plain_store(),~Unit,~Unit,~Q.plain_velocity_rest(),~Array<U32>,~View.FullCell,~Unit,~Q.plain_velocity_take,~Q.plain_velocity_put,~View.view,I.key(~S.Schema,~Array<U32>,S.identity("Velocity"))),world,handle,Some{incoming})
def plain_health_replace(world:W.World<S.Schema,S.plain_store(),Unit,Unit>,handle:W.Handle<S.Schema>,incoming:Array<U32>) -> C.Replacement<W.World<S.Schema,S.plain_store(),Unit,Unit>,Array<U32>>:
  C.replace(~S.Schema,~S.plain_store(),~Unit,~Unit,~Q.plain_health_rest(),~Array<U32>,~View.FullCell,~Unit,~Q.plain_health_take,~Q.plain_health_put,~View.view,C.define(~S.Schema,~S.plain_store(),~Unit,~Unit,~Q.plain_health_rest(),~Array<U32>,~View.FullCell,~Unit,~Q.plain_health_take,~Q.plain_health_put,~View.view,I.key(~S.Schema,~Array<U32>,S.identity("Health"))),world,handle,Some{incoming})
def plain_step_6(+h1:W.Handle<S.Schema>,+h2:W.Handle<S.Schema>,+h3:W.Handle<S.Schema>,factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>) -> Seed<S.plain_store()>:
  replaced(~S.plain_store(),finish(~S.plain_store()),factory,handles,previous,plain_health_replace(world,h3,payload(300,303)))
def plain_step_5(+h1:W.Handle<S.Schema>,+h2:W.Handle<S.Schema>,+h3:W.Handle<S.Schema>,factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>) -> Seed<S.plain_store()>:
  replaced(~S.plain_store(),(factory => world => handles => previous => plain_step_6(h1,h2,h3,factory,world,handles,previous)),factory,handles,previous,plain_position_replace(world,h3,payload(3,103)))
def plain_step_4(+h1:W.Handle<S.Schema>,+h2:W.Handle<S.Schema>,+h3:W.Handle<S.Schema>,factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>) -> Seed<S.plain_store()>:
  replaced(~S.plain_store(),(factory => world => handles => previous => plain_step_5(h1,h2,h3,factory,world,handles,previous)),factory,handles,previous,plain_velocity_replace(world,h2,payload(20,202)))
def plain_step_3(+h1:W.Handle<S.Schema>,+h2:W.Handle<S.Schema>,+h3:W.Handle<S.Schema>,factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>) -> Seed<S.plain_store()>:
  replaced(~S.plain_store(),(factory => world => handles => previous => plain_step_4(h1,h2,h3,factory,world,handles,previous)),factory,handles,previous,plain_position_replace(world,h2,payload(2,102)))
def plain_step_2(+h1:W.Handle<S.Schema>,+h2:W.Handle<S.Schema>,+h3:W.Handle<S.Schema>,factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>) -> Seed<S.plain_store()>:
  replaced(~S.plain_store(),(factory => world => handles => previous => plain_step_3(h1,h2,h3,factory,world,handles,previous)),factory,handles,previous,plain_health_replace(world,h1,payload(100,301)))
def plain_step_1(+h1:W.Handle<S.Schema>,+h2:W.Handle<S.Schema>,+h3:W.Handle<S.Schema>,factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>) -> Seed<S.plain_store()>:
  replaced(~S.plain_store(),(factory => world => handles => previous => plain_step_2(h1,h2,h3,factory,world,handles,previous)),factory,handles,previous,plain_velocity_replace(world,h1,payload(10,201)))
def plain_step_0(+h1:W.Handle<S.Schema>,+h2:W.Handle<S.Schema>,+h3:W.Handle<S.Schema>,factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>) -> Seed<S.plain_store()>:
  replaced(~S.plain_store(),(factory => world => handles => previous => plain_step_1(h1,h2,h3,factory,world,handles,previous)),factory,handles,previous,plain_position_replace(world,h1,payload(1,101)))
def plain_begin(factory:W.Factory,world:W.World<S.Schema,S.plain_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>) -> Seed<S.plain_store()>:
  match handles:
    case +h1 <> +h2 <> +h3 <> []:plain_step_0(h1,h2,h3,factory,world,[h1,h2,h3],[])
    case []:AllocationShapeRefused{factory,world,[]}
    case +h1 <> []:AllocationShapeRefused{factory,world,[h1]}
    case +h1 <> +h2 <> []:AllocationShapeRefused{factory,world,[h1,h2]}
    case +h1 <> +h2 <> +h3 <> +h4 <> +rest:AllocationShapeRefused{factory,world,h1 <> h2 <> h3 <> h4 <> rest}
def plain(factory:W.Factory) -> Seed<S.plain_store()>:
  created(~S.plain_store(),plain_begin,W.create(~S.Schema,~S.plain_store(),~Unit,~Unit,~plain_empty,factory,Unit{}))
def transient_empty(unit:Unit) -> S.transient_store():
  S.Store{Leaf.TransientComponent{Col.ensure(~S.Schema,~Array<U32>,Col.empty(~S.Schema,~Array<U32>),3),R.transient(~S.Schema,~Array<U32>,~S.identity("Position"))},Leaf.TransientComponent{Col.ensure(~S.Schema,~Array<U32>,Col.empty(~S.Schema,~Array<U32>),3),R.transient(~S.Schema,~Array<U32>,~S.identity("Velocity"))},Leaf.TransientComponent{Col.ensure(~S.Schema,~Array<U32>,Col.empty(~S.Schema,~Array<U32>),3),R.transient(~S.Schema,~Array<U32>,~S.identity("Health"))}}
def transient_position_replace(world:W.World<S.Schema,S.transient_store(),Unit,Unit>,handle:W.Handle<S.Schema>,incoming:Array<U32>) -> C.Replacement<W.World<S.Schema,S.transient_store(),Unit,Unit>,Array<U32>>:
  C.replace(~S.Schema,~S.transient_store(),~Unit,~Unit,~Q.transient_position_rest(),~Array<U32>,~View.FullCell,~Unit,~Q.transient_position_take,~Q.transient_position_put,~View.view,C.define(~S.Schema,~S.transient_store(),~Unit,~Unit,~Q.transient_position_rest(),~Array<U32>,~View.FullCell,~Unit,~Q.transient_position_take,~Q.transient_position_put,~View.view,I.key(~S.Schema,~Array<U32>,S.identity("Position"))),world,handle,Some{incoming})
def transient_velocity_replace(world:W.World<S.Schema,S.transient_store(),Unit,Unit>,handle:W.Handle<S.Schema>,incoming:Array<U32>) -> C.Replacement<W.World<S.Schema,S.transient_store(),Unit,Unit>,Array<U32>>:
  C.replace(~S.Schema,~S.transient_store(),~Unit,~Unit,~Q.transient_velocity_rest(),~Array<U32>,~View.FullCell,~Unit,~Q.transient_velocity_take,~Q.transient_velocity_put,~View.view,C.define(~S.Schema,~S.transient_store(),~Unit,~Unit,~Q.transient_velocity_rest(),~Array<U32>,~View.FullCell,~Unit,~Q.transient_velocity_take,~Q.transient_velocity_put,~View.view,I.key(~S.Schema,~Array<U32>,S.identity("Velocity"))),world,handle,Some{incoming})
def transient_health_replace(world:W.World<S.Schema,S.transient_store(),Unit,Unit>,handle:W.Handle<S.Schema>,incoming:Array<U32>) -> C.Replacement<W.World<S.Schema,S.transient_store(),Unit,Unit>,Array<U32>>:
  C.replace(~S.Schema,~S.transient_store(),~Unit,~Unit,~Q.transient_health_rest(),~Array<U32>,~View.FullCell,~Unit,~Q.transient_health_take,~Q.transient_health_put,~View.view,C.define(~S.Schema,~S.transient_store(),~Unit,~Unit,~Q.transient_health_rest(),~Array<U32>,~View.FullCell,~Unit,~Q.transient_health_take,~Q.transient_health_put,~View.view,I.key(~S.Schema,~Array<U32>,S.identity("Health"))),world,handle,Some{incoming})
def transient_step_6(+h1:W.Handle<S.Schema>,+h2:W.Handle<S.Schema>,+h3:W.Handle<S.Schema>,factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>) -> Seed<S.transient_store()>:
  replaced(~S.transient_store(),finish(~S.transient_store()),factory,handles,previous,transient_health_replace(world,h3,payload(300,303)))
def transient_step_5(+h1:W.Handle<S.Schema>,+h2:W.Handle<S.Schema>,+h3:W.Handle<S.Schema>,factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>) -> Seed<S.transient_store()>:
  replaced(~S.transient_store(),(factory => world => handles => previous => transient_step_6(h1,h2,h3,factory,world,handles,previous)),factory,handles,previous,transient_position_replace(world,h3,payload(3,103)))
def transient_step_4(+h1:W.Handle<S.Schema>,+h2:W.Handle<S.Schema>,+h3:W.Handle<S.Schema>,factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>) -> Seed<S.transient_store()>:
  replaced(~S.transient_store(),(factory => world => handles => previous => transient_step_5(h1,h2,h3,factory,world,handles,previous)),factory,handles,previous,transient_velocity_replace(world,h2,payload(20,202)))
def transient_step_3(+h1:W.Handle<S.Schema>,+h2:W.Handle<S.Schema>,+h3:W.Handle<S.Schema>,factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>) -> Seed<S.transient_store()>:
  replaced(~S.transient_store(),(factory => world => handles => previous => transient_step_4(h1,h2,h3,factory,world,handles,previous)),factory,handles,previous,transient_position_replace(world,h2,payload(2,102)))
def transient_step_2(+h1:W.Handle<S.Schema>,+h2:W.Handle<S.Schema>,+h3:W.Handle<S.Schema>,factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>) -> Seed<S.transient_store()>:
  replaced(~S.transient_store(),(factory => world => handles => previous => transient_step_3(h1,h2,h3,factory,world,handles,previous)),factory,handles,previous,transient_health_replace(world,h1,payload(100,301)))
def transient_step_1(+h1:W.Handle<S.Schema>,+h2:W.Handle<S.Schema>,+h3:W.Handle<S.Schema>,factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>) -> Seed<S.transient_store()>:
  replaced(~S.transient_store(),(factory => world => handles => previous => transient_step_2(h1,h2,h3,factory,world,handles,previous)),factory,handles,previous,transient_velocity_replace(world,h1,payload(10,201)))
def transient_step_0(+h1:W.Handle<S.Schema>,+h2:W.Handle<S.Schema>,+h3:W.Handle<S.Schema>,factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>) -> Seed<S.transient_store()>:
  replaced(~S.transient_store(),(factory => world => handles => previous => transient_step_1(h1,h2,h3,factory,world,handles,previous)),factory,handles,previous,transient_position_replace(world,h1,payload(1,101)))
def transient_begin(factory:W.Factory,world:W.World<S.Schema,S.transient_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>) -> Seed<S.transient_store()>:
  match handles:
    case +h1 <> +h2 <> +h3 <> []:transient_step_0(h1,h2,h3,factory,world,[h1,h2,h3],[])
    case []:AllocationShapeRefused{factory,world,[]}
    case +h1 <> []:AllocationShapeRefused{factory,world,[h1]}
    case +h1 <> +h2 <> []:AllocationShapeRefused{factory,world,[h1,h2]}
    case +h1 <> +h2 <> +h3 <> +h4 <> +rest:AllocationShapeRefused{factory,world,h1 <> h2 <> h3 <> h4 <> rest}
def transient(factory:W.Factory) -> Seed<S.transient_store()>:
  created(~S.transient_store(),transient_begin,W.create(~S.Schema,~S.transient_store(),~Unit,~Unit,~transient_empty,factory,Unit{}))
def constructed_empty(unit:Unit) -> S.constructed_store():
  S.Store{Leaf.Component{Col.ensure(~S.Schema,~Array<U32>,Col.empty(~S.Schema,~Array<U32>),3),R.constructed(~S.Schema,~Array<U32>,~S.identity("Position"),~S.save,D.ArrayValue{D.Integer{}})},Leaf.Component{Col.ensure(~S.Schema,~Array<U32>,Col.empty(~S.Schema,~Array<U32>),3),R.constructed(~S.Schema,~Array<U32>,~S.identity("Velocity"),~S.save,D.ArrayValue{D.Integer{}})},Leaf.Component{Col.ensure(~S.Schema,~Array<U32>,Col.empty(~S.Schema,~Array<U32>),3),R.constructed(~S.Schema,~Array<U32>,~S.identity("Health"),~S.save,D.ArrayValue{D.Integer{}})}}
def constructed_position_replace(world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,handle:W.Handle<S.Schema>,incoming:Array<U32>) -> C.Replacement<W.World<S.Schema,S.constructed_store(),Unit,Unit>,Array<U32>>:
  C.replace(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Q.constructed_position_rest(),~Array<U32>,~View.FullCell,~Unit,~Q.constructed_position_take,~Q.constructed_position_put,~View.view,C.define(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Q.constructed_position_rest(),~Array<U32>,~View.FullCell,~Unit,~Q.constructed_position_take,~Q.constructed_position_put,~View.view,I.key(~S.Schema,~Array<U32>,S.identity("Position"))),world,handle,Some{incoming})
def constructed_velocity_replace(world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,handle:W.Handle<S.Schema>,incoming:Array<U32>) -> C.Replacement<W.World<S.Schema,S.constructed_store(),Unit,Unit>,Array<U32>>:
  C.replace(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Q.constructed_velocity_rest(),~Array<U32>,~View.FullCell,~Unit,~Q.constructed_velocity_take,~Q.constructed_velocity_put,~View.view,C.define(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Q.constructed_velocity_rest(),~Array<U32>,~View.FullCell,~Unit,~Q.constructed_velocity_take,~Q.constructed_velocity_put,~View.view,I.key(~S.Schema,~Array<U32>,S.identity("Velocity"))),world,handle,Some{incoming})
def constructed_health_replace(world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,handle:W.Handle<S.Schema>,incoming:Array<U32>) -> C.Replacement<W.World<S.Schema,S.constructed_store(),Unit,Unit>,Array<U32>>:
  C.replace(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Q.constructed_health_rest(),~Array<U32>,~View.FullCell,~Unit,~Q.constructed_health_take,~Q.constructed_health_put,~View.view,C.define(~S.Schema,~S.constructed_store(),~Unit,~Unit,~Q.constructed_health_rest(),~Array<U32>,~View.FullCell,~Unit,~Q.constructed_health_take,~Q.constructed_health_put,~View.view,I.key(~S.Schema,~Array<U32>,S.identity("Health"))),world,handle,Some{incoming})
def constructed_step_6(+h1:W.Handle<S.Schema>,+h2:W.Handle<S.Schema>,+h3:W.Handle<S.Schema>,factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>) -> Seed<S.constructed_store()>:
  replaced(~S.constructed_store(),finish(~S.constructed_store()),factory,handles,previous,constructed_health_replace(world,h3,payload(300,303)))
def constructed_step_5(+h1:W.Handle<S.Schema>,+h2:W.Handle<S.Schema>,+h3:W.Handle<S.Schema>,factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>) -> Seed<S.constructed_store()>:
  replaced(~S.constructed_store(),(factory => world => handles => previous => constructed_step_6(h1,h2,h3,factory,world,handles,previous)),factory,handles,previous,constructed_position_replace(world,h3,payload(3,103)))
def constructed_step_4(+h1:W.Handle<S.Schema>,+h2:W.Handle<S.Schema>,+h3:W.Handle<S.Schema>,factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>) -> Seed<S.constructed_store()>:
  replaced(~S.constructed_store(),(factory => world => handles => previous => constructed_step_5(h1,h2,h3,factory,world,handles,previous)),factory,handles,previous,constructed_velocity_replace(world,h2,payload(20,202)))
def constructed_step_3(+h1:W.Handle<S.Schema>,+h2:W.Handle<S.Schema>,+h3:W.Handle<S.Schema>,factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>) -> Seed<S.constructed_store()>:
  replaced(~S.constructed_store(),(factory => world => handles => previous => constructed_step_4(h1,h2,h3,factory,world,handles,previous)),factory,handles,previous,constructed_position_replace(world,h2,payload(2,102)))
def constructed_step_2(+h1:W.Handle<S.Schema>,+h2:W.Handle<S.Schema>,+h3:W.Handle<S.Schema>,factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>) -> Seed<S.constructed_store()>:
  replaced(~S.constructed_store(),(factory => world => handles => previous => constructed_step_3(h1,h2,h3,factory,world,handles,previous)),factory,handles,previous,constructed_health_replace(world,h1,payload(100,301)))
def constructed_step_1(+h1:W.Handle<S.Schema>,+h2:W.Handle<S.Schema>,+h3:W.Handle<S.Schema>,factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>) -> Seed<S.constructed_store()>:
  replaced(~S.constructed_store(),(factory => world => handles => previous => constructed_step_2(h1,h2,h3,factory,world,handles,previous)),factory,handles,previous,constructed_velocity_replace(world,h1,payload(10,201)))
def constructed_step_0(+h1:W.Handle<S.Schema>,+h2:W.Handle<S.Schema>,+h3:W.Handle<S.Schema>,factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>,previous:List<Maybe<&1,Array<U32>>>) -> Seed<S.constructed_store()>:
  replaced(~S.constructed_store(),(factory => world => handles => previous => constructed_step_1(h1,h2,h3,factory,world,handles,previous)),factory,handles,previous,constructed_position_replace(world,h1,payload(1,101)))
def constructed_begin(factory:W.Factory,world:W.World<S.Schema,S.constructed_store(),Unit,Unit>,handles:List<&2,W.Handle<S.Schema>>) -> Seed<S.constructed_store()>:
  match handles:
    case +h1 <> +h2 <> +h3 <> []:constructed_step_0(h1,h2,h3,factory,world,[h1,h2,h3],[])
    case []:AllocationShapeRefused{factory,world,[]}
    case +h1 <> []:AllocationShapeRefused{factory,world,[h1]}
    case +h1 <> +h2 <> []:AllocationShapeRefused{factory,world,[h1,h2]}
    case +h1 <> +h2 <> +h3 <> +h4 <> +rest:AllocationShapeRefused{factory,world,h1 <> h2 <> h3 <> h4 <> rest}
def constructed(factory:W.Factory) -> Seed<S.constructed_store()>:
  created(~S.constructed_store(),constructed_begin,W.create(~S.Schema,~S.constructed_store(),~Unit,~Unit,~constructed_empty,factory,Unit{}))

import Base
import events.bend as E
import ../../private/src/ecs/commands.bend as Cmd
import types.bend as T
import payload.bend as P
import ../../private/src/ecs/column.bend as Col
import ../../private/src/ecs/component.bend as Cmp
import ../../private/src/ecs/compose.bend as Q
import ../../private/src/ecs/transaction.bend as Tx
import ../../private/src/ecs/ordinary-query-declaration.bend as Decl
import ../../private/src/ecs/ordinary-declaration.bend as Identity
import ../../private/src/ecs/ordinary-owned-event-family-resource.bend as Resource
import ../../private/src/ecs/ordinary-schema.bend as Schema
import ../../private/src/ecs/ordinary-system.bend as Ordinary
import ../../private/src/ecs/capabilities.bend as Cap
import ../../private/src/ecs/world.bend as W
import ../../private/src/ecs/owner-product.bend as Product
import ../../private/src/ecs/system.bend as Sys

def Store() -> Type:Product.Owner<Col.Column<T.MotionSchema,T.Position>,Product.Owner<Col.Column<T.MotionSchema,T.Velocity>,Col.Column<T.MotionSchema,T.Selected>>>
def Resources() -> Type:Product.Owner<T.MotionLedger,Unit>
def World() -> Type:W.World<T.MotionSchema,Store(),Resources(),E.event_type()>
def Rest() -> Type:Product.Owner<Col.Column<T.MotionSchema,T.Velocity>,Col.Column<T.MotionSchema,T.Selected>>
def empty(_:Unit) -> Store():Product.Owner{Col.empty_indexed(~T.MotionSchema,~T.Position),Product.Owner{Col.empty_indexed(~T.MotionSchema,~T.Velocity),Col.empty_indexed(~T.MotionSchema,~T.Selected)}}
def take_main(value:Store()) -> Rest() & Col.Column<T.MotionSchema,T.Position>:
  match value:
    case Product.Owner{main,rest}:(rest,main)
def put_main(rest:Rest(),main:Col.Column<T.MotionSchema,T.Position>) -> Store():Product.Owner{main,rest}
def main_identity() -> Identity.Declaration<T.MotionSchema,T.Position>:Identity.component(~T.MotionSchema,~T.Position,"Position")
def ledger_identity() -> Schema.Resource<T.MotionSchema,T.MotionLedger>:Schema.resource(~T.MotionSchema,~T.MotionLedger,"MotionLedger")
def quad(a:U32,b:U32,c:U32,d:U32) -> Array<U32>:ANode{ANode{ALeaf{a},ALeaf{b}},ANode{ALeaf{c},ALeaf{d}}}
def first(value:T.Four) -> U32:
  match value:
    case T.Four{a,_,_,_}:a
def sum(value:T.Four) -> U32:
  match value:
    case T.Four{a,b,c,d}:U32.add(U32.add(a,b),U32.add(c,d))
def AuxRest() -> Type:Product.Owner<Col.Column<T.MotionSchema,T.Position>,Col.Column<T.MotionSchema,T.Selected>>
def FlagRest() -> Type:Product.Owner<Col.Column<T.MotionSchema,T.Position>,Col.Column<T.MotionSchema,T.Velocity>>
def take_aux(value:Store()) -> AuxRest() & Col.Column<T.MotionSchema,T.Velocity>:
  match value:
    case Product.Owner{main,Product.Owner{aux,flag}}:(Product.Owner{main,flag},aux)
def put_aux(rest:AuxRest(),aux:Col.Column<T.MotionSchema,T.Velocity>) -> Store():
  match rest:
    case Product.Owner{main,flag}:Product.Owner{main,Product.Owner{aux,flag}}
def take_flag(value:Store()) -> FlagRest() & Col.Column<T.MotionSchema,T.Selected>:
  match value:
    case Product.Owner{main,Product.Owner{aux,flag}}:(Product.Owner{main,aux},flag)
def put_flag(rest:FlagRest(),flag:Col.Column<T.MotionSchema,T.Selected>) -> Store():
  match rest:
    case Product.Owner{main,aux}:Product.Owner{main,Product.Owner{aux,flag}}
def flag_copy(+value:T.Selected) -> T.Selected & T.Selected:(value,value)
def flag_view(value:T.Selected) -> T.Selected & T.Selected:flag_copy(value)
def main_family() -> Cmp.Family<T.MotionSchema,Store(),Rest(),T.Position,T.PositionView,T.PositionToken,take_main,put_main,P.position_get>:Cmp.Family{Identity.key(~T.MotionSchema,~T.Position,main_identity())}
def aux_identity() -> Identity.Declaration<T.MotionSchema,T.Velocity>:Identity.component(~T.MotionSchema,~T.Velocity,"Velocity")
def flag_identity() -> Identity.Declaration<T.MotionSchema,T.Selected>:Identity.component(~T.MotionSchema,~T.Selected,"Selected")
def aux_family() -> Cmp.Family<T.MotionSchema,Store(),AuxRest(),T.Velocity,T.VelocityView,T.VelocityToken,take_aux,put_aux,P.velocity_get>:Cmp.Family{Identity.key(~T.MotionSchema,~T.Velocity,aux_identity())}
def flag_family() -> Cmp.Family<T.MotionSchema,Store(),FlagRest(),T.Selected,T.Selected,T.Selected,take_flag,put_flag,flag_view>:Cmp.Family{Identity.key(~T.MotionSchema,~T.Selected,flag_identity())}
type Payload is Type:
  Payload{main:T.Position,aux:Maybe<&1,T.Velocity>,flag:Maybe<&1,T.Selected>}
def flag_installed(world:World(),handle:W.Handle<T.MotionSchema>,incoming:Maybe<&1,T.Selected>) -> World():
  match incoming:
    case None{}:world
    case Some{value}:Cmp.restore_done(~T.MotionSchema,~Store(),~Resources(),~E.event_type(),~FlagRest(),~T.Selected,~T.Selected,~T.Selected,~take_flag,~put_flag,~flag_view,Cmp.replace(~T.MotionSchema,~Store(),~Resources(),~E.event_type(),~FlagRest(),~T.Selected,~T.Selected,~T.Selected,~take_flag,~put_flag,~flag_view,flag_family(),world,handle,Some{value}))
def aux_installed(world:World(),+handle:W.Handle<T.MotionSchema>,incoming:Maybe<&1,T.Velocity>,flag:Maybe<&1,T.Selected>) -> World():
  match incoming:
    case None{}:flag_installed(world,handle,flag)
    case Some{value}:flag_installed(Cmp.restore_done(~T.MotionSchema,~Store(),~Resources(),~E.event_type(),~AuxRest(),~T.Velocity,~T.VelocityView,~T.VelocityToken,~take_aux,~put_aux,~P.velocity_get,Cmp.replace(~T.MotionSchema,~Store(),~Resources(),~E.event_type(),~AuxRest(),~T.Velocity,~T.VelocityView,~T.VelocityToken,~take_aux,~put_aux,~P.velocity_get,aux_family(),world,handle,Some{value})),handle,flag)
def populate_copy(world:World(),+handle:W.Handle<T.MotionSchema>,payload:Payload) -> World():
  match payload:
    case Payload{main,aux,flag}:aux_installed(Cmp.restore_done(~T.MotionSchema,~Store(),~Resources(),~E.event_type(),~Rest(),~T.Position,~T.PositionView,~T.PositionToken,~take_main,~put_main,~P.position_get,Cmp.replace(~T.MotionSchema,~Store(),~Resources(),~E.event_type(),~Rest(),~T.Position,~T.PositionView,~T.PositionToken,~take_main,~put_main,~P.position_get,main_family(),world,handle,Some{main})),handle,aux,flag)
def populate(world:World(),handle:W.Handle<T.MotionSchema>,payload:Payload) -> World():populate_copy(world,handle,payload)
def initial_resources() -> Resources():Product.Owner{T.MotionLedger{quad(0,101,102,103),4},Unit{}}
def payload_aux(present:Bool) -> Maybe<&1,T.Velocity>:
  match present:
    case False{}:None{}
    case True{}:Some{T.Velocity{quad(1,2,3,4),True{}}}
def payload_flag(present:Bool) -> Maybe<&1,T.Selected>:
  match present:
    case False{}:None{}
    case True{}:Some{T.Selected{8}}
def payload(+index:U32) -> Payload:Payload{T.Position{quad(index,U32.add(index,1),U32.add(index,2),U32.add(index,3)),7},payload_aux(U32.is_eq(U32.mod(index,3),0)),payload_flag(U32.is_eq(U32.mod(index,3),1))}
type Reserved is Type:
  Reserved{tx:Tx.Tx<World(),E.event_type()>,reservations:List<&2,W.Reservation<T.MotionSchema>>}
def seed_next(next:Reserved -> Reserved,reservations:List<&2,W.Reservation<T.MotionSchema>>,result:Tx.Tx<World(),E.event_type()> & W.Reservation<T.MotionSchema>) -> Reserved:
  match result:
    case (tx,reservation):next(Reserved{tx,List.append(&2,W.Reservation<T.MotionSchema>,reservations,[reservation])})
def seed_rows(fuel:Nat,+index:U32,state:Reserved) -> Reserved:
  match fuel state:
    case 0n state:state
    case 1n+rest Reserved{tx,reservations}:seed_next(state => seed_rows(rest,U32.add(index,1),state),reservations,Cmd.tx_spawn(~T.MotionSchema,~Store(),~Resources(),~E.event_type(),~Payload,~populate,tx,payload(index)))
type Seeded is Type:
  Seeded{world:World(),reservations:List<&2,W.Reservation<T.MotionSchema>>,outcome:Tx.Outcome<Unit>}
def seeded(reservations:List<&2,W.Reservation<T.MotionSchema>>,result:Tx.Returned<World(),Unit>) -> Seeded:
  match result:
    case Tx.Returned{world,outcome}:Seeded{world,reservations,outcome}
def seed_reserved(result:Reserved) -> Seeded:
  match result:
    case Reserved{tx,reservations}:seeded(reservations,Cmd.tx_finish(~T.MotionSchema,~Store(),~Resources(),~E.event_type(),~Unit,tx,Tx.Success{}))
def seed(count:U32,world:World()) -> Seeded:seed_reserved(seed_rows(U32.to_nat(count),0,Reserved{Tx.begin(~World(),~E.event_type(),world),[]}))

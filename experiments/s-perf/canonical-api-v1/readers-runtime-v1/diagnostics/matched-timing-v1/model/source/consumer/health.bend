import Base
import health-events.bend as E
import ../../../../src/ecs/commands.bend as Cmd
import types.bend as T
import payload.bend as P
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/component.bend as Cmp
import ../../../../src/ecs/compose.bend as Q
import ../../../../src/ecs/transaction.bend as Tx
import ../../../../src/ecs/ordinary-query-declaration.bend as Decl
import ../../../../src/ecs/ordinary-declaration.bend as Identity
import ../../../../src/ecs/ordinary-owned-event-family-resource.bend as Resource
import ../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../src/ecs/ordinary-system.bend as Ordinary
import ../../../../src/ecs/capabilities.bend as Cap
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/owner-product.bend as Product
import ../../../../src/ecs/system.bend as Sys

def Store() -> Type:Product.Owner<Col.Column<T.HealthSchema,T.Vitals>,Product.Owner<Col.Column<T.HealthSchema,T.Armor>,Col.Column<T.HealthSchema,T.Tracked>>>
def Resources() -> Type:Product.Owner<T.HealthLedger,Unit>
def World() -> Type:W.World<T.HealthSchema,Store(),Resources(),E.event_type()>
def Rest() -> Type:Product.Owner<Col.Column<T.HealthSchema,T.Armor>,Col.Column<T.HealthSchema,T.Tracked>>
def empty(_:Unit) -> Store():Product.Owner{Col.empty(~T.HealthSchema,~T.Vitals),Product.Owner{Col.empty(~T.HealthSchema,~T.Armor),Col.empty(~T.HealthSchema,~T.Tracked)}}
def take_main(value:Store()) -> Rest() & Col.Column<T.HealthSchema,T.Vitals>:
  match value:
    case Product.Owner{main,rest}:(rest,main)
def put_main(rest:Rest(),main:Col.Column<T.HealthSchema,T.Vitals>) -> Store():Product.Owner{main,rest}
def main_identity() -> Identity.Declaration<T.HealthSchema,T.Vitals>:Identity.component(~T.HealthSchema,~T.Vitals,"Vitals")
def ledger_identity() -> Schema.Resource<T.HealthSchema,T.HealthLedger>:Schema.resource(~T.HealthSchema,~T.HealthLedger,"HealthLedger")
def quad(a:U32,b:U32,c:U32,d:U32) -> Array<U32>:ANode{ANode{ALeaf{a},ALeaf{b}},ANode{ALeaf{c},ALeaf{d}}}
def first(value:T.Four) -> U32:
  match value:
    case T.Four{a,_,_,_}:a
def sum(value:T.Four) -> U32:
  match value:
    case T.Four{a,b,c,d}:U32.add(U32.add(a,b),U32.add(c,d))
def AuxRest() -> Type:Product.Owner<Col.Column<T.HealthSchema,T.Vitals>,Col.Column<T.HealthSchema,T.Tracked>>
def FlagRest() -> Type:Product.Owner<Col.Column<T.HealthSchema,T.Vitals>,Col.Column<T.HealthSchema,T.Armor>>
def take_aux(value:Store()) -> AuxRest() & Col.Column<T.HealthSchema,T.Armor>:
  match value:
    case Product.Owner{main,Product.Owner{aux,flag}}:(Product.Owner{main,flag},aux)
def put_aux(rest:AuxRest(),aux:Col.Column<T.HealthSchema,T.Armor>) -> Store():
  match rest:
    case Product.Owner{main,flag}:Product.Owner{main,Product.Owner{aux,flag}}
def take_flag(value:Store()) -> FlagRest() & Col.Column<T.HealthSchema,T.Tracked>:
  match value:
    case Product.Owner{main,Product.Owner{aux,flag}}:(Product.Owner{main,aux},flag)
def put_flag(rest:FlagRest(),flag:Col.Column<T.HealthSchema,T.Tracked>) -> Store():
  match rest:
    case Product.Owner{main,aux}:Product.Owner{main,Product.Owner{aux,flag}}
def flag_copy(+value:T.Tracked) -> T.Tracked & T.Tracked:(value,value)
def flag_view(value:T.Tracked) -> T.Tracked & T.Tracked:flag_copy(value)
def main_family() -> Cmp.Family<T.HealthSchema,Store(),Rest(),T.Vitals,T.VitalsView,T.VitalsToken,take_main,put_main,P.vitals_get>:Cmp.Family{Identity.key(~T.HealthSchema,~T.Vitals,main_identity())}
def aux_identity() -> Identity.Declaration<T.HealthSchema,T.Armor>:Identity.component(~T.HealthSchema,~T.Armor,"Armor")
def flag_identity() -> Identity.Declaration<T.HealthSchema,T.Tracked>:Identity.component(~T.HealthSchema,~T.Tracked,"Tracked")
def aux_family() -> Cmp.Family<T.HealthSchema,Store(),AuxRest(),T.Armor,T.ArmorView,T.ArmorToken,take_aux,put_aux,P.armor_get>:Cmp.Family{Identity.key(~T.HealthSchema,~T.Armor,aux_identity())}
def flag_family() -> Cmp.Family<T.HealthSchema,Store(),FlagRest(),T.Tracked,T.Tracked,T.Tracked,take_flag,put_flag,flag_view>:Cmp.Family{Identity.key(~T.HealthSchema,~T.Tracked,flag_identity())}
type Payload is Type:
  Payload{main:T.Vitals,aux:Maybe<&1,T.Armor>,flag:Maybe<&1,T.Tracked>}
def flag_installed(world:World(),handle:W.Handle<T.HealthSchema>,incoming:Maybe<&1,T.Tracked>) -> World():
  match incoming:
    case None{}:world
    case Some{value}:Cmp.restore_done(~T.HealthSchema,~Store(),~Resources(),~E.event_type(),~FlagRest(),~T.Tracked,~T.Tracked,~T.Tracked,~take_flag,~put_flag,~flag_view,Cmp.replace(~T.HealthSchema,~Store(),~Resources(),~E.event_type(),~FlagRest(),~T.Tracked,~T.Tracked,~T.Tracked,~take_flag,~put_flag,~flag_view,flag_family(),world,handle,Some{value}))
def aux_installed(world:World(),+handle:W.Handle<T.HealthSchema>,incoming:Maybe<&1,T.Armor>,flag:Maybe<&1,T.Tracked>) -> World():
  match incoming:
    case None{}:flag_installed(world,handle,flag)
    case Some{value}:flag_installed(Cmp.restore_done(~T.HealthSchema,~Store(),~Resources(),~E.event_type(),~AuxRest(),~T.Armor,~T.ArmorView,~T.ArmorToken,~take_aux,~put_aux,~P.armor_get,Cmp.replace(~T.HealthSchema,~Store(),~Resources(),~E.event_type(),~AuxRest(),~T.Armor,~T.ArmorView,~T.ArmorToken,~take_aux,~put_aux,~P.armor_get,aux_family(),world,handle,Some{value})),handle,flag)
def populate_copy(world:World(),+handle:W.Handle<T.HealthSchema>,payload:Payload) -> World():
  match payload:
    case Payload{main,aux,flag}:aux_installed(Cmp.restore_done(~T.HealthSchema,~Store(),~Resources(),~E.event_type(),~Rest(),~T.Vitals,~T.VitalsView,~T.VitalsToken,~take_main,~put_main,~P.vitals_get,Cmp.replace(~T.HealthSchema,~Store(),~Resources(),~E.event_type(),~Rest(),~T.Vitals,~T.VitalsView,~T.VitalsToken,~take_main,~put_main,~P.vitals_get,main_family(),world,handle,Some{main})),handle,aux,flag)
def populate(world:World(),handle:W.Handle<T.HealthSchema>,payload:Payload) -> World():populate_copy(world,handle,payload)
def initial_resources() -> Resources():Product.Owner{T.HealthLedger{quad(0,101,102,103),4},Unit{}}
def payload_aux(present:Bool) -> Maybe<&1,T.Armor>:
  match present:
    case False{}:None{}
    case True{}:Some{T.Armor{quad(1,2,3,4),3}}
def payload_flag(present:Bool) -> Maybe<&1,T.Tracked>:
  match present:
    case False{}:None{}
    case True{}:Some{T.Tracked{8}}
def payload(+index:U32) -> Payload:Payload{T.Vitals{quad(index,U32.add(index,1),U32.add(index,2),U32.add(index,3)),9,2},payload_aux(U32.is_eq(U32.mod(index,3),0)),payload_flag(U32.is_eq(U32.mod(index,3),1))}
type Reserved is Type:
  Reserved{tx:Tx.Tx<World(),E.event_type()>,reservations:List<&2,W.Reservation<T.HealthSchema>>}
def seed_next(next:Reserved -> Reserved,reservations:List<&2,W.Reservation<T.HealthSchema>>,result:Tx.Tx<World(),E.event_type()> & W.Reservation<T.HealthSchema>) -> Reserved:
  match result:
    case (tx,reservation):next(Reserved{tx,List.append(&2,W.Reservation<T.HealthSchema>,reservations,[reservation])})
def seed_rows(fuel:Nat,+index:U32,state:Reserved) -> Reserved:
  match fuel state:
    case 0n state:state
    case 1n+rest Reserved{tx,reservations}:seed_next(state => seed_rows(rest,U32.add(index,1),state),reservations,Cmd.tx_spawn(~T.HealthSchema,~Store(),~Resources(),~E.event_type(),~Payload,~populate,tx,payload(index)))
type Seeded is Type:
  Seeded{world:World(),reservations:List<&2,W.Reservation<T.HealthSchema>>,outcome:Tx.Outcome<Unit>}
def seeded(reservations:List<&2,W.Reservation<T.HealthSchema>>,result:Tx.Returned<World(),Unit>) -> Seeded:
  match result:
    case Tx.Returned{world,outcome}:Seeded{world,reservations,outcome}
def seed_reserved(result:Reserved) -> Seeded:
  match result:
    case Reserved{tx,reservations}:seeded(reservations,Cmd.tx_finish(~T.HealthSchema,~Store(),~Resources(),~E.event_type(),~Unit,tx,Tx.Success{}))
def seed(count:U32,world:World()) -> Seeded:seed_reserved(seed_rows(U32.to_nat(count),0,Reserved{Tx.begin(~World(),~E.event_type(),world),[]}))

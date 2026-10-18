import Base
import tx-metrics.bend as Metrics
import ../../../../../../../src/ecs/commands.bend as Cmd
import types.bend as T
import payload.bend as P
import ../../../../../../../src/ecs/column.bend as Col
import ../../../../../../../src/ecs/component.bend as Cmp
import ../../../../../../../src/ecs/compose.bend as Q
import ../../../../../../../src/ecs/transaction.bend as Tx
import ../../../../../../../src/ecs/ordinary-query-declaration.bend as Decl
import ../../../../../../../src/ecs/ordinary-declaration.bend as Identity
import ../../../../../../../src/ecs/ordinary-owned-event-family-resource.bend as Resource
import ../../../../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../../../../src/ecs/ordinary-system.bend as Ordinary
import ../../../../../../../src/ecs/capabilities.bend as Cap
import ../../../../../../../src/ecs/world.bend as W
import ../../../../../../../src/ecs/owner-product.bend as Product
import ../../../../../../../src/ecs/system.bend as Sys

def Store() -> Type:Product.Owner<Col.Column<T.HealthSchema,T.Vitals>,Product.Owner<Col.Column<T.HealthSchema,T.Armor>,Col.Column<T.HealthSchema,T.Tracked>>>
def Resources() -> Type:Product.Owner<T.HealthLedger,Unit>
def World() -> Type:W.World<T.HealthSchema,Store(),Resources(),Nat>
def Rest() -> Type:Product.Owner<Col.Column<T.HealthSchema,T.Armor>,Col.Column<T.HealthSchema,T.Tracked>>
def empty(_:Unit) -> Store():Product.Owner{Col.empty(~T.HealthSchema,~T.Vitals),Product.Owner{Col.empty(~T.HealthSchema,~T.Armor),Col.empty(~T.HealthSchema,~T.Tracked)}}
def take_main(value:Store()) -> Rest() & Col.Column<T.HealthSchema,T.Vitals>:
  match value:
    case Product.Owner{main,rest}:(rest,main)
def put_main(rest:Rest(),main:Col.Column<T.HealthSchema,T.Vitals>) -> Store():Product.Owner{main,rest}
def main_identity() -> Identity.Declaration<T.HealthSchema,T.Vitals>:Identity.component(~T.HealthSchema,~T.Vitals,"Vitals")
def ledger_identity() -> Schema.Resource<T.HealthSchema,T.HealthLedger>:Schema.resource(~T.HealthSchema,~T.HealthLedger,"HealthLedger")
def Ops(H:Type) -> Type:Cap.Write<H,T.Vitals,T.VitalsView> & Cap.ValueWrite<H,T.HealthLedger,T.LedgerView>
def main_cap(~H:Type,caps:Ops(H)) -> Cap.Write<H,T.Vitals,T.VitalsView>:
  match caps:
    case (main,_):main
def ledger_cap(~H:Type,caps:Ops(H)) -> Cap.ValueWrite<H,T.HealthLedger,T.LedgerView>:
  match caps:
    case (_,ledger):ledger
def declaration() -> Decl.Declaration<T.HealthSchema,Q.Frame<T.HealthSchema,Store(),Resources(),Nat>,Ops(Q.Frame<T.HealthSchema,Store(),Resources(),Nat>)>:
  Decl.pair(~T.HealthSchema,~Q.Frame<T.HealthSchema,Store(),Resources(),Nat>,~Cap.Write<Q.Frame<T.HealthSchema,Store(),Resources(),Nat>,T.Vitals,T.VitalsView>,~Cap.ValueWrite<Q.Frame<T.HealthSchema,Store(),Resources(),Nat>,T.HealthLedger,T.LedgerView>,~Decl.write(~T.HealthSchema,~T.Vitals,~Store(),~Resources(),~Nat,~Rest(),~T.VitalsView,~T.VitalsToken,~main_identity(),~P.vitals_get,~take_main,~put_main),~Resource.write(~T.HealthSchema,~Store(),~T.HealthLedger,~Unit,~Nat,~T.LedgerView,~ledger_identity(),~P.health_ledger_get))
def quad(a:U32,b:U32,c:U32,d:U32) -> Array<U32>:ANode{ANode{ALeaf{a},ALeaf{b}},ANode{ALeaf{c},ALeaf{d}}}
def first(value:T.Four) -> U32:
  match value:
    case T.Four{a,_,_,_}:a
def sum(value:T.Four) -> U32:
  match value:
    case T.Four{a,b,c,d}:U32.add(U32.add(a,b),U32.add(c,d))
def increment_main(value:T.VitalsView) -> T.Vitals:
  match value:
    case T.VitalsView{T.Four{a,b,c,d},reserve,class}:T.Vitals{quad(U32.add(a,1),b,c,d),reserve,class}
def increment_ledger(value:T.LedgerView) -> T.HealthLedger:
  match value:
    case T.LedgerView{T.Four{a,b,c,d},epoch}:T.HealthLedger{quad(U32.add(a,1),b,c,d),epoch}
def ledger_written(~H:Type,~caps:Ops(H),readsum:U32,observed:H & T.LedgerView) -> H & (Tx.Outcome<Unit> & U32):
  match observed:
    case (owner,view):(Cap.value_set(~H,~T.HealthLedger,~T.LedgerView,~ledger_cap(~H,caps),owner,increment_ledger(view)),(Tx.Success{},readsum))
def sum_view(value:T.VitalsView) -> U32:
  match value:
    case T.VitalsView{values,_,_}:sum(values)
def main_read(~H:Type,~caps:Ops(H),observed:H & Cmp.Access<T.VitalsView>) -> H & (Tx.Outcome<Unit> & U32):
  match observed:
    case (owner,Cmp.Found{+view}):ledger_written(~H,~caps,sum_view(view),Cap.value_get(~H,~T.HealthLedger,~T.LedgerView,~ledger_cap(~H,caps),Cap.set(~H,~T.Vitals,~T.VitalsView,~main_cap(~H,caps),owner,increment_main(view))))
    case (owner,_):(owner,(Tx.Failure{Unit{}},0))
def body(~H:Type,~caps:Ops(H),_:Unit,owner:H) -> H & (Tx.Outcome<Unit> & U32):main_read(~H,~caps,Cap.get(~H,~T.Vitals,~T.VitalsView,~main_cap(~H,caps),owner))
type ProfileOutput is Data:
  ProfileOutput{values:List<&2,U32>,sample:Metrics.Sample}
type ProfileFailure is Data:
  ProfileFailure{error:Q.Error<Unit>,sample:Metrics.Sample}
def profile_finished(sample:Metrics.Sample,result:Q.Executed<World(),Q.Error<Unit>,U32>) -> Sys.Outcome<World(),ProfileFailure,ProfileOutput>:
  match result:
    case Q.Executed{world,Tx.Success{},values}:Sys.Succeeded{world,ProfileOutput{values,sample}}
    case Q.Executed{world,Tx.Failure{error},_}:Sys.Failed{world,ProfileFailure{error,sample}}
def profile_observed(result:Tx.Tx<World(),Nat> & Metrics.Sample,outcome:Tx.Outcome<Q.Error<Unit>>,values:List<&2,U32>) -> Sys.Outcome<World(),ProfileFailure,ProfileOutput>:
  match result:
    case (tx,sample):profile_finished(sample,Q.finished(~T.HealthSchema,~Store(),~Resources(),~Nat,~Unit,~U32,(tx,(outcome,values))))
def profile_raw(result:Tx.Tx<World(),Nat> & (Tx.Outcome<Q.Error<Unit>> & List<&2,U32>)) -> Sys.Outcome<World(),ProfileFailure,ProfileOutput>:
  match result:
    case (tx,(outcome,values)):profile_observed(Metrics.observe(~World(),~Nat,"query-loop",tx),outcome,values)
def profile_handles(args:Unit,cursor:U32,observed:World() & List<&2,W.Handle<T.HealthSchema>>) -> Sys.Outcome<World(),ProfileFailure,ProfileOutput>:
  match observed:
    case (world,handles):profile_raw(Q.run_handles(~T.HealthSchema,~Store(),~Resources(),~Nat,~Ops,~Unit,~Unit,~U32,~Ordinary.plan(~T.HealthSchema,~Store(),~Resources(),~Nat,~Ops,~Unit,~Unit,~U32,~declaration(),~body),~body,handles,args,cursor,Tx.begin(~World(),~Nat,world)))
def profile_runner(world:World(),args:Unit & U32) -> Sys.Outcome<World(),ProfileFailure,ProfileOutput>:
  match args:
    case (args,cursor):profile_handles(args,cursor,W.handles(~T.HealthSchema,~Store(),~Resources(),~Nat,world))
def Registry() -> Type:Sys.Registry<T.HealthSchema,Store(),Resources(),Nat,Unit & U32,ProfileFailure,ProfileOutput,profile_runner>
def Owner() -> Type:Ordinary.Owner<T.HealthSchema,Registry()>
def profile_registered(result:Sys.RegistrationResult<T.HealthSchema,Store(),Resources(),Nat,Unit & U32,ProfileFailure,ProfileOutput,profile_runner>) -> Ordinary.Defined<T.HealthSchema,World(),Registry()>:
  match result:
    case Sys.RegistrationFailed{world}:Ordinary.Rejected{world}
    case Sys.Registered{world,registry}:Ordinary.Defined{world,Ordinary.Owner{registry,"dense64",Decl.clauses(~T.HealthSchema,~Q.Frame<T.HealthSchema,Store(),Resources(),Nat>,~Ops(Q.Frame<T.HealthSchema,Store(),Resources(),Nat>),declaration())}}
def define(world:World()) -> Ordinary.Defined<T.HealthSchema,World(),Registry()>:
  profile_registered(Sys.register(~T.HealthSchema,~Store(),~Resources(),~Nat,~(Unit & U32),~ProfileFailure,~ProfileOutput,~profile_runner,world,"BenchUpdate",Ordinary.access(~T.HealthSchema,Decl.clauses(~T.HealthSchema,~Q.Frame<T.HealthSchema,Store(),Resources(),Nat>,~Ops(Q.Frame<T.HealthSchema,Store(),Resources(),Nat>),declaration()))))
def profile_run_cursor(slot:String,clauses:List<&2,Decl.Clause<T.HealthSchema>>,world:World(),args:Unit,observed:Registry() & U32) -> Sys.RunResult<T.HealthSchema,Store(),Resources(),Nat,Unit & U32,ProfileFailure,ProfileOutput,profile_runner> & (String & List<&2,Decl.Clause<T.HealthSchema>>):
  match observed:
    case (registry,cursor):(Sys.run_tracked(~T.HealthSchema,~Store(),~Resources(),~Nat,~(Unit & U32),~ProfileFailure,~ProfileOutput,~profile_runner,registry,world,(args,cursor)),(slot,clauses))
def profile_run(owner:Owner(),world:World(),args:Unit) -> Sys.RunResult<T.HealthSchema,Store(),Resources(),Nat,Unit & U32,ProfileFailure,ProfileOutput,profile_runner> & (String & List<&2,Decl.Clause<T.HealthSchema>>):
  match owner:
    case Ordinary.Owner{registry,slot,clauses}:profile_run_cursor(slot,clauses,world,args,Sys.cursor(~T.HealthSchema,~Store(),~Resources(),~Nat,~(Unit & U32),~ProfileFailure,~ProfileOutput,~profile_runner,registry))

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
  Payload{main:Maybe<&1,T.Vitals>,aux:Maybe<&1,T.Armor>,flag:Maybe<&1,T.Tracked>}
def flag_installed(world:World(),handle:W.Handle<T.HealthSchema>,incoming:Maybe<&1,T.Tracked>) -> World():
  match incoming:
    case None{}:world
    case Some{value}:Cmp.restore_done(~T.HealthSchema,~Store(),~Resources(),~Nat,~FlagRest(),~T.Tracked,~T.Tracked,~T.Tracked,~take_flag,~put_flag,~flag_view,Cmp.replace(~T.HealthSchema,~Store(),~Resources(),~Nat,~FlagRest(),~T.Tracked,~T.Tracked,~T.Tracked,~take_flag,~put_flag,~flag_view,flag_family(),world,handle,Some{value}))
def aux_installed(world:World(),+handle:W.Handle<T.HealthSchema>,incoming:Maybe<&1,T.Armor>,flag:Maybe<&1,T.Tracked>) -> World():
  match incoming:
    case None{}:flag_installed(world,handle,flag)
    case Some{value}:flag_installed(Cmp.restore_done(~T.HealthSchema,~Store(),~Resources(),~Nat,~AuxRest(),~T.Armor,~T.ArmorView,~T.ArmorToken,~take_aux,~put_aux,~P.armor_get,Cmp.replace(~T.HealthSchema,~Store(),~Resources(),~Nat,~AuxRest(),~T.Armor,~T.ArmorView,~T.ArmorToken,~take_aux,~put_aux,~P.armor_get,aux_family(),world,handle,Some{value})),handle,flag)
def populate_main(world:World(),+handle:W.Handle<T.HealthSchema>,aux:Maybe<&1,T.Armor>,flag:Maybe<&1,T.Tracked>,main:Maybe<&1,T.Vitals>) -> World():
  match main:
    case None{}:aux_installed(world,handle,aux,flag)
    case Some{main}:aux_installed(Cmp.restore_done(~T.HealthSchema,~Store(),~Resources(),~Nat,~Rest(),~T.Vitals,~T.VitalsView,~T.VitalsToken,~take_main,~put_main,~P.vitals_get,Cmp.replace(~T.HealthSchema,~Store(),~Resources(),~Nat,~Rest(),~T.Vitals,~T.VitalsView,~T.VitalsToken,~take_main,~put_main,~P.vitals_get,main_family(),world,handle,Some{main})),handle,aux,flag)
def populate_copy(world:World(),+handle:W.Handle<T.HealthSchema>,payload:Payload) -> World():
  match payload:
    case Payload{main,aux,flag}:populate_main(world,handle,aux,flag,main)
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
def payload_main(present:Bool,+index:U32) -> Maybe<&1,T.Vitals>:
  match present:
    case False{}:None{}
    case True{}:Some{T.Vitals{quad(index,U32.add(index,1),U32.add(index,2),U32.add(index,3)),9,2}}
def payload(+index:U32) -> Payload:Payload{payload_main(U32.is_eq(U32.mod(index,8),0),index),payload_aux(U32.is_eq(U32.mod(index,3),0)),payload_flag(U32.is_eq(U32.mod(index,3),1))}
type Reserved is Type:
  Reserved{tx:Tx.Tx<World(),Nat>,reservations:List<&2,W.Reservation<T.HealthSchema>>}
def seed_next(next:Reserved -> Reserved,reservations:List<&2,W.Reservation<T.HealthSchema>>,result:Tx.Tx<World(),Nat> & W.Reservation<T.HealthSchema>) -> Reserved:
  match result:
    case (tx,reservation):next(Reserved{tx,List.append(&2,W.Reservation<T.HealthSchema>,reservations,[reservation])})
def seed_rows(fuel:Nat,+index:U32,state:Reserved) -> Reserved:
  match fuel state:
    case 0n state:state
    case 1n+rest Reserved{tx,reservations}:seed_next(state => seed_rows(rest,U32.add(index,1),state),reservations,Cmd.tx_spawn(~T.HealthSchema,~Store(),~Resources(),~Nat,~Payload,~populate,tx,payload(index)))
type Seeded is Type:
  Seeded{world:World(),reservations:List<&2,W.Reservation<T.HealthSchema>>,outcome:Tx.Outcome<Unit>,sample:Metrics.Sample}
def seeded(sample:Metrics.Sample,reservations:List<&2,W.Reservation<T.HealthSchema>>,result:Tx.Returned<World(),Unit>) -> Seeded:
  match result:
    case Tx.Returned{world,outcome}:Seeded{world,reservations,outcome,sample}
def seed_observed(reservations:List<&2,W.Reservation<T.HealthSchema>>,result:Tx.Tx<World(),Nat> & Metrics.Sample) -> Seeded:
  match result:
    case (tx,sample):seeded(sample,reservations,Cmd.tx_finish(~T.HealthSchema,~Store(),~Resources(),~Nat,~Unit,tx,Tx.Success{}))


def seed_reserved(result:Reserved) -> Seeded:
  match result:
    case Reserved{tx,reservations}:seed_observed(reservations,Metrics.observe(~World(),~Nat,"seed",tx))
def seed(count:U32,world:World()) -> Seeded:seed_reserved(seed_rows(U32.to_nat(count),0,Reserved{Tx.begin(~World(),~Nat,world),[]}))

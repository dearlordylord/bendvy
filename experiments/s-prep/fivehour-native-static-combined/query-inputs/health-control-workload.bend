import Base
import ./held-adapter.bend as HA
import ./raw-boundaries.bend as RB
import ./cache.bend as CC
import ./cached-payload.bend as CP
import ./types.bend as T
import ./storage.bend as S
import ./identity.bend as I
import ./commands.bend as CMD
import ./query.bend as Q
import ./observations.bend as O
import ./payload.bend as P
import ./transaction.bend as X
import ./transaction-dispatch-adapters.bend as A
import ./host.bend as H
import ./reader-host.bend as RH
import ./host-observations.bend as E
import ./dispatcher.bend as D
import ./readers.bend as R
import ./schedule.bend as K
import ./capture.bend as C
import ./host-render.bend as JSON

def quad(a:U32,b:U32,c:U32,d:U32) -> Array<U32>:
  Array.set(U32,Array.set(U32,Array.set(U32,[a:U32^2n],1,b),2,c),3,d)

def keep(~A:Type,owner:A) -> A & Unit: (owner,Unit{})

def handle_client(~Schema:Data,~F:Data,-Owner:Type,-Aux:Type,get:Owner -> Unit -> Owner & Unit,ag:Aux -> Aux & Maybe<&2,Unit>,handle:S.Handle<Schema>,flag:Maybe<&2,F>,owner:Owner,aux:Aux) -> Owner & (Aux & S.Handle<Schema>):
  (owner,(aux,handle))

def first(value:T.Four) -> U32:
  match value:
    case T.Four{a,_,_,_}: a

def sum(value:T.Four) -> U32:
  match value:
    case T.Four{a,b,c,d}: U32.add(U32.add(a,b),U32.add(c,d))

# Trusted measurement adapter; callback below never sees Tx representation.

def health_select(owner:X.Tx<S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>>,handle:S.Handle<T.HealthSchema>) -> X.Tx<S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>>:
  match owner:
    case X.Tx{world,_,undo,commands,pings,marks}: X.Tx{world,handle,undo,commands,pings,marks}

def health_body_ledger(-Owner:Type,set:Owner -> T.HealthLedgerToken -> U32 -> Owner,readsum:U32,pair:Owner & Maybe<&2,T.LedgerView>) -> Owner & U32:
  match pair:
    case (owner,Some{T.LedgerView{values,_}}): (set(owner,T.HealthLedgerToken{},U32.add(first(values),1)),readsum)
    case (owner,None{}): (owner,4294967295)

def health_body_read(-Owner:Type,set:Owner -> T.VitalsToken -> U32 -> Owner,ledger:Owner -> T.HealthLedgerToken -> Owner & Maybe<&2,T.LedgerView>,setledger:Owner -> T.HealthLedgerToken -> U32 -> Owner,pair:Owner & T.Access<T.VitalsView>) -> Owner & U32:
  match pair:
    case (owner,T.Found{T.VitalsView{+values,_,_}}): health_body_ledger(Owner,setledger,sum(values),ledger(set(owner,T.VitalsToken{},U32.add(first(values),1)),T.HealthLedgerToken{}))
    case (owner,_): (owner,4294967295)

def health_body(-Owner:Type,get:Owner -> T.VitalsToken -> Owner & T.Access<T.VitalsView>,set:Owner -> T.VitalsToken -> U32 -> Owner,ledger:Owner -> T.HealthLedgerToken -> Owner & Maybe<&2,T.LedgerView>,setledger:Owner -> T.HealthLedgerToken -> U32 -> Owner,owner:Owner) -> Owner & U32:
  health_body_read(Owner,set,ledger,setledger,get(owner,T.VitalsToken{}))

type HealthRows is Type:
  HealthRows{owner:X.Tx<S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>>,total:U32}

def health_rows_next(result:X.Tx<S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>> & U32,total:U32) -> HealthRows:
  match result:
    case (owner,value): HealthRows{owner,U32.add(total,value)}

def health_rows(handles:List<&2,S.Handle<T.HealthSchema>>,state:HealthRows) -> HealthRows:
  match handles state:
    case Nil{} result: result
    case Con{handle,tail} HealthRows{owner,total}: health_rows(tail,health_rows_next(HA.health_row(~health_body,health_select(owner,handle)),total))

def health_handles(world:S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>) -> S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & List<&2,S.Handle<T.HealthSchema>>:
  Q.each(T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,Unit,Unit,Unit,S.Handle<T.HealthSchema>,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,keep(~CC.Cache<T.Vitals,T.VitalsView>),keep(~T.Armor),handle_client(~T.HealthSchema,~T.Tracked),Q.Required{},world)


def boolnum(value:Bool) -> U32:
  match value:
    case True{}: 1
    case False{}: 0

type HealthBench is Type:
  HealthBench{host:H.HealthHost(),sparse:Bool,readsum:U32,calls:U32}

def health_presence_return(sparse:Bool,total:U32,calls:U32,pair:H.HealthHost() & D.Presence) -> HealthBench & D.Presence:
  match pair:
    case (host,view): (HealthBench{host,sparse,total,calls},view)

def health_presence(owner:HealthBench) -> HealthBench & D.Presence:
  match owner:
    case HealthBench{host,sparse,total,calls}: health_presence_return(sparse,total,calls,H.health_presence(host))

def health_frame_return(sparse:Bool,total:U32,calls:U32,pair:H.HealthHost() & (R.Readers & R.Clock)) -> HealthBench & (R.Readers & R.Clock):
  match pair:
    case (host,rest): (HealthBench{host,sparse,total,calls},rest)

def health_frame(owner:HealthBench,readers:R.Readers,boundary:R.Frame) -> HealthBench & (R.Readers & R.Clock):
  match owner:
    case HealthBench{host,sparse,total,calls}: health_frame_return(sparse,total,calls,H.frame(T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,host,readers,boundary))

def health_clock_return(sparse:Bool,total:U32,calls:U32,pair:H.HealthHost() & R.Clock) -> HealthBench & R.Clock:
  match pair:
    case (host,clock): (HealthBench{host,sparse,total,calls},clock)

def health_barrier(owner:HealthBench,clock:R.Clock) -> IO(HealthBench & R.Clock):
  match owner:
    case HealthBench{host,sparse,total,calls}: IO.bind(H.HealthHost() & R.Clock,HealthBench & R.Clock,H.barrier(T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,host,clock),pair => IO.pure(HealthBench & R.Clock,health_clock_return(sparse,total,calls,pair)))

def health_transition(owner:HealthBench,pending:Maybe<&2,Bool>,clock:R.Clock) -> HealthBench & R.Clock:
  match owner:
    case HealthBench{host,sparse,total,calls}: health_clock_return(sparse,total,calls,H.health_transition(host,pending,clock))


def health_main_sum(value:T.VitalsView) -> U32:
  match value:
    case T.VitalsView{values,meta,other}: U32.add(sum(values),U32.add(meta,other))

def health_aux_sum(value:Maybe<&2,T.ArmorView>) -> U32:
  match value:
    case None{}: 0
    case Some{T.ArmorView{values,meta}}: U32.add(sum(values),U32.add(meta,1))

def health_flag_sum(value:Maybe<&2,T.Tracked>) -> U32:
  match value:
    case None{}: 0
    case Some{T.Tracked{group}}: U32.add(group,1)

def health_row_sum(value:O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>) -> U32:
  match value:
    case O.QueryRow{S.Handle{namespace,id},main,aux,flag}: U32.add(U32.add(namespace,id),U32.add(health_main_sum(main),U32.add(health_aux_sum(aux),health_flag_sum(flag))))

def health_has_aux(value:Maybe<&2,T.ArmorView>) -> Bool:
  match value:
    case None{}: False{}
    case Some{_}: True{}

def health_included(kind:U32,value:O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>) -> Bool:
  match kind value:
    case 1 O.QueryRow{_,_,aux,_}: health_has_aux(aux)
    case 2 O.QueryRow{_,_,aux,_}: Bool.not(health_has_aux(aux))
    case _ _: True{}

def health_score(included:Bool,value:O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>,+index:U32,total:U32) -> U32 & U32:
  match included:
    case False{}: (index,total)
    case True{}: (U32.add(index,1),U32.add(total,U32.mul(index,health_row_sum(value))))

def health_sum_next(ih:U32 -> U32 -> U32,pair:U32 & U32) -> U32:
  match pair:
    case (index,total): ih(index,total)

def health_sum_go(values:List<&2,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>,+kind:U32,index:U32,total:U32) -> U32:
  match values:
    case Nil{}: U32.add(total,index)
    case Con{+head,tail}: health_sum_next(i => t => health_sum_go(tail,kind,i,t),health_score(health_included(kind,head),head,index,total))


def health_views(world:S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>) -> S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & List<&2,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>:
  Q.each(T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,T.VitalsToken,T.VitalsView,T.ArmorView,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,CP.vitals_get,P.armor_get,O.client(~T.HealthSchema,~T.VitalsToken,~T.VitalsView,~T.ArmorView,~T.Tracked,~T.VitalsToken{}),Q.Optional{},world)

def health_query3(total:U32,pair:S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & List<&2,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>) -> S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & U32:
  match pair:
    case (world,values): (world,U32.add(total,U32.mul(5,health_sum_go(values,2,1,0))))

def health_query2(total:U32,pair:S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & List<&2,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>) -> S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & U32:
  match pair:
    case (world,values): health_query3(U32.add(total,U32.mul(3,health_sum_go(values,1,1,0))),health_views(world))

def health_query1(pair:S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & List<&2,O.QueryRow<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked>>) -> S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & U32:
  match pair:
    case (world,values): health_query2(health_sum_go(values,0,1,0),health_views(world))

def health_queries(sparse:Bool,world:S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>) -> S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & U32:
  match sparse:
    case False{}: (world,0)
    case True{}: health_query1(health_views(world))

def health_committed_queries(sparse:Bool,pair:S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & List<&2,U32>) -> S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & U32:
  match pair:
    case (world,_): health_queries(sparse,world)

def health_committed(sparse:Bool,total:U32,count:U32,logs:RH.Logs<T.HealthSchema,T.HealthPing>,bindings:List<&2,E.Binding<T.HealthSchema>>,name:String,step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>,audit:Maybe<D.Audit>,run:Maybe<R.Run>,clock:R.Clock,pair:S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & U32) -> IO(D.Invoked<HealthBench,S.Handle<T.HealthSchema>>):
  match pair:
    case (world,querysum): IO.pure(D.Invoked<HealthBench,S.Handle<T.HealthSchema>>,D.Invoked{HealthBench{H.Host{world,logs,bindings,name,step,prior,events},sparse,U32.add(total,querysum),count},audit,run,T.Success{},clock,None{},[]})

def health_updated(+sparse:Bool,count:U32,logs:RH.Logs<T.HealthSchema,T.HealthPing>,bindings:List<&2,E.Binding<T.HealthSchema>>,name:String,step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>,audit:Maybe<D.Audit>,run:Maybe<R.Run>,+clock:R.Clock,result:HealthRows) -> IO(D.Invoked<HealthBench,S.Handle<T.HealthSchema>>):
  match result:
    case HealthRows{owner,total}: health_committed(sparse,total,count,logs,bindings,name,step,prior,events,audit,run,clock,health_committed_queries(sparse,X.storage_commit(T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,X.tx_finish_success(S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>,owner),D.clock_tick(clock))))

def health_queried(sparse:Bool,total:U32,count:U32,logs:RH.Logs<T.HealthSchema,T.HealthPing>,bindings:List<&2,E.Binding<T.HealthSchema>>,name:String,step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<T.HealthSchema,T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,T.HealthPing>>,audit:Maybe<D.Audit>,run:Maybe<R.Run>,clock:R.Clock,pair:S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & List<&2,S.Handle<T.HealthSchema>>) -> IO(D.Invoked<HealthBench,S.Handle<T.HealthSchema>>):
  match pair:
    case (world,handles): health_updated(sparse,count,logs,bindings,name,step,prior,events,audit,run,clock,health_rows(handles,HealthRows{X.tx_begin(S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Command<CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked>,world,S.Handle{0,0}),total}))

def health_invoke(system:K.System,mode:K.Mode,count:U32,clock:R.Clock,owner:HealthBench,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<HealthBench,S.Handle<T.HealthSchema>>):
  match owner:
    case HealthBench{H.Host{world,logs,bindings,name,step,prior,events},sparse,total,_}:
      health_queried(sparse,total,count,logs,bindings,name,step,prior,events,audit,run,clock,health_handles(world))

def health_tick(nodes:List<&2,K.Node>,runtime:D.Runtime<HealthBench,S.Handle<T.HealthSchema>>) -> IO(D.Dispatched<HealthBench,S.Handle<T.HealthSchema>>):
  D.tick(HealthBench,S.Handle<T.HealthSchema>,health_presence,health_invoke,health_barrier,health_transition,health_frame,nodes,"HealthLedger","Mode",runtime)

def health_continue(next:D.Runtime<HealthBench,S.Handle<T.HealthSchema>> -> IO(D.Runtime<HealthBench,S.Handle<T.HealthSchema>>),result:D.Dispatched<HealthBench,S.Handle<T.HealthSchema>>) -> IO(D.Runtime<HealthBench,S.Handle<T.HealthSchema>>):
  match result:
    case D.Dispatched{runtime,D.Complete{}}: next(runtime)
    case _: IO.die(D.Runtime<HealthBench,S.Handle<T.HealthSchema>>,3,"dispatch failure")

def health_loops(fuel:Nat,+system:K.System,runtime:D.Runtime<HealthBench,S.Handle<T.HealthSchema>>) -> IO(D.Runtime<HealthBench,S.Handle<T.HealthSchema>>):
  match fuel:
    case 0n: IO.pure(D.Runtime<HealthBench,S.Handle<T.HealthSchema>>,runtime)
    case 1n+rest: IO.bind(D.Dispatched<HealthBench,S.Handle<T.HealthSchema>>,D.Runtime<HealthBench,S.Handle<T.HealthSchema>>,health_tick([K.Call{system,K.Normal{}}],runtime),result => health_continue(state => health_loops(rest,system,state),result))

def health_main(+j:U32,present:Bool) -> Maybe<T.Vitals>:
  match present:
    case False{}: None{}
    case True{}: Some{T.Vitals{quad(j,U32.add(j,1),U32.add(j,2),U32.add(j,3)),9,2}}

def health_aux(present:Bool) -> Maybe<T.Armor>:
  match present:
    case False{}: None{}
    case True{}: Some{T.Armor{quad(1,2,3,4),3}}

def health_flag(present:Bool) -> Maybe<&2,T.Tracked>:
  match present:
    case False{}: None{}
    case True{}: Some{T.Tracked{8}}

def health_bundle(+j:U32,sparse:Bool) -> S.Bundle<T.Vitals,T.Armor,T.Tracked>:
  S.Bundle{health_main(j,Bool.or(Bool.not(sparse),U32.is_eq(U32.mod(j,8),0))),health_aux(U32.is_eq(U32.mod(j,3),0)),health_flag(U32.is_eq(U32.mod(j,3),1))}

def health_reserved(result:T.Reservation<S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<T.Vitals,T.Armor,T.Tracked>>) -> S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>:
  match result:
    case T.Reserved{world,_}: world
    case T.ReserveRejected{world,_}: world

def health_seed(fuel:Nat,+j:U32,+sparse:Bool,world:S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>) -> S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>:
  match fuel:
    case 0n: world
    case 1n+rest: health_seed(rest,U32.add(j,1),sparse,health_reserved(RB.health_reserve(world,health_bundle(j,sparse))))

def health_ledger(unit:Unit) -> T.HealthLedger: T.HealthLedger{quad(0,101,102,103),4}

def health_registered(count:U32,+sparse:Bool,world:S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,registered:K.Registered) -> IO(D.Runtime<HealthBench,S.Handle<T.HealthSchema>> & K.System):
  match registered:
    case K.Registered{registry,+system}: IO.bind(D.Dispatched<HealthBench,S.Handle<T.HealthSchema>>,D.Runtime<HealthBench,S.Handle<T.HealthSchema>> & K.System,health_tick([K.Deferred{}],D.Runtime{HealthBench{H.initial(T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,T.HealthPing,T.VitalsView,T.ArmorView,T.LedgerView,"health",health_seed(U32.to_nat(count),0,sparse,world),65536),sparse,0,0},registry,R.initial(),R.clock(),None{},C.Returned{},[],[],None{}}),result => IO.bind(D.Runtime<HealthBench,S.Handle<T.HealthSchema>>,D.Runtime<HealthBench,S.Handle<T.HealthSchema>> & K.System,health_continue(state => IO.pure(D.Runtime<HealthBench,S.Handle<T.HealthSchema>>,state),result),state => IO.pure(D.Runtime<HealthBench,S.Handle<T.HealthSchema>> & K.System,(state,system))))

def health_created(count:U32,sparse:Bool,result:T.Creation<S.Factory,S.World<T.HealthSchema,CC.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,CC.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>>) -> IO(D.Runtime<HealthBench,S.Handle<T.HealthSchema>> & K.System):
  match result:
    case T.Created{_,world}: health_registered(count,sparse,world,K.register(K.initial(),"BenchUpdate",K.Snapshot{},True{},False{},False{},False{}))
    case _: IO.die(D.Runtime<HealthBench,S.Handle<T.HealthSchema>> & K.System,4,"factory rejected")


def clock_frame(clock:R.Clock) -> U32:
  match clock:
    case R.Clock{_,_,_,frames}: frames

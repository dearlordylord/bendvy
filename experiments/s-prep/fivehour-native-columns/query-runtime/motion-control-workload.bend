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

def motion_select(owner:X.Tx<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>,handle:S.Handle<T.MotionSchema>) -> X.Tx<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>:
  match owner:
    case X.Tx{world,_,undo,commands,pings,marks}: X.Tx{world,handle,undo,commands,pings,marks}

def motion_body_ledger(-Owner:Type,set:Owner -> T.MotionLedgerToken -> U32 -> Owner,readsum:U32,pair:Owner & Maybe<&2,T.LedgerView>) -> Owner & U32:
  match pair:
    case (owner,Some{T.LedgerView{values,_}}): (set(owner,T.MotionLedgerToken{},U32.add(first(values),1)),readsum)
    case (owner,None{}): (owner,4294967295)

def motion_body_read(-Owner:Type,set:Owner -> T.PositionToken -> U32 -> Owner,ledger:Owner -> T.MotionLedgerToken -> Owner & Maybe<&2,T.LedgerView>,setledger:Owner -> T.MotionLedgerToken -> U32 -> Owner,pair:Owner & T.Access<T.PositionView>) -> Owner & U32:
  match pair:
    case (owner,T.Found{T.PositionView{+values,_}}): motion_body_ledger(Owner,setledger,sum(values),ledger(set(owner,T.PositionToken{},U32.add(first(values),1)),T.MotionLedgerToken{}))
    case (owner,_): (owner,4294967295)

def motion_body(-Owner:Type,get:Owner -> T.PositionToken -> Owner & T.Access<T.PositionView>,set:Owner -> T.PositionToken -> U32 -> Owner,ledger:Owner -> T.MotionLedgerToken -> Owner & Maybe<&2,T.LedgerView>,setledger:Owner -> T.MotionLedgerToken -> U32 -> Owner,owner:Owner) -> Owner & U32:
  motion_body_read(Owner,set,ledger,setledger,get(owner,T.PositionToken{}))

type MotionRows is Type:
  MotionRows{owner:X.Tx<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>,total:U32}

def motion_rows_next(result:X.Tx<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>> & U32,total:U32) -> MotionRows:
  match result:
    case (owner,value): MotionRows{owner,U32.add(total,value)}

def motion_rows(handles:List<&2,S.Handle<T.MotionSchema>>,state:MotionRows) -> MotionRows:
  match handles state:
    case Nil{} result: result
    case Con{handle,tail} MotionRows{owner,total}: motion_rows(tail,motion_rows_next(HA.motion_row(~motion_body,motion_select(owner,handle)),total))

def motion_handles(world:S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>) -> S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & List<&2,S.Handle<T.MotionSchema>>:
  Q.each(T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,Unit,Unit,Unit,S.Handle<T.MotionSchema>,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,keep(~CC.Cache<T.Position,T.PositionView>),keep(~T.Velocity),handle_client(~T.MotionSchema,~T.Selected),Q.Required{},world)

# Trusted measurement adapter; callback below never sees Tx representation.

type MotionBench is Type:
  MotionBench{host:H.MotionHost(),sparse:Bool,readsum:U32,calls:U32}

def boolnum(value:Bool) -> U32:
  match value:
    case True{}: 1
    case False{}: 0

def motion_presence_return(sparse:Bool,total:U32,calls:U32,pair:H.MotionHost() & D.Presence) -> MotionBench & D.Presence:
  match pair:
    case (host,view): (MotionBench{host,sparse,total,calls},view)

def motion_presence(owner:MotionBench) -> MotionBench & D.Presence:
  match owner:
    case MotionBench{host,sparse,total,calls}: motion_presence_return(sparse,total,calls,H.motion_presence(host))

def motion_frame_return(sparse:Bool,total:U32,calls:U32,pair:H.MotionHost() & (R.Readers & R.Clock)) -> MotionBench & (R.Readers & R.Clock):
  match pair:
    case (host,rest): (MotionBench{host,sparse,total,calls},rest)

def motion_frame(owner:MotionBench,readers:R.Readers,boundary:R.Frame) -> MotionBench & (R.Readers & R.Clock):
  match owner:
    case MotionBench{host,sparse,total,calls}: motion_frame_return(sparse,total,calls,H.frame(T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,host,readers,boundary))

def motion_clock_return(sparse:Bool,total:U32,calls:U32,pair:H.MotionHost() & R.Clock) -> MotionBench & R.Clock:
  match pair:
    case (host,clock): (MotionBench{host,sparse,total,calls},clock)

def motion_barrier(owner:MotionBench,clock:R.Clock) -> IO(MotionBench & R.Clock):
  match owner:
    case MotionBench{host,sparse,total,calls}: IO.bind(H.MotionHost() & R.Clock,MotionBench & R.Clock,H.barrier(T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,host,clock),pair => IO.pure(MotionBench & R.Clock,motion_clock_return(sparse,total,calls,pair)))

def motion_transition(owner:MotionBench,pending:Maybe<&2,Bool>,clock:R.Clock) -> MotionBench & R.Clock:
  match owner:
    case MotionBench{host,sparse,total,calls}: motion_clock_return(sparse,total,calls,H.motion_transition(host,pending,clock))


def motion_main_sum(value:T.PositionView) -> U32:
  match value:
    case T.PositionView{values,meta}: U32.add(sum(values),meta)

def motion_aux_sum(value:Maybe<&2,T.VelocityView>) -> U32:
  match value:
    case None{}: 0
    case Some{T.VelocityView{values,moving}}: U32.add(sum(values),U32.add(boolnum(moving),1))

def motion_flag_sum(value:Maybe<&2,T.Selected>) -> U32:
  match value:
    case None{}: 0
    case Some{T.Selected{group}}: U32.add(group,1)

def motion_row_sum(value:O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>) -> U32:
  match value:
    case O.QueryRow{S.Handle{namespace,id},main,aux,flag}: U32.add(U32.add(namespace,id),U32.add(motion_main_sum(main),U32.add(motion_aux_sum(aux),motion_flag_sum(flag))))

def motion_has_aux(value:Maybe<&2,T.VelocityView>) -> Bool:
  match value:
    case None{}: False{}
    case Some{_}: True{}

def motion_included(kind:U32,value:O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>) -> Bool:
  match kind value:
    case 1 O.QueryRow{_,_,aux,_}: motion_has_aux(aux)
    case 2 O.QueryRow{_,_,aux,_}: Bool.not(motion_has_aux(aux))
    case _ _: True{}

def motion_score(included:Bool,value:O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>,+index:U32,total:U32) -> U32 & U32:
  match included:
    case False{}: (index,total)
    case True{}: (U32.add(index,1),U32.add(total,U32.mul(index,motion_row_sum(value))))

def motion_sum_next(ih:U32 -> U32 -> U32,pair:U32 & U32) -> U32:
  match pair:
    case (index,total): ih(index,total)

def motion_sum_go(values:List<&2,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>,+kind:U32,index:U32,total:U32) -> U32:
  match values:
    case Nil{}: U32.add(total,index)
    case Con{+head,tail}: motion_sum_next(i => t => motion_sum_go(tail,kind,i,t),motion_score(motion_included(kind,head),head,index,total))


def motion_views(world:S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>) -> S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & List<&2,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>:
  Q.each(T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,T.PositionToken,T.PositionView,T.VelocityView,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,CP.position_get,P.velocity_get,O.client(~T.MotionSchema,~T.PositionToken,~T.PositionView,~T.VelocityView,~T.Selected,~T.PositionToken{}),Q.Optional{},world)

def motion_query3(total:U32,pair:S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & List<&2,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>) -> S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & U32:
  match pair:
    case (world,values): (world,U32.add(total,U32.mul(5,motion_sum_go(values,2,1,0))))

def motion_query2(total:U32,pair:S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & List<&2,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>) -> S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & U32:
  match pair:
    case (world,values): motion_query3(U32.add(total,U32.mul(3,motion_sum_go(values,1,1,0))),motion_views(world))

def motion_query1(pair:S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & List<&2,O.QueryRow<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected>>) -> S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & U32:
  match pair:
    case (world,values): motion_query2(motion_sum_go(values,0,1,0),motion_views(world))

def motion_queries(sparse:Bool,world:S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>) -> S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & U32:
  match sparse:
    case False{}: (world,0)
    case True{}: motion_query1(motion_views(world))

def motion_committed_queries(sparse:Bool,pair:S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & List<&2,U32>) -> S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & U32:
  match pair:
    case (world,_): motion_queries(sparse,world)

def motion_committed(sparse:Bool,total:U32,count:U32,logs:RH.Logs<T.MotionSchema,T.MotionPing>,bindings:List<&2,E.Binding<T.MotionSchema>>,name:String,step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>,audit:Maybe<D.Audit>,run:Maybe<R.Run>,clock:R.Clock,pair:S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & U32) -> IO(D.Invoked<MotionBench,S.Handle<T.MotionSchema>>):
  match pair:
    case (world,querysum): IO.pure(D.Invoked<MotionBench,S.Handle<T.MotionSchema>>,D.Invoked{MotionBench{H.Host{world,logs,bindings,name,step,prior,events},sparse,U32.add(total,querysum),count},audit,run,T.Success{},clock,None{},[]})

def motion_updated(+sparse:Bool,count:U32,logs:RH.Logs<T.MotionSchema,T.MotionPing>,bindings:List<&2,E.Binding<T.MotionSchema>>,name:String,step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>,audit:Maybe<D.Audit>,run:Maybe<R.Run>,+clock:R.Clock,result:MotionRows) -> IO(D.Invoked<MotionBench,S.Handle<T.MotionSchema>>):
  match result:
    case MotionRows{owner,total}: motion_committed(sparse,total,count,logs,bindings,name,step,prior,events,audit,run,clock,motion_committed_queries(sparse,X.storage_commit(T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,X.tx_finish_success(S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>,owner),D.clock_tick(clock))))

def motion_queried(sparse:Bool,total:U32,count:U32,logs:RH.Logs<T.MotionSchema,T.MotionPing>,bindings:List<&2,E.Binding<T.MotionSchema>>,name:String,step:String,prior:D.DispatchOutcome,events:List<&2,E.TraceEvent<T.MotionSchema,T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,T.MotionPing>>,audit:Maybe<D.Audit>,run:Maybe<R.Run>,clock:R.Clock,pair:S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & List<&2,S.Handle<T.MotionSchema>>) -> IO(D.Invoked<MotionBench,S.Handle<T.MotionSchema>>):
  match pair:
    case (world,handles): motion_updated(sparse,count,logs,bindings,name,step,prior,events,audit,run,clock,motion_rows(handles,MotionRows{X.tx_begin(S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>,world,S.Handle{0,0}),total}))

def motion_invoke(system:K.System,mode:K.Mode,count:U32,clock:R.Clock,owner:MotionBench,audit:Maybe<D.Audit>,run:Maybe<R.Run>) -> IO(D.Invoked<MotionBench,S.Handle<T.MotionSchema>>):
  match owner:
    case MotionBench{H.Host{world,logs,bindings,name,step,prior,events},sparse,total,_}:
      motion_queried(sparse,total,count,logs,bindings,name,step,prior,events,audit,run,clock,motion_handles(world))

def motion_tick(nodes:List<&2,K.Node>,runtime:D.Runtime<MotionBench,S.Handle<T.MotionSchema>>) -> IO(D.Dispatched<MotionBench,S.Handle<T.MotionSchema>>):
  D.tick(MotionBench,S.Handle<T.MotionSchema>,motion_presence,motion_invoke,motion_barrier,motion_transition,motion_frame,nodes,"MotionLedger","Mode",runtime)

def motion_continue(next:D.Runtime<MotionBench,S.Handle<T.MotionSchema>> -> IO(D.Runtime<MotionBench,S.Handle<T.MotionSchema>>),result:D.Dispatched<MotionBench,S.Handle<T.MotionSchema>>) -> IO(D.Runtime<MotionBench,S.Handle<T.MotionSchema>>):
  match result:
    case D.Dispatched{runtime,D.Complete{}}: next(runtime)
    case _: IO.die(D.Runtime<MotionBench,S.Handle<T.MotionSchema>>,3,"dispatch failure")

def motion_loops(fuel:Nat,+system:K.System,runtime:D.Runtime<MotionBench,S.Handle<T.MotionSchema>>) -> IO(D.Runtime<MotionBench,S.Handle<T.MotionSchema>>):
  match fuel:
    case 0n: IO.pure(D.Runtime<MotionBench,S.Handle<T.MotionSchema>>,runtime)
    case 1n+rest: IO.bind(D.Dispatched<MotionBench,S.Handle<T.MotionSchema>>,D.Runtime<MotionBench,S.Handle<T.MotionSchema>>,motion_tick([K.Call{system,K.Normal{}}],runtime),result => motion_continue(state => motion_loops(rest,system,state),result))

def motion_main(+j:U32,present:Bool) -> Maybe<T.Position>:
  match present:
    case False{}: None{}
    case True{}: Some{T.Position{quad(j,U32.add(j,1),U32.add(j,2),U32.add(j,3)),7}}

def motion_aux(present:Bool) -> Maybe<T.Velocity>:
  match present:
    case False{}: None{}
    case True{}: Some{T.Velocity{quad(1,2,3,4),True{}}}

def motion_flag(present:Bool) -> Maybe<&2,T.Selected>:
  match present:
    case False{}: None{}
    case True{}: Some{T.Selected{8}}

def motion_bundle(+j:U32,sparse:Bool) -> S.Bundle<T.Position,T.Velocity,T.Selected>:
  S.Bundle{motion_main(j,Bool.or(Bool.not(sparse),U32.is_eq(U32.mod(j,8),0))),motion_aux(U32.is_eq(U32.mod(j,3),0)),motion_flag(U32.is_eq(U32.mod(j,3),1))}

def motion_reserved(result:T.Reservation<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<T.Position,T.Velocity,T.Selected>>) -> S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>:
  match result:
    case T.Reserved{world,_}: world
    case T.ReserveRejected{world,_}: world

def motion_seed(fuel:Nat,+j:U32,+sparse:Bool,world:S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>) -> S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>:
  match fuel:
    case 0n: world
    case 1n+rest: motion_seed(rest,U32.add(j,1),sparse,motion_reserved(RB.motion_reserve(world,motion_bundle(j,sparse))))

def motion_ledger(unit:Unit) -> T.MotionLedger: T.MotionLedger{quad(0,101,102,103),4}

def motion_registered(count:U32,+sparse:Bool,world:S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,registered:K.Registered) -> IO(D.Runtime<MotionBench,S.Handle<T.MotionSchema>> & K.System):
  match registered:
    case K.Registered{registry,+system}: IO.bind(D.Dispatched<MotionBench,S.Handle<T.MotionSchema>>,D.Runtime<MotionBench,S.Handle<T.MotionSchema>> & K.System,motion_tick([K.Deferred{}],D.Runtime{MotionBench{H.initial(T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,T.MotionPing,T.PositionView,T.VelocityView,T.LedgerView,"motion",motion_seed(U32.to_nat(count),0,sparse,world),65536),sparse,0,0},registry,R.initial(),R.clock(),None{},C.Returned{},[],[],None{}}),result => IO.bind(D.Runtime<MotionBench,S.Handle<T.MotionSchema>>,D.Runtime<MotionBench,S.Handle<T.MotionSchema>> & K.System,motion_continue(state => IO.pure(D.Runtime<MotionBench,S.Handle<T.MotionSchema>>,state),result),state => IO.pure(D.Runtime<MotionBench,S.Handle<T.MotionSchema>> & K.System,(state,system))))

def motion_created(count:U32,sparse:Bool,result:T.Creation<S.Factory,S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>>) -> IO(D.Runtime<MotionBench,S.Handle<T.MotionSchema>> & K.System):
  match result:
    case T.Created{_,world}: motion_registered(count,sparse,world,K.register(K.initial(),"BenchUpdate",K.Snapshot{},True{},False{},False{},False{}))
    case _: IO.die(D.Runtime<MotionBench,S.Handle<T.MotionSchema>> & K.System,4,"factory rejected")


def clock_frame(clock:R.Clock) -> U32:
  match clock:
    case R.Clock{_,_,_,frames}: frames

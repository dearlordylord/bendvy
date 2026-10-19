import Base
import ../../../method/json.bend as J
import ../../../method/method.bend as M
import ../consumer/motion-local.bend as L
import ../../../consumer/motion.bend as F
import ../../../consumer/motion-publications.bend as Pub
import ../consumer/motion-reader.bend as Reader
import ../../../consumer/motion-parameters.bend as Param
import ../../../consumer/motion-callbacks.bend as C
import ../../../consumer/events.bend as E
import ../../../consumer/motion-observe.bend as O
import ../../../../sparse-motion64/consumer/s-perf/canonical-api-v1/sparse-runtime-v1/types.bend as T
import ../../../../sparse-motion64/consumer/s-perf/canonical-api-v1/sparse-runtime-v1/payload.bend as P
import ../../../../../../src/ecs/local.bend as Local
import ../../../../../../src/ecs/transaction.bend as Tx
import ../../../../../../src/ecs/component.bend as Cmp
import ../../../../../../src/ecs/world.bend as W
import ../../../../../../src/ecs/ordinary-reader-stream-parameter.bend as SP
import ../../../../../../src/ecs/event-runtime.bend as Ev
import ../../../../../../src/ecs/relation-commands.bend as Notice

type Args is Data:
  Args{a:Bool,iteration:U32,phase:U32,capture:U32,readerStatus:Maybe<&2,U32>,readerError:Maybe<&2,U32>}
def who(a:Bool) -> J.Value:
  match a:
    case True{}:J.Text{"A"}
    case False{}:J.Text{"B"}
def iteration(phase:U32,value:U32) -> J.Value:
  match phase:
    case 0:J.Null{}
    case _:M.number(value)
def mode(a:Bool,phase:U32,value:Tx.Outcome<U32>) -> J.Value:
  match a phase value:
    case _,0,_:J.Text{"Prime"}
    case True{},_,Tx.Success{}:J.Text{"Commit"}
    case False{},_,Tx.Success{}:J.Text{"Retry"}
    case _,_,Tx.Failure{_}:J.Text{"Fail"}
def outcome(value:Tx.Outcome<U32>) -> J.Value:
  match value:
    case Tx.Success{}:J.object([J.Field{"kind",J.Text{"Success"}}])
    case Tx.Failure{code}:J.object([J.Field{"kind",J.Text{"Failure"}},J.Field{"code",M.number(code)}])
def world_error(value:W.WorldError) -> J.Value:
  match value:
    case W.MissingEntity{}:J.Text{"MissingEntity"}
    case W.CapacityExceeded{}:J.Text{"CapacityExceeded"}
    case W.NamespaceExhausted{}:J.Text{"NamespaceExhausted"}
    case W.SystemIdExhausted{}:J.Text{"SystemIdExhausted"}
def reservation(state:M.State,value:W.Reservation<T.MotionSchema>) -> J.Value:
  match value:
    case W.Reserved{raw}:J.object([J.Field{"kind",J.Text{"Reserved"}},J.Field{"actor",M.reference(state,raw)}])
    case W.ReservationRejected{error}:J.object([J.Field{"kind",J.Text{"Rejected"}},J.Field{"error",world_error(error)}])
def optional_reservation(state:M.State,value:Maybe<&2,W.Reservation<T.MotionSchema>>) -> J.Value:
  match value:
    case None{}:J.Null{}
    case Some{value}:reservation(state,value)
def write(value:Cmp.Access<T.PositionView>) -> J.Value:M.access(~T.PositionView,~M.position,value)
def rejected_view(value:T.Position & T.PositionView) -> Maybe<&1,T.Position> & J.Value:
  match value:
    case (owner,view):(Some{owner},M.position(view))
def observe_rejected(value:Maybe<&1,T.Position>) -> Maybe<&1,T.Position> & J.Value:
  match value:
    case None{}:(None{},J.Null{})
    case Some{owner}:rejected_view(P.position_get(owner))
def unit(_:Unit) -> J.Value:J.Null{}
def event(value:E.event_type()) -> J.Value:
  match value:
    case Notice.Original{code}:J.object([J.Field{"code",J.Number{code}}])
    case other:J.object([J.Field{"kind",J.Text{"OtherNotice"}},J.Field{"raw",J.Text{O.event(other)}}])
def reading(value:Param.ping_view()) -> J.Value:
  match value:
    case SP.EventView{Ev.Reading{values,lagged}}:J.object([J.Field{"messages",J.array(M.values(~E.event_type(),~event,values))},J.Field{"lagged",J.Boolean{lagged}}])
def snapshot(~R:Data,~read:R -> J.Value,args:Args,state:M.State,+result:Tx.Outcome<U32>,reading:R,reservation:Maybe<&2,W.Reservation<T.MotionSchema>>,payload:Maybe<&2,T.PositionView>,writes:List<&2,Cmp.Access<T.PositionView>>,ledger:Maybe<&2,T.LedgerView>,rejected:J.Value,error:Maybe<&2,W.WorldError>,pending:Maybe<&2,Cmp.Access<T.PositionView>>) -> J.Value:
  match args:
    case Args{+a,+i,+phase,capture,readerStatus,readerError}:J.object([J.Field{"kind",J.Text{"Callback"}},J.Field{"who",who(a)},J.Field{"mode",mode(a,phase,result)},J.Field{"iteration",iteration(phase,i)},J.Field{"capture",M.number(capture)},J.Field{"readerStatus",M.maybe(~U32,~M.number,readerStatus)},J.Field{"readerError",M.maybe(~U32,~M.number,readerError)},J.Field{"reading",read(reading)},J.Field{"outcome",outcome(result)},J.Field{"reservation",optional_reservation(state,reservation)},J.Field{"payload",M.maybe(~T.PositionView,~M.position,payload)},J.Field{"writes",J.array(M.values(~Cmp.Access<T.PositionView>,~write,writes))},J.Field{"ledger",M.maybe(~T.LedgerView,~M.ledger,ledger)},J.Field{"rejected",rejected},J.Field{"error",M.maybe(~W.WorldError,~world_error,error)},J.Field{"pendingLookup",M.maybe(~Cmp.Access<T.PositionView>,~write,pending)}])
def rebuilt(~R:Data,~read:R -> J.Value,args:Args,state:M.State,+outcome:Tx.Outcome<U32>,+reading:R,+reservation:Maybe<&2,W.Reservation<T.MotionSchema>>,+payload:Maybe<&2,T.PositionView>,+writes:List<&2,Cmp.Access<T.PositionView>>,+ledger:Maybe<&2,T.LedgerView>,+error:Maybe<&2,W.WorldError>,+pending:Maybe<&2,Cmp.Access<T.PositionView>>,observed:Maybe<&1,T.Position> & J.Value) -> C.Output<R> & J.Value:
  match observed:
    case (rejected,view):(C.Output{outcome,reading,reservation,payload,writes,ledger,rejected,error,pending},snapshot(~R,~read,args,state,outcome,reading,reservation,payload,writes,ledger,view,error,pending))
def output(~R:Data,~read:R -> J.Value,args:Args,state:M.State,value:C.Output<R>) -> C.Output<R> & J.Value:
  match value:
    case C.Output{outcome,reading,reservation,payload,writes,ledger,rejected,error,pending}:rebuilt(~R,~read,args,state,outcome,reading,reservation,payload,writes,ledger,error,pending,observe_rejected(rejected))

def reader_returned(observed:C.Output<Param.ping_view()> & J.Value) -> Reader.Read & J.Value:
  match observed:
    case (callback,value):(Reader.Read{callback},value)
def reader(args:Args,state:M.State,value:Reader.Read) -> Reader.Read & J.Value:
  match value:
    case Reader.Read{callback}:reader_returned(output(~Param.ping_view(),~reading,args,state,callback))
def a_returned(+result:Tx.Outcome<U32>,observed:C.Output<Unit> & J.Value) -> L.Call & J.Value:
  match observed:
    case (callback,value):(L.ACall{result,callback},value)
def b_returned(+status:U32,+error:Maybe<&2,U32>,observed:Reader.Read & J.Value) -> L.Call & J.Value:
  match observed:
    case (callback,value):(L.BCall{status,error,Some{callback}},value)
def call(a:Bool,i:U32,phase:U32,count:U32,state:M.State,value:L.Call) -> L.Call & J.Value:
  match value:
    case L.ACall{result,callback}:a_returned(result,output(~Unit,~unit,Args{a,i,phase,count,None{},None{}},state,callback))
    case L.BCall{+status,+error,Some{callback}}:b_returned(status,error,reader(Args{a,i,phase,count,Some{status},error},state,callback))
    case L.BCall{+status,+error,None{}}:(L.BCall{status,error,None{}},J.object([J.Field{"kind",J.Text{"CallbackUnavailable"}},J.Field{"status",M.number(status)},J.Field{"error",M.maybe(~U32,~M.number,error)}]))

def counted_a(value:Array<U32> & U32) -> L.State & U32:
  match value:
    case (capture,count):(L.A{capture},count)
def counted_b(reader:Reader.Provider(),value:Array<U32> & U32) -> L.State & U32:
  match value:
    case (capture,count):(L.B{capture,reader},count)
def local_count(value:L.State) -> L.State & U32:
  match value:
    case L.A{capture}:counted_a(Array.get(U32,capture,0))
    case L.B{capture,reader}:counted_b(reader,Array.get(U32,capture,0))
def instance_count(value:L.Instance()) -> L.Instance() & U32:
  Local.observe(~T.MotionSchema,~F.Store(),~F.Resources(),~E.event_type(),~L.State,~L.Args,~Empty,~L.Returned,~L.runner,~U32,~local_count,value)
def detached(instance:L.Instance(),state:M.State,observed:L.Call & J.Value) -> L.Instance() & (L.Call & M.State):
  match observed:
    case (call,record):(instance,(call,M.append(state,record)))
def counted(a:Bool,i:U32,phase:U32,+state:M.State,value:L.Call,observed:L.Instance() & U32) -> L.Instance() & (L.Call & M.State):
  match observed:
    case (instance,count):detached(instance,state,call(a,i,phase,count,state,value))
def local(a:Bool,i:U32,phase:U32,state:M.State,handle:Maybe<&2,W.Handle<T.MotionSchema>>,instance:L.Instance(),value:L.Call) -> L.Instance() & (L.Call & M.State):
  counted(a,i,phase,M.added(state,handle),value,instance_count(instance))

def publication_mode(phase:U32) -> J.Value:
  match phase:
    case 0:J.Text{"Prime"}
    case 2:J.Text{"AfterFailure"}
    case 4:J.Text{"AfterRetry"}
    case other:J.object([J.Field{"kind",J.Text{"OtherPhase"}},J.Field{"value",M.number(other)}])
def publication(+status:U32,value:Maybe<&2,Pub.Read>) -> J.Value:
  match value:
    case Some{Pub.Read{Pub.Args{+phase,i},SP.EventView{Ev.Reading{messages,lagged}}}}:J.object([J.Field{"kind",J.Text{"Publications"}},J.Field{"mode",publication_mode(phase)},J.Field{"iteration",iteration(phase,i)},J.Field{"status",M.number(status)},J.Field{"messages",J.array(M.values(~E.event_type(),~event,messages))},J.Field{"lagged",J.Boolean{lagged}}])
    case None{}:J.object([J.Field{"kind",J.Text{"PublicationsUnavailable"}},J.Field{"status",M.number(status)}])

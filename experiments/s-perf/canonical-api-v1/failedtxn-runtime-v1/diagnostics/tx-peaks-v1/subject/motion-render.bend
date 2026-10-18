import Base
import report-doc.bend as Doc
import ../../../../dense-runtime-v1/types.bend as T
import ../../../../dense-runtime-v1/render.bend as J
import motion.bend as F
import events.bend as E
import motion-parameters.bend as P
import motion-reader.bend as Reader
import motion-publications.bend as Publications
import motion-local.bend as L
import motion-callbacks.bend as C
import motion-tx-observe.bend as Inspect
import motion-observe.bend as O
import motion-reader-owner-observe.bend as RO
import trace-observe.bend as Trace
import physical-owner-observer.bend as Dump
import ../../../../../../../src/ecs/ordinary-reader-stream-parameter.bend as SP
import ../../../../../../../src/ecs/event-runtime.bend as Ev
import ../../../../../../../src/ecs/component.bend as Cmp
import ../../../../../../../src/ecs/local.bend as Local
import ../../../../../../../src/ecs/world.bend as W
import ../../../../../../../src/ecs/transaction.bend as Tx

def outcome(value:Tx.Outcome<U32>) -> String:
  match value:
    case Tx.Success{}:"Success"
    case Tx.Failure{code}:"Failure{" ++ U32.show(code) ++ "}"
def access(value:Cmp.Access<T.PositionView>) -> String:
  match value:
    case Cmp.Found{view}:"Found{" ++ J.render_position(view) ++ "}"
    case Cmp.ComponentAbsent{}:"Absent"
    case Cmp.MissingEntity{}:"Missing"
def pending_lookup(value:Maybe<&2,Cmp.Access<T.PositionView>>) -> String:
  match value:
    case None{}:"None"
    case Some{value}:"Some{" ++ access(value) ++ "}"
def ledger(value:Maybe<&2,T.LedgerView>) -> String:
  match value:
    case None{}:"None"
    case Some{view}:"Some{" ++ J.render_ledger(view) ++ "}"
def payload(value:Maybe<&2,T.PositionView>) -> String:
  match value:
    case None{}:"None"
    case Some{view}:"Some{" ++ J.render_position(view) ++ "}"
def reservation(value:Maybe<&2,W.Reservation<T.MotionSchema>>) -> String:
  match value:
    case None{}:"None"
    case Some{value}:"Some{" ++ O.reservation(value) ++ "}"
def rejected_observed(value:T.Position & String) -> String:
  match value:
    case (_,text):"Some{" ++ text ++ "}"
def rejected(value:Maybe<&1,T.Position>) -> String:
  match value:
    case None{}:"None"
    case Some{value}:rejected_observed(O.main(value))
def error(value:Maybe<&2,W.WorldError>) -> String:
  match value:
    case None{}:"None"
    case Some{reason}:"Some{" ++ O.error(reason) ++ "}"
def ping_view(value:P.ping_view()) -> String:
  match value:
    case SP.EventView{Ev.Reading{values,lagged}}:"values=" ++ List.show(&2,E.event_type(),O.event,values) ++ ";lagged=" ++ Bool.show(lagged)
def unit(_:Unit) -> String:"Unit"
def callback(~R:Data,~reading:R -> String,value:C.Output<R>) -> String:
  match value:
    case C.Output{result,read,reserved,saved,writes,resource,returned,reason,lookup}:"outcome=" ++ outcome(result) ++ ";reading={" ++ reading(read) ++ "};reservation=" ++ reservation(reserved) ++ ";payload=" ++ payload(saved) ++ ";writes=" ++ List.show(&2,Cmp.Access<T.PositionView>,access,writes) ++ ";ledger=" ++ ledger(resource) ++ ";rejected=" ++ rejected(returned) ++ ";error=" ++ error(reason) ++ ";pendingLookup=" ++ pending_lookup(lookup)
def facts(value:Inspect.Facts) -> Doc.Doc:
  match value:
    case Inspect.Facts{undo,commands,kinds,events,trace,world}:Doc.concat([Doc.text("undo="),Doc.text(Nat.show(undo)),Doc.text(";commands="),Doc.text(Nat.show(commands)),Doc.text(";kinds="),Doc.text(kinds),Doc.text(";events="),Doc.text(List.show(&2,E.event_type(),O.event,events)),Doc.text(";trace="),Doc.text(Trace.state(trace)),Doc.text(";world={"),world,Doc.text("}")])
def read(value:Reader.Read) -> Doc.Doc:
  match value:
    case Reader.Read{output,observed}:Doc.concat([Doc.text("callback={"),Doc.text(callback(~P.ping_view(),~ping_view,output)),Doc.text("};facts={"),facts(observed),Doc.text("}")])
def maybe_read(value:Maybe<&1,Reader.Read>) -> Doc.Doc:
  match value:
    case None{}:Doc.text("None")
    case Some{value}:Doc.concat([Doc.text("Some{"),read(value),Doc.text("}")])
def maybe_u32(value:Maybe<&2,U32>) -> String:
  match value:
    case None{}:"None"
    case Some{code}:"Some{" ++ U32.show(code) ++ "}"
def call(value:L.Call) -> Doc.Doc:
  match value:
    case L.ACall{result,output,observed}:Doc.concat([Doc.text("A{outcome="),Doc.text(outcome(result)),Doc.text(";callback={"),Doc.text(callback(~Unit,~unit,output)),Doc.text("};facts={"),facts(observed),Doc.text("}}")])
    case L.BCall{status,error,output}:Doc.concat([Doc.text("B{status="),Doc.text(U32.show(status)),Doc.text(";error="),Doc.text(maybe_u32(error)),Doc.text(";output="),maybe_read(output),Doc.text("}")])
def local_a(observed:Array<U32> & String) -> L.State & String:
  match observed:
    case (capture,text):(L.A{capture},"A{capture=" ++ text ++ "}")
def local_b(left:Array<U32> & String,right:Reader.Provider() & String) -> L.State & String:
  (capture,sc)=left
  (reader,sr)=right
  (L.B{capture,reader},"B{capture=" ++ sc ++ ";reader={" ++ sr ++ "}}")
def local(value:L.State) -> L.State & String:
  match value:
    case L.A{capture}:local_a(Dump.u32_array(capture))
    case L.B{capture,reader}:local_b(Dump.u32_array(capture),RO.provider(reader))
def instance_join(+namespace:U32,+id:U32,+name:String,+accesses:List<&2,String>,observed:L.State & String) -> L.Instance() & String:
  match observed:
    case (local,text):(Local.Instance{namespace,id,name,accesses,local},"namespace=" ++ U32.show(namespace) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ O.audit_effect(name) ++ ";access=" ++ List.show(&2,String,O.audit_effect,accesses) ++ ";local={" ++ text ++ "}")
def instance(value:L.Instance()) -> L.Instance() & String:
  match value:
    case Local.Instance{namespace,id,name,accesses,owner}:instance_join(namespace,id,name,accesses,local(owner))

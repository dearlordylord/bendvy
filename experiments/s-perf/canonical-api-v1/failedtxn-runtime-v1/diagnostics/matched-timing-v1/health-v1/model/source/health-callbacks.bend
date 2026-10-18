import Base
import health-audit.bend as Audit
import ../../../../src/ecs/ordinary-service-request.bend as Request
import ../dense-runtime-v1/types.bend as T
import ../dense-runtime-v1/payload.bend as P
import ../../../../src/ecs/capabilities.bend as Cap
import ../../../../src/ecs/component.bend as Cmp
import ../../../../src/ecs/transaction.bend as Tx
import ../../../../src/ecs/world.bend as W

# Authored gameplay only: no concrete World, journal, reader or service owner.
type Ops<H:Type,E:Data> is Type:
  Ops{main:(H -> W.Handle<T.HealthSchema> -> H & Cmp.Access<T.VitalsView>) & (H -> W.Handle<T.HealthSchema> -> T.Vitals -> Cmp.SetResult<H,T.Vitals>),ledger:Cap.ValueWrite<H,T.HealthLedger,T.LedgerView>,spawn:Cap.Request<H,T.Vitals,W.Reservation<T.HealthSchema>>,publish:Cap.Send<H,E>,audit:Audit.Grant(~H)}
type Args<R:Data> is Data:
  Args{target:W.Handle<T.HealthSchema>,iteration:U32,capture:U32,twice:Bool,prime:Bool,outcome:Tx.Outcome<U32>,reading:R}
type Output<R:Data> is Type:
  Output{outcome:Tx.Outcome<U32>,reading:R,reservation:Maybe<&2,W.Reservation<T.HealthSchema>>,payload:Maybe<&2,T.VitalsView>,writes:List<&2,Cmp.Access<T.VitalsView>>,ledger:Maybe<&2,T.LedgerView>,rejected:Maybe<&1,T.Vitals>,writeError:Maybe<&2,W.WorldError>,pendingLookup:Maybe<&2,Cmp.Access<T.VitalsView>>}
def read_cap(~H:Type,~E:Data,caps:Ops<H,E>) -> H -> W.Handle<T.HealthSchema> -> H & Cmp.Access<T.VitalsView>:
  match caps:
    case Ops{(read,_),_,_,_,_}:read
def write_cap(~H:Type,~E:Data,caps:Ops<H,E>) -> H -> W.Handle<T.HealthSchema> -> T.Vitals -> Cmp.SetResult<H,T.Vitals>:
  match caps:
    case Ops{(_,write),_,_,_,_}:write
def ledger_cap(~H:Type,~E:Data,caps:Ops<H,E>) -> Cap.ValueWrite<H,T.HealthLedger,T.LedgerView>:
  match caps:
    case Ops{_,ledger,_,_,_}:ledger
def spawn_cap(~H:Type,~E:Data,caps:Ops<H,E>) -> Cap.Request<H,T.Vitals,W.Reservation<T.HealthSchema>>:
  match caps:
    case Ops{_,_,spawn,_,_}:spawn
def publish_cap(~H:Type,~E:Data,caps:Ops<H,E>) -> Cap.Send<H,E>:
  match caps:
    case Ops{_,_,_,publish,_}:publish
def audit_cap(~H:Type,~E:Data,caps:Ops<H,E>) -> Audit.Grant(~H):
  match caps:
    case Ops{_,_,_,_,audit}:audit
def quad(a:U32,b:U32,c:U32,d:U32) -> Array<U32>:ANode{ANode{ALeaf{a},ALeaf{b}},ANode{ALeaf{c},ALeaf{d}}}
def first(value:T.VitalsView) -> U32:
  match value:
    case T.VitalsView{T.Four{a,_,_,_},_,_}:a
def replaced(value:T.VitalsView,x:U32) -> T.Vitals:
  match value:
    case T.VitalsView{T.Four{_,b,c,d},reserve,class}:T.Vitals{quad(x,b,c,d),reserve,class}
def ledger_replaced(value:T.LedgerView,x:U32) -> T.HealthLedger:
  match value:
    case T.LedgerView{T.Four{_,b,c,d},epoch}:T.HealthLedger{quad(x,b,c,d),epoch}
def ledger_first(value:T.LedgerView) -> U32:
  match value:
    case T.LedgerView{T.Four{a,_,_,_},_}:a
def amount(twice:Bool) -> U32:
  match twice:
    case False{}:1
    case True{}:10
def ledger_amount(twice:Bool) -> U32:
  match twice:
    case False{}:1
    case True{}:100
def part(twice:Bool,a:U32,b:U32) -> U32:
  match twice:
    case False{}:a
    case True{}:b
def who(twice:Bool) -> String:
  match twice:
    case False{}:"A"
    case True{}:"B"
def audit_text(~R:Data,+args:Args<R>) -> String:
  match args:
    case Args{_,iteration,capture,twice,_,_,_}:"{\"who\":\"" ++ who(twice) ++ "\",\"iteration\":" ++ U32.show(iteration) ++ ",\"capture\":" ++ U32.show(capture) ++ "}"
def output(~R:Data,+args:Args<R>,reservation:Maybe<&2,W.Reservation<T.HealthSchema>>,payload:Maybe<&2,T.VitalsView>,writes:List<&2,Cmp.Access<T.VitalsView>>,ledger:Maybe<&2,T.LedgerView>) -> Output<R>:
  match args:
    case Args{_,_,_,_,_,outcome,reading}:Output{outcome,reading,reservation,payload,writes,ledger,None{},None{},None{}}
def output_reading(~R:Data,+args:Args<R>) -> R:
  match args:
    case Args{_,_,_,_,_,_,reading}:reading
def target(~R:Data,args:Args<R>) -> W.Handle<T.HealthSchema>:
  match args:
    case Args{target,_,_,_,_,_,_}:target
def get(~H:Type,~E:Data,~R:Data,~caps:Ops<H,E>,args:Args<R>,owner:H) -> H & Cmp.Access<T.VitalsView>:
  read_cap(~H,~E,caps)(owner,target(~R,args))
def set(~H:Type,~E:Data,~R:Data,~caps:Ops<H,E>,args:Args<R>,owner:H,payload:T.Vitals) -> Cmp.SetResult<H,T.Vitals>:
  write_cap(~H,~E,caps)(owner,target(~R,args),payload)
def with_lookup(~R:Data,value:Output<R>,lookup:Maybe<&2,Cmp.Access<T.VitalsView>>) -> Output<R>:
  match value:
    case Output{outcome,reading,reservation,payload,writes,ledger,rejected,error,_}:Output{outcome,reading,reservation,payload,writes,ledger,rejected,error,lookup}
def audited(~H:Type,~R:Data,+args:Args<R>,reservation:W.Reservation<T.HealthSchema>,payload:T.VitalsView,writes:List<&2,Cmp.Access<T.VitalsView>>,ledger:T.LedgerView,lookup:Maybe<&2,Cmp.Access<T.VitalsView>>,returned:H & Request.RequestResult<String,Unit>) -> H & Output<R>:
  match returned:
    case (owner,Request.Called{_}):(owner,with_lookup(~R,output(~R,args,Some{reservation},Some{payload},writes,Some{ledger}),lookup))
    case (owner,Request.Unavailable{_}):(owner,with_lookup(~R,Output{Tx.Failure{9},output_reading(~R,args),Some{reservation},Some{payload},writes,Some{ledger},None{},None{},None{}},lookup))
def pending_seen(~H:Type,~E:Data,~R:Data,~caps:Ops<H,E>,~make_event:U32 -> E,+args:Args<R>,reservation:W.Reservation<T.HealthSchema>,payload:T.VitalsView,writes:List<&2,Cmp.Access<T.VitalsView>>,ledger:T.LedgerView,event:E,observed:H & Cmp.Access<T.VitalsView>) -> H & Output<R>:
  match observed:
    case (owner,lookup):audited(~H,~R,args,reservation,payload,writes,ledger,Some{lookup},Request.request(~T.HealthSchema,~String,~Unit,~Audit.identity(),~H,~audit_cap(~H,~E,caps),Cap.send(~H,~E,~publish_cap(~H,~E,caps),owner,event),audit_text(~R,args)))
def reserved(~H:Type,~E:Data,~R:Data,~caps:Ops<H,E>,~make_event:U32 -> E,+args:Args<R>,payload:T.VitalsView,writes:List<&2,Cmp.Access<T.VitalsView>>,ledger:T.LedgerView,event:E,returned:H & W.Reservation<T.HealthSchema>) -> H & Output<R>:
  match returned:
    case (owner,W.Reserved{+handle}):pending_seen(~H,~E,~R,~caps,~make_event,args,W.Reserved{handle},payload,writes,ledger,event,read_cap(~H,~E,caps)(owner,handle))
    case (owner,W.ReservationRejected{reason}):audited(~H,~R,args,W.ReservationRejected{reason},payload,writes,ledger,None{},Request.request(~T.HealthSchema,~String,~Unit,~Audit.identity(),~H,~audit_cap(~H,~E,caps),Cap.send(~H,~E,~publish_cap(~H,~E,caps),owner,event),audit_text(~R,args)))
def spawn_observed(~H:Type,~E:Data,~R:Data,~caps:Ops<H,E>,~make_event:U32 -> E,+args:Args<R>,writes:List<&2,Cmp.Access<T.VitalsView>>,ledger:T.LedgerView,event:E,owner:H,observed:T.Vitals & T.VitalsView) -> H & Output<R>:
  match observed:
    case (payload,view):reserved(~H,~E,~R,~caps,~make_event,args,view,writes,ledger,event,Cap.request(~H,~T.Vitals,~W.Reservation<T.HealthSchema>,~spawn_cap(~H,~E,caps),owner,payload))
def spawn_parts(~H:Type,~E:Data,~R:Data,~caps:Ops<H,E>,~make_event:U32 -> E,+args:Args<R>,writes:List<&2,Cmp.Access<T.VitalsView>>,ledger:T.LedgerView,+iteration:U32,+twice:Bool,owner:H) -> H & Output<R>:
  +b=part(twice,20,200)
  +c=part(twice,30,300)
  +d=part(twice,40,400)
  spawn_observed(~H,~E,~R,~caps,~make_event,args,writes,ledger,make_event(U32.add(U32.mul(iteration,2),part(twice,0,1))),owner,P.vitals_get(T.Vitals{quad(iteration,b,c,d),9,2}))
def spawn(~H:Type,~E:Data,~R:Data,~caps:Ops<H,E>,~make_event:U32 -> E,+args:Args<R>,writes:List<&2,Cmp.Access<T.VitalsView>>,ledger:T.LedgerView,owner:H) -> H & Output<R>:
  match args:
    case Args{+target,+iteration,+capture,+twice,+prime,+outcome,+reading}:spawn_parts(~H,~E,~R,~caps,~make_event,Args{target,iteration,capture,twice,prime,outcome,reading},writes,ledger,iteration,twice,owner)
def ledger_after(~H:Type,~E:Data,~R:Data,~caps:Ops<H,E>,~make_event:U32 -> E,+args:Args<R>,writes:List<&2,Cmp.Access<T.VitalsView>>,returned:H & T.LedgerView) -> H & Output<R>:
  match returned:
    case (owner,ledger):spawn(~H,~E,~R,~caps,~make_event,args,writes,ledger,owner)
def ledger_before(~H:Type,~E:Data,~R:Data,~caps:Ops<H,E>,~make_event:U32 -> E,+args:Args<R>,writes:List<&2,Cmp.Access<T.VitalsView>>,amount:U32,returned:H & T.LedgerView) -> H & Output<R>:
  match returned:
    case (owner,+ledger):ledger_after(~H,~E,~R,~caps,~make_event,args,writes,Cap.value_get(~H,~T.HealthLedger,~T.LedgerView,~ledger_cap(~H,~E,caps),Cap.value_set(~H,~T.HealthLedger,~T.LedgerView,~ledger_cap(~H,~E,caps),owner,ledger_replaced(ledger,U32.add(ledger_first(ledger),amount)))))
def after_second(~H:Type,~E:Data,~R:Data,~caps:Ops<H,E>,~make_event:U32 -> E,+args:Args<R>,writes:List<&2,Cmp.Access<T.VitalsView>>,amount:U32,returned:H & Cmp.Access<T.VitalsView>) -> H & Output<R>:
  match returned:
    case (owner,view):ledger_before(~H,~E,~R,~caps,~make_event,args,List.append(&2,Cmp.Access<T.VitalsView>,writes,[view]),amount,Cap.value_get(~H,~T.HealthLedger,~T.LedgerView,~ledger_cap(~H,~E,caps),owner))
def second_written(~H:Type,~E:Data,~R:Data,~caps:Ops<H,E>,~make_event:U32 -> E,+args:Args<R>,writes:List<&2,Cmp.Access<T.VitalsView>>,result:Cmp.SetResult<H,T.Vitals>) -> H & Output<R>:
  match result:
    case Cmp.Written{owner}:after_second(~H,~E,~R,~caps,~make_event,args,writes,100,get(~H,~E,~R,~caps,args,owner))
    case Cmp.WriteRejected{owner,incoming,error}:(owner,Output{Tx.Failure{10},output_reading(~R,args),None{},None{},writes,None{},Some{incoming},Some{error},None{}})
    case Cmp.WriteFailure{owner,error}:(owner,Output{Tx.Failure{10},output_reading(~R,args),None{},None{},writes,None{},None{},Some{error},None{}})
def maybe_second(~H:Type,~E:Data,~R:Data,~caps:Ops<H,E>,~make_event:U32 -> E,+args:Args<R>,+old:T.VitalsView,writes:List<&2,Cmp.Access<T.VitalsView>>,twice:Bool,owner:H) -> H & Output<R>:
  match twice:
    case False{}:ledger_before(~H,~E,~R,~caps,~make_event,args,writes,1,Cap.value_get(~H,~T.HealthLedger,~T.LedgerView,~ledger_cap(~H,~E,caps),owner))
    case True{}:second_written(~H,~E,~R,~caps,~make_event,args,writes,set(~H,~E,~R,~caps,args,owner,replaced(old,U32.add(first(old),30))))
def after_first(~H:Type,~E:Data,~R:Data,~caps:Ops<H,E>,~make_event:U32 -> E,+args:Args<R>,old:T.VitalsView,twice:Bool,returned:H & Cmp.Access<T.VitalsView>) -> H & Output<R>:
  match returned:
    case (owner,view):maybe_second(~H,~E,~R,~caps,~make_event,args,old,[view],twice,owner)
def first_written(~H:Type,~E:Data,~R:Data,~caps:Ops<H,E>,~make_event:U32 -> E,+args:Args<R>,old:T.VitalsView,twice:Bool,result:Cmp.SetResult<H,T.Vitals>) -> H & Output<R>:
  match result:
    case Cmp.Written{owner}:after_first(~H,~E,~R,~caps,~make_event,args,old,twice,get(~H,~E,~R,~caps,args,owner))
    case Cmp.WriteRejected{owner,incoming,error}:(owner,Output{Tx.Failure{10},output_reading(~R,args),None{},None{},[],None{},Some{incoming},Some{error},None{}})
    case Cmp.WriteFailure{owner,error}:(owner,Output{Tx.Failure{10},output_reading(~R,args),None{},None{},[],None{},None{},Some{error},None{}})
def initial(~H:Type,~E:Data,~R:Data,~caps:Ops<H,E>,~make_event:U32 -> E,+args:Args<R>,+twice:Bool,returned:H & Cmp.Access<T.VitalsView>) -> H & Output<R>:
  match returned:
    case (owner,Cmp.Found{+old}):first_written(~H,~E,~R,~caps,~make_event,args,old,twice,set(~H,~E,~R,~caps,args,owner,replaced(old,U32.add(first(old),amount(twice)))))
    case (owner,_):(owner,Output{Tx.Failure{8},output_reading(~R,args),None{},None{},[],None{},None{},None{},None{}})
def chosen(~H:Type,~E:Data,~R:Data,~caps:Ops<H,E>,~make_event:U32 -> E,+args:Args<R>,prime:Bool,twice:Bool,owner:H) -> H & Output<R>:
  match prime:
    case True{}:(owner,output(~R,args,None{},None{},[],None{}))
    case False{}:initial(~H,~E,~R,~caps,~make_event,args,twice,get(~H,~E,~R,~caps,args,owner))
def body(~H:Type,~E:Data,~R:Data,~caps:Ops<H,E>,~make_event:U32 -> E,+args:Args<R>,owner:H) -> H & Output<R>:
  match args:
    case Args{+target,+iteration,+capture,+twice,+prime,+outcome,+reading}:chosen(~H,~E,~R,~caps,~make_event,Args{target,iteration,capture,twice,prime,outcome,reading},prime,twice,owner)

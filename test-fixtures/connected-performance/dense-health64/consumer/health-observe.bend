import Base
import ../../../../src/ecs/ordinary-app-execution-recipe.bend as Exec
import ../../../../src/ecs/ordinary-app-records.bend as Leaf
import ../../../../src/ecs/ordinary-app-registration-fields.bend as Fields
import health-logical.bend as Logical
import ../../dense-motion64/consumer/s-perf/canonical-api-v1/dense-runtime-v1/render.bend as JSON
import ../../../../src/ecs/inspector-query-projection.bend as Projection
import ../../../../src/ecs/inspector-query.bend as IQ
import ../../../../src/ecs/component.bend as Cmp
import health.bend as F
import health-driver.bend as Driver
import ../../dense-motion64/consumer/s-perf/canonical-api-v1/dense-runtime-v1/types.bend as T
import ../../dense-motion64/consumer/public-audit61/app-a-current-carrier-v1/owner-observer.bend as Dump
import ../../dense-motion64/consumer/public-audit61/app-a-current-carrier-v1/allocator-observer.bend as Gen
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/owner-product.bend as Product
import ../../../../src/ecs/ordinary-query-declaration.bend as Decl
import ../../../../src/ecs/compose.bend as Q
import ../../../../src/ecs/transaction.bend as Tx
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/deferred-command.bend as Deferred
import ../../../../src/ecs/entity-allocator.bend as Alloc
import ../../../../src/ecs/entity-key.bend as Key
def main_joined(+reserve:U32,+class:U32,observed:Array<U32> & String) -> T.Vitals & String:
  match observed:
    case (values,text):(T.Vitals{values,reserve,class},"Vitals{" ++ text ++ ";" ++ U32.show(reserve) ++ "," ++ U32.show(class) ++ "}")
def main(owner:T.Vitals) -> T.Vitals & String:
  match owner:
    case T.Vitals{values,reserve,class}:main_joined(reserve,class,Dump.u32_array(values))
def aux_joined(+grade:U32,observed:Array<U32> & String) -> T.Armor & String:
  match observed:
    case (values,text):(T.Armor{values,grade},"Armor{" ++ text ++ ";" ++ U32.show(grade) ++ "}")
def aux(owner:T.Armor) -> T.Armor & String:
  match owner:
    case T.Armor{values,grade}:aux_joined(grade,Dump.u32_array(values))
def ledger_joined(+epoch:U32,observed:Array<U32> & String) -> T.HealthLedger & String:
  match observed:
    case (values,text):(T.HealthLedger{values,epoch},"HealthLedger{" ++ text ++ ";" ++ U32.show(epoch) ++ "}")
def ledger(owner:T.HealthLedger) -> T.HealthLedger & String:
  match owner:
    case T.HealthLedger{values,epoch}:ledger_joined(epoch,Dump.u32_array(values))
def flag_copy(+value:T.Tracked) -> T.Tracked & String:
  match value:
    case T.Tracked{+group}:(T.Tracked{group},"Tracked{" ++ U32.show(group) ++ "}")
def flag(value:T.Tracked) -> T.Tracked & String:flag_copy(value)
def store_join(left:Col.Column<T.HealthSchema,T.Vitals> & String,middle:Col.Column<T.HealthSchema,T.Armor> & String,right:Col.Column<T.HealthSchema,T.Tracked> & String) -> F.Store() & String:
  (main,sm)=left
  (aux,sa)=middle
  (flag,sf)=right
  (Product.Owner{main,Product.Owner{aux,flag}},"main={" ++ sm ++ "};aux={" ++ sa ++ "};flag={" ++ sf ++ "}")
def store(owner:F.Store()) -> F.Store() & String:
  match owner:
    case Product.Owner{mc,Product.Owner{ac,fc}}:store_join(Dump.column(~T.HealthSchema,~T.Vitals,~main,mc),Dump.column(~T.HealthSchema,~T.Armor,~aux,ac),Dump.column(~T.HealthSchema,~T.Tracked,~flag,fc))
def resources_join(unit:Unit,observed:T.HealthLedger & String) -> F.Resources() & String:
  match observed:
    case (value,text):(Product.Owner{value,unit},text ++ ";sibling=Unit")
def resources(owner:F.Resources()) -> F.Resources() & String:
  match owner:
    case Product.Owner{value,unit}:resources_join(unit,ledger(value))
def world_join(+namespace:U32,+events:List<&2,Nat>,+registrations:List<&2,W.RegistrationMeta>,+nextSystem:U32,+clock:U32,observedAllocator:Alloc.Allocator & String,observedStore:F.Store() & String,observedResource:F.Resources() & String,observedPending:List<Deferred.Command<F.World()>> & (Nat & String)) -> F.World() & String:
  (allocator,sa)=observedAllocator
  (store,ss)=observedStore
  (resource,sr)=observedResource
  (pending,(count,kinds))=observedPending
  (W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystem,clock},"namespace=" ++ U32.show(namespace) ++ "|allocator={" ++ sa ++ "}|store={" ++ ss ++ "}|resource={" ++ sr ++ "}|events=" ++ List.show(&2,Nat,Nat.show,events) ++ "|pending=" ++ Nat.show(count) ++ ":" ++ kinds ++ "|registrations=" ++ List.show(&2,W.RegistrationMeta,Dump.registration,registrations) ++ "|nextSystem=" ++ U32.show(nextSystem) ++ "|clock=" ++ U32.show(clock))
def world(owner:F.World()) -> F.World() & String:
  match owner:
    case W.World{namespace,allocator,stored,resource,events,pending,registrations,nextSystem,clock}:world_join(namespace,events,registrations,nextSystem,clock,Gen.allocator(allocator),store(stored),resources(resource),Dump.callbacks(~F.World(),~F.World(),pending))
def mode(value:Decl.Mode) -> String:
  match value:
    case Decl.Read{}:"Read"
    case Decl.Write{}:"Write"
    case Decl.Optional{}:"Optional"
    case Decl.With{}:"With"
    case Decl.Without{}:"Without"
    case Decl.Added{}:"Added"
    case Decl.Changed{}:"Changed"
def clause(value:Decl.Clause<T.HealthSchema>) -> String:
  match value:
    case Decl.Clause{key,value}:key ++ ":" ++ mode(value)
def owner_fields(token:Fields.Token<Driver.Registry()>,args:Unit,outputs:List<&2,U32>,fields:Fields.Fields<T.HealthSchema>) -> Driver.Owner() & String:
  match fields:
    case Fields.Fields{+ns,+id,+name,+access,+cursor,+slot,+clauses,+kind}:(Exec.Invocation{Leaf.Record{token,Fields.Fields{ns,id,name,access,cursor,slot,clauses,kind}},args,outputs},"ns=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";access=" ++ List.show(&2,String,x=>x,access) ++ ";cursor=" ++ U32.show(cursor) ++ ";slot=" ++ slot ++ ";clauses=" ++ List.show(&2,Decl.Clause<T.HealthSchema>,clause,clauses))
def owner(value:Driver.Owner()) -> Driver.Owner() & String:
  match value:
    case Exec.Invocation{Leaf.Record{token,+fields},args,outputs}:owner_fields(token,args,outputs,fields)
def error(value:W.WorldError) -> String:
  match value:
    case W.MissingEntity{}:"MissingEntity"
    case W.CapacityExceeded{}:"CapacityExceeded"
    case W.NamespaceExhausted{}:"NamespaceExhausted"
    case W.SystemIdExhausted{}:"SystemIdExhausted"
def status(value:Driver.Status) -> String:
  match value:
    case Driver.Succeeded{}:"Succeeded"
    case Driver.Failed{Q.UserError{_}}:"UserError(Unit)"
    case Driver.Failed{Q.AccessError{reason}}:"AccessError(" ++ error(reason) ++ ")"
    case Driver.Rejected{cursor}:"RegistrationRejected(" ++ U32.show(cursor) ++ ")"
def audit(value:Driver.Audit) -> String:
  match value:
    case Driver.Audit{values,total,count}:"values=" ++ List.show(&2,U32,U32.show,values) ++ ";readsum=" ++ U32.show(total) ++ ";updated=" ++ Nat.show(count)
def state_join(+audits:List<&2,Driver.Audit>,+statuses:List<&2,Driver.Status>,world:F.World() & String,owner:Driver.Owner() & String) -> Driver.View & String:
  (world,sw)=world
  (owner,so)=owner
  (Driver.View{world,owner,audits,statuses},"world={" ++ sw ++ "}|owner={" ++ so ++ "}|audit=" ++ List.show(&2,Driver.Audit,audit,audits) ++ "|statuses=" ++ List.show(&2,Driver.Status,status,statuses))
def state_view(value:Driver.View) -> Driver.View & String:
  match value:
    case Driver.View{w,o,audit,statuses}:state_join(audit,statuses,world(w),owner(o))
def handle(value:W.Handle<T.HealthSchema>) -> String:
  match value:
    case W.Handle{ns,Key.EntityKey{index,generation}}:U32.show(ns) ++ ":" ++ U32.show(index) ++ ":" ++ U32.show(generation)
def reservation(value:W.Reservation<T.HealthSchema>) -> String:
  match value:
    case W.Reserved{id}:"Reserved(" ++ handle(id) ++ ")"
    case W.ReservationRejected{reason}:"ReservationRejected(" ++ error(reason) ++ ")"
def outcome(value:Tx.Outcome<Unit>) -> String:
  match value:
    case Tx.Success{}:"Success"
    case Tx.Failure{_}:"Failure(Unit)"

def access(~V:Data,~show:V -> String,value:Cmp.Access<V>) -> String:
  match value:
    case Cmp.Found{value}:"Found(" ++ show(value) ++ ")"
    case Cmp.ComponentAbsent{}:"ComponentAbsent"
    case Cmp.MissingEntity{}:"MissingEntity"
def row(value:IQ.ProjectedRow<T.HealthSchema,Logical.Value()>) -> String:
  match value:
    case IQ.ProjectedRow{entity,Projection.Product{main,Projection.Product{aux,flag}}}:"handle=" ++ handle(entity) ++ ";main=" ++ access(~T.VitalsView,~JSON.render_vitals,main) ++ ";aux=" ++ access(~T.ArmorView,~JSON.render_armor,aux) ++ ";flag=" ++ access(~T.Tracked,~JSON.render_tracked,flag)
def rows_observed(observed:F.World() & Logical.Rows()) -> F.World() & String:
  match observed:
    case (world,rows):(world,List.show(&2,IQ.ProjectedRow<T.HealthSchema,Logical.Value()>,row,rows))
def rows(world:F.World()) -> F.World() & String:rows_observed(Logical.rows(world))

def state(value:Driver.State) -> Driver.State & String:Driver.inspect(~String,state_view,value)

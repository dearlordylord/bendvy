import Base
import tx-metrics.bend as Metrics
import motion-logical.bend as Logical
import render.bend as JSON
import ../private/src/ecs/inspector-query-projection.bend as Projection
import ../private/src/ecs/inspector-query.bend as IQ
import ../private/src/ecs/component.bend as Cmp
import motion.bend as F
import motion-driver.bend as Driver
import types.bend as T
import ../private/experiments/public-audit61/app-a-current-carrier-v1/owner-observer.bend as Dump
import ../private/experiments/public-audit61/app-a-current-carrier-v1/allocator-observer.bend as Gen
import ../private/src/ecs/world.bend as W
import ../private/src/ecs/owner-product.bend as Product
import ../private/src/ecs/ordinary-system.bend as Ordinary
import ../private/src/ecs/system.bend as Sys
import ../private/src/ecs/ordinary-query-declaration.bend as Decl
import ../private/src/ecs/compose.bend as Q
import ../private/src/ecs/transaction.bend as Tx
import ../private/src/ecs/column.bend as Col
import ../private/src/ecs/deferred-command.bend as Deferred
import ../private/src/ecs/entity-allocator.bend as Alloc
import ../private/src/ecs/entity-key.bend as Key
def main_joined(+frame:U32,observed:Array<U32> & String) -> T.Position & String:
  match observed:
    case (values,text):(T.Position{values,frame},"Position{" ++ text ++ ";" ++ U32.show(frame) ++ "}")
def main(owner:T.Position) -> T.Position & String:
  match owner:
    case T.Position{values,frame}:main_joined(frame,Dump.u32_array(values))
def aux_joined(+moving:Bool,observed:Array<U32> & String) -> T.Velocity & String:
  match observed:
    case (values,text):(T.Velocity{values,moving},"Velocity{" ++ text ++ ";" ++ Bool.show(moving) ++ "}")
def aux(owner:T.Velocity) -> T.Velocity & String:
  match owner:
    case T.Velocity{values,moving}:aux_joined(moving,Dump.u32_array(values))
def ledger_joined(+epoch:U32,observed:Array<U32> & String) -> T.MotionLedger & String:
  match observed:
    case (values,text):(T.MotionLedger{values,epoch},"MotionLedger{" ++ text ++ ";" ++ U32.show(epoch) ++ "}")
def ledger(owner:T.MotionLedger) -> T.MotionLedger & String:
  match owner:
    case T.MotionLedger{values,epoch}:ledger_joined(epoch,Dump.u32_array(values))
def flag_copy(+value:T.Selected) -> T.Selected & String:
  match value:
    case T.Selected{+group}:(T.Selected{group},"Selected{" ++ U32.show(group) ++ "}")
def flag(value:T.Selected) -> T.Selected & String:flag_copy(value)
def store_join(left:Col.Column<T.MotionSchema,T.Position> & String,middle:Col.Column<T.MotionSchema,T.Velocity> & String,right:Col.Column<T.MotionSchema,T.Selected> & String) -> F.Store() & String:
  (main,sm)=left
  (aux,sa)=middle
  (flag,sf)=right
  (Product.Owner{main,Product.Owner{aux,flag}},"main={" ++ sm ++ "};aux={" ++ sa ++ "};flag={" ++ sf ++ "}")
def store(owner:F.Store()) -> F.Store() & String:
  match owner:
    case Product.Owner{mc,Product.Owner{ac,fc}}:store_join(Dump.column(~T.MotionSchema,~T.Position,~main,mc),Dump.column(~T.MotionSchema,~T.Velocity,~aux,ac),Dump.column(~T.MotionSchema,~T.Selected,~flag,fc))
def resources_join(unit:Unit,observed:T.MotionLedger & String) -> F.Resources() & String:
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
def clause(value:Decl.Clause<T.MotionSchema>) -> String:
  match value:
    case Decl.Clause{key,value}:key ++ ":" ++ mode(value)
def owner(value:F.Owner()) -> F.Owner() & String:
  match value:
    case Ordinary.Owner{Sys.Registry{+ns,+id,+name,+access,+cursor},+slot,+clauses}:(Ordinary.Owner{Sys.Registry{ns,id,name,access,cursor},slot,clauses},"ns=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";access=" ++ List.show(&2,String,x=>x,access) ++ ";cursor=" ++ U32.show(cursor) ++ ";slot=" ++ slot ++ ";clauses=" ++ List.show(&2,Decl.Clause<T.MotionSchema>,clause,clauses))
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
def state_join(samples:List<&2,Metrics.Sample>,+audits:List<&2,Driver.Audit>,+statuses:List<&2,Driver.Status>,world:F.World() & String,owner:F.Owner() & String) -> Driver.View & String:
  (world,sw)=world
  (owner,so)=owner
  (Driver.View{world,owner,audits,statuses,samples},"world={" ++ sw ++ "}|owner={" ++ so ++ "}|audit=" ++ List.show(&2,Driver.Audit,audit,audits) ++ "|statuses=" ++ List.show(&2,Driver.Status,status,statuses))
def state_view(value:Driver.View) -> Driver.View & String:
  match value:
    case Driver.View{w,o,audit,statuses,samples}:state_join(samples,audit,statuses,world(w),owner(o))
def handle(value:W.Handle<T.MotionSchema>) -> String:
  match value:
    case W.Handle{ns,Key.EntityKey{index,generation}}:U32.show(ns) ++ ":" ++ U32.show(index) ++ ":" ++ U32.show(generation)
def reservation(value:W.Reservation<T.MotionSchema>) -> String:
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
def row(value:IQ.ProjectedRow<T.MotionSchema,Logical.Value()>) -> String:
  match value:
    case IQ.ProjectedRow{entity,Projection.Product{main,Projection.Product{aux,flag}}}:"handle=" ++ handle(entity) ++ ";main=" ++ access(~T.PositionView,~JSON.render_position,main) ++ ";aux=" ++ access(~T.VelocityView,~JSON.render_velocity,aux) ++ ";flag=" ++ access(~T.Selected,~JSON.render_selected,flag)
def rows_observed(observed:F.World() & Logical.Rows()) -> F.World() & String:
  match observed:
    case (world,rows):(world,List.show(&2,IQ.ProjectedRow<T.MotionSchema,Logical.Value()>,row,rows))
def rows(world:F.World()) -> F.World() & String:rows_observed(Logical.rows(world))

def state(value:Driver.State) -> Driver.State & String:Driver.inspect(~state_view,value)

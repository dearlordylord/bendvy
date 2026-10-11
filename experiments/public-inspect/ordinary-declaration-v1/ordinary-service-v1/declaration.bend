import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as Fragment
# One operational binding supplies identity, slot ownership, availability and call.
# No host IO, sharing, cleanup or callback-failure recovery contract is added.
type Slot<P:Type> is Type:
  Missing{}
  Ready{owner:P}
type Declaration<-S:Data,-R:Type,-P:Type,-Rest:Type,-take:R -> Rest & Slot<P>,-put:Rest -> Slot<P> -> R,-call:P -> P> is Data:
  Declaration{id:U32,key:String}
type Status<S:Data> is Data:
  Status{id:U32,key:String,provided:Bool}
def declare(~S:Data,~R:Type,~P:Type,~Rest:Type,~take:R -> Rest & Slot<P>,~put:Rest -> Slot<P> -> R,~call:P -> P,id:U32,key:String) -> Declaration<S,R,P,Rest,take,put,call>:
  Declaration{id,key}
def requirement(~S:Data,~R:Type,~P:Type,~Rest:Type,~take:R -> Rest & Slot<P>,~put:Rest -> Slot<P> -> R,~call:P -> P,value:Declaration<S,R,P,Rest,take,put,call>) -> SP.Requirement<S>:
  match value:
    case Declaration{id,_}:SP.Service{id}
def entry(~S:Data,~R:Type,~P:Type,~Rest:Type,~take:R -> Rest & Slot<P>,~put:Rest -> Slot<P> -> R,~call:P -> P,value:Declaration<S,R,P,Rest,take,put,call>) -> Fragment.Entry<S>:
  match value:
    case Declaration{_,+key}:Fragment.Entry{Fragment.Service{},key,key}
def key(~S:Data,~R:Type,~P:Type,~Rest:Type,~take:R -> Rest & Slot<P>,~put:Rest -> Slot<P> -> R,~call:P -> P,value:Declaration<S,R,P,Rest,take,put,call>) -> String:
  match value:
    case Declaration{_,key}:key
def slot_observed(~S:Data,~R:Type,~P:Type,~Rest:Type,~take:R -> Rest & Slot<P>,~put:Rest -> Slot<P> -> R,~call:P -> P,declaration:Declaration<S,R,P,Rest,take,put,call>,value:Rest & Slot<P>) -> R & Status<S>:
  match declaration value:
    case Declaration{+id,+key}, (rest,Missing{}):(put(rest,Missing{}),Status{id,key,False{}})
    case Declaration{+id,+key}, (rest,Ready{owner}):(put(rest,Ready{owner}),Status{id,key,True{}})
def world_restored(~S:Data,~C:Type,~R:Type,~E:Data,+ns:U32,+next:U32,+high:U32,live:Array<Bool>,+cap:U32,+depth:Nat,store:C,+events:List<&2,E>,pending:List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,+registrations:List<&2,W.RegistrationMeta>,+nextSystem:U32,+clock:U32,value:R & Status<S>) -> W.World<S,C,R,E> & List<&2,Status<S>>:
  match value:
    case (resource,status):(W.World{ns,next,high,live,cap,depth,store,resource,events,pending,registrations,nextSystem,clock},[status])
def world_observed(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~take:R -> Rest & Slot<P>,~put:Rest -> Slot<P> -> R,~call:P -> P,declaration:Declaration<S,R,P,Rest,take,put,call>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & List<&2,Status<S>>:
  match world:
    case W.World{+ns,+next,+high,live,+cap,+depth,store,resource,+events,pending,+registrations,+nextSystem,+clock}:world_restored(~S,~C,~R,~E,ns,next,high,live,cap,depth,store,events,pending,registrations,nextSystem,clock,slot_observed(~S,~R,~P,~Rest,~take,~put,~call,declaration,take(resource)))
type Setup<S:Data,C:Type,R:Type,E:Data,-scan:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,Status<S>>> is Data:
  Setup{entries:List<&2,Fragment.Entry<S>>}
def single(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~take:R -> Rest & Slot<P>,~put:Rest -> Slot<P> -> R,~call:P -> P,~declaration:Declaration<S,R,P,Rest,take,put,call>) -> Setup<S,C,R,E,world_observed(~S,~C,~R,~E,~P,~Rest,~take,~put,~call,declaration)>:
  Setup{[entry(~S,~R,~P,~Rest,~take,~put,~call,declaration)]}
def scan_join(~S:Data,~C:Type,~R:Type,~E:Data,first:List<&2,Status<S>>,second:W.World<S,C,R,E> & List<&2,Status<S>>) -> W.World<S,C,R,E> & List<&2,Status<S>>:
  match second:
    case (world,statuses):(world,List.append(&2,Status<S>,first,statuses))
def scan_next(~S:Data,~C:Type,~R:Type,~E:Data,~right:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,Status<S>>,value:W.World<S,C,R,E> & List<&2,Status<S>>) -> W.World<S,C,R,E> & List<&2,Status<S>>:
  match value:
    case (world,statuses):scan_join(~S,~C,~R,~E,statuses,right(world))
def scan_pair(~S:Data,~C:Type,~R:Type,~E:Data,~left:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,Status<S>>,~right:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,Status<S>>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & List<&2,Status<S>>:
  scan_next(~S,~C,~R,~E,~right,left(world))
def append(~S:Data,~C:Type,~R:Type,~E:Data,~left:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,Status<S>>,~right:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,Status<S>>,a:Setup<S,C,R,E,left>,b:Setup<S,C,R,E,right>) -> Setup<S,C,R,E,scan_pair(~S,~C,~R,~E,~left,~right)>:
  match a b:
    case Setup{a} Setup{b}:Setup{List.append(&2,Fragment.Entry<S>,a,b)}
def available_next(~S:Data,provided:Bool,id:U32,rest:List<&2,SP.Requirement<S>>) -> List<&2,SP.Requirement<S>>:
  match provided:
    case False{}:rest
    case True{}:SP.Service{id} <> rest
def available(~S:Data,statuses:List<&2,Status<S>>) -> List<&2,SP.Requirement<S>>:
  match statuses:
    case []:[]
    case Status{id,_,provided} <> rest:available_next(~S,provided,id,available(~S,rest))
def provisioned(~S:Data,~C:Type,~R:Type,~E:Data,value:W.World<S,C,R,E> & List<&2,Status<S>>) -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>:
  match value:
    case (world,statuses):(world,available(~S,statuses))
def provision(~S:Data,~C:Type,~R:Type,~E:Data,~scan:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,Status<S>>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>:
  provisioned(~S,~C,~R,~E,scan(world))
def slot_called(~R:Type,~P:Type,~Rest:Type,~put:Rest -> Slot<P> -> R,~call:P -> P,value:Rest & Slot<P>) -> R:
  match value:
    case (rest,Missing{}):put(rest,Missing{})
    case (rest,Ready{owner}):put(rest,Ready{call(owner)})
def runner(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~take:R -> Rest & Slot<P>,~put:Rest -> Slot<P> -> R,~call:P -> P,~declaration:Declaration<S,R,P,Rest,take,put,call>,world:W.World<S,C,R,E>,_:Unit) -> Sys.Outcome<W.World<S,C,R,E>,Unit,Unit>:
  match world:
    case W.World{+ns,+next,+high,live,+cap,+depth,store,resource,+events,pending,+registrations,+nextSystem,+clock}:Sys.Succeeded{W.World{ns,next,high,live,cap,depth,store,slot_called(~R,~P,~Rest,~put,~call,take(resource)),events,pending,registrations,nextSystem,clock},Unit{}}
def define(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~take:R -> Rest & Slot<P>,~put:Rest -> Slot<P> -> R,~call:P -> P,~declaration:Declaration<S,R,P,Rest,take,put,call>,world:W.World<S,C,R,E>,name:String) -> Sys.RegistrationResult<S,C,R,E,Unit,Unit,Unit,runner(~S,~C,~R,~E,~P,~Rest,~take,~put,~call,~declaration)>:
  Sys.register(~S,~C,~R,~E,~Unit,~Unit,~Unit,~runner(~S,~C,~R,~E,~P,~Rest,~take,~put,~call,~declaration),world,name,[key(~S,~R,~P,~Rest,~take,~put,~call,declaration)])

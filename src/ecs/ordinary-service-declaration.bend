import Base
import ./clock-state.bend as Clock
import ./deferred-command.bend as Deferred
import entity-allocator.bend as Alloc
import ./world.bend as W
import ./system.bend as Sys
import ./schedule.bend as Sch
import ./schedule-provision.bend as SP
import ./schema-fragments.bend as Fragment
# One operational binding supplies identity, slot ownership, availability and call.
# No host IO, sharing, cleanup or callback-failure recovery contract is added.
# Actual service payload ownership: Missing has no P; Ready retains affine P.
# This is provisioned resource state, not proof that external host IO will succeed.
type Slot<P:Type> is Type:
  Missing{}
  Ready{owner:P}
# Trusted service binding joins id/key with one resource slot lens and P -> P call.
# The same binding drives requirements, availability and invocation; strings alone
# do not grant arbitrary host access. take/put/call must thread actual owners.
type Declaration<-S:Data,-R:Type,-P:Type,-Rest:Type,-take:R -> Rest & Slot<P>,-put:Rest -> Slot<P> -> R,-call:P -> P> is Data:
  Declaration{id:U32,key:String}
# Detached availability observation from the slot: provided means Ready was seen,
# not that a host operation was tested, completed or made rollback-safe.
type Status<S:Data> is Data:
  Status{id:U32,key:String,provided:Bool}
# Retain a service identity with closed operational adapters. Does not install P,
# validate external availability or register a runner. Caller-authored adapters
# remain trusted; no sharing/cleanup/host-failure recovery protocol is added.
def declare(~S:Data,~R:Type,~P:Type,~Rest:Type,~take:R -> Rest & Slot<P>,~put:Rest -> Slot<P> -> R,~call:P -> P,id:U32,key:String) -> Declaration<S,R,P,Rest,take,put,call>:
  Declaration{id,key}
# Derive the service-id requirement from this operational declaration.
def requirement(~S:Data,~R:Type,~P:Type,~Rest:Type,~take:R -> Rest & Slot<P>,~put:Rest -> Slot<P> -> R,~call:P -> P,value:Declaration<S,R,P,Rest,take,put,call>) -> SP.Requirement<S>:
  match value:
    case Declaration{id,_}:SP.Service{id}
# Derive Service schema metadata from the declaration key; not a separate grant.
def entry(~S:Data,~R:Type,~P:Type,~Rest:Type,~take:R -> Rest & Slot<P>,~put:Rest -> Slot<P> -> R,~call:P -> P,value:Declaration<S,R,P,Rest,take,put,call>) -> Fragment.Entry<S>:
  match value:
    case Declaration{_,+key}:Fragment.Entry{Fragment.Service{},key,key}
# Return the declaration key for metadata, without inspecting or calling P.
def key(~S:Data,~R:Type,~P:Type,~Rest:Type,~take:R -> Rest & Slot<P>,~put:Rest -> Slot<P> -> R,~call:P -> P,value:Declaration<S,R,P,Rest,take,put,call>) -> String:
  match value:
    case Declaration{_,key}:key
def slot_observed(~S:Data,~R:Type,~P:Type,~Rest:Type,~take:R -> Rest & Slot<P>,~put:Rest -> Slot<P> -> R,~call:P -> P,declaration:Declaration<S,R,P,Rest,take,put,call>,value:Rest & Slot<P>) -> R & Status<S>:
  match declaration value:
    case Declaration{+id,+key}, (rest,Missing{}):(put(rest,Missing{}),Status{id,key,False{}})
    case Declaration{+id,+key}, (rest,Ready{owner}):(put(rest,Ready{owner}),Status{id,key,True{}})
def world_restored(~S:Data,~C:Type,~R:Type,~E:Data,+ns:U32,allocator:Alloc.Allocator,store:C,+events:List<&2,E>,pending:List<Deferred.Command<W.World<S,C,R,E>>>,+registrations:List<&2,W.RegistrationMeta>,+nextSystem:U32,+clock:Clock.State,value:R & Status<S>) -> W.World<S,C,R,E> & List<&2,Status<S>>:
  match value:
    case (resource,status):(W.World{ns,allocator,store,resource,events,pending,registrations,nextSystem,clock},[status])
# Advanced availability scan: take and replace the actual slot, returning World
# with one detached Status. Does not invoke call; trusted lenses must preserve owners.
def world_observed(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~take:R -> Rest & Slot<P>,~put:Rest -> Slot<P> -> R,~call:P -> P,declaration:Declaration<S,R,P,Rest,take,put,call>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & List<&2,Status<S>>:
  match world:
    case W.World{+ns,allocator,store,resource,+events,pending,+registrations,+nextSystem,+clock}:world_restored(~S,~C,~R,~E,ns,allocator,store,events,pending,registrations,nextSystem,clock,slot_observed(~S,~R,~P,~Rest,~take,~put,~call,declaration,take(resource)))
# Detached service inventory with an erased World availability scan. Entries and
# scan should come from the same operational declarations; raw forgery is trusted.
type Setup<S:Data,C:Type,R:Type,E:Data,-scan:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,Status<S>>> is Data:
  Setup{entries:List<&2,Fragment.Entry<S>>}
# Build one service inventory/availability scan from its retained declaration.
def single(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~take:R -> Rest & Slot<P>,~put:Rest -> Slot<P> -> R,~call:P -> P,~declaration:Declaration<S,R,P,Rest,take,put,call>) -> Setup<S,C,R,E,world_observed(~S,~C,~R,~E,~P,~Rest,~take,~put,~call,declaration)>:
  Setup{[entry(~S,~R,~P,~Rest,~take,~put,~call,declaration)]}
def scan_join(~S:Data,~C:Type,~R:Type,~E:Data,first:List<&2,Status<S>>,second:W.World<S,C,R,E> & List<&2,Status<S>>) -> W.World<S,C,R,E> & List<&2,Status<S>>:
  match second:
    case (world,statuses):(world,List.append(&2,Status<S>,first,statuses))
def scan_next(~S:Data,~C:Type,~R:Type,~E:Data,~right:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,Status<S>>,value:W.World<S,C,R,E> & List<&2,Status<S>>) -> W.World<S,C,R,E> & List<&2,Status<S>>:
  match value:
    case (world,statuses):scan_join(~S,~C,~R,~E,statuses,right(world))
# Advanced left-then-right World scan composition, retaining returned World and
# concatenating statuses in that order. Does not call either service payload.
def scan_pair(~S:Data,~C:Type,~R:Type,~E:Data,~left:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,Status<S>>,~right:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,Status<S>>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & List<&2,Status<S>>:
  scan_next(~S,~C,~R,~E,~right,left(world))
# Compose service setup inventories and scans in left-before-right order. Does
# not validate global identity uniqueness or provide a missing service payload.
def append(~S:Data,~C:Type,~R:Type,~E:Data,~left:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,Status<S>>,~right:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,Status<S>>,a:Setup<S,C,R,E,left>,b:Setup<S,C,R,E,right>) -> Setup<S,C,R,E,scan_pair(~S,~C,~R,~E,~left,~right)>:
  match a b:
    case Setup{a} Setup{b}:Setup{List.append(&2,Fragment.Entry<S>,a,b)}
def available_next(~S:Data,provided:Bool,id:U32,rest:List<&2,SP.Requirement<S>>) -> List<&2,SP.Requirement<S>>:
  match provided:
    case False{}:rest
    case True{}:SP.Service{id} <> rest
# Convert provided statuses to ordered service requirements; absent slots add none.
# This is a metadata conversion, not a host capability invocation.
def available(~S:Data,statuses:List<&2,Status<S>>) -> List<&2,SP.Requirement<S>>:
  match statuses:
    case []:[]
    case Status{id,_,provided} <> rest:available_next(~S,provided,id,available(~S,rest))
def provisioned(~S:Data,~C:Type,~R:Type,~E:Data,value:W.World<S,C,R,E> & List<&2,Status<S>>) -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>:
  match value:
    case (world,statuses):(world,available(~S,statuses))
# Advanced preflight adapter deriving currently provided requirements via scan.
# Returns World; readiness is based on actual slots rather than a second key list.
def provision(~S:Data,~C:Type,~R:Type,~E:Data,~scan:W.World<S,C,R,E> -> W.World<S,C,R,E> & List<&2,Status<S>>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & List<&2,SP.Requirement<S>>:
  provisioned(~S,~C,~R,~E,scan(world))
def slot_called(~R:Type,~P:Type,~Rest:Type,~put:Rest -> Slot<P> -> R,~call:P -> P,value:Rest & Slot<P>) -> R:
  match value:
    case (rest,Missing{}):put(rest,Missing{})
    case (rest,Ready{owner}):put(rest,Ready{call(owner)})
# Registered service runner: if Ready, call consumes/returns actual P once and is
# put back; Missing is a successful no-op here. Schedule preflight is separate.
# No Tx journal, host exception recovery or rollback of external effects is added.
def runner(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~take:R -> Rest & Slot<P>,~put:Rest -> Slot<P> -> R,~call:P -> P,~declaration:Declaration<S,R,P,Rest,take,put,call>,world:W.World<S,C,R,E>,_:Unit) -> Sys.Outcome<W.World<S,C,R,E>,Unit,Unit>:
  match world:
    case W.World{+ns,allocator,store,resource,+events,pending,+registrations,+nextSystem,+clock}:Sys.Succeeded{W.World{ns,allocator,store,slot_called(~R,~P,~Rest,~put,~call,take(resource)),events,pending,registrations,nextSystem,clock},Unit{}}
# Register the declaration-bound runner with its operational key as access
# metadata. Returns ordinary registration success/refusal with World; does not
# call the service or itself enforce a schedule availability preflight.
def define(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~Rest:Type,~take:R -> Rest & Slot<P>,~put:Rest -> Slot<P> -> R,~call:P -> P,~declaration:Declaration<S,R,P,Rest,take,put,call>,world:W.World<S,C,R,E>,name:String) -> Sys.RegistrationResult<S,C,R,E,Unit,Unit,Unit,runner(~S,~C,~R,~E,~P,~Rest,~take,~put,~call,~declaration)>:
  Sys.register(~S,~C,~R,~E,~Unit,~Unit,~Unit,~runner(~S,~C,~R,~E,~P,~Rest,~take,~put,~call,~declaration),world,name,[key(~S,~R,~P,~Rest,~take,~put,~call,declaration)])

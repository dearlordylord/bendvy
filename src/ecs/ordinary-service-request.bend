import Base
import ./clock-state.bend as Clock
import ./capabilities.bend as Cap
import ./ordinary-service-declaration.bend as Service
import ./schema-fragments.bend as Fragment
import ./schedule-provision.bend as Provision
import ./world.bend as W
import ./transaction.bend as T
import ./trace-facts.bend as Trace
import ./deferred-command.bend as Deferred
import ./entity-allocator.bend as Alloc

type Identity<-S:Data,-Input:Type,-Output:Type> is Data:
  Identity{id:U32,key:String}
type Declaration<-S:Data,-R:Type,-P:Type,-Rest:Type,-Input:Type,-Output:Type,-identity:Identity<S,Input,Output>,-take:R -> Rest & Service.Slot<P>,-put:Rest -> Service.Slot<P> -> R,-call:P -> Input -> P & Output> is Data:
  Declaration{}
type RequestResult<-Input:Type,-Output:Type> is Type:
  Called{output:Output}
  Unavailable{input:Input}
type Grant<-S:Data,-Input:Type,-Output:Type,-identity:Identity<S,Input,Output>,-H:Type> is Type:
  Grant{operation:Cap.OwnedRequest<H,Input,RequestResult<Input,Output>>}
def declare(~S:Data,~R:Type,~P:Type,~Rest:Type,~Input:Type,~Output:Type,~identity:Identity<S,Input,Output>,~take:R -> Rest & Service.Slot<P>,~put:Rest -> Service.Slot<P> -> R,~call:P -> Input -> P & Output) -> Declaration<S,R,P,Rest,Input,Output,identity,take,put,call>:
  Declaration{}
def key(~S:Data,~Input:Type,~Output:Type,identity:Identity<S,Input,Output>) -> String:
  match identity:
    case Identity{_,key}:key
def requirement(~S:Data,~Input:Type,~Output:Type,identity:Identity<S,Input,Output>) -> Provision.Requirement<S>:
  match identity:
    case Identity{id,_}:Provision.Service{id}
def entry(~S:Data,~Input:Type,~Output:Type,identity:Identity<S,Input,Output>) -> Fragment.Entry<S>:
  match identity:
    case Identity{_,+key}:Fragment.Entry{Fragment.Service{},key,key}
def called(~R:Type,~P:Type,~Rest:Type,~Input:Type,~Output:Type,~put:Rest -> Service.Slot<P> -> R,rest:Rest,value:P & Output) -> R & RequestResult<Input,Output>:
  match value:
    case (owner,output):(put(rest,Service.Ready{owner}),Called{output})
def slot_called(~S:Data,~R:Type,~P:Type,~Rest:Type,~Input:Type,~Output:Type,~identity:Identity<S,Input,Output>,~take:R -> Rest & Service.Slot<P>,~put:Rest -> Service.Slot<P> -> R,~call:P -> Input -> P & Output,input:Input,value:Rest & Service.Slot<P>) -> R & RequestResult<Input,Output>:
  match value:
    case (rest,Service.Missing{}):(put(rest,Service.Missing{}),Unavailable{input})
    case (rest,Service.Ready{owner}):called(~R,~P,~Rest,~Input,~Output,~put,rest,call(owner,input))
def world_called(~S:Data,~C:Type,~R:Type,~E:Data,~Input:Type,~Output:Type,+namespace:U32,allocator:Alloc.Allocator,store:C,+events:List<&2,E>,pending:List<Deferred.Command<W.World<S,C,R,E>>>,+registrations:List<&2,W.RegistrationMeta>,+nextSystem:U32,+clock:Clock.State,value:R & RequestResult<Input,Output>) -> W.World<S,C,R,E> & RequestResult<Input,Output>:
  match value:
    case (resource,result):(W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystem,clock},result)
def request_world(~C:Type,~E:Data,~S:Data,~R:Type,~P:Type,~Rest:Type,~Input:Type,~Output:Type,~identity:Identity<S,Input,Output>,~take:R -> Rest & Service.Slot<P>,~put:Rest -> Service.Slot<P> -> R,~call:P -> Input -> P & Output,world:W.World<S,C,R,E>,input:Input) -> W.World<S,C,R,E> & RequestResult<Input,Output>:
  match world:
    case W.World{+namespace,allocator,store,resource,+events,pending,+registrations,+nextSystem,+clock}:world_called(~S,~C,~R,~E,~Input,~Output,namespace,allocator,store,events,pending,registrations,nextSystem,clock,slot_called(~S,~R,~P,~Rest,~Input,~Output,~identity,~take,~put,~call,input,take(resource)))
def transaction_called(~S:Data,~C:Type,~R:Type,~E:Data,~Input:Type,~Output:Type,undo:List<(W.World<S,C,R,E> -> W.World<S,C,R,E>)>,commands:List<Deferred.Command<W.World<S,C,R,E>>>,events:List<&2,E>,trace:Trace.State,value:W.World<S,C,R,E> & RequestResult<Input,Output>) -> T.Tx<W.World<S,C,R,E>,E> & RequestResult<Input,Output>:
  match value:
    case (world,result):(T.Tx{world,undo,commands,events,trace},result)
def request_transaction(~C:Type,~E:Data,~S:Data,~R:Type,~P:Type,~Rest:Type,~Input:Type,~Output:Type,~identity:Identity<S,Input,Output>,~take:R -> Rest & Service.Slot<P>,~put:Rest -> Service.Slot<P> -> R,~call:P -> Input -> P & Output,transaction:T.Tx<W.World<S,C,R,E>,E>,input:Input) -> T.Tx<W.World<S,C,R,E>,E> & RequestResult<Input,Output>:
  match transaction:
    case T.Tx{world,undo,commands,events,trace}:transaction_called(~S,~C,~R,~E,~Input,~Output,undo,commands,events,trace,request_world(~C,~E,~S,~R,~P,~Rest,~Input,~Output,~identity,~take,~put,~call,world,input))
def grant(~C:Type,~E:Data,~S:Data,~R:Type,~P:Type,~Rest:Type,~Input:Type,~Output:Type,~identity:Identity<S,Input,Output>,~take:R -> Rest & Service.Slot<P>,~put:Rest -> Service.Slot<P> -> R,~call:P -> Input -> P & Output,~declaration:Declaration<S,R,P,Rest,Input,Output,identity,take,put,call>) -> Grant<S,Input,Output,identity,T.Tx<W.World<S,C,R,E>,E>>:
  Grant{Cap.OwnedRequest{request_transaction(~C,~E,~S,~R,~P,~Rest,~Input,~Output,~identity,~take,~put,~call)}}
def request_field(~S:Data,~Input:Type,~Output:Type,~identity:Identity<S,Input,Output>,~H:Type,value:Grant<S,Input,Output,identity,H>) -> H -> Input -> H & RequestResult<Input,Output>:
  match value:
    case Grant{operation}:Cap.owned_request_field(~H,~Input,~RequestResult<Input,Output>,operation)
def request(~S:Data,~Input:Type,~Output:Type,~identity:Identity<S,Input,Output>,~H:Type,~operation:Grant<S,Input,Output,identity,H>,owner:H,input:Input) -> H & RequestResult<Input,Output>:
  request_field(~S,~Input,~Output,~identity,~H,operation)(owner,input)

def declaration_key(~S:Data,~R:Type,~P:Type,~Rest:Type,~Input:Type,~Output:Type,~identity:Identity<S,Input,Output>,~take:R -> Rest & Service.Slot<P>,~put:Rest -> Service.Slot<P> -> R,~call:P -> Input -> P & Output,_: Declaration<S,R,P,Rest,Input,Output,identity,take,put,call>) -> String:
  key(~S,~Input,~Output,identity)
def declaration_requirement(~S:Data,~R:Type,~P:Type,~Rest:Type,~Input:Type,~Output:Type,~identity:Identity<S,Input,Output>,~take:R -> Rest & Service.Slot<P>,~put:Rest -> Service.Slot<P> -> R,~call:P -> Input -> P & Output,_: Declaration<S,R,P,Rest,Input,Output,identity,take,put,call>) -> Provision.Requirement<S>:
  requirement(~S,~Input,~Output,identity)
def declaration_entry(~S:Data,~R:Type,~P:Type,~Rest:Type,~Input:Type,~Output:Type,~identity:Identity<S,Input,Output>,~take:R -> Rest & Service.Slot<P>,~put:Rest -> Service.Slot<P> -> R,~call:P -> Input -> P & Output,_: Declaration<S,R,P,Rest,Input,Output,identity,take,put,call>) -> Fragment.Entry<S>:
  entry(~S,~Input,~Output,identity)
def status(~S:Data,~Input:Type,~Output:Type,identity:Identity<S,Input,Output>,provided:Bool) -> Service.Status<S>:
  match identity:
    case Identity{id,key}:Service.Status{id,key,provided}
def slot_observed(~S:Data,~R:Type,~P:Type,~Rest:Type,~Input:Type,~Output:Type,~identity:Identity<S,Input,Output>,~take:R -> Rest & Service.Slot<P>,~put:Rest -> Service.Slot<P> -> R,~call:P -> Input -> P & Output,value:Rest & Service.Slot<P>) -> R & List<&2,Service.Status<S>>:
  match value:
    case (rest,Service.Missing{}):(put(rest,Service.Missing{}),[status(~S,~Input,~Output,identity,False{})])
    case (rest,Service.Ready{owner}):(put(rest,Service.Ready{owner}),[status(~S,~Input,~Output,identity,True{})])
def world_observed_join(~S:Data,~C:Type,~R:Type,~E:Data,+namespace:U32,allocator:Alloc.Allocator,store:C,+events:List<&2,E>,pending:List<Deferred.Command<W.World<S,C,R,E>>>,+registrations:List<&2,W.RegistrationMeta>,+nextSystem:U32,+clock:Clock.State,value:R & List<&2,Service.Status<S>>) -> W.World<S,C,R,E> & List<&2,Service.Status<S>>:
  match value:
    case (resource,statuses):(W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystem,clock},statuses)
def world_observed(~C:Type,~E:Data,~S:Data,~R:Type,~P:Type,~Rest:Type,~Input:Type,~Output:Type,~identity:Identity<S,Input,Output>,~take:R -> Rest & Service.Slot<P>,~put:Rest -> Service.Slot<P> -> R,~call:P -> Input -> P & Output,~declaration:Declaration<S,R,P,Rest,Input,Output,identity,take,put,call>,world:W.World<S,C,R,E>) -> W.World<S,C,R,E> & List<&2,Service.Status<S>>:
  match world:
    case W.World{+namespace,allocator,store,resource,+events,pending,+registrations,+nextSystem,+clock}:world_observed_join(~S,~C,~R,~E,namespace,allocator,store,events,pending,registrations,nextSystem,clock,slot_observed(~S,~R,~P,~Rest,~Input,~Output,~identity,~take,~put,~call,take(resource)))
def setup(~C:Type,~E:Data,~S:Data,~R:Type,~P:Type,~Rest:Type,~Input:Type,~Output:Type,~identity:Identity<S,Input,Output>,~take:R -> Rest & Service.Slot<P>,~put:Rest -> Service.Slot<P> -> R,~call:P -> Input -> P & Output,~declaration:Declaration<S,R,P,Rest,Input,Output,identity,take,put,call>) -> Service.Setup<S,C,R,E,world_observed(~C,~E,~S,~R,~P,~Rest,~Input,~Output,~identity,~take,~put,~call,~declaration)>:
  Service.Setup{[declaration_entry(~S,~R,~P,~Rest,~Input,~Output,~identity,~take,~put,~call,declaration)]}

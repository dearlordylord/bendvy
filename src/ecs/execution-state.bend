import Base
import ./world.bend as W
import ./entity-allocator.bend as A
import ./entity-key.bend as K
import ./clock-state.bend as Clock
import ./change-tick.bend as Tick
import ./deferred-command.bend as Deferred

type Scope<-S:Data,-C:Type,-R:Type> is Type:
  Scope{store:C,resource:R,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>}
type Administration<-S:Data,-C:Type,-R:Type,-E:Data> is Type:
  Administration{namespace:U32,allocator:A.Allocator,events:List<&2,E>,pending:List<Deferred.Command<W.World<S,C,R,E>>>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:Clock.State}
def separated(~S:Data,~C:Type,~R:Type,~E:Data,tick:Tick.Tick,observed:W.World<S,C,R,E> & List<&2,W.Handle<S>>) -> Administration<S,C,R,E> & Scope<S,C,R>:
  match observed:
    case (W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock},handles):(Administration{namespace,allocator,events,pending,registrations,nextSystemId,clock},Scope{store,resource,handles,tick,None{}})
def separate(~S:Data,~C:Type,~R:Type,~E:Data,world:W.World<S,C,R,E>,tick:Tick.Tick) -> Administration<S,C,R,E> & Scope<S,C,R>:
  separated(~S,~C,~R,~E,tick,W.handles(~S,~C,~R,~E,world))
def reassemble(~S:Data,~C:Type,~R:Type,~E:Data,admin:Administration<S,C,R,E>,scope:Scope<S,C,R>) -> W.World<S,C,R,E>:
  match admin scope:
    case Administration{namespace,allocator,events,pending,registrations,nextSystemId,clock} Scope{store,resource,_,_,_}:W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock}
def same(~S:Data,left:W.Handle<S>,right:W.Handle<S>) -> Bool:
  match left right:
    case W.Handle{ln,lk} W.Handle{rn,rk}:Bool.and(U32.is_eq(ln,rn),K.equal(lk,rk))
def member(~S:Data,+handle:W.Handle<S>,handles:List<&2,W.Handle<S>>) -> Bool:
  match handles:
    case []:False{}
    case current <> rest:Bool.or(same(~S,handle,current),member(~S,handle,rest))

# The cursor belongs to this admitted system, independently of the shared clock.
def window(~S:Data,~C:Type,~R:Type,scope:Scope<S,C,R>,prior:Maybe<&2,Tick.Tick>) -> Scope<S,C,R>:
  match scope:
    case Scope{store,resource,handles,tick,_}:Scope{store,resource,handles,tick,prior}

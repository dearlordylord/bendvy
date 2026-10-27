import Base
import ./execution-lifecycle-notices.bend as Notice
import ./entity-allocator.bend as Alloc
import ./clock-state.bend as Clock
import ./change-tick.bend as Tick
import ./lifecycle.bend as Life
import ./deferred-command.bend as Deferred
import ./execution-composer-layout.bend as Layout
import ./execution-system.bend as Sys
import ./world.bend as W

type Slot<-P:Type> is Type:
  Missing{}
  Provided{owner:P}
type Status<V:Data> is Data:
  Status{value:Maybe<&2,V>}
type Called<-Out:Type> is Type:
  Unavailable{}
  Called{output:Out}
def refreshed(~P:Type,~V:Data,result:P & V) -> Slot<P> & Status<V>:
  match result:
    case (owner,view):(Provided{owner},Status{Some{view}})
def refresh(~P:Type,~V:Data,~project:P -> P & V,slot:Slot<P>) -> Slot<P> & Status<V>:
  match slot:
    case Missing{}:(Missing{},Status{None{}})
    case Provided{owner}:refreshed(~P,~V,project(owner))
def called(~P:Type,-Out:Type,result:P & Out) -> Slot<P> & Called<Out>:
  match result:
    case (owner,output):(Provided{owner},Called{output})
def call(~P:Type,~Out:Type,~invoke:P -> P & Out,slot:Slot<P>) -> Slot<P> & Called<Out>:
  match slot:
    case Missing{}:(Missing{},Unavailable{})
    case Provided{owner}:called(~P,Out,invoke(owner))
def required(~V:Data,key:String,status:Status<V>) -> Sys.Completion<String,Bool>:
  match status:
    case Status{None{}}:Sys.BodyError{"missing-service:" ++ key,False{}}
    case Status{Some{_}}:Sys.Success{True{}}

type Provision<-World:Type,-P:Type> is Type:
  Provisioned{world:World}
  ProvisionRefused{world:World,incoming:P}
def restored(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,incoming:Maybe<&1,P>,world:W.World<S,C,R,E>) -> Provision<W.World<S,C,R,E>,P>:
  match incoming:
    case None{}:Provisioned{world}
    case Some{owner}:ProvisionRefused{world,owner}
def provided_slot(~S:Data,~R:Type,~P:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~shape:{Layout.payload(layout,route) == Slot<P> : Type},rest:Layout.resource_rest(~S,layout,route),cache:Layout.view(layout,route),stamp:Life.Stamp,tick:Tick.Tick,incoming:P,existing:Slot<P>) -> R & Maybe<&1,P>:
  match existing:
    case Missing{}:(Layout.checked_owner(Layout.resources(~S,layout),R,Equal.sym(Type,R,Layout.resources(~S,layout),same),Layout.resource_put(~S,layout,route,rest,Layout.ResourceSlot{Layout.initialize(layout,route,Layout.checked_owner(Slot<P>,Layout.payload(layout,route),Equal.sym(Type,Layout.payload(layout,route),Slot<P>,shape),Provided{incoming})),Life.after_write(True{},False{},stamp,tick)})),None{})
    case Provided{owner}:(Layout.checked_owner(Layout.resources(~S,layout),R,Equal.sym(Type,R,Layout.resources(~S,layout),same),Layout.resource_put(~S,layout,route,rest,Layout.ResourceSlot{Layout.Viewed{Layout.checked_owner(Slot<P>,Layout.payload(layout,route),Equal.sym(Type,Layout.payload(layout,route),Slot<P>,shape),Provided{owner}),cache},stamp})),Some{incoming})
def selected_slot(~S:Data,~R:Type,~P:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~shape:{Layout.payload(layout,route) == Slot<P> : Type},tick:Tick.Tick,incoming:P,result:Layout.resource_rest(~S,layout,route) & Layout.ResourceSlot<S,Layout.stored(layout,route),Layout.key(layout,route),Layout.origin(layout,route)>) -> R & Maybe<&1,P>:
  match result:
    case (rest,Layout.ResourceSlot{Layout.Viewed{owner,cache},stamp}):provided_slot(~S,~R,~P,~layout,~route,~same,~shape,rest,cache,stamp,tick,incoming,Layout.checked_owner(Layout.payload(layout,route),Slot<P>,shape,owner))
def provided_resources(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,namespace:U32,allocator:Alloc.Allocator,store:C,events:List<&2,E>,pending:List<Deferred.Command<W.World<S,C,R,E>>>,registrations:List<&2,W.RegistrationMeta>,next:U32,clock:Clock.State,result:R & Maybe<&1,P>,lifecycle:Notice.Journal<S>) -> Provision<W.World<S,C,R,E>,P>:
  match result:
    case (resources,incoming):restored(~S,~C,~R,~E,~P,incoming,W.World{namespace,allocator,store,resources,events,pending,registrations,next,clock,lifecycle})
def provide(~S:Data,~C:Type,~R:Type,~E:Data,~P:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{R == Layout.resources(~S,layout) : Type},~shape:{Layout.payload(layout,route) == Slot<P> : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},world:W.World<S,C,R,E>,incoming:P) -> Provision<W.World<S,C,R,E>,P>:
  match world:
    case W.World{namespace,allocator,store,resources,events,pending,registrations,next,+clock,lifecycle}:provided_resources(~S,~C,~R,~E,~P,namespace,allocator,store,events,pending,registrations,next,clock,selected_slot(~S,~R,~P,~layout,~route,~same,~shape,Clock.current(clock),incoming,Layout.resource_take(~S,layout,route,Layout.checked_owner(R,Layout.resources(~S,layout),same,resources))),lifecycle)

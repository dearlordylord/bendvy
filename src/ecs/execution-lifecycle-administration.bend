import Base
import ./world.bend as W
import ./execution-lifecycle-notices.bend as Notice
import ./execution-composer-layout.bend as Layout
import ./entity-allocator.bend as A
import ./clock-state.bend as Clock
import ./deferred-command.bend as Deferred

def registered(~S:Data,~C:Type,~R:Type,~E:Data,~origin:Layout.Layout,~selector:Notice.Selector,namespace:U32,allocator:A.Allocator,store:C,resource:R,events:List<&2,E>,pending:List<Deferred.Command<W.World<S,C,R,E>>>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:Clock.State,result:Notice.Journal<S> & Notice.Registration<S,origin,selector>) -> W.World<S,C,R,E> & Notice.Registration<S,origin,selector>:
  match result:
    case (journal,reader):(W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,journal},reader)
def register(~S:Data,~C:Type,~R:Type,~E:Data,~origin:Layout.Layout,~selector:Notice.Selector,world:W.World<S,C,R,E>,start:Notice.Start) -> W.World<S,C,R,E> & Notice.Registration<S,origin,selector>:
  match world:
    case W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,journal}:registered(~S,~C,~R,~E,~origin,~selector,namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,Notice.register(~S,~origin,~selector,start,journal))
def register_removed(~S:Data,~C:Type,~R:Type,~E:Data,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~valid:{Layout.grant_valid(~layout,~route) == True{} : Bool},world:W.World<S,C,R,E>,start:Notice.Start) -> W.World<S,C,R,E> & Notice.Registration<S,Layout.origin(layout,route),Notice.Removed{Layout.key(layout,route)}>:
  register(~S,~C,~R,~E,~(Layout.origin(layout,route)),~(Notice.Removed{Layout.key(layout,route)}),world,start)
def register_despawn(~S:Data,~C:Type,~R:Type,~E:Data,world:W.World<S,C,R,E>,start:Notice.Start) -> W.World<S,C,R,E> & Notice.Registration<S,Layout.EmptyLayout{},Notice.Despawned{}>:
  register(~S,~C,~R,~E,~(Layout.EmptyLayout{}),~(Notice.Despawned{}),world,start)
def retired(~S:Data,~C:Type,~R:Type,~E:Data,~origin:Layout.Layout,~selector:Notice.Selector,namespace:U32,allocator:A.Allocator,store:C,resource:R,events:List<&2,E>,pending:List<Deferred.Command<W.World<S,C,R,E>>>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:Clock.State,result:Notice.Journal<S> & Notice.Retirement<S,origin,selector>) -> W.World<S,C,R,E> & Notice.Retirement<S,origin,selector>:
  match result:
    case (journal,reader):(W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,journal},reader)
def retire(~S:Data,~C:Type,~R:Type,~E:Data,~origin:Layout.Layout,~selector:Notice.Selector,world:W.World<S,C,R,E>,reader:Notice.Reader<S,origin,selector>) -> W.World<S,C,R,E> & Notice.Retirement<S,origin,selector>:
  match world:
    case W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,journal}:retired(~S,~C,~R,~E,~origin,~selector,namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,Notice.retire(~S,~origin,~selector,journal,reader))

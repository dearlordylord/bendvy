import Base
import ./execution-composer-layout.bend as Layout
import ./execution-relation-context.bend as Context
import ./execution-relation-resource-publication.bend as Resource
import ./execution-relation-store.bend as Store
import ./execution-relation-operation.bend as O
import ./execution-resource-policy.bend as Policy
import ./relation-types.bend as T
import ./world.bend as W
import ./deferred-command.bend as Deferred
import ./clock-state.bend as Clock
import ./execution-lifecycle-notices.bend as Notice
import ./change-tick.bend as Tick
import ./entity-allocator.bend as Allocator

# World fields outside allocator/resources remain actual affine owners here.
type Frame<-S:Data,-C:Type,-WR:Type,-E:Data> is Type:
  Frame{namespace:U32,columns:C,events:List<&2,E>,pending:List<Deferred.Command<W.World<S,C,WR,E>>>,registrations:List<&2,W.RegistrationMeta>,nextSystem:U32,clock:Clock.State,lifecycle:Notice.Journal<S>}
def restored(-S:Data,-C:Type,-WR:Type,-E:Data,-Binding:Type,binding:Binding,frame:Frame<S,C,WR,E>,result:Allocator.Allocator & (WR & Store.Receipt<S>)) -> W.World<S,C,WR,E> & (Binding & Store.Receipt<S>):
  match frame result:
    case Frame{namespace,columns,events,pending,registrations,nextSystem,clock,lifecycle}, (allocator,(resources,receipt)):(W.World{namespace,allocator,columns,resources,events,pending,registrations,nextSystem,clock,lifecycle},(binding,receipt))
def checked(~S:Data,~C:Type,~WR:Type,~E:Data,~resources:Layout.Layout,~same:{WR == Layout.resources(~S,resources) : Type},~route:Layout.Route,~valid:{Layout.grant_valid(~resources,~route) == True{} : Bool},~descriptor:T.Descriptor<S>,~payload:{Layout.payload(resources,route) == Store.Store<S,descriptor> : Type},~view:{Layout.view(resources,route) == Store.View<S,descriptor> : Data},~protected:{Layout.policy(resources,route) == Policy.ProtectedRelation{S,descriptor} : Policy.Policy},allowed:Bool,binding:Context.Binding<S,WR,resources,same,route,descriptor,payload,view,protected>,world:W.World<S,C,WR,E>,operation:O.Operation<S>,tick:Tick.Tick) -> W.World<S,C,WR,E> & (Context.Binding<S,WR,resources,same,route,descriptor,payload,view,protected> & Store.Receipt<S>):
  match allowed binding world:
    case False{} binding world:(world,(binding,Store.Refused{operation,Store.NamespaceMismatch{}}))
    case True{} Context.Binding{+context} W.World{+namespace,allocator,columns,owners,events,pending,registrations,nextSystem,clock,lifecycle}:restored(S,C,WR,E,Context.Binding<S,WR,resources,same,route,descriptor,payload,view,protected>,Context.Binding{context},Frame{namespace,columns,events,pending,registrations,nextSystem,clock,lifecycle},Resource.apply(~S,~WR,~resources,~same,~route,~valid,~descriptor,~payload,~view,context,namespace,allocator,owners,operation,tick))
# The protected proof is about the selected canonical leaf's actual policy.
# No body, callback, clock advance, second queue, or caller-supplied graph exists.
def apply(~S:Data,~C:Type,~WR:Type,~E:Data,~resources:Layout.Layout,~same:{WR == Layout.resources(~S,resources) : Type},~route:Layout.Route,~valid:{Layout.grant_valid(~resources,~route) == True{} : Bool},~descriptor:T.Descriptor<S>,~payload:{Layout.payload(resources,route) == Store.Store<S,descriptor> : Type},~view:{Layout.view(resources,route) == Store.View<S,descriptor> : Data},~protected:{Layout.policy(resources,route) == Policy.ProtectedRelation{S,descriptor} : Policy.Policy},binding:Context.Binding<S,WR,resources,same,route,descriptor,payload,view,protected>,world:W.World<S,C,WR,E>,operation:O.Operation<S>,tick:Tick.Tick) -> W.World<S,C,WR,E> & (Context.Binding<S,WR,resources,same,route,descriptor,payload,view,protected> & Store.Receipt<S>):
  match binding world:
    case Context.Binding{Context.Context{+expected}} W.World{+actual,allocator,columns,owners,events,pending,registrations,nextSystem,clock,lifecycle}:checked(~S,~C,~WR,~E,~resources,~same,~route,~valid,~descriptor,~payload,~view,~protected,U32.is_eq(expected,actual),Context.Binding{Context.Context{expected}},W.World{actual,allocator,columns,owners,events,pending,registrations,nextSystem,clock,lifecycle},operation,tick)

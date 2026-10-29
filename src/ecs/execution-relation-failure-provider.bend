import Base
import ./execution-composer-layout.bend as Layout
import ./execution-layout-access.bend as LayoutAccess
import ./execution-resource-policy.bend as Policy
import ./execution-relation-store.bend as Store
import ./execution-relation-failure-access.bend as Access
import ./execution-state.bend as State
import ./owner-product.bend as Product
import ./relation-types.bend as T
import ./execution-resource-store.bend as Resources
import ./execution-resource-access.bend as ResourceAccess
import ./execution-resource-interpreter.bend as Interpreter
import ./execution-relation-failure-channel.bend as Reader

def Slot(~S:Data,~full:Layout.Layout,~route:Layout.Route,~descriptor:T.Descriptor<S>) -> Type:
  Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S,descriptor>,Store.View<S,descriptor>>,Layout.key(full,route),Layout.origin(full,route)>
def checked_lens(~S:Data,~R:Type,~full:Layout.Layout,~route:Layout.Route,~descriptor:T.Descriptor<S>,~local:Layout.Layout,~selected:Layout.Route,~same:{R == Layout.resources(~S,local) : Type},slot:{LayoutAccess.resource_slot(~S,local,selected) == Slot(~S,~full,~route,~descriptor) : Type}) -> Product.Lens<R,Slot(~S,~full,~route,~descriptor),Layout.resource_rest(~S,local,selected)>:
  %slot : Product.Lens<R,_,Layout.resource_rest(~S,local,selected)>
  LayoutAccess.resource_lens(~S,~R,~local,~selected,~same)

# The physical slot equality retains the actual full schema origin and policy.
# No raw graph writer, arbitrary owner transform or guessed key reaches H.
def whole(~S:Data,~C:Type,~R:Type,~full:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~full,~route) == True{} : Bool},~descriptor:T.Descriptor<S>,~payload:{Layout.payload(full,route) == Store.Store<S,descriptor> : Type},~view:{Layout.view(full,route) == Store.View<S,descriptor> : Data},~protected:{Layout.policy(full,route) == Policy.ProtectedRelation{S,descriptor} : Policy.Policy},~local:Layout.Layout,~selected:Layout.Route,~same:{R == Layout.resources(~S,local) : Type},~localvalid:{Layout.grant_valid(~local,~selected) == True{} : Bool},~slot:{LayoutAccess.resource_slot(~S,local,selected) == Slot(~S,~full,~route,~descriptor) : Type}) -> Access.Read<S,descriptor,full,route,State.Scope<S,C,R>>:
  Access.cap(~S,~descriptor,~full,~route,~C,~R,~Layout.resource_rest(~S,local,selected),~checked_lens(~S,~R,~full,~route,~descriptor,~local,~selected,~same,slot))

def view_reader(~S:Data,~descriptor:T.Descriptor<S>,~H:Type,~V:Data,view:{V == Store.View<S,descriptor> : Data},cap:ResourceAccess.Reader<H,V>) -> ResourceAccess.Reader<H,Store.View<S,descriptor>>:
  %view : ResourceAccess.Reader<H,_>
  cap
def cached_read(~S:Data,~descriptor:T.Descriptor<S>,~full:Layout.Layout,~route:Layout.Route,~C:Type,~R:Type,cap:ResourceAccess.Reader<State.Scope<S,C,R>,Store.View<S,descriptor>>,reader:Reader.Reader<S,descriptor,full,route>,scope:State.Scope<S,C,R>) -> State.Scope<S,C,R> & Reader.Reading<S,descriptor,full,route>:
  match cap scope:
    case ResourceAccess.UnsupportedReader{} scope:(scope,Reader.Refused{reader})
    case ResourceAccess.Reader{get} State.Scope{columns,resources,handles,+tick,prior,+view}:Access.cached_returned(~S,~descriptor,~full,~route,~State.Scope<S,C,R>,Access.view_namespace(~S,view),tick,reader,get(State.Scope{columns,resources,handles,tick,prior,view}))
# The same recipe-backed cache serves Whole and Sparse models. Exact nominal
# payload/view/policy witnesses come from the closed declaration, never a key.
def general(~S:Data,~C:Type,~R:Type,~full:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~full,~route) == True{} : Bool},~descriptor:T.Descriptor<S>,~payload:{Layout.payload(full,route) == Store.Store<S,descriptor> : Type},~view:{Layout.view(full,route) == Store.View<S,descriptor> : Data},~protected:{Layout.policy(full,route) == Policy.ProtectedRelation{S,descriptor} : Policy.Policy},~model:Resources.Model,~local:{R == Resources.owner(~S,full,model) : Type}) -> Access.Read<S,descriptor,full,route,State.Scope<S,C,R>>:
  Access.Read{reader => scope => cached_read(~S,~descriptor,~full,~route,~C,~R,view_reader(~S,~descriptor,~State.Scope<S,C,R>,~Layout.view(full,route),view,Interpreter.read_caps(~S,~C,~R,~full,~route,model,local)),reader,scope)}

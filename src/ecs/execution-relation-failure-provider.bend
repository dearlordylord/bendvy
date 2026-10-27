import Base
import ./execution-composer-layout.bend as Layout
import ./execution-layout-access.bend as LayoutAccess
import ./execution-resource-policy.bend as Policy
import ./execution-relation-store.bend as Store
import ./execution-relation-failure-access.bend as Access
import ./execution-state.bend as State
import ./owner-product.bend as Product
import ./relation-types.bend as T

def Slot(~S:Data,~full:Layout.Layout,~route:Layout.Route,~descriptor:T.Descriptor<S>) -> Type:
  Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S,descriptor>,Store.View<S,descriptor>>,Layout.key(full,route),Layout.origin(full,route)>
def checked_lens(~S:Data,~R:Type,~full:Layout.Layout,~route:Layout.Route,~descriptor:T.Descriptor<S>,~local:Layout.Layout,~selected:Layout.Route,~same:{R == Layout.resources(~S,local) : Type},slot:{LayoutAccess.resource_slot(~S,local,selected) == Slot(~S,~full,~route,~descriptor) : Type}) -> Product.Lens<R,Slot(~S,~full,~route,~descriptor),Layout.resource_rest(~S,local,selected)>:
  %slot : Product.Lens<R,_,Layout.resource_rest(~S,local,selected)>
  LayoutAccess.resource_lens(~S,~R,~local,~selected,~same)

# The physical slot equality retains the actual full schema origin and policy.
# No raw graph writer, arbitrary owner transform or guessed key reaches H.
def whole(~S:Data,~C:Type,~R:Type,~full:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~full,~route) == True{} : Bool},~descriptor:T.Descriptor<S>,~payload:{Layout.payload(full,route) == Store.Store<S,descriptor> : Type},~view:{Layout.view(full,route) == Store.View<S,descriptor> : Data},~protected:{Layout.policy(full,route) == Policy.ProtectedRelation{S,descriptor} : Policy.Policy},~local:Layout.Layout,~selected:Layout.Route,~same:{R == Layout.resources(~S,local) : Type},~localvalid:{Layout.grant_valid(~local,~selected) == True{} : Bool},~slot:{LayoutAccess.resource_slot(~S,local,selected) == Slot(~S,~full,~route,~descriptor) : Type}) -> Access.Read<S,descriptor,full,route,State.Scope<S,C,R>>:
  Access.cap(~S,~descriptor,~full,~route,~C,~R,~Layout.resource_rest(~S,local,selected),~checked_lens(~S,~R,~full,~route,~descriptor,~local,~selected,~same,slot))

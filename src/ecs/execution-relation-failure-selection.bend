import Base
import ./execution-builder.bend as Build
import ./execution-composer-layout.bend as Layout
import ./execution-layout-access.bend as LayoutAccess
import ./execution-resource-policy.bend as Policy
import ./execution-relation-store.bend as Store
import ./execution-relation-failure-provider.bend as Provider
import ./execution-relation-failure-access.bend as Access
import ./relation-types.bend as T

def selected(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type,~full:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~full,~route) == True{} : Bool},~descriptor:T.Descriptor<S>,~payload:{Layout.payload(full,route) == Store.Store<S,descriptor> : Type},~view:{Layout.view(full,route) == Store.View<S,descriptor> : Data},~protected:{Layout.policy(full,route) == Policy.ProtectedRelation{S,descriptor} : Policy.Policy},~local:Layout.Layout,~physical:Layout.Route,~same:{R == Layout.resources(~S,local) : Type},~localvalid:{Layout.grant_valid(~local,~physical) == True{} : Bool},~slot:{LayoutAccess.resource_slot(~S,local,physical) == Provider.Slot(~S,~full,~route,~descriptor) : Type},~basic:Build.BasicResourceRead(~S,~C,~R,~H,~B),~general:Build.GeneralResourceRead(~S,~C,~R,~H,~B),~failure:Build.FailureRead(~S,~C,~R,~H,~B),book:B) -> B & Access.Read<S,descriptor,full,route,H>:
  failure(full,route,valid,descriptor,payload,view,protected,local,physical,same,localvalid,slot,book)

# The abstract H is introduced by the ordinary Builder. The declaration cannot
# manufacture its capability from a concrete physical scope or graph owner.
def select(~S:Data,~C:Type,~R:Type,~H:Type,~B:Type,~full:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~full,~route) == True{} : Bool},~descriptor:T.Descriptor<S>,~payload:{Layout.payload(full,route) == Store.Store<S,descriptor> : Type},~view:{Layout.view(full,route) == Store.View<S,descriptor> : Data},~protected:{Layout.policy(full,route) == Policy.ProtectedRelation{S,descriptor} : Policy.Policy},~local:Layout.Layout,~physical:Layout.Route,~same:{R == Layout.resources(~S,local) : Type},~localvalid:{Layout.grant_valid(~local,~physical) == True{} : Bool},~slot:{LayoutAccess.resource_slot(~S,local,physical) == Provider.Slot(~S,~full,~route,~descriptor) : Type},~resource:Build.ResourceRead(~S,~C,~R,~H,~B),book:B) -> B & Access.Read<S,descriptor,full,route,H>:
  resource(Access.Ops(~S,~descriptor,~full,~route),selected(~S,~C,~R,~H,~B,~full,~route,~valid,~descriptor,~payload,~view,~protected,~local,~physical,~same,~localvalid,~slot),book)

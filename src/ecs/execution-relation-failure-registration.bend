import Base
import ./execution-composer-layout.bend as Layout
import ./execution-relation-resource-publication.bend as Cast
import ./execution-relation-failure-provider.bend as Provider
import ./execution-relation-failure-channel.bend as Reader
import ./execution-relation-store.bend as Store
import ./execution-resource-policy.bend as Policy
import ./relation-types.bend as T
import ./lifecycle.bend as Life

type Registration<-S:Data,-resources:Layout.Layout,-route:Layout.Route,-descriptor:T.Descriptor<S>> is Type:
  Registered{owners:Layout.resources(~S,resources),reader:Reader.Reader<S,descriptor,resources,route>}
  Refused{owners:Layout.resources(~S,resources)}
def projected(~S:Data,~resources:Layout.Layout,~route:Layout.Route,~descriptor:T.Descriptor<S>,stamp:Life.Stamp,reader:Reader.Reader<S,descriptor,resources,route>,result:Store.Store<S,descriptor> & Store.View<S,descriptor>) -> Provider.Slot(~S,~resources,~route,~descriptor) & Maybe<&1,Reader.Reader<S,descriptor,resources,route>>:
  match result:
    case (store,view):(Layout.ResourceSlot{Layout.Viewed{store,view},stamp},Some{reader})
def registered(~S:Data,~resources:Layout.Layout,~route:Layout.Route,~descriptor:T.Descriptor<S>,view:Store.View<S,descriptor>,stamp:Life.Stamp,result:Store.Registration<S,descriptor,resources,route>) -> Provider.Slot(~S,~resources,~route,~descriptor) & Maybe<&1,Reader.Reader<S,descriptor,resources,route>>:
  match result:
    case Store.Registered{store,reader}:projected(~S,~resources,~route,~descriptor,stamp,reader,Store.project(~S,~descriptor,store))
    case Store.RegistrationRefused{store}:(Layout.ResourceSlot{Layout.Viewed{store,view},stamp},None{})
def slot(~S:Data,~resources:Layout.Layout,~route:Layout.Route,~descriptor:T.Descriptor<S>,value:Provider.Slot(~S,~resources,~route,~descriptor)) -> Provider.Slot(~S,~resources,~route,~descriptor) & Maybe<&1,Reader.Reader<S,descriptor,resources,route>>:
  match value:
    case Layout.ResourceSlot{Layout.Viewed{store,view},stamp}:registered(~S,~resources,~route,~descriptor,view,stamp,Store.register(~S,~descriptor,~resources,~route,store))
def outcome(~S:Data,~resources:Layout.Layout,~route:Layout.Route,~descriptor:T.Descriptor<S>,owners:Layout.resources(~S,resources),reader:Maybe<&1,Reader.Reader<S,descriptor,resources,route>>) -> Registration<S,resources,route,descriptor>:
  match reader:
    case None{}:Refused{owners}
    case Some{reader}:Registered{owners,reader}
def restored(~S:Data,~resources:Layout.Layout,~route:Layout.Route,~descriptor:T.Descriptor<S>,~payload:{Layout.payload(resources,route) == Store.Store<S,descriptor> : Type},~view:{Layout.view(resources,route) == Store.View<S,descriptor> : Data},rest:Layout.resource_rest(~S,resources,route),result:Provider.Slot(~S,~resources,~route,~descriptor) & Maybe<&1,Reader.Reader<S,descriptor,resources,route>>) -> Registration<S,resources,route,descriptor>:
  match result:
    case (slot,reader):outcome(~S,~resources,~route,~descriptor,Layout.resource_put(~S,resources,route,rest,Cast.slot(~S,~Layout.key(resources,route),~Layout.origin(resources,route),~Store.Store<S,descriptor>,~Layout.payload(resources,route),~Store.View<S,descriptor>,~Layout.view(resources,route),Equal.sym(Type,Layout.payload(resources,route),Store.Store<S,descriptor>,payload),Equal.sym(Data,Layout.view(resources,route),Store.View<S,descriptor>,view),slot)),reader)
def taken(~S:Data,~resources:Layout.Layout,~route:Layout.Route,~descriptor:T.Descriptor<S>,~payload:{Layout.payload(resources,route) == Store.Store<S,descriptor> : Type},~view:{Layout.view(resources,route) == Store.View<S,descriptor> : Data},result:Layout.resource_rest(~S,resources,route) & Layout.ResourceSlot<S,Layout.stored(resources,route),Layout.key(resources,route),Layout.origin(resources,route)>) -> Registration<S,resources,route,descriptor>:
  match result:
    case (rest,owner):restored(~S,~resources,~route,~descriptor,~payload,~view,rest,slot(~S,~resources,~route,~descriptor,Cast.slot(~S,~Layout.key(resources,route),~Layout.origin(resources,route),~Layout.payload(resources,route),~Store.Store<S,descriptor>,~Layout.view(resources,route),~Store.View<S,descriptor>,payload,view,owner)))
# Trusted schema setup uses actual canonical resource owners. Reader IDs come
# only from this selected Store; registration refreshes its metadata cache while
# preserving the resource's write stamp and graph.
def register(~S:Data,~resources:Layout.Layout,~route:Layout.Route,~valid:{Layout.grant_valid(~resources,~route) == True{} : Bool},~descriptor:T.Descriptor<S>,~payload:{Layout.payload(resources,route) == Store.Store<S,descriptor> : Type},~view:{Layout.view(resources,route) == Store.View<S,descriptor> : Data},~protected:{Layout.policy(resources,route) == Policy.ProtectedRelation{S,descriptor} : Policy.Policy},owners:Layout.resources(~S,resources)) -> Registration<S,resources,route,descriptor>:
  taken(~S,~resources,~route,~descriptor,~payload,~view,Layout.resource_take(~S,resources,route,owners))

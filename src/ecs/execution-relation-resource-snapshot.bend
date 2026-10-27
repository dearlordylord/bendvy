import Base
import ./execution-composer-layout.bend as Layout
import ./execution-resource-policy.bend as Policy
import ./execution-relation-resource-publication.bend as Cast
import ./execution-relation-store.bend as Store
import ./relation-types.bend as T

type GraphView<-S:Data> is Data:
  GraphView{route:Layout.Route,descriptor:T.Descriptor<S>,namespace:U32,graph:T.Graph<S>}
def Program(~S:Data,~resources:Layout.Layout) -> Type:
  Layout.resources(~S,resources) -> Layout.resources(~S,resources) & List<&2,GraphView<S>>
def empty(~S:Data,~resources:Layout.Layout,owners:Layout.resources(~S,resources)) -> Layout.resources(~S,resources) & List<&2,GraphView<S>>:
  (owners,[])
def observed(~S:Data,~descriptor:T.Descriptor<S>,~key:String,~origin:Layout.Layout,route:Layout.Route,slot:Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S,descriptor>,Store.View<S,descriptor>>,key,origin>) -> Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S,descriptor>,Store.View<S,descriptor>>,key,origin> & GraphView<S>:
  match slot:
    case Layout.ResourceSlot{Layout.Viewed{Store.Store{+namespace,+graph,failures,sequence,nextReader},cache},stamp}:(Layout.ResourceSlot{Layout.Viewed{Store.Store{namespace,graph,failures,sequence,nextReader},cache},stamp},GraphView{route,descriptor,namespace,graph})
def restored(~S:Data,~resources:Layout.Layout,~route:Layout.Route,~descriptor:T.Descriptor<S>,~payload:{Layout.payload(resources,route) == Store.Store<S,descriptor> : Type},~view:{Layout.view(resources,route) == Store.View<S,descriptor> : Data},previous:List<&2,GraphView<S>>,rest:Layout.resource_rest(~S,resources,route),result:Layout.ResourceSlot<S,Layout.Viewed<Store.Store<S,descriptor>,Store.View<S,descriptor>>,Layout.key(resources,route),Layout.origin(resources,route)> & GraphView<S>) -> Layout.resources(~S,resources) & List<&2,GraphView<S>>:
  match result:
    case (slot,seen):(Layout.resource_put(~S,resources,route,rest,Cast.slot(~S,~Layout.key(resources,route),~Layout.origin(resources,route),~Store.Store<S,descriptor>,~Layout.payload(resources,route),~Store.View<S,descriptor>,~Layout.view(resources,route),Equal.sym(Type,Layout.payload(resources,route),Store.Store<S,descriptor>,payload),Equal.sym(Data,Layout.view(resources,route),Store.View<S,descriptor>,view),slot)),seen <> previous)
def selected(~S:Data,~resources:Layout.Layout,~route:Layout.Route,~descriptor:T.Descriptor<S>,~payload:{Layout.payload(resources,route) == Store.Store<S,descriptor> : Type},~view:{Layout.view(resources,route) == Store.View<S,descriptor> : Data},previous:List<&2,GraphView<S>>,result:Layout.resource_rest(~S,resources,route) & Layout.ResourceSlot<S,Layout.stored(resources,route),Layout.key(resources,route),Layout.origin(resources,route)>) -> Layout.resources(~S,resources) & List<&2,GraphView<S>>:
  match result:
    case (rest,slot):restored(~S,~resources,~route,~descriptor,~payload,~view,previous,rest,observed(~S,~descriptor,~Layout.key(resources,route),~Layout.origin(resources,route),route,Cast.slot(~S,~Layout.key(resources,route),~Layout.origin(resources,route),~Layout.payload(resources,route),~Store.Store<S,descriptor>,~Layout.view(resources,route),~Store.View<S,descriptor>,payload,view,slot)))
def gathered(~S:Data,~resources:Layout.Layout,~route:Layout.Route,~descriptor:T.Descriptor<S>,~payload:{Layout.payload(resources,route) == Store.Store<S,descriptor> : Type},~view:{Layout.view(resources,route) == Store.View<S,descriptor> : Data},result:Layout.resources(~S,resources) & List<&2,GraphView<S>>) -> Layout.resources(~S,resources) & List<&2,GraphView<S>>:
  match result:
    case (owners,previous):selected(~S,~resources,~route,~descriptor,~payload,~view,previous,Layout.resource_take(~S,resources,route,owners))
# A closed grant extends this observer beside its mutating dispatcher. It never
# grants gameplay access to the graph owner, failure channel or resource lens.
def extend(~S:Data,~resources:Layout.Layout,~route:Layout.Route,~descriptor:T.Descriptor<S>,~payload:{Layout.payload(resources,route) == Store.Store<S,descriptor> : Type},~view:{Layout.view(resources,route) == Store.View<S,descriptor> : Data},~protected:{Layout.policy(resources,route) == Policy.ProtectedRelation{S,descriptor} : Policy.Policy},previous:Program(~S,~resources)) -> Program(~S,~resources):
  owners => gathered(~S,~resources,~route,~descriptor,~payload,~view,previous(owners))

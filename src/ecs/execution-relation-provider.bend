import Base
import ./execution-composer-layout.bend as Layout
import ./execution-resource-policy.bend as Policy
import ./execution-relation-context.bend as Context
import ./execution-relation-store.bend as Store
import ./relation-types.bend as T

# Provisioning gives the canonical leaf its actual protected access policy.
# Persistence remains independent; this leaf has ordinary persistence behavior.
def layout(~S:Data,~descriptor:T.Descriptor<S>,key:String) -> Layout.Layout:
  Layout.LayoutLeaf{Store.Store<S,descriptor>,Store.View<S,descriptor>,Store.project(~S,~descriptor),key,Policy.ProtectedRelation{S,descriptor}}

# Authority is derived from the actual full schema and exact selected leaf, not
# from a key lookup or a policy tag interpreted as a payload type.
def bind(~S:Data,~WR:Type,~resources:Layout.Layout,~same:{WR == Layout.resources(~S,resources) : Type},~route:Layout.Route,~valid:{Layout.grant_valid(~resources,~route) == True{} : Bool},~descriptor:T.Descriptor<S>,~payload:{Layout.payload(resources,route) == Store.Store<S,descriptor> : Type},~view:{Layout.view(resources,route) == Store.View<S,descriptor> : Data},~protected:{Layout.policy(resources,route) == Policy.ProtectedRelation{S,descriptor} : Policy.Policy},context:Context.Context<S,WR,resources,same>) -> Context.Binding<S,WR,resources,same,route,descriptor,payload,view,protected>:
  Context.Binding{context}

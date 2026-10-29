import Base
import ./execution-lifetime-scope-store.bend as Store
import ./execution-composer-layout.bend as Layout
import ./execution-resource-policy.bend as Policy

# Setup receives the namespace from the actual Factory/SchemaCreated context.
def layout(~S:Data,key:String) -> Layout.Layout:
  Layout.LayoutLeaf{Store.Store<S>,Store.View<S>,Store.project(~S),key,Policy.ProtectedLifetimeScope{S}}

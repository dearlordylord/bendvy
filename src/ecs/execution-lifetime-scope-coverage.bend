import Base
import ./execution-command-permission.bend as Permission
import ./execution-composer-layout.bend as Layout
import ./execution-resource-policy.bend as Policy
import ./execution-relation-resource-snapshot.bend as Snapshot
import ./execution-relation-failure-retention.bend as Retention

# Cleanup may mutate every declared relation family. It refuses before mutation
# if the accepted catalogue omits any protected graph in the actual root layout.
def contains(~S:Data,~resources:Layout.Layout,+route:Layout.Route,relations:Permission.Relations<S,resources>) -> Bool:
  match relations:
    case Permission.NoRelations{}:False{}
    case Permission.RelationAllowed{selected,_,_,_,_,_,rest}:Bool.or(Permission.same_route(route,selected),contains(~S,~resources,route,rest))
    case Permission.ScopeAllowed{_,_,_,_,_,rest}:contains(~S,~resources,route,rest)
def append(prefix:Layout.Route,+suffix:Layout.Route) -> Layout.Route:
  match prefix:
    case Layout.AtLeaf{}:suffix
    case Layout.InLeft{rest}:Layout.InLeft{append(rest,suffix)}
    case Layout.InRight{rest}:Layout.InRight{append(rest,suffix)}
def leaf(~S:Data,~resources:Layout.Layout,policy:Policy.Policy,route:Layout.Route,relations:Permission.Relations<S,resources>) -> Bool:
  match policy:
    case Policy.ProtectedRelation{_,_}:contains(~S,~resources,route,relations)
    case Policy.Ordinary{}:True{}
    case Policy.ProtectedLifetimeScope{_}:True{}
def layout(~S:Data,~resources:Layout.Layout,current:Layout.Layout,+prefix:Layout.Route,+relations:Permission.Relations<S,resources>) -> Bool:
  match current:
    case Layout.EmptyLayout{}:True{}
    case Layout.LayoutLeaf{_,_,_,_,policy}:leaf(~S,~resources,policy,prefix,relations)
    case Layout.ClassifiedLayoutLeaf{_,_,_,_,_,policy}:leaf(~S,~resources,policy,prefix,relations)
    case Layout.LayoutPair{left,right}:Bool.and(layout(~S,~resources,left,append(prefix,Layout.InLeft{Layout.AtLeaf{}}),relations),layout(~S,~resources,right,append(prefix,Layout.InRight{Layout.AtLeaf{}}),relations))
def namespaces(~S:Data,+namespace:U32,views:List<&2,Snapshot.GraphView<S>>) -> Bool:
  match views:
    case []:True{}
    case Snapshot.GraphView{_,_,stored,_} <> rest:Bool.and(U32.is_eq(namespace,stored),namespaces(~S,namespace,rest))

def scope_contains(-S:Data,-resources:Layout.Layout,+route:Layout.Route,relations:Permission.Relations<S,resources>) -> Bool:
  match relations:
    case Permission.NoRelations{}:False{}
    case Permission.RelationAllowed{_,_,_,_,_,_,rest}:scope_contains(S,resources,route,rest)
    case Permission.ScopeAllowed{selected,_,_,_,_,rest}:Bool.or(Permission.same_route(route,selected),scope_contains(S,resources,route,rest))
def scopes_leaf(-S:Data,-resources:Layout.Layout,policy:Policy.Policy,route:Layout.Route,relations:Permission.Relations<S,resources>) -> Bool:
  match policy:
    case Policy.ProtectedLifetimeScope{_}:scope_contains(S,resources,route,relations)
    case Policy.ProtectedRelation{_,_}:True{}
    case Policy.Ordinary{}:True{}
def scopes_layout(-S:Data,-resources:Layout.Layout,current:Layout.Layout,+prefix:Layout.Route,+relations:Permission.Relations<S,resources>) -> Bool:
  match current:
    case Layout.EmptyLayout{}:True{}
    case Layout.LayoutLeaf{_,_,_,_,policy}:scopes_leaf(S,resources,policy,prefix,relations)
    case Layout.ClassifiedLayoutLeaf{_,_,_,_,_,policy}:scopes_leaf(S,resources,policy,prefix,relations)
    case Layout.LayoutPair{left,right}:Bool.and(scopes_layout(S,resources,left,append(prefix,Layout.InLeft{Layout.AtLeaf{}}),relations),scopes_layout(S,resources,right,append(prefix,Layout.InRight{Layout.AtLeaf{}}),relations))
def scope_routes(-S:Data,-resources:Layout.Layout,relations:Permission.Relations<S,resources>) -> List<&2,Layout.Route>:
  match relations:
    case Permission.NoRelations{}:[]
    case Permission.RelationAllowed{_,_,_,_,_,_,rest}:scope_routes(S,resources,rest)
    case Permission.ScopeAllowed{route,_,_,_,_,rest}:route <> scope_routes(S,resources,rest)
def protected_leaf(policy:Policy.Policy) -> Bool:
  match policy:
    case Policy.ProtectedRelation{_,_}:True{}
    case Policy.ProtectedLifetimeScope{_}:True{}
    case Policy.Ordinary{}:False{}
def has_protected(current:Layout.Layout) -> Bool:
  match current:
    case Layout.EmptyLayout{}:False{}
    case Layout.LayoutLeaf{_,_,_,_,policy}:protected_leaf(policy)
    case Layout.ClassifiedLayoutLeaf{_,_,_,_,_,policy}:protected_leaf(policy)
    case Layout.LayoutPair{left,right}:Bool.or(has_protected(left),has_protected(right))
def provisioned_leaf(policy:Policy.Policy,route:Layout.Route,graphs:List<&2,Layout.Route>,scopes:List<&2,Layout.Route>) -> Bool:
  match policy:
    case Policy.Ordinary{}:True{}
    case Policy.ProtectedRelation{_,_}:Retention.contains(route,graphs)
    case Policy.ProtectedLifetimeScope{_}:Retention.contains(route,scopes)
def provisioned_layout(current:Layout.Layout,+prefix:Layout.Route,+graphs:List<&2,Layout.Route>,+scopes:List<&2,Layout.Route>) -> Bool:
  match current:
    case Layout.EmptyLayout{}:True{}
    case Layout.LayoutLeaf{_,_,_,_,policy}:provisioned_leaf(policy,prefix,graphs,scopes)
    case Layout.ClassifiedLayoutLeaf{_,_,_,_,_,policy}:provisioned_leaf(policy,prefix,graphs,scopes)
    case Layout.LayoutPair{left,right}:Bool.and(provisioned_layout(left,append(prefix,Layout.InLeft{Layout.AtLeaf{}}),graphs,scopes),provisioned_layout(right,append(prefix,Layout.InRight{Layout.AtLeaf{}}),graphs,scopes))
def cleanup_complete(~S:Data,~resources:Layout.Layout,+relations:Permission.Relations<S,resources>,routes:Maybe<&2,Permission.CleanupRoutes>) -> Bool:
  match routes:
    case None{}:Bool.and(layout(~S,~resources,resources,Layout.AtLeaf{},relations),scopes_layout(S,resources,resources,Layout.AtLeaf{},relations))
    case Some{Permission.CleanupRoutes{graphs,scopes}}:provisioned_layout(resources,Layout.AtLeaf{},graphs,scopes)
def cleanup_scopes(-S:Data,-resources:Layout.Layout,relations:Permission.Relations<S,resources>,routes:Maybe<&2,Permission.CleanupRoutes>) -> List<&2,Layout.Route>:
  match routes:
    case None{}:scope_routes(S,resources,relations)
    case Some{Permission.CleanupRoutes{_,scopes}}:scopes

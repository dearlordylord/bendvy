import Base
import ./execution-command-permission.bend as Permission
import ./execution-composer-layout.bend as Layout
import ./execution-resource-policy.bend as Policy
import ./execution-relation-resource-snapshot.bend as Snapshot

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

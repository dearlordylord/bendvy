import Base
import ./execution-composer-layout.bend as L
import ./owner-product.bend as Product
import ./execution-command-permission.bend as P
import ./execution-relation-resource-dispatch.bend as G
import ./execution-lifetime-scope-resource-dispatch.bend as Scope
import ./execution-relation-resource-snapshot.bend as Snapshot
import ./execution-relation-operation.bend as Operation
import ./execution-lifetime-scope-store.bend as Store
import ./execution-relation-failure-retention.bend as Retention
import ./execution-schema-provisioning.bend as Provision
import ./entity-allocator.bend as A
import ./change-tick.bend as Tick

def graph_left(~S:Data,~left:L.Layout,~right:L.Layout,rightOwner:L.resources(~S,right),result:A.Allocator & (L.resources(~S,left) & G.Outcome<S>)) -> A.Allocator & (L.resources(~S,L.LayoutPair{left,right}) & G.Outcome<S>):
  match result:
    case (allocator,(leftOwner,outcome)):(allocator,(Product.Owner{leftOwner,rightOwner},outcome))
def graph_right(~S:Data,~left:L.Layout,~right:L.Layout,leftOwner:L.resources(~S,left),result:A.Allocator & (L.resources(~S,right) & G.Outcome<S>)) -> A.Allocator & (L.resources(~S,L.LayoutPair{left,right}) & G.Outcome<S>):
  match result:
    case (allocator,(rightOwner,outcome)):(allocator,(Product.Owner{leftOwner,rightOwner},outcome))
def graph(~S:Data,~left:L.Layout,~right:L.Layout,leftProgram:G.Program(~S,~left),rightProgram:G.Program(~S,~right),expected:U32,actual:U32,allocator:A.Allocator,owners:L.resources(~S,L.LayoutPair{left,right}),route:L.Route,operation:Operation.Operation<S>,tick:Tick.Tick) -> A.Allocator & (L.resources(~S,L.LayoutPair{left,right}) & G.Outcome<S>):
  match owners route:
    case Product.Owner{leftOwner,rightOwner} L.InLeft{rest}:graph_left(~S,~left,~right,rightOwner,leftProgram(expected,actual,allocator,leftOwner,rest,operation,tick))
    case Product.Owner{leftOwner,rightOwner} L.InRight{rest}:graph_right(~S,~left,~right,leftOwner,rightProgram(expected,actual,allocator,rightOwner,rest,operation,tick))
    case owners L.AtLeaf{}:(allocator,(owners,G.Undeclared{operation}))
def scope_left(~S:Data,~left:L.Layout,~right:L.Layout,rightOwner:L.resources(~S,right),result:A.Allocator & (L.resources(~S,left) & Scope.Outcome<S>)) -> A.Allocator & (L.resources(~S,L.LayoutPair{left,right}) & Scope.Outcome<S>):
  match result:
    case (allocator,(leftOwner,outcome)):(allocator,(Product.Owner{leftOwner,rightOwner},outcome))
def scope_right(~S:Data,~left:L.Layout,~right:L.Layout,leftOwner:L.resources(~S,left),result:A.Allocator & (L.resources(~S,right) & Scope.Outcome<S>)) -> A.Allocator & (L.resources(~S,L.LayoutPair{left,right}) & Scope.Outcome<S>):
  match result:
    case (allocator,(rightOwner,outcome)):(allocator,(Product.Owner{leftOwner,rightOwner},outcome))
def scopes(~S:Data,~left:L.Layout,~right:L.Layout,leftProgram:Scope.Program(~S,~left),rightProgram:Scope.Program(~S,~right),expected:U32,actual:U32,allocator:A.Allocator,owners:L.resources(~S,L.LayoutPair{left,right}),route:L.Route,request:Store.Request<S>,tick:Tick.Tick) -> A.Allocator & (L.resources(~S,L.LayoutPair{left,right}) & Scope.Outcome<S>):
  match owners route:
    case Product.Owner{leftOwner,rightOwner} L.InLeft{rest}:scope_left(~S,~left,~right,rightOwner,leftProgram(expected,actual,allocator,leftOwner,rest,request,tick))
    case Product.Owner{leftOwner,rightOwner} L.InRight{rest}:scope_right(~S,~left,~right,leftOwner,rightProgram(expected,actual,allocator,rightOwner,rest,request,tick))
    case owners L.AtLeaf{}:(allocator,(owners,Scope.Undeclared{request}))
def prefix(left:Bool,route:L.Route) -> L.Route:
  match left:
    case True{}:L.InLeft{route}
    case False{}:L.InRight{route}
def views(-S:Data,+left:Bool,values:List<&2,Snapshot.GraphView<S>>) -> List<&2,Snapshot.GraphView<S>>:
  match values:
    case []:[]
    case Snapshot.GraphView{route,descriptor,namespace,graph} <> rest:Snapshot.GraphView{prefix(left,route),descriptor,namespace,graph} <> views(S,left,rest)
def observed(~S:Data,~left:L.Layout,~right:L.Layout,leftResult:L.resources(~S,left) & List<&2,Snapshot.GraphView<S>>,rightResult:L.resources(~S,right) & List<&2,Snapshot.GraphView<S>>) -> L.resources(~S,L.LayoutPair{left,right}) & List<&2,Snapshot.GraphView<S>>:
  match leftResult rightResult:
    case (leftOwner,leftViews), (rightOwner,rightViews):(Product.Owner{leftOwner,rightOwner},List.append(&2,Snapshot.GraphView<S>,views(S,True{},leftViews),views(S,False{},rightViews)))
def snapshot(~S:Data,~left:L.Layout,~right:L.Layout,leftProgram:Snapshot.Program(~S,~left),rightProgram:Snapshot.Program(~S,~right),owners:L.resources(~S,L.LayoutPair{left,right})) -> L.resources(~S,L.LayoutPair{left,right}) & List<&2,Snapshot.GraphView<S>>:
  match owners:
    case Product.Owner{leftOwner,rightOwner}:observed(~S,~left,~right,leftProgram(leftOwner),rightProgram(rightOwner))
def selection(~S:Data,~left:L.Layout,~right:L.Layout,leftSelection:P.Selection<S,left>,rightSelection:P.Selection<S,right>) -> P.Selection<S,L.LayoutPair{left,right}>:
  match leftSelection rightSelection:
    case P.Selection{leftGraph,leftSnapshot,leftScopes,_} P.Selection{rightGraph,rightSnapshot,rightScopes,_}:P.Selection{graph(~S,~left,~right,leftGraph,rightGraph),snapshot(~S,~left,~right,leftSnapshot,rightSnapshot),scopes(~S,~left,~right,leftScopes,rightScopes),P.Unprovisioned{}}
def maintain(~S:Data,~left:L.Layout,~right:L.Layout,leftProgram:Retention.Program(~S,~left),rightProgram:Retention.Program(~S,~right),tick:Tick.Tick,owners:L.resources(~S,L.LayoutPair{left,right})) -> L.resources(~S,L.LayoutPair{left,right}):
  match tick owners:
    case +tick Product.Owner{leftOwner,rightOwner}:Product.Owner{leftProgram(tick,leftOwner),rightProgram(tick,rightOwner)}
def build(~S:Data,~left:L.Layout,~right:L.Layout,~Left:Type,~Right:Type,leftBuild:U32 -> Left -> L.resources(~S,left),rightBuild:U32 -> Right -> L.resources(~S,right),namespace:U32,seeds:Product.Owner<Left,Right>) -> L.resources(~S,L.LayoutPair{left,right}):
  match namespace seeds:
    case +namespace Product.Owner{leftSeed,rightSeed}:Product.Owner{leftBuild(namespace,leftSeed),rightBuild(namespace,rightSeed)}
def routes(+left:Bool,values:List<&2,L.Route>) -> List<&2,L.Route>:
  match values:
    case []:[]
    case route <> rest:prefix(left,route) <> routes(left,rest)
def joined_routes(left:List<&2,L.Route>,right:List<&2,L.Route>) -> List<&2,L.Route>:
  List.append(&2,L.Route,routes(True{},left),routes(False{},right))
def preflight_returned(~S:Data,~left:L.Layout,~right:L.Layout,leftResult:L.resources(~S,left) & Bool,rightResult:L.resources(~S,right) & Bool) -> L.resources(~S,L.LayoutPair{left,right}) & Bool:
  match leftResult rightResult:
    case (leftOwner,leftValid), (rightOwner,rightValid):(Product.Owner{leftOwner,rightOwner},Bool.and(leftValid,rightValid))
def preflight(~S:Data,~left:L.Layout,~right:L.Layout,leftProgram:U32 -> L.resources(~S,left) -> L.resources(~S,left) & Bool,rightProgram:U32 -> L.resources(~S,right) -> L.resources(~S,right) & Bool,namespace:U32,owners:L.resources(~S,L.LayoutPair{left,right})) -> L.resources(~S,L.LayoutPair{left,right}) & Bool:
  match namespace owners:
    case +namespace Product.Owner{leftOwner,rightOwner}:preflight_returned(~S,~left,~right,leftProgram(namespace,leftOwner),rightProgram(namespace,rightOwner))
def pair(~S:Data,~left:L.Layout,~right:L.Layout,~Left:Type,~Right:Type,leftProvision:Provision.Blueprint<S,left,Left>,rightProvision:Provision.Blueprint<S,right,Right>) -> Provision.Blueprint<S,L.LayoutPair{left,right},Product.Owner<Left,Right>>:
  match leftProvision rightProvision:
    case Provision.Blueprint{leftBuild,leftGraphs,leftScopes,leftSelection,leftRetention,leftPreflight} Provision.Blueprint{rightBuild,rightGraphs,rightScopes,rightSelection,rightRetention,rightPreflight}:Provision.Blueprint{build(~S,~left,~right,~Left,~Right,leftBuild,rightBuild),joined_routes(leftGraphs,rightGraphs),joined_routes(leftScopes,rightScopes),selection(~S,~left,~right,leftSelection,rightSelection),maintain(~S,~left,~right,leftRetention,rightRetention),preflight(~S,~left,~right,leftPreflight,rightPreflight)}

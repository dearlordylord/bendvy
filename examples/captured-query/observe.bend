import Base
import ./schema.bend as S
import ./body.bend as B
import ./audit.bend as Audit
import ./app.bend as A
import ./payload.bend as P
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-resource-query-leaf.bend as Leaf
import ../../src/ecs/execution-parallel-scope.bend as Scope
import ../../src/ecs/execution-resource-query-execution.bend as Execution
import ../../src/ecs/execution-compiled-binding.bend as Binding
import ../../src/ecs/execution-prepared.bend as Prep
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-resource-admission.bend as Admission
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/inspector.bend as I
import ../../src/ecs/component.bend as Component
import ../../src/ecs/execution-inspector-component.bend as Columns
import ../../src/ecs/inspector-query-projection.bend as Rows
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-command-publication.bend as Publish
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-generalized-root-application.bend as General
import ../../src/ecs/execution-parallel-root-application.bend as Root
import ../../src/ecs/dependency-application.bend as App

def rebuilt(~Owner:Type,~Node:Type,rebuild:Owner -> Node,result:Owner & String) -> Node & String:
  match result:
    case (owner,text):(rebuild(owner),text)
def node(~Compilation:Type,~World:Type,~Owner:Type,~Evidence:Data,~Permit:Data,observe:Owner -> Owner & String,held:Leaf.Node<Compilation,World,Owner,Evidence,Permit>) -> Leaf.Node<Compilation,World,Owner,Evidence,Permit> & String:
  match held:
    case Leaf.Uninspected{Scope.CompiledBinding{compilation,owner}}:rebuilt(~Owner,~Leaf.Node<Compilation,World,Owner,Evidence,Permit>,owner=>Leaf.Uninspected{Scope.CompiledBinding{compilation,owner}},observe(owner))
    case Leaf.Inspected{Scope.CompiledBinding{compilation,owner},evidence,id,valid}:rebuilt(~Owner,~Leaf.Node<Compilation,World,Owner,Evidence,Permit>,owner=>Leaf.Inspected{Scope.CompiledBinding{compilation,owner},evidence,id,valid},observe(owner))
    case Leaf.Prepared{Execution.HeldReady{Binding.Binding{compilation,Prep.Prepared{namespace,owner,permits,provenance},evidence}}}:rebuilt(~Owner,~Leaf.Node<Compilation,World,Owner,Evidence,Permit>,owner=>Leaf.Prepared{Execution.HeldReady{Binding.Binding{compilation,Prep.Prepared{namespace,owner,permits,provenance},evidence}}},observe(owner))
    case Leaf.Prepared{Execution.HeldInventory{compilation,Prep.Inventory{owner,provenance},evidence}}:rebuilt(~Owner,~Leaf.Node<Compilation,World,Owner,Evidence,Permit>,owner=>Leaf.Prepared{Execution.HeldInventory{compilation,Prep.Inventory{owner,provenance},evidence}},observe(owner))
def args(retry:Bool,value:B.Args) -> B.Args:
  match retry:
    case True{}:B.Args{999}
    case False{}:value
def packed(retry:Bool,+ns:U32,+id:U32,+name:String,+access:List<&2,String>,+cursor:Maybe<&2,Tick.Tick>,+arguments:B.Args,+rows:List<&2,B.Row>,unused:List<(Array<U32> -> Array<U32> & Unit)>,result:P.Pack & P.Observation) -> B.Owner() & String:
  match arguments result:
    case B.Args{failAt}, (capture,P.Observation{first,second}):(Sys.Owner{ns,id,name,access,cursor,B.Local{capture,args(retry,arguments),rows,unused}},"namespace=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";access=" ++ List.show(&2,String,x => x,access) ++ ";cursor=" ++ Tick.cursor_show(cursor) ++ ";capture={" ++ P.text(first) ++ ";" ++ P.text(second) ++ "};failAt=" ++ U32.show(failAt) ++ ";outputs=" ++ List.show(&2,B.Row,B.row,rows))
def query_owner(retry:Bool,owner:B.Owner()) -> B.Owner() & String:
  match owner:
    case Sys.Owner{ns,id,name,access,cursor,B.Local{capture,arguments,rows,unused}}:packed(retry,ns,id,name,access,cursor,arguments,rows,unused,P.project(capture))
def audit_owner(owner:Audit.Owner()) -> Audit.Owner() & String:
  match owner:
    case Sys.Owner{+ns,+id,+name,+access,+cursor,local}:(Sys.Owner{ns,id,name,access,cursor,local},"namespace=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";access=" ++ List.show(&2,String,x => x,access) ++ ";cursor=" ++ Tick.cursor_show(cursor))
def audit_node(held:Audit.Node()) -> Audit.Node() & String:
  node(~Decl.Compilation<S.Workshop,S.Store(~S.Workshop),B.C(),B.R(),Audit.Ops>,~S.World(~S.Workshop),~Audit.Owner(),~Admission.Evidence<S.Workshop,S.components(),S.resources(),B.C(),B.R(),Audit.Ops,Audit.kernel>,~Prep.Permit<S.Workshop,S.Store(~S.Workshop)>,audit_owner,held)
def query_node(retry:Bool,held:B.Node()) -> B.Node() & String:
  node(~Decl.Compilation<S.Workshop,S.Store(~S.Workshop),B.C(),B.R(),B.Ops>,~S.World(~S.Workshop),~B.Owner(),~Admission.Evidence<S.Workshop,S.components(),S.resources(),B.C(),B.R(),B.Ops,B.kernel>,~Prep.Permit<S.Workshop,S.Store(~S.Workshop)>,query_owner(retry),held)
def joined(left:Audit.Node() & String,right:B.Node() & String) -> A.Nodes() & String:
  match left right:
    case (left,a), (right,b):(Product.Owner{left,right},"audit={" ++ a ++ "};captured={" ++ b ++ "}")
def nodes(retry:Bool,held:A.Nodes()) -> A.Nodes() & String:
  match held:
    case Product.Owner{left,right}:joined(audit_node(left),query_node(retry,right))
def row(value:Rows.Row<S.Workshop,P.Tree>) -> String:
  match value:
    case Rows.Row{_,I.Value{Component.Found{tree},_,_}}:P.text(tree)
    case _:"Absent"
def scanned(world:S.World(~S.Workshop)) -> I.Frame<S.Workshop,S.Store(~S.Workshop),Unit,Unit> & List<&2,Rows.Row<S.Workshop,P.Tree>>:
  Columns.scan(~S.Workshop,~S.Store(~S.Workshop),~Unit,~Unit,~S.components(),~L.AtLeaf{},~{==},~Rows.Required{},I.Frame{world,None{}})
def written(result:S.World(~S.Workshop) & Buffer.Receipt<S.Workshop,Array<U32>,Maybe<&1,Array<U32>>>) -> S.World(~S.Workshop):
  match result:
    case (world,_):world
def refresh_rows(rows:List<&2,Rows.Row<S.Workshop,P.Tree>>,+tick:Tick.Tick,world:S.World(~S.Workshop)) -> S.World(~S.Workshop):
  match rows:
    case []:world
    case Rows.Row{target,I.Value{Component.Found{tree},_,_}} <> rest:refresh_rows(rest,tick,written(Publish.family(~S.Workshop,~Unit,~Unit,~S.components(),~L.AtLeaf{},world,target,Some{P.array(tree)},tick)))
    case _ <> rest:refresh_rows(rest,tick,world)
def refresh_tick(rows:List<&2,Rows.Row<S.Workshop,P.Tree>>,result:S.World(~S.Workshop) & Tick.Tick) -> S.World(~S.Workshop):
  match result:
    case (world,tick):refresh_rows(rows,tick,world)
def refreshed(retry:Bool,rows:List<&2,Rows.Row<S.Workshop,P.Tree>>,world:S.World(~S.Workshop)) -> S.World(~S.Workshop):
  match retry:
    case True{}:refresh_tick(rows,W.advance_clock(~S.Workshop,~S.Store(~S.Workshop),~Unit,~Unit,world))
    case False{}:world
def world(retry:Bool,result:I.Frame<S.Workshop,S.Store(~S.Workshop),Unit,Unit> & List<&2,Rows.Row<S.Workshop,P.Tree>>) -> S.World(~S.Workshop) & String:
  match result:
    case (I.Frame{world,_},+rows):(refreshed(retry,rows,world),"cells=" ++ List.show(&2,Rows.Row<S.Workshop,P.Tree>,row,rows))
def observed(rebuild:S.World(~S.Workshop) -> A.Nodes() -> A.Application(),world:S.World(~S.Workshop) & String,nodes:A.Nodes() & String) -> A.Application() & String:
  match world nodes:
    case (world,a), (nodes,b):(rebuild(world,nodes),a ++ ";" ++ b)
def update(+retry:Bool,app:A.Application()) -> A.Application() & String:
  match app:
    case Root.Scheduled{App.State{General.Present{held,displaced},heldNodes,guards,handler,stateBindings},plan,bindings,rules,deferred}:observed(world => nodes => Root.Scheduled{App.State{General.Present{world,displaced},nodes,guards,handler,stateBindings},plan,bindings,rules,deferred},world(retry,scanned(held)),nodes(retry,heldNodes))
    case app:(app,"refused inventory retained")

def snapshot(app:A.Application()) -> A.Application() & String:update(False{},app)
def retried(result:A.Application() & String) -> A.Application():
  match result:
    case (app,_):app
def retry(app:A.Application()) -> A.Application():retried(update(True{},app))

import Base
import ./dependency-plan.bend as Plan
import ./execution-deferred-plan.bend as Deferred

type Explicit is Data:
  Explicit{before:U32,condition:Maybe<&2,U32>}
type Settings is Data:
  Settings{automatic:Bool,finalApply:Bool,ignored:List<&2,Plan.Edge>,explicit:List<&2,Explicit>}
type Automatic is Data:
  Automatic{distance:Nat,id:U32}
type Graph is Data:
  Graph{nodes:List<&2,Plan.Node<String>>,edges:List<&2,Plan.Edge>,syncs:List<&2,U32>,automatic:List<&2,Automatic>}
type Built is Data:
  Built{plan:Plan.Build<String>,syncs:List<&2,U32>}
type GraphResult is Data:
  GraphReady{graph:Graph}
  GraphRejected{reason:Plan.Invalid<String>}
def defaults() -> Settings:Settings{True{},True{},[],[]}
def member(+id:U32,ids:List<&2,U32>) -> Bool:
  match ids:
    case []:False{}
    case other <> rest:Bool.or(U32.is_eq(id,other),member(id,rest))
def edge_member(+before:U32,+after:U32,edges:List<&2,Plan.Edge>) -> Bool:
  match edges:
    case []:False{}
    case Plan.Edge{a,b} <> rest:Bool.or(Bool.and(U32.is_eq(a,before),U32.is_eq(b,after)),edge_member(before,after,rest))
def fresh_choice(used:Bool,candidate:U32,next:Maybe<&2,U32>) -> Maybe<&2,U32>:
  match used:
    case False{}:Some{candidate}
    case True{}:next
def fresh(fuel:Nat,+nodes:List<&2,Plan.Node<String>>,+candidate:U32) -> Maybe<&2,U32>:
  match fuel:
    case 0n:None{}
    case 1n++rest:fresh_choice(Plan.has(~String,nodes,candidate),candidate,fresh(rest,nodes,U32.add(candidate,1)))
def available(+nodes:List<&2,Plan.Node<String>>) -> Maybe<&2,U32>:
  fresh(1n+List.length(&2,Plan.Node<String>,nodes),nodes,0)
def explicit_target(explicit:Explicit) -> U32:
  match explicit:
    case Explicit{before,_}:before
def targets(explicit:List<&2,Explicit>) -> List<&2,U32>:
  match explicit:
    case []:[]
    case Explicit{before,_} <> rest:before <> targets(rest)
def check_explicit_entry(known:Bool,duplicate:Bool,id:U32,condition:Maybe<&2,U32>,next:Maybe<&2,Plan.Invalid<String>>) -> Maybe<&2,Plan.Invalid<String>>:
  match known duplicate condition:
    case False{} _ _:Some{Plan.UnknownDependency{id}}
    case True{} True{} _:Some{Plan.Duplicate{id}}
    case True{} False{} Some{_}:Some{Plan.InvalidCondition{id}}
    case True{} False{} None{}:next
def check_explicit(explicit:List<&2,Explicit>,+nodes:List<&2,Plan.Node<String>>) -> Maybe<&2,Plan.Invalid<String>>:
  match explicit:
    case []:None{}
    case Explicit{+before,condition} <> +rest:check_explicit_entry(Plan.has(~String,nodes,before),member(before,targets(rest)),before,condition,check_explicit(rest,nodes))
def check_ignored_entry(present:Bool,id:U32,next:Maybe<&2,Plan.Invalid<String>>) -> Maybe<&2,Plan.Invalid<String>>:
  match present:
    case True{}:next
    case False{}:Some{Plan.UnknownDependency{id}}
def check_ignored(ignored:List<&2,Plan.Edge>,+edges:List<&2,Plan.Edge>) -> Maybe<&2,Plan.Invalid<String>>:
  match ignored:
    case []:None{}
    case Plan.Edge{before,+after} <> rest:check_ignored_entry(edge_member(before,after,edges),after,check_ignored(rest,edges))
def redirect_edge(+target:U32,sync:U32,edge:Plan.Edge) -> Plan.Edge:
  match edge:
    case Plan.Edge{before,+after}:Plan.Edge{before,Bool.pick(U32,U32.is_eq(after,target),sync,after)}
def redirect(edges:List<&2,Plan.Edge>,+target:U32,+sync:U32) -> List<&2,Plan.Edge>:
  match edges:
    case []:[Plan.Edge{sync,target}]
    case edge <> rest:redirect_edge(target,sync,edge) <> redirect(rest,target,sync)
def add_sync(+id:U32,+target:U32,graph:Graph) -> Graph:
  match graph:
    case Graph{nodes,edges,syncs,automatic}:Graph{Plan.Node{id,[]} <> nodes,redirect(edges,target,id),id <> syncs,automatic}
def add_explicit_choice(choice:Maybe<&2,U32>,target:U32,graph:Graph) -> GraphResult:
  match choice:
    case None{}:GraphRejected{Plan.Cycle{}}
    case Some{id}:GraphReady{add_sync(id,target,graph)}
def add_explicit(target:U32,+graph:Graph) -> GraphResult:
  match graph:
    case Graph{+nodes,edges,syncs,automatic}:add_explicit_choice(available(nodes),target,Graph{nodes,edges,syncs,automatic})
def explicit_step(target:U32,result:GraphResult) -> GraphResult:
  match result:
    case GraphRejected{reason}:GraphRejected{reason}
    case GraphReady{graph}:add_explicit(target,graph)
def explicit_graph(explicit:List<&2,Explicit>,graph:Graph) -> GraphResult:
  match explicit:
    case []:GraphReady{graph}
    case Explicit{before,_} <> rest:explicit_step(before,explicit_graph(rest,graph))
def metadata_node(+syncs:List<&2,U32>,deferred:List<&2,U32>,node:Plan.Node<String>) -> Deferred.Node:
  match node:
    case Plan.Node{+id,_}:Deferred.Node{id,member(id,deferred),member(id,syncs),False{},member(id,syncs)}
def metadata(nodes:List<&2,Plan.Node<String>>,+syncs:List<&2,U32>,+deferred:List<&2,U32>) -> List<&2,Deferred.Node>:
  match nodes:
    case []:[]
    case node <> rest:metadata_node(syncs,deferred,node) <> metadata(rest,syncs,deferred)
def deferred_edges(edges:List<&2,Plan.Edge>,+ignored:List<&2,Plan.Edge>) -> List<&2,Deferred.Edge>:
  match edges:
    case []:[]
    case Plan.Edge{+before,+after} <> rest:Deferred.Edge{before,after,edge_member(before,after,ignored)} <> deferred_edges(rest,ignored)
def automatic_choice(same:Bool,id:U32,rest:Maybe<&2,U32>) -> Maybe<&2,U32>:
  match same:
    case True{}:Some{id}
    case False{}:rest
def automatic_id(automatic:List<&2,Automatic>,+distance:Nat) -> Maybe<&2,U32>:
  match automatic:
    case []:None{}
    case Automatic{other,id} <> rest:automatic_choice(Nat.is_eq(other,distance),id,automatic_id(rest,distance))
def keep_edge(same:Bool,edge:Plan.Edge,rest:List<&2,Plan.Edge>) -> List<&2,Plan.Edge>:
  match same:
    case True{}:rest
    case False{}:edge <> rest
def remove_edge(edges:List<&2,Plan.Edge>,+before:U32,+after:U32) -> List<&2,Plan.Edge>:
  match edges:
    case []:[]
    case Plan.Edge{+a,+b} <> rest:keep_edge(Bool.and(U32.is_eq(a,before),U32.is_eq(b,after)),Plan.Edge{a,b},remove_edge(rest,before,after))
def connect(+before:U32,+after:U32,+sync:U32,graph:Graph) -> Graph:
  match graph:
    case Graph{nodes,edges,syncs,automatic}:Graph{nodes,Plan.Edge{before,sync} <> Plan.Edge{sync,after} <> remove_edge(edges,before,after),syncs,automatic}
def allocated(before:U32,after:U32,distance:Nat,choice:Maybe<&2,U32>,graph:Graph) -> GraphResult:
  match choice graph:
    case None{} _:GraphRejected{Plan.Cycle{}}
    case Some{+id} Graph{nodes,edges,syncs,automatic}:GraphReady{connect(before,after,id,Graph{Plan.Node{id,[]} <> nodes,edges,id <> syncs,Automatic{distance,id} <> automatic})}
def reuse_automatic(before:U32,after:U32,distance:Nat,choice:Maybe<&2,U32>,+graph:Graph) -> GraphResult:
  match choice graph:
    case Some{id} graph:GraphReady{connect(before,after,id,graph)}
    case None{} Graph{+nodes,edges,syncs,automatic}:allocated(before,after,distance,available(nodes),Graph{nodes,edges,syncs,automatic})
def boundary_step(boundary:Deferred.Boundary,+graph:Graph) -> GraphResult:
  match boundary graph:
    case Deferred.Boundary{before,after,_,Some{id}} graph:GraphReady{connect(before,after,id,graph)}
    case Deferred.Boundary{before,after,+distance,None{}} Graph{nodes,edges,syncs,+automatic}:reuse_automatic(before,after,distance,automatic_id(automatic,distance),Graph{nodes,edges,syncs,automatic})
def boundary_result(boundary:Deferred.Boundary,result:GraphResult) -> GraphResult:
  match result:
    case GraphRejected{reason}:GraphRejected{reason}
    case GraphReady{graph}:boundary_step(boundary,graph)
def materialize(boundaries:List<&2,Deferred.Boundary>,graph:Graph) -> GraphResult:
  match boundaries:
    case []:GraphReady{graph}
    case boundary <> rest:boundary_result(boundary,materialize(rest,graph))
def synchronized(automatic:Bool,ignored:List<&2,Plan.Edge>,deferred:List<&2,U32>,+syncs:List<&2,U32>,automaticIds:List<&2,Automatic>,plan:Plan.Build<String>) -> GraphResult:
  match plan:
    case Plan.Rejected{reason}:GraphRejected{reason}
    case Plan.Planned{+nodes,+edges}:materialize(Deferred.plan(automatic,metadata(nodes,syncs,deferred),deferred_edges(edges,ignored)),Graph{nodes,edges,syncs,automaticIds})
def explicit_ready(automatic:Bool,ignored:List<&2,Plan.Edge>,deferred:List<&2,U32>,result:GraphResult) -> GraphResult:
  match result:
    case GraphRejected{reason}:GraphRejected{reason}
    case GraphReady{Graph{+nodes,+edges,syncs,automaticIds}}:synchronized(automatic,ignored,deferred,syncs,automaticIds,Plan.sort(~String,List.length(&2,Plan.Node<String>,nodes),nodes,edges))
def compiled(result:GraphResult) -> Built:
  match result:
    case GraphRejected{reason}:Built{Plan.Rejected{reason},[]}
    case GraphReady{Graph{+nodes,edges,syncs,_}}:Built{Plan.sort(~String,List.length(&2,Plan.Node<String>,nodes),nodes,edges),syncs}
def validated(invalid:Maybe<&2,Plan.Invalid<String>>,automatic:Bool,ignored:List<&2,Plan.Edge>,explicit:List<&2,Explicit>,deferred:List<&2,U32>,nodes:List<&2,Plan.Node<String>>,edges:List<&2,Plan.Edge>) -> Built:
  match invalid:
    case Some{reason}:Built{Plan.Rejected{reason},[]}
    case None{}:compiled(explicit_ready(automatic,ignored,deferred,explicit_graph(explicit,Graph{nodes,edges,[],[]})))

# Pinned Bevy ad678262 auto_insert_apply_deferred.rs: synchronize the graph,
# before dependent systems' conditions run. Synthetic nodes are library-only;
# their fresh IDs are checked against every actual and generated graph node.
# Conditioned explicit barriers are rejected rather than treated as guaranteed
# synchronization; this API exposes unconditional explicit-before placements.
def compile(settings:Settings,deferred:List<&2,U32>,plan:Plan.Build<String>) -> Built:
  match settings plan:
    case _ Plan.Rejected{reason}:Built{Plan.Rejected{reason},[]}
    case Settings{automatic,_,+ignored,+explicit} Plan.Planned{+nodes,+edges}:validated(Plan.first_error(~String,check_explicit(explicit,nodes),check_ignored(ignored,edges)),automatic,ignored,explicit,deferred,nodes,edges)

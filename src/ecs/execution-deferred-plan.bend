import Base

# Inputs are the already validated flattened DAG in topological order. The
# ordinary registry must derive hasDeferred from its owned command buffers.
type Node is Data:
  Node{id:U32,hasDeferred:Bool,explicit:Bool,conditional:Bool,exclusive:Bool}
type Edge is Data:
  Edge{before:U32,after:U32,ignoreDeferred:Bool}
type Position is Data:
  Position{id:U32,distance:Nat,pending:Bool}
type Explicit is Data:
  Explicit{distance:Nat,id:U32}
type State is Data:
  State{positions:List<&2,Position>,explicit:List<&2,Explicit>}
type Boundary is Data:
  Boundary{before:U32,after:U32,distance:Nat,reuse:Maybe<&2,U32>}

def node_id(node:Node) -> U32:
  match node:
    case Node{id,_,_,_,_}:id
def explicit(node:Node) -> Bool:
  match node:
    case Node{_,_,isExplicit,conditional,_}:Bool.and(isExplicit,Bool.not(conditional))
def exclusive(node:Node) -> Bool:
  match node:
    case Node{_,_,_,_,isExclusive}:isExclusive
def deferred(node:Node) -> Bool:
  match node:
    case Node{_,hasDeferred,_,_,_}:hasDeferred
def find_choice(same:Bool,node:Node,rest:Node) -> Node:
  match same:
    case True{}:node
    case False{}:rest
def find(nodes:List<&2,Node>,+id:U32) -> Node:
  match nodes:
    case []:Node{id,False{},False{},False{},False{}}
    case +node <> rest:find_choice(U32.is_eq(node_id(node),id),node,find(rest,id))
def position_choice(same:Bool,value:Position,rest:Position) -> Position:
  match same:
    case True{}:value
    case False{}:rest
def position(positions:List<&2,Position>,+id:U32) -> Position:
  match positions:
    case []:Position{id,0n,False{}}
    case Position{+other,distance,pending} <> rest:position_choice(U32.is_eq(other,id),Position{other,distance,pending},position(rest,id))
def keep_position(same:Bool,value:Position,rest:List<&2,Position>) -> List<&2,Position>:
  match same:
    case True{}:rest
    case False{}:value <> rest
def without(positions:List<&2,Position>,+id:U32) -> List<&2,Position>:
  match positions:
    case []:[]
    case Position{+other,distance,pending} <> rest:keep_position(U32.is_eq(other,id),Position{other,distance,pending},without(rest,id))
def update(positions:List<&2,Position>,value:Position) -> List<&2,Position>:
  match value:
    case Position{+id,distance,pending}:Position{id,distance,pending} <> without(positions,id)
def weight(needsSync:Bool,target:Node) -> Nat:
  match needsSync:
    case True{}:1n
    case False{}:Bool.pick(Nat,explicit(target),1n,0n)
def target_updated(positions:List<&2,Position>,+distance:Nat,+needsSync:Bool,+ignored:Bool,target:Node,current:Position) -> List<&2,Position>:
  match current:
    case Position{id,oldDistance,pending}:update(positions,Position{id,Nat.max(oldDistance,Nat.add(distance,weight(Bool.and(needsSync,Bool.not(ignored)),target))),Bool.or(pending,Bool.and(needsSync,ignored))})
def outgoing_edge(positions:List<&2,Position>,distance:Nat,needsSync:Bool,ignoreDeferred:Bool,+target:Node,current:Position) -> List<&2,Position>:
  target_updated(positions,distance,needsSync,Bool.and(ignoreDeferred,Bool.not(exclusive(target))),target,current)
def selected_edge(positions:List<&2,Position>,distance:Nat,needsSync:Bool,ignoreDeferred:Bool,target:Node,current:Position,matches:Bool) -> List<&2,Position>:
  match matches:
    case False{}:positions
    case True{}:outgoing_edge(positions,distance,needsSync,ignoreDeferred,target,current)
def outgoing(edges:List<&2,Edge>,+nodes:List<&2,Node>,+id:U32,+distance:Nat,+needsSync:Bool,+positions:List<&2,Position>) -> List<&2,Position>:
  match edges:
    case []:positions
    case Edge{before,+after,ignoreDeferred} <> rest:outgoing(rest,nodes,id,distance,needsSync,selected_edge(positions,distance,needsSync,ignoreDeferred,find(nodes,after),position(positions,after),U32.is_eq(before,id)))
def syncs(isExplicit:Bool,id:U32,distance:Nat,explicitNodes:List<&2,Explicit>) -> List<&2,Explicit>:
  match isExplicit:
    case True{}:Explicit{distance,id} <> explicitNodes
    case False{}:explicitNodes
def visit_position(+node:Node,edges:List<&2,Edge>,nodes:List<&2,Node>,positions:List<&2,Position>,explicitNodes:List<&2,Explicit>,current:Position) -> State:
  match current:
    case Position{+id,+distance,pending}:State{outgoing(edges,nodes,id,distance,Bool.and(Bool.not(explicit(node)),Bool.or(pending,deferred(node))),positions),syncs(explicit(node),id,distance,explicitNodes)}
def visit(+node:Node,edges:List<&2,Edge>,nodes:List<&2,Node>,state:State) -> State:
  match state:
    case State{+positions,explicitNodes}:visit_position(node,edges,nodes,positions,explicitNodes,position(positions,node_id(node)))
def distances(order:List<&2,Node>,+nodes:List<&2,Node>,+edges:List<&2,Edge>,state:State) -> State:
  match order:
    case []:state
    case node <> rest:distances(rest,nodes,edges,visit(node,edges,nodes,state))
def explicit_choice(same:Bool,id:U32,rest:Maybe<&2,U32>) -> Maybe<&2,U32>:
  match same:
    case True{}:Some{id}
    case False{}:rest
def reuse(explicitNodes:List<&2,Explicit>,+distance:Nat) -> Maybe<&2,U32>:
  match explicitNodes:
    case []:None{}
    case Explicit{other,id} <> rest:explicit_choice(Nat.is_eq(other,distance),id,reuse(rest,distance))
def boundary_step(before:U32,after:U32,from:Position,to:Position,target:Node,explicitNodes:List<&2,Explicit>,+rest:List<&2,Boundary>) -> List<&2,Boundary>:
  match from to target:
    case Position{_,distance,_} Position{_,+next,_} Node{_,_,isExplicit,_,_}:Bool.pick(List<&2,Boundary>,Bool.or(Nat.is_eq(distance,next),isExplicit),rest,Boundary{before,after,next,reuse(explicitNodes,next)} <> rest)
def boundaries(edges:List<&2,Edge>,+nodes:List<&2,Node>,+positions:List<&2,Position>,+explicitNodes:List<&2,Explicit>) -> List<&2,Boundary>:
  match edges:
    case []:[]
    case Edge{+before,+after,_} <> rest:boundary_step(before,after,position(positions,before),position(positions,after),find(nodes,after),explicitNodes,boundaries(rest,nodes,positions,explicitNodes))
def planned(nodes:List<&2,Node>,edges:List<&2,Edge>,state:State) -> List<&2,Boundary>:
  match state:
    case State{positions,explicitNodes}:boundaries(edges,nodes,positions,explicitNodes)

# Bevy ad678262, schedule/auto_insert_apply_deferred.rs build: distance rises
# for a needed sync or an unconditional explicit sync target. Ignored edges
# postpone deferred visibility through later nodes; exclusive targets override
# that suppression. Reuse one explicit boundary at the required distance.
# Final flushing is an executor setting, independent of this graph-build pass.
def plan(enabled:Bool,+order:List<&2,Node>,+edges:List<&2,Edge>) -> List<&2,Boundary>:
  match enabled:
    case False{}:[]
    case True{}:planned(order,edges,distances(order,order,edges,State{[],[]}))

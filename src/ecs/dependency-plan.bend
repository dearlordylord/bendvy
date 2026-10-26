import Base

type Node<Requirement:Data> is Data:
  Node{id:U32,requirements:List<&2,Requirement>}
type Edge is Data:
  Edge{before:U32,after:U32}
type Invalid<Requirement:Data> is Data:
  Duplicate{id:U32}
  UnknownDependency{id:U32}
  Missing{id:U32,requirement:Requirement}
  Cycle{}
  InvalidCondition{id:U32}
type Build<Requirement:Data> is Data:
  Planned{order:List<&2,Node<Requirement>>,edges:List<&2,Edge>}
  Rejected{reason:Invalid<Requirement>}

def node_id(~Requirement:Data,node:Node<Requirement>) -> U32:
  match node:
    case Node{id,_}:id

def has(~Requirement:Data,nodes:List<&2,Node<Requirement>>,+id:U32) -> Bool:
  match nodes:
    case []:False{}
    case Node{other,_} <> rest:Bool.or(U32.is_eq(other,id),has(~Requirement,rest,id))

def duplicate_step(~Requirement:Data,found:Bool,id:U32,next:Maybe<&2,Invalid<Requirement>>) -> Maybe<&2,Invalid<Requirement>>:
  match found:
    case True{}:Some{Duplicate{id}}
    case False{}:next

def duplicates(~Requirement:Data,nodes:List<&2,Node<Requirement>>) -> Maybe<&2,Invalid<Requirement>>:
  match nodes:
    case []:None{}
    case Node{+id,_} <> +rest:duplicate_step(~Requirement,has(~Requirement,rest,id),id,duplicates(~Requirement,rest))

def endpoint(~Requirement:Data,known:Bool,id:U32,next:Maybe<&2,Invalid<Requirement>>) -> Maybe<&2,Invalid<Requirement>>:
  match known:
    case False{}:Some{UnknownDependency{id}}
    case True{}:next

def endpoints(~Requirement:Data,edges:List<&2,Edge>,+nodes:List<&2,Node<Requirement>>) -> Maybe<&2,Invalid<Requirement>>:
  match edges:
    case []:None{}
    case Edge{+before,+after} <> rest:endpoint(~Requirement,has(~Requirement,nodes,before),before,endpoint(~Requirement,has(~Requirement,nodes,after),after,endpoints(~Requirement,rest,nodes)))

def requirement_step(~Requirement:Data,present:Bool,id:U32,requirement:Requirement,next:Maybe<&2,Invalid<Requirement>>) -> Maybe<&2,Invalid<Requirement>>:
  match present:
    case False{}:Some{Missing{id,requirement}}
    case True{}:next

def requirements(~Requirement:Data,~available:Requirement -> Bool,needs:List<&2,Requirement>,+id:U32) -> Maybe<&2,Invalid<Requirement>>:
  match needs:
    case []:None{}
    case +first <> rest:requirement_step(~Requirement,available(first),id,first,requirements(~Requirement,~available,rest,id))

def first_error(~Requirement:Data,first:Maybe<&2,Invalid<Requirement>>,next:Maybe<&2,Invalid<Requirement>>) -> Maybe<&2,Invalid<Requirement>>:
  match first:
    case None{}:next
    case Some{reason}:Some{reason}

def provisioned(~Requirement:Data,~available:Requirement -> Bool,nodes:List<&2,Node<Requirement>>) -> Maybe<&2,Invalid<Requirement>>:
  match nodes:
    case []:None{}
    case Node{id,needs} <> rest:first_error(~Requirement,requirements(~Requirement,~available,needs,id),provisioned(~Requirement,~available,rest))

def predecessor_pending(~Requirement:Data,edges:List<&2,Edge>,+pending:List<&2,Node<Requirement>>,+id:U32) -> Bool:
  match edges:
    case []:False{}
    case Edge{before,after} <> rest:Bool.or(Bool.and(U32.is_eq(after,id),has(~Requirement,pending,before)),predecessor_pending(~Requirement,rest,pending,id))

def choose(~Requirement:Data,blocked:Bool,node:Node<Requirement>,next:Maybe<&2,Node<Requirement>>) -> Maybe<&2,Node<Requirement>>:
  match blocked:
    case False{}:Some{node}
    case True{}:next

def next_ready(~Requirement:Data,candidates:List<&2,Node<Requirement>>,+pending:List<&2,Node<Requirement>>,+edges:List<&2,Edge>) -> Maybe<&2,Node<Requirement>>:
  match candidates:
    case []:None{}
    case +first <> rest:choose(~Requirement,predecessor_pending(~Requirement,edges,pending,node_id(~Requirement,first)),first,next_ready(~Requirement,rest,pending,edges))

def keep_other(~Requirement:Data,same:Bool,node:Node<Requirement>,rest:List<&2,Node<Requirement>>) -> List<&2,Node<Requirement>>:
  match same:
    case True{}:rest
    case False{}:node <> rest

def remove(~Requirement:Data,nodes:List<&2,Node<Requirement>>,+id:U32) -> List<&2,Node<Requirement>>:
  match nodes:
    case []:[]
    case +first <> rest:keep_other(~Requirement,U32.is_eq(node_id(~Requirement,first),id),first,remove(~Requirement,rest,id))

def prepend(~Requirement:Data,node:Node<Requirement>,built:Build<Requirement>) -> Build<Requirement>:
  match built:
    case Rejected{reason}:Rejected{reason}
    case Planned{order,edges}:Planned{node <> order,edges}

def selected(~Requirement:Data,choice:Maybe<&2,Node<Requirement>>,next:Node<Requirement> -> Build<Requirement>) -> Build<Requirement>:
  match choice:
    case None{}:Rejected{Cycle{}}
    case Some{node}:next(node)

def exhausted(~Requirement:Data,pending:List<&2,Node<Requirement>>,edges:List<&2,Edge>) -> Build<Requirement>:
  match pending:
    case []:Planned{[],edges}
    case _ :Rejected{Cycle{}}

def progress(~Requirement:Data,+pending:List<&2,Node<Requirement>>,+edges:List<&2,Edge>,next:List<&2,Node<Requirement>> -> Build<Requirement>) -> Build<Requirement>:
  match pending:
    case []:Planned{[],edges}
    case _ :selected(~Requirement,next_ready(~Requirement,pending,pending,edges),+node => prepend(~Requirement,node,next(remove(~Requirement,pending,node_id(~Requirement,node)))))

def sort(~Requirement:Data,fuel:Nat,pending:List<&2,Node<Requirement>>,+edges:List<&2,Edge>) -> Build<Requirement>:
  match fuel:
    case 0n:exhausted(~Requirement,pending,edges)
    case 1n+prior:progress(~Requirement,pending,edges,remaining => sort(~Requirement,prior,remaining,edges))

def validated(~Requirement:Data,invalid:Maybe<&2,Invalid<Requirement>>,+nodes:List<&2,Node<Requirement>>,edges:List<&2,Edge>) -> Build<Requirement>:
  match invalid:
    case Some{reason}:Rejected{reason}
    case None{}:sort(~Requirement,List.length(&2,Node<Requirement>,nodes),nodes,edges)

# Metadata does not grant access. The ordinary registration constructor supplies
# these nodes from the declarations that also construct its confined capabilities.
def build(~Requirement:Data,~available:Requirement -> Bool,+nodes:List<&2,Node<Requirement>>,+edges:List<&2,Edge>) -> Build<Requirement>:
  validated(~Requirement,first_error(~Requirement,duplicates(~Requirement,nodes),first_error(~Requirement,endpoints(~Requirement,edges,nodes),provisioned(~Requirement,~available,nodes))),nodes,edges)

def before(first:U32,second:U32) -> Edge:Edge{first,second}
def after(second:U32,first:U32) -> Edge:Edge{first,second}
def chain_from(ids:List<&2,U32>,+previous:U32) -> List<&2,Edge>:
  match ids:
    case []:[]
    case +next <> rest:Edge{previous,next} <> chain_from(rest,next)
def chain(ids:List<&2,U32>) -> List<&2,Edge>:
  match ids:
    case []:[]
    case first <> rest:chain_from(rest,first)

def ready_member(~Requirement:Data,blocked:Bool,node:Node<Requirement>,rest:List<&2,Node<Requirement>>) -> List<&2,Node<Requirement>>:
  match blocked:
    case True{}:rest
    case False{}:node <> rest

def ready_scan(~Requirement:Data,candidates:List<&2,Node<Requirement>>,+pending:List<&2,Node<Requirement>>,+edges:List<&2,Edge>) -> List<&2,Node<Requirement>>:
  match candidates:
    case []:[]
    case +first <> rest:ready_member(~Requirement,predecessor_pending(~Requirement,edges,pending,node_id(~Requirement,first)),first,ready_scan(~Requirement,rest,pending,edges))

# Pending contains every not-yet-completed node, including disabled or refused
# work until its completion is recorded. Success is not a prerequisite here.
def ready(~Requirement:Data,+pending:List<&2,Node<Requirement>>,edges:List<&2,Edge>) -> List<&2,Node<Requirement>>:
  ready_scan(~Requirement,pending,pending,edges)

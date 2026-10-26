import Base
import ./dependency-plan.bend as Plan
import ../../../../src/ecs/dependency-executor.bend as Exec
import ./spec.bend as Spec
import ./LAWS.bend as Laws

def handled_equal(-State:Data,-Requirement:Data,-Error:Data,-Out:Data,next:State -> List<&2,Exec.Observation<Error,Out>> -> Exec.ExecutionResult<State,Requirement,Error,Out>,returned:State & Exec.Handling,+error:Error,+events:List<&2,Exec.Observation<Error,Out>>) -> {Exec.handled(~State,~Requirement,~Error,~Out,next,returned,error,events) == Spec.after_handler(~State,~Requirement,~Error,~Out,next,returned,error,events) : Exec.ExecutionResult<State,Requirement,Error,Out>}:
  match returned:
    case (state,Exec.Continue{}):{==}
    case (state,Exec.Escalate{}):{==}

# ---- ready_exact ----
# Runtime-erased type arguments let these witnesses be inspected in a generic
# proof. The following lemmas relate each witness to the unchanged actual/spec code.
def member_value(-Requirement:Data,nodes:List<&2,Plan.Node<Requirement>>,+id:U32) -> Bool:
  match nodes:
    case []:False{}
    case Plan.Node{other,_} <> rest:Bool.or(U32.is_eq(other,id),member_value(Requirement,rest,id))

def blocked_value(-Requirement:Data,edges:List<&2,Plan.Edge>,+pending:List<&2,Plan.Node<Requirement>>,+id:U32) -> Bool:
  match edges:
    case []:False{}
    case Plan.Edge{before,after} <> rest:Bool.or(Bool.and(U32.is_eq(after,id),member_value(Requirement,pending,before)),blocked_value(Requirement,rest,pending,id))

def member_actual(-Requirement:Data,nodes:List<&2,Plan.Node<Requirement>>,+id:U32) -> {member_value(Requirement,nodes,id) == Plan.has(~Requirement,nodes,id) : Bool}:
  match nodes:
    case []:{==}
    case Plan.Node{+other,_} <> +rest:
      %member_actual(Requirement,rest,id) : {Bool.or(U32.is_eq(other,id),member_value(Requirement,rest,id)) == Bool.or(U32.is_eq(other,id),_) : Bool}
      {==}

def member_spec(-Requirement:Data,nodes:List<&2,Plan.Node<Requirement>>,+id:U32) -> {member_value(Requirement,nodes,id) == Spec.includes(~Requirement,nodes,id) : Bool}:
  match nodes:
    case []:{==}
    case Plan.Node{+other,_} <> +rest:
      %member_spec(Requirement,rest,id) : {Bool.or(U32.is_eq(other,id),member_value(Requirement,rest,id)) == Bool.or(U32.is_eq(other,id),_) : Bool}
      {==}

def blocked_actual(-Requirement:Data,edges:List<&2,Plan.Edge>,+pending:List<&2,Plan.Node<Requirement>>,+id:U32) -> {blocked_value(Requirement,edges,pending,id) == Plan.predecessor_pending(~Requirement,edges,pending,id) : Bool}:
  match edges:
    case []:{==}
    case Plan.Edge{+before,+after} <> +rest:
      %member_actual(Requirement,pending,before) : {blocked_value(Requirement,Plan.Edge{before,after} <> rest,pending,id) == Bool.or(Bool.and(U32.is_eq(after,id),_),Plan.predecessor_pending(~Requirement,rest,pending,id)) : Bool}
      %blocked_actual(Requirement,rest,pending,id) : {blocked_value(Requirement,Plan.Edge{before,after} <> rest,pending,id) == Bool.or(Bool.and(U32.is_eq(after,id),member_value(Requirement,pending,before)),_) : Bool}
      {==}

def negate_block(+target:Bool,+present:Bool,+blocked:Bool) -> {Bool.not(Bool.or(Bool.and(target,present),blocked)) == Bool.and(Bool.or(Bool.not(target),Bool.not(present)),Bool.not(blocked)) : Bool}:
  match target present blocked:
    case False{} False{} False{}:{==}
    case False{} False{} True{}:{==}
    case False{} True{} False{}:{==}
    case False{} True{} True{}:{==}
    case True{} False{} False{}:{==}
    case True{} False{} True{}:{==}
    case True{} True{} False{}:{==}
    case True{} True{} True{}:{==}

def blocked_spec(-Requirement:Data,edges:List<&2,Plan.Edge>,+pending:List<&2,Plan.Node<Requirement>>,+id:U32) -> {Bool.not(blocked_value(Requirement,edges,pending,id)) == Spec.all_dependencies_satisfied(~Requirement,pending,id,edges) : Bool}:
  match edges:
    case []:{==}
    case Plan.Edge{+before,+after} <> +rest:
      %member_spec(Requirement,pending,before) : {Bool.not(blocked_value(Requirement,Plan.Edge{before,after} <> rest,pending,id)) == Bool.and(Bool.or(Bool.not(U32.is_eq(after,id)),Bool.not(_)),Spec.all_dependencies_satisfied(~Requirement,pending,id,rest)) : Bool}
      %blocked_spec(Requirement,rest,pending,id) : {Bool.not(blocked_value(Requirement,Plan.Edge{before,after} <> rest,pending,id)) == Bool.and(Bool.or(Bool.not(U32.is_eq(after,id)),Bool.not(member_value(Requirement,pending,before))),_) : Bool}
      negate_block(U32.is_eq(after,id),member_value(Requirement,pending,before),blocked_value(Requirement,rest,pending,id))

def keep_value(-Requirement:Data,blocked:Bool,node:Plan.Node<Requirement>,rest:List<&2,Plan.Node<Requirement>>) -> List<&2,Plan.Node<Requirement>>:
  match blocked:
    case False{}:node <> rest
    case True{}:rest

def scan_value(-Requirement:Data,nodes:List<&2,Plan.Node<Requirement>>,+pending:List<&2,Plan.Node<Requirement>>,+edges:List<&2,Plan.Edge>) -> List<&2,Plan.Node<Requirement>>:
  match nodes:
    case []:[]
    case Plan.Node{+id,needs} <> rest:keep_value(Requirement,blocked_value(Requirement,edges,pending,id),Plan.Node{id,needs},scan_value(Requirement,rest,pending,edges))

def keep_actual(-Requirement:Data,+blocked:Bool,+node:Plan.Node<Requirement>,+rest:List<&2,Plan.Node<Requirement>>) -> {keep_value(Requirement,blocked,node,rest) == Plan.ready_member(~Requirement,blocked,node,rest) : List<&2,Plan.Node<Requirement>>}:
  match blocked:
    case False{}:{==}
    case True{}:{==}

def keep_spec(-Requirement:Data,+blocked:Bool,+node:Plan.Node<Requirement>,+rest:List<&2,Plan.Node<Requirement>>) -> {keep_value(Requirement,blocked,node,rest) == Spec.include_ready(~Requirement,Bool.not(blocked),node,rest) : List<&2,Plan.Node<Requirement>>}:
  match blocked:
    case False{}:{==}
    case True{}:{==}

def scan_actual(-Requirement:Data,nodes:List<&2,Plan.Node<Requirement>>,+pending:List<&2,Plan.Node<Requirement>>,+edges:List<&2,Plan.Edge>) -> {scan_value(Requirement,nodes,pending,edges) == Plan.ready_scan(~Requirement,nodes,pending,edges) : List<&2,Plan.Node<Requirement>>}:
  match nodes:
    case []:{==}
    case Plan.Node{+id,+needs} <> +rest:
      %scan_actual(Requirement,rest,pending,edges) : {scan_value(Requirement,Plan.Node{id,needs} <> rest,pending,edges) == Plan.ready_member(~Requirement,Plan.predecessor_pending(~Requirement,edges,pending,id),Plan.Node{id,needs},_) : List<&2,Plan.Node<Requirement>>}
      %blocked_actual(Requirement,edges,pending,id) : {scan_value(Requirement,Plan.Node{id,needs} <> rest,pending,edges) == Plan.ready_member(~Requirement,_,Plan.Node{id,needs},scan_value(Requirement,rest,pending,edges)) : List<&2,Plan.Node<Requirement>>}
      keep_actual(Requirement,blocked_value(Requirement,edges,pending,id),Plan.Node{id,needs},scan_value(Requirement,rest,pending,edges))

def scan_spec(-Requirement:Data,nodes:List<&2,Plan.Node<Requirement>>,+pending:List<&2,Plan.Node<Requirement>>,+edges:List<&2,Plan.Edge>) -> {scan_value(Requirement,nodes,pending,edges) == Spec.scan_ready(~Requirement,nodes,pending,edges) : List<&2,Plan.Node<Requirement>>}:
  match nodes:
    case []:{==}
    case Plan.Node{+id,+needs} <> +rest:
      %scan_spec(Requirement,rest,pending,edges) : {scan_value(Requirement,Plan.Node{id,needs} <> rest,pending,edges) == Spec.include_ready(~Requirement,Spec.all_dependencies_satisfied(~Requirement,pending,id,edges),Plan.Node{id,needs},_) : List<&2,Plan.Node<Requirement>>}
      %blocked_spec(Requirement,edges,pending,id) : {scan_value(Requirement,Plan.Node{id,needs} <> rest,pending,edges) == Spec.include_ready(~Requirement,_,Plan.Node{id,needs},scan_value(Requirement,rest,pending,edges)) : List<&2,Plan.Node<Requirement>>}
      keep_spec(Requirement,blocked_value(Requirement,edges,pending,id),Plan.Node{id,needs},scan_value(Requirement,rest,pending,edges))

def Laws.ready_exact(Requirement,pending,edges):
  %scan_actual(Requirement,pending,pending,edges) : {_ == Spec.ready(~Requirement,pending,edges) : List<&2,Plan.Node<Requirement>>}
  scan_spec(Requirement,pending,pending,edges)

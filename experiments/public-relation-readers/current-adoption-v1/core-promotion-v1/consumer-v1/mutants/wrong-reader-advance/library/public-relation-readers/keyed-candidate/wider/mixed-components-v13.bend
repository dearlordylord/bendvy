import Base
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/lifecycle.bend as L
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/relation-types.bend as G
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/relation-commands.bend as RC
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/removals.bend as Rm
import /workspace/formal-proofs/bendvy-worktrees/parity-43-readers-current/experiments/public-relation-readers/current-adoption-v1/core-promotion-v1/consumer-v1/mutants/wrong-reader-advance/library/public-inspect/bend-candidate/removal-publication.bend as P

type FamilyTag is Data:
  Stock{}
type Token is Data:
  Token{}
type Payload is Type:
  Payload{cells: Array<U32>}
type Cells<S: Data> is Type:
  Cells{column: Col.Column<S,Payload>,retired: List<Payload>}
type Rest<S: Data> is Type:
  Rest{graph: G.Graph<S>,retired: List<Payload>}
type Message<S: Data> is Data:
  Ordinary{value: U32}
  Removal{notice: P.Notice<S,FamilyTag>}
def Store(~S: Data) -> Type: RC.Store<S,Cells<S>>
def Notice(~S: Data) -> Data: RC.Notice<S,Message<S>>
def World(~S: Data) -> Type: W.World<S,Store(~S),Array<U32>,Notice(~S)>

def take(~S: Data,store: Store(~S)) -> Rest<S> & Col.Column<S,Payload>:
  match store:
    case RC.Store{Cells{column,retired},graph}: (Rest{graph,retired},column)
def put(~S: Data,rest: Rest<S>,column: Col.Column<S,Payload>) -> Store(~S):
  match rest:
    case Rest{graph,retired}: RC.Store{Cells{column,retired},graph}
# Array projection consumes and returns the exact same affine payload owner.
def array_join(left: Array<U32> & List<&2,U32>,right: Array<U32> & List<&2,U32>) -> Array<U32> & List<&2,U32>:
  match left right:
    case (left,xs), (right,ys): (ANode{left,right},List.append(&2,U32,xs,ys))
def array_project(cells: Array<U32>) -> Array<U32> & List<&2,U32>:
  match cells:
    case ALeaf{+value}: (ALeaf{value},[value])
    case ANode{left,right}: array_join(array_project(left),array_project(right))
def project_join(observed: Array<U32> & List<&2,U32>) -> Payload & List<&2,U32>:
  (cells,values) = observed
  (Payload{cells},values)
def project(owner: Payload) -> Payload & List<&2,U32>:
  match owner:
    case Payload{cells}: project_join(array_project(cells))
def empty(~S: Data,_: Unit) -> Store(~S):
  RC.Store{Cells{Col.empty(~S,~Payload),[]},G.Graph{[],[]}}
def family(~S: Data) -> C.Family<S,Store(~S),Rest<S>,Payload,List<&2,U32>,Token,take(~S),put(~S),project>:
  C.Family{"Stock"}
def replace(~S: Data,world: World(~S),handle: W.Handle<S>,incoming: Maybe<&1,Payload>) -> C.Replacement<World(~S),Payload>:
  C.replace(~S,~Store(~S),~Array<U32>,~Notice(~S),~Rest<S>,~Payload,~List<&2,U32>,~Token,~take(~S),~put(~S),~project,family(~S),world,handle,incoming)
def get(~S: Data,world: World(~S),handle: W.Handle<S>) -> World(~S) & C.Access<List<&2,U32>>:
  C.get(~S,~Store(~S),~Array<U32>,~Notice(~S),~Rest<S>,~Payload,~List<&2,U32>,~Token,~take(~S),~put(~S),~project,family(~S),world,handle)
def lifecycle(~S: Data,world: World(~S),handle: W.Handle<S>) -> World(~S) & L.Stamp:
  C.lifecycle(~S,~Store(~S),~Array<U32>,~Notice(~S),~Rest<S>,~Payload,~List<&2,U32>,~Token,~take(~S),~put(~S),~project,family(~S),world,handle)

def cleared(~S: Data,+handle: W.Handle<S>,result: Col.SwapOutcome<S,Payload>,graph: G.Graph<S>,retired: List<Payload>) -> Store(~S) & List<&2,Rm.Record<S,FamilyTag>>:
  match result:
    case Col.Accepted{column,None{}}: (RC.Store{Cells{column,retired},graph},[])
    case Col.Accepted{column,Some{owner}}: (RC.Store{Cells{column,owner <> retired},graph},[Rm.Removed{handle,Stock{}}])
    case Col.Rejected{column,None{}}: (RC.Store{Cells{column,retired},graph},[])
    case Col.Rejected{column,Some{owner}}: (RC.Store{Cells{column,owner <> retired},graph},[])
def clear(~S: Data,store: Store(~S),handle: W.Handle<S>) -> Store(~S) & List<&2,Rm.Record<S,FamilyTag>>:
  match store handle:
    case RC.Store{Cells{column,retired},graph} W.Handle{namespace,+id}: cleared(~S,W.Handle{namespace,id},Col.clear(~S,~Payload,column,id),graph,retired)
def encode(~S: Data,notice: P.Notice<S,FamilyTag>) -> Notice(~S):
  RC.Original{Removal{notice}}
def enqueue_clear(~S: Data,world: World(~S),handle: W.Handle<S>) -> World(~S):
  P.enqueue(~S,~Store(~S),~Array<U32>,~Notice(~S),~FamilyTag,~clear(~S),~encode(~S),world,handle)
def select_removal(~S: Data,event: Notice(~S)) -> Maybe<&2,Rm.Record<S,FamilyTag>>:
  match event:
    case RC.Original{Removal{P.Notice{_,record}}}: Some{record}
    case _: None{}
def is_event(~S: Data,event: Notice(~S)) -> Bool:
  match event:
    case RC.Original{Ordinary{_}}: True{}
    case _: False{}

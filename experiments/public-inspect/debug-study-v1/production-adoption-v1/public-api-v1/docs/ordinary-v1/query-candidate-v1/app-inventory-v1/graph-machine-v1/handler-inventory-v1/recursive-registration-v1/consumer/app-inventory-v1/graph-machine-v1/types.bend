import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-inventory-v1/graph-machine-v1/handler-inventory-v1/recursive-registration-v1/consumer/app-inventory-v1/graph-machine-v1/schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/relation-types.bend as Rel
import /workspace/formal-proofs/bendvy/src/ecs/relation-graph.bend as Graph
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as Tx
import /workspace/formal-proofs/bendvy/experiments/public-simulation/bend-v1/owner-view.bend as View
type Tag is Data:
  Tag{}
type Key is Data:
  Mode{}
type State is Data:
  Boot{}
  Play{}
type Resources is Type:
  Resources{array:Array<U32>,slot:M.Slot<Tag,Key,State>,graph:Rel.Graph<Tag>,relation:Rel.Descriptor<Tag>}
type ResourceView is Data:
  ResourceView{array:View.FullCell,slot:M.Slot<Tag,Key,State>,graph:Rel.Graph<Tag>,relation:Rel.Descriptor<Tag>}
def take(resources:Resources) -> Resources & M.Slot<Tag,Key,State>:
  match resources:
    case Resources{array,+slot,graph,relation}:(Resources{array,slot,graph,relation},slot)
def put(resources:Resources,slot:M.Slot<Tag,Key,State>) -> Resources:
  match resources:
    case Resources{array,_,graph,relation}:Resources{array,slot,graph,relation}
def family() -> M.Family<Tag,Key,State,Resources,take,put>:
  M.Family{"Mode"}
def descriptor() -> Rel.Descriptor<Tag>:
  Rel.Descriptor{7,"Parent","Children",Rel.Hierarchy{}}
def keep_commands(resources:Resources,commands:List<(Resources -> Resources)>) -> Resources:
  resources
def keep_events(resources:Resources,events:List<&2,Unit>) -> Resources:
  resources
def queued(family:M.Family<Tag,Key,State,Resources,take,put>,resources:Resources) -> Tx.Returned<Resources,Unit>:
  Tx.finish(~Resources,~Unit,~Unit,~keep_commands,~keep_events,M.next_declared(~Tag,~Key,~State,~Resources,~Unit,~take,~put,family,Tx.begin(~Resources,~Unit,resources),M.Set{Play{},False{}}),Tx.Success{})
def viewed(+slot:M.Slot<Tag,Key,State>,+graph:Rel.Graph<Tag>,+relation:Rel.Descriptor<Tag>,got:Array<U32> & View.FullCell) -> Resources & ResourceView:
  match got:
    case (array,view):(Resources{array,slot,graph,relation},ResourceView{view,slot,graph,relation})
def view(resources:Resources) -> Resources & ResourceView:
  match resources:
    case Resources{array,slot,graph,relation}:viewed(slot,graph,relation,View.view(array))
def related(array:Array<U32>,slot:M.Slot<Tag,Key,State>,relation:Rel.Descriptor<Tag>,result:Rel.CoreResult<Tag>) -> Resources & Maybe<&2,Rel.Error>:
  match result:
    case Rel.CoreResult{graph,error}:(Resources{array,slot,graph,relation},error)
def relate(resources:Resources) -> Resources & Maybe<&2,Rel.Error>:
  match resources:
    case Resources{array,slot,graph,+relation}:related(array,slot,relation,Graph.relate(~Tag,graph,relation,1,2,True{},True{}))

import Base
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/app.bend as DTO
# No recipe function is an outer Application or Observer type index.
type Observer<-S:Data,-World:Type,-Owners:Type,-Rows:Data> is Type:
  Observer{step:World -> Owners -> World & (Owners & (Observer<S,World,Owners,Rows> & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>))}
type Application<-S:Data,-World:Type,-Owners:Type,-Rows:Data> is Type:
  Application{world:World,owners:Owners,observer:Observer<S,World,Owners,Rows>,debug:Bool}
def entered(~S:Data,~World:Type,~Owners:Type,~Rows:Data,observer:Observer<S,World,Owners,Rows>,world:World,owners:Owners) -> World & (Owners & (Observer<S,World,Owners,Rows> & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>)):
  match observer:
    case Observer{step}:step(world,owners)
def snapshot_entered(~S:Data,~World:Type,~Owners:Type,~Rows:Data,result:World & (Owners & (Observer<S,World,Owners,Rows> & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>))) -> Application<S,World,Owners,Rows> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>:
  match result:
    case (world,(owners,(next,value))):(Application{world,owners,next,True{}},Some{value})
def snapshot(~S:Data,~World:Type,~Owners:Type,~Rows:Data,app:Application<S,World,Owners,Rows>) -> Application<S,World,Owners,Rows> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>:
  match app:
    case Application{world,owners,observer,False{}}:(Application{world,owners,observer,False{}},None{})
    case Application{world,owners,observer,True{}}:snapshot_entered(~S,~World,~Owners,~Rows,entered(~S,~World,~Owners,~Rows,observer,world,owners))
def enable_debug(~S:Data,~World:Type,~Owners:Type,~Rows:Data,app:Application<S,World,Owners,Rows>,enabled:Bool) -> Application<S,World,Owners,Rows>:
  match app:
    case Application{world,owners,observer,_}:Application{world,owners,observer,enabled}
def leaf_described(~S:Data,~World:Type,~Owners:Type,~Rows:Data,world:World,next:Observer<S,World,Owners,Rows>,rows:Rows,rendered:List<&2,String>,result:Owners & List<&2,DTO.Binding<S>>) -> World & (Owners & (Observer<S,World,Owners,Rows> & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>)):
  match result:
    case (owners,bindings):(world,(owners,(next,DTO.Product{bindings,DTO.Observation{rows,rendered}})))
def leaf_observed(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~describe:Owners -> Owners & List<&2,DTO.Binding<S>>,owners:Owners,next:Observer<S,World,Owners,Rows>,result:World & DTO.Observation<Rows>) -> World & (Owners & (Observer<S,World,Owners,Rows> & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>)):
  match result:
    case (world,DTO.Observation{rows,rendered}):leaf_described(~S,~World,~Owners,~Rows,world,next,rows,rendered,describe(owners))
def leaf_step(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~observe:World -> World & DTO.Observation<Rows>,~describe:Owners -> Owners & List<&2,DTO.Binding<S>>,world:World,owners:Owners) -> World & (Owners & (Observer<S,World,Owners,Rows> & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>)):
  leaf_observed(~S,~World,~Owners,~Rows,~describe,owners,Observer{leaf_step(~S,~World,~Owners,~Rows,~observe,~describe)},observe(world))
def leaf(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~observe:World -> World & DTO.Observation<Rows>,~describe:Owners -> Owners & List<&2,DTO.Binding<S>>) -> Observer<S,World,Owners,Rows>:
  Observer{leaf_step(~S,~World,~Owners,~Rows,~observe,~describe)}
def pair_right(~S:Data,~World:Type,~L:Type,~R:Type,~LR:Data,~RR:Data,build:Observer<S,World,L,LR> -> Observer<S,World,R,RR> -> Observer<S,World,L & R,DTO.Product<LR,RR>>,left:L,nextLeft:Observer<S,World,L,LR>,leftBindings:List<&2,DTO.Binding<S>>,leftRows:LR,leftRendered:List<&2,String>,result:World & (R & (Observer<S,World,R,RR> & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<RR>>))) -> World & ((L & R) & (Observer<S,World,L & R,DTO.Product<LR,RR>> & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<DTO.Product<LR,RR>>>)):
  match result:
    case (world,(right,(nextRight,DTO.Product{rightBindings,DTO.Observation{rightRows,rightRendered}}))):(world,((left,right),(build(nextLeft,nextRight),DTO.Product{List.append(&2,DTO.Binding<S>,leftBindings,rightBindings),DTO.Observation{DTO.Product{leftRows,rightRows},List.append(&2,String,leftRendered,rightRendered)}})))
def pair_left(~S:Data,~World:Type,~L:Type,~R:Type,~LR:Data,~RR:Data,build:Observer<S,World,L,LR> -> Observer<S,World,R,RR> -> Observer<S,World,L & R,DTO.Product<LR,RR>>,right:R,rightObserver:Observer<S,World,R,RR>,result:World & (L & (Observer<S,World,L,LR> & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<LR>>))) -> World & ((L & R) & (Observer<S,World,L & R,DTO.Product<LR,RR>> & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<DTO.Product<LR,RR>>>)):
  match result:
    case (world,(left,(nextLeft,DTO.Product{bindings,DTO.Observation{rows,rendered}}))):pair_right(~S,~World,~L,~R,~LR,~RR,build,left,nextLeft,bindings,rows,rendered,entered(~S,~World,~R,~RR,rightObserver,world,right))
def pair_step(~S:Data,~World:Type,~L:Type,~R:Type,~LR:Data,~RR:Data,leftObserver:Observer<S,World,L,LR>,rightObserver:Observer<S,World,R,RR>,world:World,owners:L & R) -> World & ((L & R) & (Observer<S,World,L & R,DTO.Product<LR,RR>> & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<DTO.Product<LR,RR>>>)):
  match owners:
    case (left,right):pair_left(~S,~World,~L,~R,~LR,~RR,(nextLeft => nextRight => Observer{pair_step(~S,~World,~L,~R,~LR,~RR,nextLeft,nextRight)}),right,rightObserver,entered(~S,~World,~L,~LR,leftObserver,world,left))
def pair(~S:Data,~World:Type,~L:Type,~R:Type,~LR:Data,~RR:Data,left:Observer<S,World,L,LR>,right:Observer<S,World,R,RR>) -> Observer<S,World,L & R,DTO.Product<LR,RR>>:
  Observer{pair_step(~S,~World,~L,~R,~LR,~RR,left,right)}

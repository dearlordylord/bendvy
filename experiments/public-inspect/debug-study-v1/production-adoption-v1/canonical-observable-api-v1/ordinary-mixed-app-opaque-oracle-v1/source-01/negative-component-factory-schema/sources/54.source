import Base
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/app.bend as DTO
type Leaf<-S:Data,-World:Type,-Owners:Type,-Rows:Data,-observe:World -> World & DTO.Observation<Rows>,-describe:Owners -> Owners & List<&2,DTO.Binding<S>>> is Type:
  Leaf{}
type RecipePair<-L:Type,-R:Type> is Type:
  RecipePair{left:L,right:R}
type Application<-S:Data,-World:Type,-Owners:Type,-Rows:Data,-Recipe:Type> is Type:
  Application{world:World,owners:Owners,recipe:Recipe,debug:Bool}
def enabled(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~Recipe:Type,app:Application<S,World,Owners,Rows,Recipe>,flag:Bool) -> Application<S,World,Owners,Rows,Recipe>:
  match app:
    case Application{world,owners,recipe,_}:Application{world,owners,recipe,flag}
def snap_entered(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~Recipe:Type,result:World & (Owners & (Recipe & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>))) -> Application<S,World,Owners,Rows,Recipe> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>:
  match result:
    case (world,(owners,(recipe,value))):(Application{world,owners,recipe,True{}},Some{value})
def snapshot(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~Recipe:Type,interpret:Recipe -> World -> Owners -> World & (Owners & (Recipe & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>)),app:Application<S,World,Owners,Rows,Recipe>) -> Application<S,World,Owners,Rows,Recipe> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>:
  match app:
    case Application{world,owners,recipe,False{}}:(Application{world,owners,recipe,False{}},None{})
    case Application{world,owners,recipe,True{}}:snap_entered(~S,~World,~Owners,~Rows,~Recipe,interpret(recipe,world,owners))
def leaf_described(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~observe:World -> World & DTO.Observation<Rows>,~describe:Owners -> Owners & List<&2,DTO.Binding<S>>,world:World,rows:DTO.Observation<Rows>,result:Owners & List<&2,DTO.Binding<S>>) -> World & (Owners & (Leaf<S,World,Owners,Rows,observe,describe> & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>)):
  match result:
    case (owners,bindings):(world,(owners,(Leaf{},DTO.Product{bindings,rows})))
def leaf_observed(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~observe:World -> World & DTO.Observation<Rows>,~describe:Owners -> Owners & List<&2,DTO.Binding<S>>,owners:Owners,result:World & DTO.Observation<Rows>) -> World & (Owners & (Leaf<S,World,Owners,Rows,observe,describe> & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>)):
  match result:
    case (world,rows):leaf_described(~S,~World,~Owners,~Rows,~observe,~describe,world,rows,describe(owners))
def leaf_view(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~observe:World -> World & DTO.Observation<Rows>,~describe:Owners -> Owners & List<&2,DTO.Binding<S>>,recipe:Leaf<S,World,Owners,Rows,observe,describe>,world:World,owners:Owners) -> World & (Owners & (Leaf<S,World,Owners,Rows,observe,describe> & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>)):
  leaf_observed(~S,~World,~Owners,~Rows,~observe,~describe,owners,observe(world))
def pair_right(~S:Data,~World:Type,~L:Type,~R:Type,~LR:Data,~RR:Data,~LP:Type,~RP:Type,left:L,leftRecipe:LP,leftBindings:List<&2,DTO.Binding<S>>,leftRows:LR,leftRendered:List<&2,String>,result:World & (R & (RP & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<RR>>))) -> World & ((L & R) & (RecipePair<LP,RP> & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<DTO.Product<LR,RR>>>)):
  match result:
    case (world,(right,(rightRecipe,DTO.Product{rightBindings,DTO.Observation{rightRows,rightRendered}}))):(world,((left,right),(RecipePair{leftRecipe,rightRecipe},DTO.Product{List.append(&2,DTO.Binding<S>,leftBindings,rightBindings),DTO.Observation{DTO.Product{leftRows,rightRows},List.append(&2,String,leftRendered,rightRendered)}})))
def pair_left(~S:Data,~World:Type,~L:Type,~R:Type,~LR:Data,~RR:Data,~LP:Type,~RP:Type,right:R,rightRecipe:RP,rightView:RP -> World -> R -> World & (R & (RP & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<RR>>)),result:World & (L & (LP & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<LR>>))) -> World & ((L & R) & (RecipePair<LP,RP> & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<DTO.Product<LR,RR>>>)):
  match result:
    case (world,(left,(leftRecipe,DTO.Product{bindings,DTO.Observation{rows,rendered}}))):pair_right(~S,~World,~L,~R,~LR,~RR,~LP,~RP,left,leftRecipe,bindings,rows,rendered,rightView(rightRecipe,world,right))
def pair_owners(~S:Data,~World:Type,~L:Type,~R:Type,~LR:Data,~RR:Data,~LP:Type,~RP:Type,leftView:LP -> World -> L -> World & (L & (LP & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<LR>>)),rightView:RP -> World -> R -> World & (R & (RP & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<RR>>)),leftRecipe:LP,rightRecipe:RP,world:World,owners:L & R) -> World & ((L & R) & (RecipePair<LP,RP> & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<DTO.Product<LR,RR>>>)):
  match owners:
    case (left,right):pair_left(~S,~World,~L,~R,~LR,~RR,~LP,~RP,right,rightRecipe,rightView,leftView(leftRecipe,world,left))
def pair_view(~S:Data,~World:Type,~L:Type,~R:Type,~LR:Data,~RR:Data,~LP:Type,~RP:Type,leftView:LP -> World -> L -> World & (L & (LP & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<LR>>)),rightView:RP -> World -> R -> World & (R & (RP & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<RR>>)),recipe:RecipePair<LP,RP>,world:World,owners:L & R) -> World & ((L & R) & (RecipePair<LP,RP> & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<DTO.Product<LR,RR>>>)):
  match recipe:
    case RecipePair{left,right}:pair_owners(~S,~World,~L,~R,~LR,~RR,~LP,~RP,leftView,rightView,left,right,world,owners)

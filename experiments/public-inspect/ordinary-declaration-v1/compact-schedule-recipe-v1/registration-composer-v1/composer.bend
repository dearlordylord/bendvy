import Base
import ../recipe-tree-v1/tree.bend as Tree
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/app.bend as DTO
# Registration construction token. No runtime callback is stored or duplicated.
# Each registration operation must construct its own canonical leaf description.
type Registered<S:Data,World:Type,Owners:Type,Rows:Data,-observe:World -> World & DTO.Observation<Rows>,-describe:Owners -> Owners & List<&2,DTO.Binding<S>>> is Type:
  Registered{world:World,owners:Owners,recipe:Tree.Recipe<World,Rows,observe>,debug:Bool}
def empty_observe(~World:Type,world:World) -> World & DTO.Observation<Unit>:
  (world,DTO.Observation{Unit{},[]})
def empty_describe(~S:Data,owner:Unit) -> Unit & List<&2,DTO.Binding<S>>:
  (owner,[])
def empty(~S:Data,~World:Type,world:World) -> Registered<S,World,Unit,Unit,empty_observe(~World),empty_describe(~S)>:
  Registered{world,Unit{},Tree.Recipe{},False{}}
def enabled(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~observe:World -> World & DTO.Observation<Rows>,~describe:Owners -> Owners & List<&2,DTO.Binding<S>>,app:Registered<S,World,Owners,Rows,observe,describe>,flag:Bool) -> Registered<S,World,Owners,Rows,observe,describe>:
  match app:
    case Registered{world,owners,recipe,_}:Registered{world,owners,recipe,flag}
def returned(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~observe:World -> World & DTO.Observation<Rows>,~describe:Owners -> Owners & List<&2,DTO.Binding<S>>,result:Tree.Application<S,World,Owners,Rows,observe> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>) -> Registered<S,World,Owners,Rows,observe,describe> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>:
  match result:
    case (Tree.Application{world,owners,recipe,debug},value):(Registered{world,owners,recipe,debug},value)
def snapshot(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~observe:World -> World & DTO.Observation<Rows>,~describe:Owners -> Owners & List<&2,DTO.Binding<S>>,app:Registered<S,World,Owners,Rows,observe,describe>) -> Registered<S,World,Owners,Rows,observe,describe> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>:
  match app:
    case Registered{world,owners,recipe,debug}:returned(~S,~World,~Owners,~Rows,~observe,~describe,Tree.snapshot(~S,~World,~Owners,~Rows,~observe,describe,Tree.Application{world,owners,recipe,debug}))
def appended(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~observe:World -> World & DTO.Observation<Rows>,~describe:Owners -> Owners & List<&2,DTO.Binding<S>>,~Leaf:Type,~Value:Data,~leafObserve:World -> World & DTO.Observation<Value>,~leafDescribe:Leaf -> Leaf & List<&2,DTO.Binding<S>>,world:World,owners:Owners,leaf:Leaf,debug:Bool) -> Registered<S,World,Owners & Leaf,DTO.Product<Rows,Value>,Tree.observe_pair(~World,~Rows,~Value,~observe,~leafObserve),Tree.describe_pair(~S,~Owners,~Leaf,~describe,~leafDescribe)>:
  Registered{world,(owners,leaf),Tree.Recipe{},debug}

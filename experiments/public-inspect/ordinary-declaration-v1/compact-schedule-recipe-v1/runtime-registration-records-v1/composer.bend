import Base
import ./records.bend as Records
import ./description.bend as Description
import ../recipe-tree-v1/tree.bend as Tree
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/app.bend as DTO
type Registered<S:Data,World:Type,Owners:Type,Rows:Data,-observe:World -> World & DTO.Observation<Rows>> is Type:
  Registered{world:World,owners:Owners,recipe:Tree.Recipe<World,Rows,observe>,records:List<&2,Records.Fields<S>>,debug:Bool}
def empty_observe(~World:Type,world:World) -> World & DTO.Observation<Unit>:
  (world,DTO.Observation{Unit{},[]})
def empty(~S:Data,~World:Type,world:World) -> Registered<S,World,Unit,Unit,empty_observe(~World)>:
  Registered{world,Unit{},Tree.Recipe{},[],False{}}
def enabled(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~observe:World -> World & DTO.Observation<Rows>,app:Registered<S,World,Owners,Rows,observe>,flag:Bool) -> Registered<S,World,Owners,Rows,observe>:
  match app:
    case Registered{world,owners,recipe,records,_}:Registered{world,owners,recipe,records,flag}
def observed(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~observe:World -> World & DTO.Observation<Rows>,owners:Owners,+records:List<&2,Records.Fields<S>>,result:World & DTO.Observation<Rows>) -> Registered<S,World,Owners,Rows,observe> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>:
  match result:
    case (world,view):(Registered{world,owners,Tree.Recipe{},records,True{}},Some{DTO.Product{Description.bindings(~S,records),view}})
def snapshot(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~observe:World -> World & DTO.Observation<Rows>,app:Registered<S,World,Owners,Rows,observe>) -> Registered<S,World,Owners,Rows,observe> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>:
  match app:
    case Registered{world,owners,recipe,records,False{}}:(Registered{world,owners,recipe,records,False{}},None{})
    case Registered{world,owners,_,records,True{}}:observed(~S,~World,~Owners,~Rows,~observe,owners,records,observe(world))
def appended(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~observe:World -> World & DTO.Observation<Rows>,~Leaf:Type,~Value:Data,~leafObserve:World -> World & DTO.Observation<Value>,world:World,owners:Owners,leaf:Leaf,records:List<&2,Records.Fields<S>>,fields:Records.Fields<S>,debug:Bool) -> Registered<S,World,Owners & Leaf,DTO.Product<Rows,Value>,Tree.observe_pair(~World,~Rows,~Value,~observe,~leafObserve)>:
  Registered{world,(owners,leaf),Tree.Recipe{},List.append(&2,Records.Fields<S>,records,[fields]),debug}

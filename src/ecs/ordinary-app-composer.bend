import Base
import ./ordinary-app-registration-fields.bend as Records
import ./ordinary-app-description.bend as Description
import ./ordinary-app-recipe.bend as Tree
import ./ordinary-app-observation-data.bend as DTO
type Registered<S:Data,World:Type,Owners:Type,Rows:Data,-observe:World -> World & DTO.Observation<Rows>> is Type:
  Registered{world:World,owners:Owners,recipe:Tree.Recipe<World,Rows,observe>,debug:Bool}
def empty_observe(~World:Type,world:World) -> World & DTO.Observation<Unit>:
  (world,DTO.Observation{Unit{},[]})
def empty(~S:Data,~World:Type,world:World) -> Registered<S,World,Unit,Unit,empty_observe(~World)>:
  Registered{world,Unit{},Tree.Recipe{},False{}}
def enabled(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~observe:World -> World & DTO.Observation<Rows>,app:Registered<S,World,Owners,Rows,observe>,flag:Bool) -> Registered<S,World,Owners,Rows,observe>:
  match app:
    case Registered{world,owners,recipe,_}:Registered{world,owners,recipe,flag}
def observed(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~observe:World -> World & DTO.Observation<Rows>,owners:Owners,fields:List<&2,Records.Fields<S>>,result:World & DTO.Observation<Rows>) -> Registered<S,World,Owners,Rows,observe> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>:
  match result:
    case (world,view):(Registered{world,owners,Tree.Recipe{},True{}},Some{DTO.Product{Description.bindings(~S,fields),view}})
def folded(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~observe:World -> World & DTO.Observation<Rows>,world:World,result:Owners & List<&2,Records.Fields<S>>) -> Registered<S,World,Owners,Rows,observe> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>:
  match result:
    case (owners,fields):observed(~S,~World,~Owners,~Rows,~observe,owners,fields,observe(world))
def snapshot(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~observe:World -> World & DTO.Observation<Rows>,fold:Owners -> Owners & List<&2,Records.Fields<S>>,app:Registered<S,World,Owners,Rows,observe>) -> Registered<S,World,Owners,Rows,observe> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>:
  match app:
    case Registered{world,owners,recipe,False{}}:(Registered{world,owners,recipe,False{}},None{})
    case Registered{world,owners,_,True{}}:folded(~S,~World,~Owners,~Rows,~observe,world,fold(owners))
def appended(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~observe:World -> World & DTO.Observation<Rows>,~Leaf:Type,~Value:Data,~leafObserve:World -> World & DTO.Observation<Value>,world:World,owners:Owners,leaf:Leaf,debug:Bool) -> Registered<S,World,Owners & Leaf,DTO.Product<Rows,Value>,Tree.observe_pair(~World,~Rows,~Value,~observe,~leafObserve)>:
  Registered{world,(owners,leaf),Tree.Recipe{},debug}

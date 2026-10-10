import Base
import ./ordinary-app-observation-data.bend as DTO
type Recipe<World:Type,Rows:Data,-observe:World -> World & DTO.Observation<Rows>> is Type:
  Recipe{}
def observation_right(~World:Type,~L:Data,~R:Data,left:L,leftText:List<&2,String>,result:World & DTO.Observation<R>) -> World & DTO.Observation<DTO.Product<L,R>>:
  match result:
    case (world,DTO.Observation{right,rightText}):(world,DTO.Observation{DTO.Product{left,right},List.append(&2,String,leftText,rightText)})
def observation_left(~World:Type,~L:Data,~R:Data,~right:World -> World & DTO.Observation<R>,result:World & DTO.Observation<L>) -> World & DTO.Observation<DTO.Product<L,R>>:
  match result:
    case (world,DTO.Observation{value,text}):observation_right(~World,~L,~R,value,text,right(world))
def observe_pair(~World:Type,~L:Data,~R:Data,~left:World -> World & DTO.Observation<L>,~right:World -> World & DTO.Observation<R>,world:World) -> World & DTO.Observation<DTO.Product<L,R>>:
  observation_left(~World,~L,~R,~right,left(world))

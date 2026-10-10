import Base
import /workspace/formal-proofs/bendvy-worktrees/schedule-observation-v1/experiments/public-inspect/ordinary-declaration-v1/compact-observation-app-v1/recipes.bend as Compact
import ../automatic-app-observation-v1/app.bend as DTO
type Application<-S:Data,-World:Type,-Owners:Type,-Rows:Data,-Recipe:Type,-interpret:Recipe -> World -> Owners -> World & (Owners & (Recipe & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>))> is Type:
  Application{inner:Compact.Application<S,World,Owners,Rows,Recipe>}
def retained(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~Recipe:Type,~interpret:Recipe -> World -> Owners -> World & (Owners & (Recipe & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>)),app:Compact.Application<S,World,Owners,Rows,Recipe>) -> Application<S,World,Owners,Rows,Recipe,interpret>:
  Application{app}
def enabled(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~Recipe:Type,~interpret:Recipe -> World -> Owners -> World & (Owners & (Recipe & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>)),app:Application<S,World,Owners,Rows,Recipe,interpret>,flag:Bool) -> Application<S,World,Owners,Rows,Recipe,interpret>:
  match app:
    case Application{inner}:Application{Compact.enabled(~S,~World,~Owners,~Rows,~Recipe,inner,flag)}
def returned(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~Recipe:Type,~interpret:Recipe -> World -> Owners -> World & (Owners & (Recipe & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>)),result:Compact.Application<S,World,Owners,Rows,Recipe> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>) -> Application<S,World,Owners,Rows,Recipe,interpret> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>:
  match result:
    case (inner,value):(Application{inner},value)
def snapshot(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~Recipe:Type,~interpret:Recipe -> World -> Owners -> World & (Owners & (Recipe & DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>)),app:Application<S,World,Owners,Rows,Recipe,interpret>) -> Application<S,World,Owners,Rows,Recipe,interpret> & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Rows>>>:
  match app:
    case Application{inner}:returned(~S,~World,~Owners,~Rows,~Recipe,~interpret,Compact.snapshot(~S,~World,~Owners,~Rows,~Recipe,interpret,inner))

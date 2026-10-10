import Base
import /workspace/formal-proofs/bendvy-worktrees/schedule-observation-v1/experiments/public-inspect/ordinary-declaration-v1/compact-observation-app-v1/recipes.bend as Compact
def duplicate(~S:Data,~World:Type,~Owners:Type,~Rows:Data,~Recipes:Type,app:Compact.Application<S,World,Owners,Rows,Recipes>) -> Compact.Application<S,World,Owners,Rows,Recipes> & Compact.Application<S,World,Owners,Rows,Recipes>:
  (app,app)

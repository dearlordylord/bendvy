import Base
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/query-contract.bend as QC
import ../../examples/query-composition/schema.bend as S
import ../../examples/query-composition/gameplay.bend as G

def bad(~H: Type,~caps: G.WorkOps(H),ctx: H) -> H:
  Cap.set(~H,~S.Recipe,~S.RecipeView,~G.work_recipe(~H,caps),ctx,S.recipe_payload(1))

import Base
import ../candidate/src/ecs/world.bend as W
import ../candidate/src/ecs/check.bend as Check
import ./owner-observation.bend as Owner
def read_join(result:Check.Frame<Owner.Schema,Array<U32>,Owner.Owner,U32> & Owner.Observation) -> W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> & Owner.Observation:
  match result:
    case (Check.Frame{world},observation):(world,observation)
def read(world:W.World<Owner.Schema,Array<U32>,Owner.Owner,U32>) -> W.World<Owner.Schema,Array<U32>,Owner.Owner,U32> & Owner.Observation:
  read_join(Check.resource_read(~Owner.Schema,~Array<U32>,~Owner.Owner,~U32,~Owner.Observation,~Owner.project,Check.Frame{world}))

import Base
import ../main.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sy

def bad(registry:Sy.Registry<M.Second,Unit,Array<U32>,Unit,Unit,Unit,U32,M.runner(~M.Second)>,world:M.World(~M.First)) -> Sy.RunResult<M.First,Unit,Array<U32>,Unit,Unit,Unit,U32,M.runner(~M.First)>:
  Sy.run(~M.First,~Unit,~Array<U32>,~Unit,~Unit,~Unit,~U32,~M.runner(~M.First),registry,world,Unit{})

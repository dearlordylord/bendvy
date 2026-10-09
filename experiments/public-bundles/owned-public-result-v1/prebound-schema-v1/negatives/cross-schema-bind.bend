import Base
import ../main.bend as M
import ../registration.bend as Bind
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as SF
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sy

def bad(fragment:SF.Fragment<M.Second,M.World(~M.First)>) -> SF.Bound<M.First,M.World(~M.First),Sy.RegistrationResult<M.First,Unit,Array<U32>,Unit,Unit,Unit,U32,M.runner(~M.First)>>:
  Bind.bind(~M.First,~Unit,~Array<U32>,~Unit,~Unit,~Unit,~U32,~M.runner(~M.First),~M.initialize(~M.First),fragment,[M.entry(~M.First)])

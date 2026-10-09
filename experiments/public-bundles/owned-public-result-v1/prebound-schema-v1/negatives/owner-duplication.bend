import Base
import ../main.bend as M
import ../registration.bend as Bind
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as SF
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sy

def duplicate(value:SF.Bound<M.First,M.World(~M.First),Sy.RegistrationResult<M.First,Unit,Array<U32>,Unit,Unit,Unit,U32,M.runner(~M.First)>>) -> M.World(~M.First) & M.World(~M.First):
  match value:
    case SF.Built{Sy.Registered{world,_}}:(world,world)
    case SF.Built{Sy.RegistrationFailed{world}}:(world,world)
    case SF.BindRejected{_,SF.Fragment{_,world}}:(world,world)
def bad(fragment:SF.Fragment<M.First,M.World(~M.First)>) -> M.World(~M.First) & M.World(~M.First):
  duplicate(Bind.bind(~M.First,~Unit,~Array<U32>,~Unit,~Unit,~Unit,~U32,~M.runner(~M.First),~M.initialize(~M.First),fragment,[M.entry(~M.First)]))

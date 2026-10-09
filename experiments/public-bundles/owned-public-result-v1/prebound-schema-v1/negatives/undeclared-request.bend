import Base
import ../main.bend as M
import ../registration.bend as Bind
import /workspace/formal-proofs/bendvy/src/ecs/schema-fragments.bend as SF
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sy
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap

def body(~H:Type,~cap:Cap.ValueRead<H,U32>,args:Unit,owner:H) -> H & U32:
  Cap.owned_request(~H,~Unit,~U32,~cap,owner,Unit{})
def runner(world:M.World(~M.First),args:Unit) -> Sy.Outcome<M.World(~M.First),Unit,U32>:
  M.observed(~M.First,Cap.invoke(~(H => Cap.ValueRead<H,U32>),~Unit,~U32,~body,~M.World(~M.First),~Cap.ValueRead{M.get(~M.First)},args,world))
def initialize(world:M.World(~M.First)) -> Sy.RegistrationResult<M.First,Unit,Array<U32>,Unit,Unit,Unit,U32,runner>:
  Sy.register(~M.First,~Unit,~Array<U32>,~Unit,~Unit,~Unit,~U32,~runner,world,"negative",["array"])
def bad(fragment:SF.Fragment<M.First,M.World(~M.First)>) -> SF.Bound<M.First,M.World(~M.First),Sy.RegistrationResult<M.First,Unit,Array<U32>,Unit,Unit,Unit,U32,runner>>:
  Bind.bind(~M.First,~Unit,~Array<U32>,~Unit,~Unit,~Unit,~U32,~runner,~initialize,fragment,[M.entry(~M.First)])

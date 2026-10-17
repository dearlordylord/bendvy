import Base
import ../../../examples/scheduled-health/system.bend as Decay
import ../../../examples/scheduled-health/schema.bend as S
import ../../../examples/scheduled-health/components.bend as D
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/world-io.bend as WI
import ../../../src/ecs/ordinary-system.bend as O
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/ordinary-query-declaration.bend as Decl

def boolean(value:Bool) -> String:
  match value:
    case True{}:"true"
    case False{}:"false"
def named(namespace:U32,position:U32,value:S.World() & U32) -> String:
  match value:
    case (_,actual):"foreign-world=Rejected distinct=" ++ boolean(Bool.not(U32.is_eq(namespace,actual))) ++ " cursor=" ++ U32.show(position)
def rejected(value:Sys.RunResult<S.Schema,S.Store,Unit,Unit,Unit & U32,Q.Error<Decay.Error>,List<&2,D.Health>,Decay.Runner()> & (String & List<&2,Decl.Clause<S.Schema>>)) -> String:
  match value:
    case (Sys.RegistrationRejected{Sys.Registry{namespace,_,_,_,position},world,_},_):named(namespace,position,W.namespace(~S.Schema,~S.Store,~Unit,~Unit,world))
    case _:"ERROR: foreign World accepted"
def second(owner:Decay.Owner(),value:WI.Creation<S.Schema,S.Store,Unit,Unit>) -> IO(Unit):
  match value:
    case WI.Created{world}:IO.print(rejected(Decay.tick(owner,world)))
    case _:IO.die(Unit,1,"second World refused")
def registered(value:O.Defined<S.Schema,S.World(),Sys.Registry<S.Schema,S.Store,Unit,Unit,Unit & U32,Q.Error<Decay.Error>,List<&2,D.Health>,Decay.Runner()>>) -> IO(Unit):
  match value:
    case O.Defined{_,owner}:IO.bind(WI.Creation<S.Schema,S.Store,Unit,Unit>,Unit,WI.create(~S.Schema,~S.Store,~Unit,~Unit,~S.empty,Unit{}),second(owner))
    case _:IO.die(Unit,1,"registration refused")
def first(value:WI.Creation<S.Schema,S.Store,Unit,Unit>) -> IO(Unit):
  match value:
    case WI.Created{world}:registered(Decay.define(world))
    case _:IO.die(Unit,1,"first World refused")
def main() -> IO(Unit):
  IO.bind(WI.Creation<S.Schema,S.Store,Unit,Unit>,Unit,WI.create(~S.Schema,~S.Store,~Unit,~Unit,~S.empty,Unit{}),first)

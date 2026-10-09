import Base
import ../provider.bend as P
import ../context.bend as Ctx
import ../hooks.bend as H
import ../../../src/ecs/world-io.bend as WIO
import skip-core.bend as Core

def created(~S: Data,result: WIO.Creation<S,P.Store<S>,P.Resources<S>,Unit>) -> IO(String):
  match result:
    case WIO.Created{world}: IO.pure(String,Core.provisioned(~S,H.provision(~S,~(world => operation => Ctx.hook_runner(~S,world,operation)),world)))
    case WIO.Refused{_}: IO.pure(String,"WORLD_CREATE_REFUSED")
def scenario(~S: Data) -> IO(String):
  IO.bind(WIO.Creation<S,P.Store<S>,P.Resources<S>,Unit>,String,WIO.create(~S,~P.Store<S>,~P.Resources<S>,~Unit,~(unit => P.empty_store(~S,unit)),P.initial_resources(~S)),result => created(~S,result))
def main() -> IO(Unit):
  IO.bind(String,Unit,scenario(~P.SchemaA),a => IO.bind(String,Unit,scenario(~P.SchemaB),b => IO.print("SCHEMA=A\n" ++ a ++ "\nSCHEMA=B\n" ++ b)))

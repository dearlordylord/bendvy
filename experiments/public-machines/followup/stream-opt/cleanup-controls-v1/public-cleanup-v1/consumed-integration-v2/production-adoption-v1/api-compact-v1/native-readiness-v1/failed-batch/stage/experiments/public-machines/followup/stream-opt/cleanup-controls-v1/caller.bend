import Base
import ../../../provider.bend as P
import ../../../context.bend as Ctx
import ../../../hooks.bend as H
import ../../../../../src/ecs/world-io.bend as WIO
import caller-core.bend as Core

def initial_created(~S: Data,result: WIO.Creation<S,P.Store<S>,P.Resources<S>,Unit>) -> IO(Core.Initialized<S>):
  match result:
    case WIO.Created{world}: IO.pure(Core.Initialized<S>,Core.initialized(~S,H.provision(~S,~(world => operation => Ctx.hook_runner(~S,world,operation)),world)))
    case WIO.Refused{resource}: IO.pure(Core.Initialized<S>,Core.CreationRefused{resource})
def initial(~S: Data,other: Bool) -> IO(Core.Initialized<S>):
  IO.bind(WIO.Creation<S,P.Store<S>,P.Resources<S>,Unit>,Core.Initialized<S>,WIO.create(~S,~P.Store<S>,~P.Resources<S>,~Unit,~(unit => P.empty_store(~S,unit)),Core.resource(~S,other)),value => initial_created(~S,value))
def scenario(~S: Data) -> IO(String):
  IO.bind(Core.Initialized<S>,String,initial(~S,False{}),a => IO.bind(Core.Initialized<S>,String,initial(~S,True{}),b => IO.pure(String,Core.assembled(~S,a,b))))
def main() -> IO(Unit):
  IO.bind(String,Unit,scenario(~P.SchemaA),a => IO.bind(String,Unit,scenario(~P.SchemaB),b => IO.print("SCHEMA=A\n" ++ a ++ "\nSCHEMA=B\n" ++ b)))

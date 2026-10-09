import Base
import ../provider.bend as P
import ../../../src/ecs/world-io.bend as WIO
import overflow-core.bend as Core

def provisioned(~S: Data,count: Nat,result: Core.Provision<S>) -> String:
  match result:
    case Core.Provisioned{runtime}: Core.finish(~S,Core.execute(~S,count,runtime))
    case Core.PublisherRejected{_}: "PUBLISHER_REGISTRATION_REFUSED"
    case Core.ReaderRejected{_,_}: "READER_REGISTRATION_REFUSED"
def created(~S: Data,count: Nat,result: WIO.Creation<S,P.Store<S>,Core.Resources<S>,Unit>) -> IO(String):
  match result:
    case WIO.Created{world}: IO.pure(String,provisioned(~S,count,Core.provision(~S,world)))
    case WIO.Refused{_}: IO.pure(String,"WORLD_CREATE_REFUSED")
def scenario(~S: Data,count: Nat) -> IO(String):
  IO.bind(WIO.Creation<S,P.Store<S>,Core.Resources<S>,Unit>,String,WIO.create(~S,~P.Store<S>,~Core.Resources<S>,~Unit,~(unit => P.empty_store(~S,unit)),Core.initial_resources(~S)),result => created(~S,count,result))
def accepted(valid: Bool,+count: U32) -> IO(Unit):
  match valid:
    case False{}: IO.die(Unit,2,"full overflow requires count 65537")
    case True{}: IO.bind(String,Unit,scenario(~P.SchemaA,U32.to_nat(count)),a => IO.bind(String,Unit,scenario(~P.SchemaB,U32.to_nat(count)),b => IO.print("SCHEMA=A\n" ++ a ++ "\nSCHEMA=B\n" ++ b)))
def parsed(count: Maybe<&2,U32>) -> IO(Unit):
  match count:
    case None{}: IO.die(Unit,2,"invalid count")
    case Some{+count}: accepted(U32.is_eq(count,65537),count)
def args(values: List<String>) -> IO(Unit):
  match values:
    case _ <> count <> _: parsed(U32.read(count))
    case _: IO.die(Unit,2,"count required")
def main() -> IO(Unit):
  IO.bind(List<String>,Unit,IO.args(),values => args(values))

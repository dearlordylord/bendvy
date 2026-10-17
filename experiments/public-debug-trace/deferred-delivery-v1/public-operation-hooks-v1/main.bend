import Base
import ./fixture.bend as F
import ./scenario.bend as Scenario
import ./handler-registration.bend as Registration
import ../../../../src/ecs/transaction.bend as T
import ../../../../src/ecs/world-io.bend as WI
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/ordinary-resource-field-system.bend as Field

def finished(~S:Data,evidence:List<F.SeedEvidence<S>>,handlers:F.HandlerOwners(~S),value:Maybe<&1,F.Application(~S)>) -> IO(String):
  match value:
    case None{}:IO.pure(String,Scenario.run(~S,evidence,None{}))
    case Some{app}:IO.pure(String,Scenario.run(~S,evidence,Some{(app,handlers)}))
def registered(~S:Data,evidence:List<F.SeedEvidence<S>>,handlers:F.HandlerOwners(~S),source:W.Handle<S>,target:W.Handle<S>,value:Maybe<&1,F.Registered7(~S)>) -> IO(String):
  match value:
    case None{}:IO.pure(String,Scenario.run(~S,evidence,None{}))
    case Some{app}:finished(~S,evidence,handlers,F.attach_inputs(~S,app,F.held(~S,source,target)))
def handlers_registered(~S:Data,evidence:List<F.SeedEvidence<S>>,source:W.Handle<S>,target:W.Handle<S>,value:Maybe<&1,F.World(~S) & F.HandlerOwners(~S)>) -> IO(String):
  match value:
    case None{}:IO.pure(String,Scenario.run(~S,evidence,None{}))
    case Some{(world,handlers)}:registered(~S,evidence,handlers,source,target,F.register(~S,F.queued(~S,world)))
def handler_access(~S:Data,value:Field.Declaration<S,T.Tx<F.World(~S),F.Notice(~S)>,F.Ops(~S)(T.Tx<F.World(~S),F.Notice(~S)>)>) -> List<&2,String>:
  match value:
    case Field.Declaration{_,clauses}:Field.access(~S,clauses)
def both_seeded(~S:Data,source:W.Handle<S>,first:F.SeedEvidence<S>,value:F.World(~S) & F.SeedEvidence<S>) -> IO(String):
  match value:
    case (world,F.SeedEvidence{W.Reserved{+target},activation,write,recovered}):handlers_registered(~S,[first,F.SeedEvidence{W.Reserved{target},activation,write,recovered}],source,target,Registration.register(~S,~F.Store(~S),~F.Resources(~S),~F.Notice(~S),~U32,~F.handler_runner(~S),world,handler_access(~S,F.raw(~S))))
    case (_,second):IO.pure(String,Scenario.run(~S,[first,second],None{}))
def first_seeded(~S:Data,value:F.World(~S) & F.SeedEvidence<S>) -> IO(String):
  match value:
    case (world,F.SeedEvidence{W.Reserved{+source},activation,write,recovered}):both_seeded(~S,source,F.SeedEvidence{W.Reserved{source},activation,write,recovered},F.setup(~S,world))
    case (_,first):IO.pure(String,Scenario.run(~S,[first],None{}))
def created(~S:Data,value:WI.Creation<S,F.Store(~S),F.Resources(~S),F.Notice(~S)>) -> IO(String):
  match value:
    case WI.Created{world}:first_seeded(~S,F.setup(~S,F.inserted(~S,world)))
    case _:IO.die(String,1,"trace World creation failed")
def run(~S:Data) -> IO(String):IO.bind(WI.Creation<S,F.Store(~S),F.Resources(~S),F.Notice(~S)>,String,WI.create(~S,~F.Store(~S),~F.Resources(~S),~F.Notice(~S),~F.empty(~S),F.resources(~S)),created(~S))
def printed(workshop:String,garden:String) -> IO(Unit):IO.print("Workshop\n" ++ workshop ++ "Garden\n" ++ garden)
def workshop(value:String) -> IO(Unit):IO.bind(String,Unit,run(~F.Garden),garden=>printed(value,garden))
def main() -> IO(Unit):IO.bind(String,Unit,run(~F.Workshop),workshop)

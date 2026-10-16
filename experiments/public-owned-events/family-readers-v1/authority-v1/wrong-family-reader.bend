import Base
import ../fixture.bend as Fixture
import ../../ordinary-v1/payload.bend as Payload
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/capabilities.bend as Cap
import ../../../../src/ecs/transaction.bend as T
type A is Data:A{}
type B is Data:B{}
def rejected(runtime:Fixture.Runtime(~A),reader:Fixture.Reader_b(~A),registry:Fixture.Registry_a(~A),args:Payload.Args) -> Fixture.Ran_a(~A):Fixture.run_a(~A,runtime,reader,registry,args)

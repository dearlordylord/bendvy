import Base
import ../fixture.bend as Fixture
type A is Data:A{}
type B is Data:B{}
def accepted(runtime:Fixture.Runtime(~A),reader:Fixture.Reader(~A),registry:Fixture.Registry(~A),args:Fixture.Args) -> Fixture.Ran(~A):Fixture.run(~A,runtime,reader,registry,args)

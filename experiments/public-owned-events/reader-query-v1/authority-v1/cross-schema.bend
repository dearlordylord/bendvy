import Base
import ../fixture.bend as Fixture
type A is Data:A{}
type B is Data:B{}
def rejected(runtime:Fixture.Runtime(~B),reader:Fixture.Reader(~A),registry:Fixture.Registry(~A),args:Fixture.Args) -> Fixture.Ran(~A):Fixture.run(~A,runtime,reader,registry,args)

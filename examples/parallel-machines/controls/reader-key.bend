import Base
import ../declarations.bend as D
import ../events.bend as Events
import ../../../src/ecs/execution-machine-stream.bend as Stream
import ../../../src/ecs/execution-composer-layout.bend as Layout

type OtherKey is Data:
  OtherKey{}
def forbidden(~S:Data,reader:Events.Reader(~S)) -> Stream.Reader<S,OtherKey,D.Mode,D.layout(S),Layout.AtLeaf{}>:reader

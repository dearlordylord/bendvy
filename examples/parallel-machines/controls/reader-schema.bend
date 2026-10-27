import Base
import ../declarations.bend as D
import ../events.bend as Events
import ../../../src/ecs/execution-machine-stream.bend as Stream
import ../../../src/ecs/execution-composer-layout.bend as Layout

type First is Data:
  First{}
type Second is Data:
  Second{}
def forbidden(reader:Events.Reader(~First)) -> Stream.Reader<Second,D.Key,D.Mode,D.layout(Second),Layout.AtLeaf{}>:reader

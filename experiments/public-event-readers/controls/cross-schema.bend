import Base
import ../../../src/ecs/event-runtime.bend as E

type A is Data:
  A{}
type B is Data:
  B{}
def bad(reader: E.Reader<A>) -> E.Reader<B>: reader

import Base
import ../../../src/ecs/event-runtime.bend as E

type Schema is Data:
  Schema{}
def bad(reader: E.Reader<Schema>) -> E.Reader<Schema> & E.Reader<Schema>:
  (reader,reader)

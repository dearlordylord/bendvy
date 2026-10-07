import Base
import ../../src/ecs/reader-domains.bend as D
import schema.bend as S

def duplicate(events: D.Events<S.Schema,S.Notice>) -> D.Events<S.Schema,S.Notice> & D.Events<S.Schema,S.Notice>:
  (events,events)

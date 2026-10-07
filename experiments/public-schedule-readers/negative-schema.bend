import Base
import ../../src/ecs/reader-domains.bend as D
import schema.bend as S
import ../../src/ecs/event-runtime.bend as Ev

type Other is Data:
  Other{}
def cross(events: D.Events<Other,S.Notice>,world: S.World()) -> Ev.Runtime<S.Schema,S.Store,Unit,S.Notice>:
  D.attach(~S.Schema,~S.Store,~Unit,~S.Notice,events,world)

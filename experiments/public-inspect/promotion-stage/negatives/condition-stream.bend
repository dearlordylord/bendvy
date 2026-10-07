import Base
import ../condition.bend as Check
import ../../bend-candidate/consumer.bend as A
import ../../bend-candidate/joint.bend as J
import ../../../../src/ecs/capabilities.bend as Cap
import ../../../../src/ecs/event-runtime.bend as Ev
def bad() -> Cap.ValueRead<Check.Frame<A.Schema,A.Store,A.Resource,U32>,Ev.Reading<U32>>:
  J.event_grant(~A.Schema,~A.Store,~A.Resource,~U32,~Unit)

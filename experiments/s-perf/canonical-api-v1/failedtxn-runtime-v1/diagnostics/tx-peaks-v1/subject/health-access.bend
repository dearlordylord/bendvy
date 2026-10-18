import Base
import ../../../../dense-runtime-v1/types.bend as T
import health.bend as F
import health-audit.bend as Audit
import health-events.bend as E
import ../../../../../../../src/ecs/ordinary-declaration.bend as Identity
import ../../../../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../../../../src/ecs/ordinary-event-declaration.bend as Event

def access() -> List<&2,String>:
  [Identity.key(~T.HealthSchema,~T.Vitals,F.main_identity()),Schema.resource_key(~T.HealthSchema,~T.HealthLedger,Schema.resource(~T.HealthSchema,~T.HealthLedger,"HealthLedger")),Audit.key(),Event.access(~T.HealthSchema,~E.event_type(),Event.write(~T.HealthSchema,~E.event_type(),Event.domain(~T.HealthSchema,~E.event_type(),"ping")))]

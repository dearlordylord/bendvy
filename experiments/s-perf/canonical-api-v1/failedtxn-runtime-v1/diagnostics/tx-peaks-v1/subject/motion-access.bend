import Base
import ../../../../dense-runtime-v1/types.bend as T
import motion.bend as F
import motion-audit.bend as Audit
import events.bend as E
import ../../../../../../../src/ecs/ordinary-declaration.bend as Identity
import ../../../../../../../src/ecs/ordinary-schema.bend as Schema
import ../../../../../../../src/ecs/ordinary-event-declaration.bend as Event

def access() -> List<&2,String>:
  [Identity.key(~T.MotionSchema,~T.Position,F.main_identity()),Schema.resource_key(~T.MotionSchema,~T.MotionLedger,Schema.resource(~T.MotionSchema,~T.MotionLedger,"MotionLedger")),Audit.key(),Event.access(~T.MotionSchema,~E.event_type(),Event.write(~T.MotionSchema,~E.event_type(),Event.domain(~T.MotionSchema,~E.event_type(),"ping")))]

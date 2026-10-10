import Base
import ../ordinary-bundle.bend as Front
import ../../complete-families-v1/canonical.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
def bad(identity:Identity.Declaration<K.SchemaB,K.Payload>) -> Front.Plan<K.SchemaA,K.Incoming,K.Payload>:Front.component(~K.SchemaA,~K.Incoming,~K.Payload,identity)

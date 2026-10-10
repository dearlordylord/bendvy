import Base
import installer.bend as I
import ../marker-phases-v1/apply-retention-v1/consumer.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
def rejected(owners:C.Owners<C.SchemaB>) -> Sch.Build<C.SchemaB,Array<Array<U32>>,C.Resources<C.SchemaB>,String,C.Owners<C.SchemaB>>:I.install(~C.SchemaB,~Array<Array<U32>>,~C.Resources<C.SchemaB>,~String,~C.Owners<C.SchemaB>,~String,I.declare(~C.SchemaA,"wrong-schema"),1,owners)

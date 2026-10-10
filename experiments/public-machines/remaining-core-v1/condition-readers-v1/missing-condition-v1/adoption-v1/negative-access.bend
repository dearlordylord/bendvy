import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import ../../provider.bend as P
import ../checked-schedule.bend as CheckedSch
def rejected(~H:Type,owner:H) -> H & M.CurrentView<P.SchemaA,P.FlowToken,P.Flow>:Cap.value_read(~H,~M.CurrentView<P.SchemaA,P.FlowToken,P.Flow>,~Unit{},owner)

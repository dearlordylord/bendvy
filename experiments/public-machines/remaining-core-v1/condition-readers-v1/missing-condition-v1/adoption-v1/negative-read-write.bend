import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import ../../provider.bend as P
import ../checked-schedule.bend as CheckedSch
def rejected(~H:Type,~cap:Cap.ValueRead<H,M.CurrentView<P.SchemaA,P.FlowToken,P.Flow>>,input:M.QueueInput<P.Flow>,owner:H) -> H:Cap.value_set(~H,~M.QueueInput<P.Flow>,~M.CurrentView<P.SchemaA,P.FlowToken,P.Flow>,~cap,owner,input)

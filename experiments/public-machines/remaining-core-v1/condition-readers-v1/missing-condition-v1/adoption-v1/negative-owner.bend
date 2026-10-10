import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import ../../provider.bend as P
import ../checked-schedule.bend as CheckedSch
def rejected(~H:Type,owner:H,world:W.World<P.SchemaA,P.Store<P.SchemaA>,P.Resources<P.SchemaA>,Unit>) -> H & Sys.Outcome<W.World<P.SchemaA,P.Store<P.SchemaA>,P.Resources<P.SchemaA>,Unit>,String,H>:(owner,Sys.Succeeded{world,owner})

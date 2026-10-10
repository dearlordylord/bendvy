import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import ../../provider.bend as P
import ../checked-schedule.bend as CheckedSch
def skip(~H:Type,owner:H,world:W.World<P.SchemaB,P.Store<P.SchemaB>,P.Resources<P.SchemaB>,Unit>,id:U32) -> H & W.World<P.SchemaB,P.Store<P.SchemaB>,P.Resources<P.SchemaB>,Unit>:(owner,world)
def dispatch(~H:Type,owner:H,world:W.World<P.SchemaB,P.Store<P.SchemaB>,P.Resources<P.SchemaB>,Unit>,id:U32) -> H & Sys.Outcome<W.World<P.SchemaB,P.Store<P.SchemaB>,P.Resources<P.SchemaB>,Unit>,String,Unit>:(owner,Sys.Succeeded{world,Unit{}})
def condition(world:W.World<P.SchemaB,P.Store<P.SchemaB>,P.Resources<P.SchemaB>,Unit>,id:U32) -> W.World<P.SchemaB,P.Store<P.SchemaB>,P.Resources<P.SchemaB>,Unit> & Result<String,Bool>:(world,Done{True{}})
def rejected(~H:Type,schedule:Sch.Schedule<P.SchemaA,P.Store<P.SchemaB>,P.Resources<P.SchemaB>,Unit,H>,world:W.World<P.SchemaB,P.Store<P.SchemaB>,P.Resources<P.SchemaB>,Unit>) -> Sch.RunResult<P.SchemaB,P.Store<P.SchemaB>,P.Resources<P.SchemaB>,Unit,H,String>:CheckedSch.run_with_skip(~P.SchemaB,~P.Store<P.SchemaB>,~P.Resources<P.SchemaB>,~Unit,~H,~String,~skip(~H),~dispatch(~H),~condition,schedule,world)

import Base
import adapter.bend as Adapter
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/machine-handlers.bend as H
import /workspace/formal-proofs/bendvy/src/ecs/machine-handler-bundle.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-schedule.bend as Ordinary
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/experiments/public-handlers/remaining-core-v1/types.bend as T
def rejected(~X:Type,~cap:Cap.ValueRead<X,M.CurrentView<T.SchemaA,T.MachineKey,T.State>>,input:M.QueueInput<T.State>,owner:X) -> X:Cap.value_set(~X,~M.QueueInput<T.State>,~M.CurrentView<T.SchemaA,T.MachineKey,T.State>,~cap,owner,input)

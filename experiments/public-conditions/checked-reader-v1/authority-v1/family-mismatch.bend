import Base
import ../fixture.bend as F
import /workspace/formal-proofs/bendvy/experiments/public-conditions/component-query-v1/schema.bend as Model
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-checked-family-schedule.bend as Checked
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-event-family-runtime.bend as Family
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-checked-bindings.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-observation-data.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Fields
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schedule.bend as Single
import /workspace/formal-proofs/bendvy/src/ecs/checked-condition-schedule.bend as Error
import /workspace/formal-proofs/bendvy/src/ecs/event-stream.bend as Stream
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/schedule-provision.bend as SP
def rejected(~S:Data,value:Family.Application<S,Array<U32>,F.Resources(~S),U32,Array<U32>,F.Owners(~S),F.Rows(),F.observe(~S),F.fold(~S)>) -> Checked.Attachment<F.Registered(~S),B.Bindings<F.World(~S),F.Guards(~S),F.select(~S)>,F.Application(~S)>:Checked.attach(~S,~Array<U32>,~F.Resources(~S),~U32,~F.FamilyState(~S),~F.Owners(~S),~F.Rows(),~F.observe(~S),~F.fold(~S),~F.Guards(~S),~F.select(~S),value,"readers",F.plan(~S),F.bindings(~S))

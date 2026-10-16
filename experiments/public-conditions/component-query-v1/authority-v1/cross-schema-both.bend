import Base
import ../fixture.bend as F
import ../schema.bend as Model
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-check-query.bend as CQ
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-check-declaration.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-component-binding.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-checked-condition.bend as Cond
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
def rejected() -> D.Declaration<Model.Workshop,Model.Store(~Model.Workshop),F.Resources(~Model.Workshop),Unit,F.MixedOps(~Model.Workshop)>:D.both(~Model.Workshop,~Model.Store(~Model.Workshop),~F.Resources(~Model.Workshop),~Unit,~F.JoinOps(~Model.Workshop),~F.ThresholdOps(~Model.Workshop),~F.joined_declaration(~Model.Garden),~F.threshold_declaration(~Model.Workshop))

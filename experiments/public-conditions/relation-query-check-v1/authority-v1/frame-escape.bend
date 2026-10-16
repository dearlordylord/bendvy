import Base
import ../fixture.bend as F
import ../schema.bend as Model
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-check-relation.bend as Rel
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-inspector-relation.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-check-query.bend as CQ
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-check-declaration.bend as CD
import /workspace/formal-proofs/bendvy/src/ecs/relation-query.bend as RQ
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy/src/ecs/check.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as IQ
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-checked-condition.bend as Cond
def rejected(~S:Data,~H:Type,~caps:F.JoinOps(~S)(H),owner:H) -> K.Frame<S,Model.Store(~S),F.Resources(~S),A.Notice<S,Unit>>:owner

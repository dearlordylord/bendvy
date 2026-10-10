import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-bundle.bend as Front
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/canonical-world-v1/complete-families-v1/canonical.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-declaration.bend as Identity
def bad(identity:Identity.Declaration<K.SchemaB,K.Payload>) -> Front.Plan<K.SchemaA,K.Incoming,K.Payload>:Front.component(~K.SchemaA,~K.Incoming,~K.Payload,identity)

import Base
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-bundle.bend as Front
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/canonical-world-v1/duplicate-admission-v1/public-relocation-v1/A/bundle.bend as B
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/canonical-world-v1/duplicate-admission-v1/public-relocation-v1/A/runtime.bend as R
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/canonical-world-v1/complete-families-v1/canonical.bend as K
def bad(plan:Front.Plan<K.SchemaB,B.Raw(),B.Cooked()>,owner:B.Owner(R.Mail),input:B.Input()) -> B.Owner(R.Mail) & B.Output():Front.request(~K.SchemaA,~B.Store,~R.Mail,~U32,~B.Packet,~K.Context<K.SchemaA>,~B.Raw(),~B.Cooked(),~B.ConstructorError(),~K.stage(~K.SchemaA),~B.pack,~B.unpack,plan,owner,input)

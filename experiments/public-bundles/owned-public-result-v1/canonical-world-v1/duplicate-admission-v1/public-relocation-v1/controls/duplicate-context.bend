import Base
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/canonical-world-v1/duplicate-admission-v1/public-relocation-v1/A/bundle.bend as B
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/canonical-world-v1/duplicate-admission-v1/public-relocation-v1/A/runtime.bend as R
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def bad(~H:Type,~cap:Cap.OwnedRequest<H,B.Input(),B.Output()>,input:B.Input(),ctx:H) -> H & (H & B.Output()):(ctx,B.body(~H,~cap,input,ctx))

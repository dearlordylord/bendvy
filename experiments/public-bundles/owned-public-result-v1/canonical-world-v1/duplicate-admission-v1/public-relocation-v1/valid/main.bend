import Base
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/canonical-world-v1/duplicate-admission-v1/public-relocation-v1/valid/duplicate.bend as Drive
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/canonical-world-v1/duplicate-admission-v1/public-relocation-v1/valid/runtime.bend as R
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/canonical-world-v1/duplicate-admission-v1/public-relocation-v1/valid/bundle.bend as B
import /workspace/formal-proofs/bendvy-worktrees/bundle41-authority-refresh-v1/experiments/public-bundles/owned-public-result-v1/canonical-world-v1/complete-families-v1/canonical.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/world-io.bend as WIO
def created(result:WIO.Creation<K.SchemaA,B.Store,R.Mail,U32>) -> IO(Unit):
  match result:
    case WIO.Created{world}:IO.print(Drive.begun(world))
    case WIO.Refused{mail}:IO.print("namespace-refused")
def main() -> IO(Unit):IO.bind(WIO.Creation<K.SchemaA,B.Store,R.Mail,U32>,Unit,WIO.create(~K.SchemaA,~B.Store,~R.Mail,~U32,~R.empty,R.Mail{[],[],[],[],ANode{ALeaf{70},ALeaf{71}}}),created)

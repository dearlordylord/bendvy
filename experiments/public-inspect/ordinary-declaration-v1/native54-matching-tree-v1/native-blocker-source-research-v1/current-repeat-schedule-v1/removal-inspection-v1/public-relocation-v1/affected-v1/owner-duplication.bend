import Base
import /workspace/formal-proofs/bendvy-worktrees/native54-matching-tree-v1/experiments/public-inspect/ordinary-declaration-v1/native54-matching-tree-v1/native-blocker-source-research-v1/current-repeat-schedule-v1/removal-inspection-v1/public-relocation-v1/consumer-public.bend as C
def duplicated(owner:C.Fixture<C.A>) -> C.Fixture<C.A> & C.Fixture<C.A>:(owner,owner)
def main() -> C.Fixture<C.A> & C.Fixture<C.A>:duplicated(C.setup(~C.A))

import Base
import runtime.bend as R
import ../bundle.bend as B
import ../canonical.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/bundle-install.bend as F
import ../affected-v1/schemaB/bundle.bend as Other
def bad(world:R.World(),receipt:Other.Recovery(R.Mail)) -> F.Restore<R.World(),B.Entries(),B.Recovery(R.Mail)>:R.resume_entries(world,receipt)

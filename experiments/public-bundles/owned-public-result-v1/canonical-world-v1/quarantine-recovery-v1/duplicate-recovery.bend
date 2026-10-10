import Base
import runtime.bend as R
import ../bundle.bend as B
import ../canonical.bend as K
import /workspace/formal-proofs/bendvy/src/ecs/bundle-install.bend as F
def bad(world:R.World(),receipt:B.Recovery(R.Mail)) -> B.Recovery(R.Mail) & F.Restore<R.World(),B.Entries(),B.Recovery(R.Mail)>:(receipt,R.resume_entries(world,receipt))

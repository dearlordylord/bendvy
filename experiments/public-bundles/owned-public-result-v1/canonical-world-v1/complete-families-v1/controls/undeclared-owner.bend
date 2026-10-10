import Base
import ../bundle.bend as B
import ../runtime.bend as R
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def bad(~H:Type,input:B.Input(),ctx:H) -> H & B.Output():B.request(~R.Mail,ctx,input)

import Base
import ../../bundle.bend as B
import ../../runtime.bend as R
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def bad(~H:Type,~cap:Cap.OwnedRequest<H,B.Input(),B.Output()>,input:B.Input(),ctx:H) -> H & (H & B.Output()):(ctx,B.body(~H,~cap,input,ctx))

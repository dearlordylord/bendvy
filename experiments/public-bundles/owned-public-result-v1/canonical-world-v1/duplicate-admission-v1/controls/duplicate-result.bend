import Base
import ../bundle.bend as B
import ../runtime.bend as R
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def duplicated(output:B.Output()) -> B.Output() & B.Output():(output,output)
def joined(~H:Type,result:H & B.Output()) -> H & (B.Output() & B.Output()):
  match result:
    case (ctx,output):(ctx,duplicated(output))
def bad(~H:Type,~cap:Cap.OwnedRequest<H,B.Input(),B.Output()>,input:B.Input(),ctx:H) -> H & (B.Output() & B.Output()):joined(~H,B.body(~H,~cap,input,ctx))

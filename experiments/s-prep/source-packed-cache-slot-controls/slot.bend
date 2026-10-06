import Base
import ./cached-payload.bend as CP
import ./types.bend as T
import ./host-render.bend as R
def data(values:List<&1,U32>) -> List<&2,U32>:
  match values:
    case Nil{}: []
    case Con{head,tail}: head <> data(tail)
def observe(label:U32,retained:T.PositionView,first:U32,result:CP.PrototypeMotionMainSlot & U32) -> IO(Unit):
  match result:
    case (CP.PrototypeMotionMainSlot{array,frame,a,b,c,d,cf},second): IO.print("{\"length\":" ++ U32.show(label) ++ ",\"array\":" ++ R.render_list(U32,U32.show,data(Array.to_list(~U32,array))) ++ ",\"rawFrame\":" ++ U32.show(frame) ++ ",\"cached\":" ++ R.render_position(T.PositionView{T.Four{a,b,c,d},cf}) ++ ",\"retained\":" ++ R.render_position(retained) ++ ",\"old\":[" ++ U32.show(first) ++ "," ++ U32.show(second) ++ "]}")
def first(label:U32,retained:T.PositionView,result:CP.PrototypeMotionMainSlot & U32) -> IO(Unit):
  match result:
    case (owner,old): observe(label,retained,old,CP.prototype_slot_position_swap(owner,700))
def got(label:U32,result:CP.PrototypeMotionMainSlot & T.PositionView) -> IO(Unit):
  match result:
    case (owner,retained): first(label,retained,CP.prototype_slot_position_swap(owner,500))
def run(label:U32,array:Array<U32>) -> IO(Unit):
  got(label,CP.prototype_slot_position_get(CP.PrototypeMotionMainSlot{array,4,999,200,300,400,77}))
def main() -> IO(Unit):
  do IO<Unit>:
    run(1,[100:U32^0n])
    run(2,Array.set(U32,[100:U32^1n],1,101))
    run(4,Array.set(U32,Array.set(U32,Array.set(U32,[100:U32^2n],1,101),2,102),3,103))
    run(8,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,[100:U32^3n],1,101),2,102),3,103),4,104),5,105),6,106),7,107))
    return Unit{}

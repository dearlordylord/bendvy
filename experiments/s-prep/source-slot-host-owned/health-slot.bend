import Base
import ./cached-payload.bend as CP
import ./types.bend as T
import ./host-render.bend as R
def data(values:List<&1,U32>) -> List<&2,U32>:
  match values:
    case Nil{}: []
    case Con{head,tail}: head <> data(tail)
def observe(label:U32,retained:T.VitalsView,first:U32,result:CP.PrototypeHealthMainSlot & U32) -> IO(Unit):
  match result:
    case (CP.PrototypeHealthMainSlot{array,reserve,class,a,b,c,d,cr,cc},second): IO.print("{\"length\":" ++ U32.show(label) ++ ",\"array\":" ++ R.render_list(U32,U32.show,data(Array.to_list(~U32,array))) ++ ",\"rawReserve\":" ++ U32.show(reserve) ++ ",\"rawClass\":" ++ U32.show(class) ++ ",\"cached\":" ++ R.render_vitals(T.VitalsView{T.Four{a,b,c,d},cr,cc}) ++ ",\"retained\":" ++ R.render_vitals(retained) ++ ",\"old\":[" ++ U32.show(first) ++ "," ++ U32.show(second) ++ "]}")
def first(label:U32,retained:T.VitalsView,result:CP.PrototypeHealthMainSlot & U32) -> IO(Unit):
  match result:
    case (owner,old): observe(label,retained,old,CP.prototype_slot_vitals_swap(owner,700))
def got(label:U32,result:CP.PrototypeHealthMainSlot & T.VitalsView) -> IO(Unit):
  match result:
    case (owner,retained): first(label,retained,CP.prototype_slot_vitals_swap(owner,500))
def run(label:U32,array:Array<U32>) -> IO(Unit):
  got(label,CP.prototype_slot_vitals_get(CP.PrototypeHealthMainSlot{array,4,5,999,200,300,400,77,88}))
def main() -> IO(Unit):
  do IO<Unit>:
    run(1,[100:U32^0n])
    run(2,Array.set(U32,[100:U32^1n],1,101))
    run(4,Array.set(U32,Array.set(U32,Array.set(U32,[100:U32^2n],1,101),2,102),3,103))
    run(8,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,[100:U32^3n],1,101),2,102),3,103),4,104),5,105),6,106),7,107))
    run(16,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,[100:U32^4n],1,101),2,102),3,103),4,104),5,105),6,106),7,107),8,108),9,109),10,110),11,111),12,112),13,113),14,114),15,115))
    return Unit{}

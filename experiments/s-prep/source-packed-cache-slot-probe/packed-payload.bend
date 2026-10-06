# Private persistent concrete Main slot; original nominal public types stay unchanged.
type PrototypeMotionMainSlot is Type:
  PrototypeMotionMainSlot{coordinates:Array<U32>,rawframe:U32,a:U32,b:U32,c:U32,d:U32,cachedframe:U32}
def prototype_slot_position_result(result:T.Position & T.PositionView) -> PrototypeMotionMainSlot:
  match result:
    case (T.Position{coordinates,rawframe},T.PositionView{T.Four{a,b,c,d},cachedframe}): PrototypeMotionMainSlot{coordinates,rawframe,a,b,c,d,cachedframe}
def prototype_slot_position_new(raw:T.Position) -> PrototypeMotionMainSlot:
  prototype_slot_position_result(P.position_get(raw))
def prototype_slot_position_get(owner:PrototypeMotionMainSlot) -> PrototypeMotionMainSlot & T.PositionView:
  match owner:
    case PrototypeMotionMainSlot{coordinates,rawframe,+a,+b,+c,+d,+cachedframe}: (PrototypeMotionMainSlot{coordinates,rawframe,a,b,c,d,cachedframe},T.PositionView{T.Four{a,b,c,d},cachedframe})
def prototype_slot_position_raw(owner:PrototypeMotionMainSlot) -> T.Position:
  match owner:
    case PrototypeMotionMainSlot{coordinates,rawframe,_,_,_,_,_}: T.Position{coordinates,rawframe}
def prototype_slot_position_swap_done(rawframe:U32,b:U32,c:U32,d:U32,cachedframe:U32,+value:U32,result:Array<U32> & U32) -> PrototypeMotionMainSlot & U32:
  match result:
    case (coordinates,old): (PrototypeMotionMainSlot{Array.set(U32,coordinates,0,value),rawframe,value,b,c,d,cachedframe},old)
def prototype_slot_position_swap(owner:PrototypeMotionMainSlot,value:U32) -> PrototypeMotionMainSlot & U32:
  match owner:
    case PrototypeMotionMainSlot{coordinates,rawframe,_,b,c,d,cachedframe}: prototype_slot_position_swap_done(rawframe,b,c,d,cachedframe,value,Array.get(U32,coordinates,0))

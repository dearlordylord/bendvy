# Private persistent concrete Main slot; original nominal public types stay unchanged.
type PrototypeHealthMainSlot is Type:
  PrototypeHealthMainSlot{levels:Array<U32>,rawreserve:U32,rawclass:U32,a:U32,b:U32,c:U32,d:U32,cachedreserve:U32,cachedclass:U32}
def prototype_slot_vitals_result(result:T.Vitals & T.VitalsView) -> PrototypeHealthMainSlot:
  match result:
    case (T.Vitals{levels,rawreserve,rawclass},T.VitalsView{T.Four{a,b,c,d},cachedreserve,cachedclass}): PrototypeHealthMainSlot{levels,rawreserve,rawclass,a,b,c,d,cachedreserve,cachedclass}
def prototype_slot_vitals_new(raw:T.Vitals) -> PrototypeHealthMainSlot:
  prototype_slot_vitals_result(P.vitals_get(raw))
def prototype_slot_vitals_get(owner:PrototypeHealthMainSlot) -> PrototypeHealthMainSlot & T.VitalsView:
  match owner:
    case PrototypeHealthMainSlot{levels,rawreserve,rawclass,+a,+b,+c,+d,+cachedreserve,+cachedclass}: (PrototypeHealthMainSlot{levels,rawreserve,rawclass,a,b,c,d,cachedreserve,cachedclass},T.VitalsView{T.Four{a,b,c,d},cachedreserve,cachedclass})
def prototype_slot_vitals_raw(owner:PrototypeHealthMainSlot) -> T.Vitals:
  match owner:
    case PrototypeHealthMainSlot{levels,rawreserve,rawclass,_,_,_,_,_,_}: T.Vitals{levels,rawreserve,rawclass}
def prototype_slot_vitals_swap_done(rawreserve:U32,rawclass:U32,b:U32,c:U32,d:U32,cachedreserve:U32,cachedclass:U32,+value:U32,result:Array<U32> & U32) -> PrototypeHealthMainSlot & U32:
  match result:
    case (levels,old): (PrototypeHealthMainSlot{Array.set(U32,levels,0,value),rawreserve,rawclass,value,b,c,d,cachedreserve,cachedclass},old)
def prototype_slot_vitals_swap(owner:PrototypeHealthMainSlot,value:U32) -> PrototypeHealthMainSlot & U32:
  match owner:
    case PrototypeHealthMainSlot{levels,rawreserve,rawclass,_,b,c,d,cachedreserve,cachedclass}: prototype_slot_vitals_swap_done(rawreserve,rawclass,b,c,d,cachedreserve,cachedclass,value,Array.get(U32,levels,0))

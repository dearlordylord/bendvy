import Base
import ./types.bend as T
import ./cached-payload.bend as CP
import ./payload.bend as P

def position_done(a:U32,b:U32,c:U32,d:U32,frame:U32,result:T.Position & T.PositionView) -> CP.PrototypeMotionMainSlot & T.PositionView:
  match result:
    case (T.Position{array,rawframe},view): (CP.PrototypeMotionMainSlot{array,rawframe,a,b,c,d,frame},view)
def position_get(owner:CP.PrototypeMotionMainSlot) -> CP.PrototypeMotionMainSlot & T.PositionView:
  match owner:
    case CP.PrototypeMotionMainSlot{array,rawframe,a,b,c,d,frame}: position_done(a,b,c,d,frame,P.position_get(T.Position{array,rawframe}))
def vitals_done(a:U32,b:U32,c:U32,d:U32,reserve:U32,class:U32,result:T.Vitals & T.VitalsView) -> CP.PrototypeHealthMainSlot & T.VitalsView:
  match result:
    case (T.Vitals{array,rawreserve,rawclass},view): (CP.PrototypeHealthMainSlot{array,rawreserve,rawclass,a,b,c,d,reserve,class},view)
def vitals_get(owner:CP.PrototypeHealthMainSlot) -> CP.PrototypeHealthMainSlot & T.VitalsView:
  match owner:
    case CP.PrototypeHealthMainSlot{array,rawreserve,rawclass,a,b,c,d,reserve,class}: vitals_done(a,b,c,d,reserve,class,P.vitals_get(T.Vitals{array,rawreserve,rawclass}))

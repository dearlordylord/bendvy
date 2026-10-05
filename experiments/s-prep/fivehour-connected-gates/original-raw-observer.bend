import Base
import ./types.bend as T
import ./cache.bend as C
import ./payload.bend as P

def done(-Raw:Type,-View:Data,cached:View,result:Raw & View) -> C.Cache<Raw,View> & View:
  match result:
    case (raw,view): (C.Cache{raw,cached},view)
def observe(-Raw:Type,-View:Data,get:Raw -> Raw & View,owner:C.Cache<Raw,View>) -> C.Cache<Raw,View> & View:
  match owner:
    case C.Cache{raw,cached}: done(Raw,View,cached,get(raw))
def position_get(owner:C.Cache<T.Position,T.PositionView>) -> C.Cache<T.Position,T.PositionView> & T.PositionView:
  observe(T.Position,T.PositionView,P.position_get,owner)
def vitals_get(owner:C.Cache<T.Vitals,T.VitalsView>) -> C.Cache<T.Vitals,T.VitalsView> & T.VitalsView:
  observe(T.Vitals,T.VitalsView,P.vitals_get,owner)
def motion_ledger_get(owner:C.Cache<T.MotionLedger,T.LedgerView>) -> C.Cache<T.MotionLedger,T.LedgerView> & T.LedgerView:
  observe(T.MotionLedger,T.LedgerView,P.motion_ledger_get,owner)
def health_ledger_get(owner:C.Cache<T.HealthLedger,T.LedgerView>) -> C.Cache<T.HealthLedger,T.LedgerView> & T.LedgerView:
  observe(T.HealthLedger,T.LedgerView,P.health_ledger_get,owner)

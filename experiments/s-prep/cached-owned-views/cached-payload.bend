import Base
import ./types.bend as T
import ./uncached-payload.bend as P
import ./cache.bend as C

def position_patch(view:T.PositionView,value:U32) -> T.PositionView:
  match view:
    case T.PositionView{T.Four{_,b,c,d},frame}: T.PositionView{T.Four{value,b,c,d},frame}
def position_new(raw:T.Position) -> C.Checked<T.Position,T.PositionView>:
  C.checkpoint(T.Position,T.PositionView,P.position_get,C.Checked{C.init(T.Position,T.PositionView,P.position_get,raw),[]})
def position_get(owner:C.Checked<T.Position,T.PositionView>) -> C.Checked<T.Position,T.PositionView> & T.PositionView:
  C.checked_read(T.Position,T.PositionView,C.checkpoint(T.Position,T.PositionView,P.position_get,owner))
def position_swap(owner:C.Checked<T.Position,T.PositionView>,value:U32) -> C.Checked<T.Position,T.PositionView> & U32:
  C.checked_swap(T.Position,T.PositionView,P.position_swap,position_patch,P.position_get,owner,value)

def vitals_patch(view:T.VitalsView,value:U32) -> T.VitalsView:
  match view:
    case T.VitalsView{T.Four{_,b,c,d},reserve,class}: T.VitalsView{T.Four{value,b,c,d},reserve,class}
def vitals_new(raw:T.Vitals) -> C.Checked<T.Vitals,T.VitalsView>:
  C.checkpoint(T.Vitals,T.VitalsView,P.vitals_get,C.Checked{C.init(T.Vitals,T.VitalsView,P.vitals_get,raw),[]})
def vitals_get(owner:C.Checked<T.Vitals,T.VitalsView>) -> C.Checked<T.Vitals,T.VitalsView> & T.VitalsView:
  C.checked_read(T.Vitals,T.VitalsView,C.checkpoint(T.Vitals,T.VitalsView,P.vitals_get,owner))
def vitals_swap(owner:C.Checked<T.Vitals,T.VitalsView>,value:U32) -> C.Checked<T.Vitals,T.VitalsView> & U32:
  C.checked_swap(T.Vitals,T.VitalsView,P.vitals_swap,vitals_patch,P.vitals_get,owner,value)

def motion_ledger_patch(view:T.LedgerView,value:U32) -> T.LedgerView:
  match view:
    case T.LedgerView{T.Four{_,b,c,d},epoch}: T.LedgerView{T.Four{value,b,c,d},epoch}
def motion_ledger_new(raw:T.MotionLedger) -> C.Checked<T.MotionLedger,T.LedgerView>:
  C.checkpoint(T.MotionLedger,T.LedgerView,P.motion_ledger_get,C.Checked{C.init(T.MotionLedger,T.LedgerView,P.motion_ledger_get,raw),[]})
def motion_ledger_get(owner:C.Checked<T.MotionLedger,T.LedgerView>) -> C.Checked<T.MotionLedger,T.LedgerView> & T.LedgerView:
  C.checked_read(T.MotionLedger,T.LedgerView,C.checkpoint(T.MotionLedger,T.LedgerView,P.motion_ledger_get,owner))
def motion_ledger_swap(owner:C.Checked<T.MotionLedger,T.LedgerView>,value:U32) -> C.Checked<T.MotionLedger,T.LedgerView> & U32:
  C.checked_swap(T.MotionLedger,T.LedgerView,P.motion_ledger_swap,motion_ledger_patch,P.motion_ledger_get,owner,value)

def health_ledger_patch(view:T.LedgerView,value:U32) -> T.LedgerView:
  match view:
    case T.LedgerView{T.Four{_,b,c,d},epoch}: T.LedgerView{T.Four{value,b,c,d},epoch}
def health_ledger_new(raw:T.HealthLedger) -> C.Checked<T.HealthLedger,T.LedgerView>:
  C.checkpoint(T.HealthLedger,T.LedgerView,P.health_ledger_get,C.Checked{C.init(T.HealthLedger,T.LedgerView,P.health_ledger_get,raw),[]})
def health_ledger_get(owner:C.Checked<T.HealthLedger,T.LedgerView>) -> C.Checked<T.HealthLedger,T.LedgerView> & T.LedgerView:
  C.checked_read(T.HealthLedger,T.LedgerView,C.checkpoint(T.HealthLedger,T.LedgerView,P.health_ledger_get,owner))
def health_ledger_swap(owner:C.Checked<T.HealthLedger,T.LedgerView>,value:U32) -> C.Checked<T.HealthLedger,T.LedgerView> & U32:
  C.checked_swap(T.HealthLedger,T.LedgerView,P.health_ledger_swap,health_ledger_patch,P.health_ledger_get,owner,value)

import Base
import ./types.bend as T
import ./uncached-payload.bend as P
import ./cache.bend as C
def uncached_done(-Raw:Type,-View:Data,cached:View,result:Raw & View) -> C.Cache<Raw,View> & View:
  match result:
    case (raw,view): (C.Cache{raw,cached},view)
def uncached(-Raw:Type,-View:Data,get:Raw -> Raw & View,owner:C.Cache<Raw,View>) -> C.Cache<Raw,View> & View:
  match owner:
    case C.Cache{raw,cached}: uncached_done(Raw,View,cached,get(raw))

def position_patch(view:T.PositionView,value:U32) -> T.PositionView:
  match view:
    case T.PositionView{T.Four{_,b,c,d},frame}: T.PositionView{T.Four{value,b,c,d},frame}
def position_new(raw:T.Position) -> C.Cache<T.Position,T.PositionView>:
  C.init(T.Position,T.PositionView,P.position_get,raw)
def position_get(owner:C.Cache<T.Position,T.PositionView>) -> C.Cache<T.Position,T.PositionView> & T.PositionView:
  C.get(T.Position,T.PositionView,owner)
def position_uncached(owner:C.Cache<T.Position,T.PositionView>) -> C.Cache<T.Position,T.PositionView> & T.PositionView:
  uncached(T.Position,T.PositionView,P.position_get,owner)
def position_swap(owner:C.Cache<T.Position,T.PositionView>,value:U32) -> C.Cache<T.Position,T.PositionView> & U32:
  C.swap(T.Position,T.PositionView,P.position_swap,position_patch,owner,value)

def vitals_patch(view:T.VitalsView,value:U32) -> T.VitalsView:
  match view:
    case T.VitalsView{T.Four{_,b,c,d},reserve,class}: T.VitalsView{T.Four{value,b,c,d},reserve,class}
def vitals_new(raw:T.Vitals) -> C.Cache<T.Vitals,T.VitalsView>:
  C.init(T.Vitals,T.VitalsView,P.vitals_get,raw)
def vitals_get(owner:C.Cache<T.Vitals,T.VitalsView>) -> C.Cache<T.Vitals,T.VitalsView> & T.VitalsView:
  C.get(T.Vitals,T.VitalsView,owner)
def vitals_uncached(owner:C.Cache<T.Vitals,T.VitalsView>) -> C.Cache<T.Vitals,T.VitalsView> & T.VitalsView:
  uncached(T.Vitals,T.VitalsView,P.vitals_get,owner)
def vitals_swap(owner:C.Cache<T.Vitals,T.VitalsView>,value:U32) -> C.Cache<T.Vitals,T.VitalsView> & U32:
  C.swap(T.Vitals,T.VitalsView,P.vitals_swap,vitals_patch,owner,value)

def motion_ledger_patch(view:T.LedgerView,value:U32) -> T.LedgerView:
  match view:
    case T.LedgerView{T.Four{_,b,c,d},epoch}: T.LedgerView{T.Four{value,b,c,d},epoch}
def motion_ledger_new(raw:T.MotionLedger) -> C.Cache<T.MotionLedger,T.LedgerView>:
  C.init(T.MotionLedger,T.LedgerView,P.motion_ledger_get,raw)
def motion_ledger_get(owner:C.Cache<T.MotionLedger,T.LedgerView>) -> C.Cache<T.MotionLedger,T.LedgerView> & T.LedgerView:
  C.get(T.MotionLedger,T.LedgerView,owner)
def motion_ledger_uncached(owner:C.Cache<T.MotionLedger,T.LedgerView>) -> C.Cache<T.MotionLedger,T.LedgerView> & T.LedgerView:
  uncached(T.MotionLedger,T.LedgerView,P.motion_ledger_get,owner)
def motion_ledger_swap(owner:C.Cache<T.MotionLedger,T.LedgerView>,value:U32) -> C.Cache<T.MotionLedger,T.LedgerView> & U32:
  C.swap(T.MotionLedger,T.LedgerView,P.motion_ledger_swap,motion_ledger_patch,owner,value)

def health_ledger_patch(view:T.LedgerView,value:U32) -> T.LedgerView:
  match view:
    case T.LedgerView{T.Four{_,b,c,d},epoch}: T.LedgerView{T.Four{value,b,c,d},epoch}
def health_ledger_new(raw:T.HealthLedger) -> C.Cache<T.HealthLedger,T.LedgerView>:
  C.init(T.HealthLedger,T.LedgerView,P.health_ledger_get,raw)
def health_ledger_get(owner:C.Cache<T.HealthLedger,T.LedgerView>) -> C.Cache<T.HealthLedger,T.LedgerView> & T.LedgerView:
  C.get(T.HealthLedger,T.LedgerView,owner)
def health_ledger_uncached(owner:C.Cache<T.HealthLedger,T.LedgerView>) -> C.Cache<T.HealthLedger,T.LedgerView> & T.LedgerView:
  uncached(T.HealthLedger,T.LedgerView,P.health_ledger_get,owner)
def health_ledger_swap(owner:C.Cache<T.HealthLedger,T.LedgerView>,value:U32) -> C.Cache<T.HealthLedger,T.LedgerView> & U32:
  C.swap(T.HealthLedger,T.LedgerView,P.health_ledger_swap,health_ledger_patch,owner,value)

def velocity_get(owner:T.Velocity) -> T.Velocity & T.VelocityView:
  P.velocity_get(owner)
def armor_get(owner:T.Armor) -> T.Armor & T.ArmorView:
  P.armor_get(owner)

import Base
import ./types.bend as T

def four_done(a: U32,b: U32,c: U32,result: Array<U32> & U32) -> Array<U32> & T.Four:
  match result:
    case (array,d): (array,T.Four{a,b,c,d})
def four_c(a: U32,b: U32,result: Array<U32> & U32) -> Array<U32> & T.Four:
  match result:
    case (array,c): four_done(a,b,c,Array.get(U32,array,3))
def four_b(a: U32,result: Array<U32> & U32) -> Array<U32> & T.Four:
  match result:
    case (array,b): four_c(a,b,Array.get(U32,array,2))
def four_a(result: Array<U32> & U32) -> Array<U32> & T.Four:
  match result:
    case (array,a): four_b(a,Array.get(U32,array,1))
def four(array: Array<U32>) -> Array<U32> & T.Four:
  four_a(Array.get(U32,array,0))

def position_observed(+frame: U32,result: Array<U32> & T.Four) -> T.Position & T.PositionView:
  match result:
    case (array,values): (T.Position{array,frame},T.PositionView{values,frame})
def position_get(owner: T.Position) -> T.Position & T.PositionView:
  match owner:
    case T.Position{array,frame}: position_observed(frame,four(array))
def position_swapped(+frame: U32,result: Array<U32> & U32) -> T.Position & U32:
  match result:
    case (array,old): (T.Position{array,frame},old)
def position_swap(owner: T.Position,value: U32) -> T.Position & U32:
  match owner:
    case T.Position{array,frame}: position_swapped(frame,Array.swap(U32,array,0,value))

def vitals_observed(+reserve: U32,+class: U32,result: Array<U32> & T.Four) -> T.Vitals & T.VitalsView:
  match result:
    case (array,values): (T.Vitals{array,reserve,class},T.VitalsView{values,reserve,class})
def vitals_get(owner: T.Vitals) -> T.Vitals & T.VitalsView:
  match owner:
    case T.Vitals{array,reserve,class}: vitals_observed(reserve,class,four(array))
def vitals_swapped(+reserve: U32,+class: U32,result: Array<U32> & U32) -> T.Vitals & U32:
  match result:
    case (array,old): (T.Vitals{array,reserve,class},old)
def vitals_swap(owner: T.Vitals,value: U32) -> T.Vitals & U32:
  match owner:
    case T.Vitals{array,reserve,class}: vitals_swapped(reserve,class,Array.swap(U32,array,0,value))

def velocity_observed(+moving: Bool,result: Array<U32> & T.Four) -> T.Velocity & T.VelocityView:
  match result:
    case (array,values): (T.Velocity{array,moving},T.VelocityView{values,moving})
def velocity_get(owner: T.Velocity) -> T.Velocity & T.VelocityView:
  match owner:
    case T.Velocity{array,moving}: velocity_observed(moving,four(array))

def armor_observed(+grade: U32,result: Array<U32> & T.Four) -> T.Armor & T.ArmorView:
  match result:
    case (array,values): (T.Armor{array,grade},T.ArmorView{values,grade})
def armor_get(owner: T.Armor) -> T.Armor & T.ArmorView:
  match owner:
    case T.Armor{array,grade}: armor_observed(grade,four(array))

def motion_ledger_observed(+epoch: U32,result: Array<U32> & T.Four) -> T.MotionLedger & T.LedgerView:
  match result:
    case (array,values): (T.MotionLedger{array,epoch},T.LedgerView{values,epoch})
def motion_ledger_get(owner: T.MotionLedger) -> T.MotionLedger & T.LedgerView:
  match owner:
    case T.MotionLedger{array,epoch}: motion_ledger_observed(epoch,four(array))
def motion_ledger_swapped(+epoch: U32,result: Array<U32> & U32) -> T.MotionLedger & U32:
  match result:
    case (array,old): (T.MotionLedger{array,epoch},old)
def motion_ledger_swap(owner: T.MotionLedger,value: U32) -> T.MotionLedger & U32:
  match owner:
    case T.MotionLedger{array,epoch}: motion_ledger_swapped(epoch,Array.swap(U32,array,0,value))

def health_ledger_observed(+epoch: U32,result: Array<U32> & T.Four) -> T.HealthLedger & T.LedgerView:
  match result:
    case (array,values): (T.HealthLedger{array,epoch},T.LedgerView{values,epoch})
def health_ledger_get(owner: T.HealthLedger) -> T.HealthLedger & T.LedgerView:
  match owner:
    case T.HealthLedger{array,epoch}: health_ledger_observed(epoch,four(array))
def health_ledger_swapped(+epoch: U32,result: Array<U32> & U32) -> T.HealthLedger & U32:
  match result:
    case (array,old): (T.HealthLedger{array,epoch},old)
def health_ledger_swap(owner: T.HealthLedger,value: U32) -> T.HealthLedger & U32:
  match owner:
    case T.HealthLedger{array,epoch}: health_ledger_swapped(epoch,Array.swap(U32,array,0,value))

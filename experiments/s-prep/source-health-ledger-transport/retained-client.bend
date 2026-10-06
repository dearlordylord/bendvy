import Base
import ./types.bend as T

def motion_ledger_after(~Owner:Type,pair:Owner & Maybe<&2,T.LedgerView>,old:T.LedgerView) -> Owner & U32:
  match pair old:
    case (owner,Some{T.LedgerView{T.Four{200,101,102,103},4}}) T.LedgerView{T.Four{100,101,102,103},4}: (owner,1)
    case (owner,_) _: (owner,0)
def motion_ledger_before(~Owner:Type,~ledger:Owner -> T.MotionLedgerToken -> Owner & Maybe<&2,T.LedgerView>,~setledger:Owner -> T.MotionLedgerToken -> U32 -> Owner,pair:Owner & Maybe<&2,T.LedgerView>) -> Owner & U32:
  match pair:
    case (owner,Some{old}): motion_ledger_after(~Owner,ledger(setledger(owner,T.MotionLedgerToken{},200),T.MotionLedgerToken{}),old)
    case (owner,_): (owner,0)
def motion_main_after(~Owner:Type,~ledger:Owner -> T.MotionLedgerToken -> Owner & Maybe<&2,T.LedgerView>,~setledger:Owner -> T.MotionLedgerToken -> U32 -> Owner,pair:Owner & T.Access<T.PositionView>,old:T.PositionView) -> Owner & U32:
  match pair old:
    case (owner,T.Found{T.PositionView{T.Four{30,11,12,13},7}}) T.PositionView{T.Four{10,11,12,13},7}: motion_ledger_before(~Owner,~ledger,~setledger,ledger(owner,T.MotionLedgerToken{}))
    case (owner,_) _: (owner,0)
def motion_main_before(~Owner:Type,~get:Owner -> T.PositionToken -> Owner & T.Access<T.PositionView>,~set:Owner -> T.PositionToken -> U32 -> Owner,~ledger:Owner -> T.MotionLedgerToken -> Owner & Maybe<&2,T.LedgerView>,~setledger:Owner -> T.MotionLedgerToken -> U32 -> Owner,pair:Owner & T.Access<T.PositionView>) -> Owner & U32:
  match pair:
    case (owner,T.Found{old}): motion_main_after(~Owner,~ledger,~setledger,get(set(owner,T.PositionToken{},30),T.PositionToken{}),old)
    case (owner,_): (owner,4294967295)

def motion_body(~Owner:Type,~get:Owner -> T.PositionToken -> Owner & T.Access<T.PositionView>,~set:Owner -> T.PositionToken -> U32 -> Owner,~ledger:Owner -> T.MotionLedgerToken -> Owner & Maybe<&2,T.LedgerView>,~setledger:Owner -> T.MotionLedgerToken -> U32 -> Owner,owner:Owner) -> Owner & U32:
  motion_main_before(~Owner,~get,~set,~ledger,~setledger,get(owner,T.PositionToken{}))


def health_ledger_after(~Owner:Type,pair:Owner & Maybe<&2,T.LedgerView>,old:T.LedgerView) -> Owner & U32:
  match pair old:
    case (owner,Some{T.LedgerView{T.Four{200,101,102,103},4}}) T.LedgerView{T.Four{100,101,102,103},4}: (owner,1)
    case (owner,_) _: (owner,0)
def health_ledger_before(~Owner:Type,~ledger:Owner -> T.HealthLedgerToken -> Owner & Maybe<&2,T.LedgerView>,~setledger:Owner -> T.HealthLedgerToken -> U32 -> Owner,pair:Owner & Maybe<&2,T.LedgerView>) -> Owner & U32:
  match pair:
    case (owner,Some{old}): health_ledger_after(~Owner,ledger(setledger(owner,T.HealthLedgerToken{},200),T.HealthLedgerToken{}),old)
    case (owner,_): (owner,0)
def health_main_after(~Owner:Type,~ledger:Owner -> T.HealthLedgerToken -> Owner & Maybe<&2,T.LedgerView>,~setledger:Owner -> T.HealthLedgerToken -> U32 -> Owner,pair:Owner & T.Access<T.VitalsView>,old:T.VitalsView) -> Owner & U32:
  match pair old:
    case (owner,T.Found{T.VitalsView{T.Four{30,11,12,13},9,2}}) T.VitalsView{T.Four{10,11,12,13},9,2}: health_ledger_before(~Owner,~ledger,~setledger,ledger(owner,T.HealthLedgerToken{}))
    case (owner,_) _: (owner,0)
def health_main_before(~Owner:Type,~get:Owner -> T.VitalsToken -> Owner & T.Access<T.VitalsView>,~set:Owner -> T.VitalsToken -> U32 -> Owner,~ledger:Owner -> T.HealthLedgerToken -> Owner & Maybe<&2,T.LedgerView>,~setledger:Owner -> T.HealthLedgerToken -> U32 -> Owner,pair:Owner & T.Access<T.VitalsView>) -> Owner & U32:
  match pair:
    case (owner,T.Found{old}): health_main_after(~Owner,~ledger,~setledger,get(set(owner,T.VitalsToken{},30),T.VitalsToken{}),old)
    case (owner,_): (owner,4294967295)

def health_body(~Owner:Type,~get:Owner -> T.VitalsToken -> Owner & T.Access<T.VitalsView>,~set:Owner -> T.VitalsToken -> U32 -> Owner,~ledger:Owner -> T.HealthLedgerToken -> Owner & Maybe<&2,T.LedgerView>,~setledger:Owner -> T.HealthLedgerToken -> U32 -> Owner,owner:Owner) -> Owner & U32:
  health_main_before(~Owner,~get,~set,~ledger,~setledger,get(owner,T.VitalsToken{}))

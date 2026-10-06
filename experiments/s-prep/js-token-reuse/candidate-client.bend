import Base
import ./types.bend as T

def first(value:T.Four) -> U32:
  match value:
    case T.Four{a,_,_,_}: a

def sum(value:T.Four) -> U32:
  match value:
    case T.Four{a,b,c,d}: U32.add(U32.add(a,b),U32.add(c,d))


def motion_body_ledger(~Owner:Type,~set:Owner -> T.MotionLedgerToken -> U32 -> Owner,readsum:U32,pair:Owner & Maybe<&2,T.LedgerView>) -> Owner & U32:
  match pair:
    case (owner,Some{T.LedgerView{values,_}}): (set(owner,T.MotionLedgerToken{},U32.add(first(values),1)),readsum)
    case (owner,None{}): (owner,4294967295)

def motion_body_read(~Owner:Type,~set:Owner -> T.PositionToken -> U32 -> Owner,~ledger:Owner -> T.MotionLedgerToken -> Owner & Maybe<&2,T.LedgerView>,~setledger:Owner -> T.MotionLedgerToken -> U32 -> Owner,pair:Owner & T.Access<T.PositionView>) -> Owner & U32:
  match pair:
    case (owner,T.Found{T.PositionView{+values,_}}): motion_body_ledger(~Owner,~setledger,sum(values),ledger(set(owner,T.PositionToken{},U32.add(first(values),1)),T.MotionLedgerToken{}))
    case (owner,_): (owner,4294967295)

def motion_body_ledger_tokens(~Owner:Type,~set:Owner -> T.MotionLedgerToken -> U32 -> Owner,token:T.MotionLedgerToken,readsum:U32,pair:Owner & Maybe<&2,T.LedgerView>) -> Owner & U32:
  match pair:
    case (owner,Some{T.LedgerView{values,_}}): (set(owner,token,U32.add(first(values),1)),readsum)
    case (owner,None{}): (owner,4294967295)

def motion_body_read_tokens(~Owner:Type,~set:Owner -> T.PositionToken -> U32 -> Owner,~ledger:Owner -> T.MotionLedgerToken -> Owner & Maybe<&2,T.LedgerView>,~setledger:Owner -> T.MotionLedgerToken -> U32 -> Owner,token:T.PositionToken,pair:Owner & T.Access<T.PositionView>) -> Owner & U32:
  match pair:
    case (owner,T.Found{T.PositionView{+values,_}}):
      +ledgerToken = {T.MotionLedgerToken{} : T.MotionLedgerToken}
      motion_body_ledger_tokens(~Owner,~setledger,ledgerToken,sum(values),ledger(set(owner,token,U32.add(first(values),1)),ledgerToken))
    case (owner,_): (owner,4294967295)

def motion_body(~Owner:Type,~get:Owner -> T.PositionToken -> Owner & T.Access<T.PositionView>,~set:Owner -> T.PositionToken -> U32 -> Owner,~ledger:Owner -> T.MotionLedgerToken -> Owner & Maybe<&2,T.LedgerView>,~setledger:Owner -> T.MotionLedgerToken -> U32 -> Owner,owner:Owner) -> Owner & U32:
  +token = {T.PositionToken{} : T.PositionToken}
  motion_body_read_tokens(~Owner,~set,~ledger,~setledger,token,get(owner,token))

def health_body_ledger(~Owner:Type,~set:Owner -> T.HealthLedgerToken -> U32 -> Owner,readsum:U32,pair:Owner & Maybe<&2,T.LedgerView>) -> Owner & U32:
  match pair:
    case (owner,Some{T.LedgerView{values,_}}): (set(owner,T.HealthLedgerToken{},U32.add(first(values),1)),readsum)
    case (owner,None{}): (owner,4294967295)

def health_body_read(~Owner:Type,~set:Owner -> T.VitalsToken -> U32 -> Owner,~ledger:Owner -> T.HealthLedgerToken -> Owner & Maybe<&2,T.LedgerView>,~setledger:Owner -> T.HealthLedgerToken -> U32 -> Owner,pair:Owner & T.Access<T.VitalsView>) -> Owner & U32:
  match pair:
    case (owner,T.Found{T.VitalsView{+values,_,_}}): health_body_ledger(~Owner,~setledger,sum(values),ledger(set(owner,T.VitalsToken{},U32.add(first(values),1)),T.HealthLedgerToken{}))
    case (owner,_): (owner,4294967295)

def health_body_ledger_tokens(~Owner:Type,~set:Owner -> T.HealthLedgerToken -> U32 -> Owner,token:T.HealthLedgerToken,readsum:U32,pair:Owner & Maybe<&2,T.LedgerView>) -> Owner & U32:
  match pair:
    case (owner,Some{T.LedgerView{values,_}}): (set(owner,token,U32.add(first(values),1)),readsum)
    case (owner,None{}): (owner,4294967295)

def health_body_read_tokens(~Owner:Type,~set:Owner -> T.VitalsToken -> U32 -> Owner,~ledger:Owner -> T.HealthLedgerToken -> Owner & Maybe<&2,T.LedgerView>,~setledger:Owner -> T.HealthLedgerToken -> U32 -> Owner,token:T.VitalsToken,pair:Owner & T.Access<T.VitalsView>) -> Owner & U32:
  match pair:
    case (owner,T.Found{T.VitalsView{+values,_,_}}):
      +ledgerToken = {T.HealthLedgerToken{} : T.HealthLedgerToken}
      health_body_ledger_tokens(~Owner,~setledger,ledgerToken,sum(values),ledger(set(owner,token,U32.add(first(values),1)),ledgerToken))
    case (owner,_): (owner,4294967295)

def health_body(~Owner:Type,~get:Owner -> T.VitalsToken -> Owner & T.Access<T.VitalsView>,~set:Owner -> T.VitalsToken -> U32 -> Owner,~ledger:Owner -> T.HealthLedgerToken -> Owner & Maybe<&2,T.LedgerView>,~setledger:Owner -> T.HealthLedgerToken -> U32 -> Owner,owner:Owner) -> Owner & U32:
  +token = {T.VitalsToken{} : T.VitalsToken}
  health_body_read_tokens(~Owner,~set,~ledger,~setledger,token,get(owner,token))

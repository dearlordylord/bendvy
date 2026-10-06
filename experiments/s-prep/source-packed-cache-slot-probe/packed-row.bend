type PrototypePackedMotionRowOwner is Type:
  PrototypePackedMotionRowOwner{coordinates:Array<U32>,rawframe:U32,a:U32,b:U32,c:U32,d:U32,cachedframe:U32,ledger_raw:T.MotionLedger,ledger_cached:T.LedgerView,handle:S.Handle<T.MotionSchema>,undo:X.PrototypeFlatInverse<T.MotionSchema>,marks:X.PrototypeFlatMark<T.MotionSchema>}
def prototype_packed_row_get(owner:PrototypePackedMotionRowOwner,token:T.PositionToken) -> PrototypePackedMotionRowOwner & T.Access<T.PositionView>:
  match owner token:
    case PrototypePackedMotionRowOwner{coordinates,rawframe,+a,+b,+c,+d,+cachedframe,ledger_raw,ledger_cached,handle,undo,marks} T.PositionToken{}: (PrototypePackedMotionRowOwner{coordinates,rawframe,a,b,c,d,cachedframe,ledger_raw,ledger_cached,handle,undo,marks},T.Found{T.PositionView{T.Four{a,b,c,d},cachedframe}})
def prototype_packed_row_ledger(owner:PrototypePackedMotionRowOwner,token:T.MotionLedgerToken) -> PrototypePackedMotionRowOwner & Maybe<&2,T.LedgerView>:
  match owner token:
    case PrototypePackedMotionRowOwner{coordinates,rawframe,a,b,c,d,cachedframe,ledger_raw,+ledger_cached,handle,undo,marks} T.MotionLedgerToken{}: (PrototypePackedMotionRowOwner{coordinates,rawframe,a,b,c,d,cachedframe,ledger_raw,ledger_cached,handle,undo,marks},Some{ledger_cached})
def prototype_packed_row_set_done(rawframe:U32,b:U32,c:U32,d:U32,cachedframe:U32,ledger_raw:T.MotionLedger,ledger_cached:T.LedgerView,+handle:S.Handle<T.MotionSchema>,undo:X.PrototypeFlatInverse<T.MotionSchema>,marks:X.PrototypeFlatMark<T.MotionSchema>,+value:U32,result:Array<U32> & U32) -> PrototypePackedMotionRowOwner:
  match handle result:
    case S.Handle{+space,+id} Tuple{coordinates,old}: PrototypePackedMotionRowOwner{Array.set(U32,coordinates,0,value),rawframe,value,b,c,d,cachedframe,ledger_raw,ledger_cached,S.Handle{space,id},X.PrototypeFlatMain{space,id,old,undo},X.PrototypeFlatMark{space,id,marks}}
def prototype_packed_row_set(owner:PrototypePackedMotionRowOwner,token:T.PositionToken,value:U32) -> PrototypePackedMotionRowOwner:
  match owner token:
    case PrototypePackedMotionRowOwner{coordinates,rawframe,_,b,c,d,cachedframe,ledger_raw,ledger_cached,handle,undo,marks} T.PositionToken{}: prototype_packed_row_set_done(rawframe,b,c,d,cachedframe,ledger_raw,ledger_cached,handle,undo,marks,value,Array.get(U32,coordinates,0))
def prototype_packed_row_setledger_done(coordinates:Array<U32>,rawframe:U32,a:U32,b:U32,c:U32,d:U32,cachedframe:U32,handle:S.Handle<T.MotionSchema>,undo:X.PrototypeFlatInverse<T.MotionSchema>,marks:X.PrototypeFlatMark<T.MotionSchema>,cached:T.LedgerView,value:U32,result:T.MotionLedger & U32) -> PrototypePackedMotionRowOwner:
  match result:
    case (raw,old): PrototypePackedMotionRowOwner{coordinates,rawframe,a,b,c,d,cachedframe,raw,P.motion_ledger_patch(cached,value),handle,X.PrototypeFlatLedger{old,undo},marks}
def prototype_packed_row_setledger(owner:PrototypePackedMotionRowOwner,token:T.MotionLedgerToken,value:U32) -> PrototypePackedMotionRowOwner:
  match owner token value:
    case PrototypePackedMotionRowOwner{coordinates,rawframe,a,b,c,d,cachedframe,ledger_raw,cached,handle,undo,marks} T.MotionLedgerToken{} +value: prototype_packed_row_setledger_done(coordinates,rawframe,a,b,c,d,cachedframe,handle,undo,marks,cached,value,P.prototype_motion_ledger_raw_swap(ledger_raw,value))
def prototype_packed_row_invoke(~client:@-Owner:Type -> @-get:(Owner -> T.PositionToken -> Owner & T.Access<T.PositionView>) -> @-set:(Owner -> T.PositionToken -> U32 -> Owner) -> @-ledger:(Owner -> T.MotionLedgerToken -> Owner & Maybe<&2,T.LedgerView>) -> @-setledger:(Owner -> T.MotionLedgerToken -> U32 -> Owner) -> Owner -> Owner & U32,owner:PrototypePackedMotionRowOwner) -> PrototypePackedMotionRowOwner & U32:
  client(PrototypePackedMotionRowOwner,prototype_packed_row_get,prototype_packed_row_set,prototype_packed_row_ledger,prototype_packed_row_setledger,owner)

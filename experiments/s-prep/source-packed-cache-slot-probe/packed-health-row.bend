type PrototypePackedHealthRowOwner is Type:
  PrototypePackedHealthRowOwner{levels:Array<U32>,rawreserve:U32,rawclass:U32,a:U32,b:U32,c:U32,d:U32,cachedreserve:U32,cachedclass:U32,totals:Array<U32>,epoch:U32,ledger_cached:T.LedgerView,handle:S.Handle<T.HealthSchema>,undo:X.PrototypeFlatInverse<T.HealthSchema>,marks:X.PrototypeFlatMark<T.HealthSchema>}
def prototype_packed_prototype_journalledger_health_get(owner:PrototypePackedHealthRowOwner,token:T.VitalsToken) -> PrototypePackedHealthRowOwner & T.Access<T.VitalsView>:
  match owner token:
    case PrototypePackedHealthRowOwner{levels,rawreserve,rawclass,+a,+b,+c,+d,+cachedreserve,+cachedclass,totals,epoch,ledger_cached,handle,undo,marks} T.VitalsToken{}: (PrototypePackedHealthRowOwner{levels,rawreserve,rawclass,a,b,c,d,cachedreserve,cachedclass,totals,epoch,ledger_cached,handle,undo,marks},T.Found{T.VitalsView{T.Four{a,b,c,d},cachedreserve,cachedclass}})
def prototype_packed_prototype_journalledger_health_ledger(owner:PrototypePackedHealthRowOwner,token:T.HealthLedgerToken) -> PrototypePackedHealthRowOwner & Maybe<&2,T.LedgerView>:
  match owner token:
    case PrototypePackedHealthRowOwner{levels,rawreserve,rawclass,a,b,c,d,cachedreserve,cachedclass,totals,epoch,+ledger_cached,handle,undo,marks} T.HealthLedgerToken{}: (PrototypePackedHealthRowOwner{levels,rawreserve,rawclass,a,b,c,d,cachedreserve,cachedclass,totals,epoch,ledger_cached,handle,undo,marks},Some{ledger_cached})
def prototype_packed_prototype_journalledger_health_set_fused_done(totals:Array<U32>,epoch:U32,ledger_cached:T.LedgerView,+handle:S.Handle<T.HealthSchema>,undo:X.PrototypeFlatInverse<T.HealthSchema>,marks:X.PrototypeFlatMark<T.HealthSchema>,rawreserve:U32,rawclass:U32,b:U32,c:U32,d:U32,cachedreserve:U32,cachedclass:U32,+value:U32,result:Array<U32> & U32) -> PrototypePackedHealthRowOwner:
  match handle result:
    case S.Handle{+space,+id} Tuple{levels,old}: PrototypePackedHealthRowOwner{Array.set(U32,levels,0,value),rawreserve,rawclass,value,b,c,d,cachedreserve,cachedclass,totals,epoch,ledger_cached,S.Handle{space,id},X.PrototypeFlatMain{space,id,old,undo},X.PrototypeFlatMark{space,id,marks}}
def prototype_packed_prototype_journalledger_health_set(owner:PrototypePackedHealthRowOwner,token:T.VitalsToken,value:U32) -> PrototypePackedHealthRowOwner:
  match owner token:
    case PrototypePackedHealthRowOwner{levels,rawreserve,rawclass,_,b,c,d,cachedreserve,cachedclass,totals,epoch,ledger_cached,+handle,undo,marks} T.VitalsToken{}:
      +value = value
      prototype_packed_prototype_journalledger_health_set_fused_done(totals,epoch,ledger_cached,handle,undo,marks,rawreserve,rawclass,b,c,d,cachedreserve,cachedclass,value,Array.get(U32,levels,0))
def prototype_packed_prototype_journalledger_health_setledger_done(levels:Array<U32>,rawreserve:U32,rawclass:U32,a:U32,b:U32,c:U32,d:U32,cachedreserve:U32,cachedclass:U32,epoch:U32,handle:S.Handle<T.HealthSchema>,undo:X.PrototypeFlatInverse<T.HealthSchema>,marks:X.PrototypeFlatMark<T.HealthSchema>,cached:T.LedgerView,+value:U32,result:Array<U32> & U32) -> PrototypePackedHealthRowOwner:
  match result:
    case (totals,old): PrototypePackedHealthRowOwner{levels,rawreserve,rawclass,a,b,c,d,cachedreserve,cachedclass,Array.set(U32,totals,0,value),epoch,P.health_ledger_patch(cached,value),handle,X.PrototypeFlatLedger{old,undo},marks}
def prototype_packed_prototype_journalledger_health_setledger(owner:PrototypePackedHealthRowOwner,token:T.HealthLedgerToken,value:U32) -> PrototypePackedHealthRowOwner:
  match owner token:
    case PrototypePackedHealthRowOwner{levels,rawreserve,rawclass,a,b,c,d,cachedreserve,cachedclass,totals,epoch,cached,handle,undo,marks} T.HealthLedgerToken{}:
      +value = value
      prototype_packed_prototype_journalledger_health_setledger_done(levels,rawreserve,rawclass,a,b,c,d,cachedreserve,cachedclass,epoch,handle,undo,marks,cached,value,Array.get(U32,totals,0))
def prototype_packed_prototype_journalledger_health_invoke(~client:@-Owner:Type -> @-get:(Owner -> T.VitalsToken -> Owner & T.Access<T.VitalsView>) -> @-set:(Owner -> T.VitalsToken -> U32 -> Owner) -> @-ledger:(Owner -> T.HealthLedgerToken -> Owner & Maybe<&2,T.LedgerView>) -> @-setledger:(Owner -> T.HealthLedgerToken -> U32 -> Owner) -> Owner -> Owner & U32,owner:PrototypePackedHealthRowOwner) -> PrototypePackedHealthRowOwner & U32:
  client(PrototypePackedHealthRowOwner,prototype_packed_prototype_journalledger_health_get,prototype_packed_prototype_journalledger_health_set,prototype_packed_prototype_journalledger_health_ledger,prototype_packed_prototype_journalledger_health_setledger,owner)


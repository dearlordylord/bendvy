# Private concrete-schema journal. All public generic definitions remain intact.
type PrototypeFlatInverse<-Schema: Data> is Data:
  PrototypeFlatMain{namespace: U32, id: U32, old: U32, tail: PrototypeFlatInverse<Schema>}
  PrototypeFlatLedger{old: U32, tail: PrototypeFlatInverse<Schema>}
  PrototypeFlatEnd{}
type PrototypeFlatMark<-Schema: Data> is Data:
  PrototypeFlatMark{namespace: U32, id: U32, tail: PrototypeFlatMark<Schema>}
  PrototypeFlatMarksEnd{}
type PrototypeFlatTx<-Schema: Data,-W: Type,-C: Type> is Type:
  PrototypeFlatTx{world: W, selected: S.Handle<Schema>, undo: PrototypeFlatInverse<Schema>, commands: List<C>, pings: List<&2,U32>, marks: PrototypeFlatMark<Schema>}
type PrototypeFlatFinished<-Schema: Data,-W: Type,-C: Type> is Type:
  PrototypeFlatCommitted{world: W, commands: List<C>, pings: List<&2,U32>, marks: PrototypeFlatMark<Schema>}
  PrototypeFlatReverted{world: W}

def prototype_flat_inverse_pack(~Schema: Data,values: List<&2,Inverse<S.Handle<Schema>>>) -> PrototypeFlatInverse<Schema>:
  match values:
    case Nil{}: PrototypeFlatEnd{}
    case Con{MainInverse{S.Handle{space,id},old},tail}: PrototypeFlatMain{space,id,old,prototype_flat_inverse_pack(~Schema,tail)}
    case Con{LedgerInverse{old},tail}: PrototypeFlatLedger{old,prototype_flat_inverse_pack(~Schema,tail)}
def prototype_flat_inverse_unpack(~Schema: Data,values: PrototypeFlatInverse<Schema>) -> List<&2,Inverse<S.Handle<Schema>>>:
  match values:
    case PrototypeFlatEnd{}: []
    case PrototypeFlatMain{space,id,old,tail}: MainInverse{S.Handle{space,id},old} <> prototype_flat_inverse_unpack(~Schema,tail)
    case PrototypeFlatLedger{old,tail}: LedgerInverse{old} <> prototype_flat_inverse_unpack(~Schema,tail)
def prototype_flat_mark_pack(~Schema: Data,values: List<&2,S.Handle<Schema>>) -> PrototypeFlatMark<Schema>:
  match values:
    case Nil{}: PrototypeFlatMarksEnd{}
    case Con{S.Handle{space,id},tail}: PrototypeFlatMark{space,id,prototype_flat_mark_pack(~Schema,tail)}
def prototype_flat_mark_unpack(~Schema: Data,values: PrototypeFlatMark<Schema>) -> List<&2,S.Handle<Schema>>:
  match values:
    case PrototypeFlatMarksEnd{}: []
    case PrototypeFlatMark{space,id,tail}: S.Handle{space,id} <> prototype_flat_mark_unpack(~Schema,tail)
def prototype_flat_pack(~Schema: Data,~W: Type,~C: Type,owner: Tx<W,S.Handle<Schema>,C>) -> PrototypeFlatTx<Schema,W,C>:
  match owner:
    case Tx{world,selected,undo,commands,pings,marks}: PrototypeFlatTx{world,selected,prototype_flat_inverse_pack(~Schema,undo),commands,pings,prototype_flat_mark_pack(~Schema,marks)}
def prototype_flat_unpack(~Schema: Data,~W: Type,~C: Type,owner: PrototypeFlatTx<Schema,W,C>) -> Tx<W,S.Handle<Schema>,C>:
  match owner:
    case PrototypeFlatTx{world,selected,undo,commands,pings,marks}: Tx{world,selected,prototype_flat_inverse_unpack(~Schema,undo),commands,pings,prototype_flat_mark_unpack(~Schema,marks)}
def prototype_flat_finish_success(~Schema: Data,~W: Type,~C: Type,owner: PrototypeFlatTx<Schema,W,C>) -> PrototypeFlatFinished<Schema,W,C>:
  match owner:
    case PrototypeFlatTx{world,_,_,commands,pings,marks}: PrototypeFlatCommitted{world,List.reverse(&1,C,commands),List.reverse(&2,U32,pings),marks}
def prototype_flat_unwind(~Schema: Data,~W: Type,~restore_main: W -> S.Handle<Schema> -> U32 -> W,~restore_ledger: W -> U32 -> W,undo: PrototypeFlatInverse<Schema>,world: W) -> W:
  match undo:
    case PrototypeFlatEnd{}: world
    case PrototypeFlatMain{space,id,old,tail}: prototype_flat_unwind(~Schema,~W,~restore_main,~restore_ledger,tail,restore_main(world,S.Handle{space,id},old))
    case PrototypeFlatLedger{old,tail}: prototype_flat_unwind(~Schema,~W,~restore_main,~restore_ledger,tail,restore_ledger(world,old))
def prototype_flat_finish_failure(~Schema: Data,~W: Type,~C: Type,~restore_main: W -> S.Handle<Schema> -> U32 -> W,~restore_ledger: W -> U32 -> W,owner: PrototypeFlatTx<Schema,W,C>) -> PrototypeFlatFinished<Schema,W,C>:
  match owner:
    case PrototypeFlatTx{world,_,undo,_,_,_}: PrototypeFlatReverted{prototype_flat_unwind(~Schema,~W,~restore_main,~restore_ledger,undo,world)}

# Identical namespace/bounds/live guards; marks remain reverse chronological.
def prototype_flat_storage_mark_loop(~Schema: Data,~M: Type,~A: Type,~F: Data,~L: Type,~Mode: Data,marks: PrototypeFlatMark<Schema>,+namespace: U32,next: U32,main: Array<Maybe<M>>,aux: Array<Maybe<A>>,flags: Array<Maybe<&2,F>>,added: Array<U32>,transport: Array<Bool> & Array<U32>,+capacity: U32,depth: Nat,+high: U32,pending: List<S.Command<M,A,F>>,ledger: Maybe<L>,mode: Mode,+tick: U32) -> S.World<Schema,M,A,F,L,Mode>:
  match marks transport:
    case PrototypeFlatMarksEnd{} Tuple{live,changed}: S.World{namespace,next,S.Rows{main,aux,S.MetadataColumns{live,flags,added,changed},capacity,depth,high},pending,ledger,mode}
    case PrototypeFlatMark{foreign,+id,rest} Tuple{live,changed}:
      prototype_flat_storage_mark_loop(~Schema,~M,~A,~F,~L,~Mode,rest,namespace,next,main,aux,flags,added,prototype_storage_mark_guard(Bool.and(U32.is_eq(namespace,foreign),Bool.and((0 < id : U32),Bool.and((id <= capacity : U32),(id <= high : U32)))),live,changed,id,tick),capacity,depth,high,pending,ledger,mode,tick)
def prototype_flat_storage_mark_all(~Schema: Data,~M: Type,~A: Type,~F: Data,~L: Type,~Mode: Data,marks: PrototypeFlatMark<Schema>,world: S.World<Schema,M,A,F,L,Mode>,+tick: U32) -> S.World<Schema,M,A,F,L,Mode>:
  match marks world:
    case PrototypeFlatMarksEnd{} world: world
    case marks S.World{namespace,next,S.Rows{main,aux,S.MetadataColumns{live,flags,added,changed},capacity,depth,high},pending,ledger,mode}: prototype_flat_storage_mark_loop(~Schema,~M,~A,~F,~L,~Mode,marks,namespace,next,main,aux,flags,added,(live,changed),capacity,depth,high,pending,ledger,mode,tick)
def prototype_flat_storage_commit(~Schema: Data,~M: Type,~A: Type,~F: Data,~L: Type,~Mode: Data,result: PrototypeFlatFinished<Schema,S.World<Schema,M,A,F,L,Mode>,S.Command<M,A,F>>,tick: U32) -> S.World<Schema,M,A,F,L,Mode> & List<&2,U32>:
  match result:
    case PrototypeFlatCommitted{world,commands,pings,marks}: (S.publish(Schema,M,A,F,L,Mode,prototype_flat_storage_mark_all(~Schema,~M,~A,~F,~L,~Mode,marks,world,tick),List.reverse(&1,S.Command<M,A,F>,commands)),pings)
    case PrototypeFlatReverted{world}: (world,[])

def prototype_flat_pair_unpack(~Schema: Data,~W: Type,~C: Type,result: PrototypeFlatTx<Schema,W,C> & U32) -> Tx<W,S.Handle<Schema>,C> & U32:
  match result:
    case (owner,value): (prototype_flat_unpack(~Schema,~W,~C,owner),value)

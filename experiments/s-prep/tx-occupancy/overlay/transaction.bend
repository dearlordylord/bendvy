import Base
import ./types.bend as T
import ./storage.bend as S

# Trusted adapter-private representation; never passed concretely to clients.
type Inverse<-H: Data> is Data:
  MainInverse{handle: H, old: U32}
  LedgerInverse{old: U32}
type Tx<-W: Type,-H: Data,-C: Type> is Type:
  Tx{world: W, selected: H, undo: List<&2,Inverse<H>>, commands: List<C>, pings: List<&2,U32>, marks: List<&2,H>, meter: String}
type Finished<-W: Type,-C: Type,-H: Data> is Type:
  Committed{world: W, commands: List<C>, pings: List<&2,U32>, marks: List<&2,H>, meter: String}
  Reverted{world: W, meter: String}


# Diagnostic traversal returns every affine payload and preserves list order.
def diag_cons(-C: Type,head: C,pair: List<C> & U32) -> List<C> & U32:
  match pair:
    case (tail,count): (head <> tail,U32.add(count,1))
def diag_length(-C: Type,values: List<C>) -> List<C> & U32:
  match values:
    case Nil{}: ([],0)
    case Con{head,tail}: diag_cons(C,head,diag_length(C,tail))
def diag_finish(-W: Type,-H: Data,-C: Type,world: W,selected: H,+undo: List<&2,Inverse<H>>,+pings: List<&2,U32>,+marks: List<&2,H>,+meter: String,phase: String,pair: List<C> & U32) -> Tx<W,H,C>:
  match pair:
    case (commands,count): Tx{world,selected,undo,commands,pings,marks,meter ++ phase ++ ":" ++ U32.show(count) ++ ":" ++ Nat.show(List.length(&2,U32,pings)) ++ ":" ++ Nat.show(List.length(&2,Inverse<H>,undo)) ++ ":" ++ Nat.show(List.length(&2,H,marks)) ++ ";"}
def diag_sample(-W: Type,-H: Data,-C: Type,phase: String,t: Tx<W,H,C>) -> Tx<W,H,C>:
  match t:
    case Tx{world,selected,undo,commands,pings,marks,meter}: diag_finish(W,H,C,world,selected,undo,pings,marks,meter,phase,diag_length(C,commands))

def tx_begin(-W: Type,-H: Data,-C: Type, world: W, selected: H) -> Tx<W,H,C>:
  diag_sample(W,H,C,"tx_begin",Tx{world,selected,[],[],[],[],""})
def record_main(-W: Type,-H: Data,-C: Type,+handle: H,undo: List<&2,Inverse<H>>,commands: List<C>,pings: List<&2,U32>,marks: List<&2,H>,meter: String,result: W & T.Access<U32>) -> Tx<W,H,C>:
  match result:
    case (world,T.Found{old}): diag_sample(W,H,C,"record_main",Tx{world,handle,MainInverse{handle,old} <> undo,commands,pings,handle <> marks,meter})
    case (world,_): diag_sample(W,H,C,"record_main",Tx{world,handle,undo,commands,pings,marks,meter})
def tx_set_main0(-W: Type,-H: Data,-C: Type,write: W -> H -> U32 -> W & T.Access<U32>, t: Tx<W,H,C>,value: U32) -> Tx<W,H,C>:
  match t:
    case Tx{world,+selected,undo,commands,pings,marks,meter}: record_main(W,H,C,selected,undo,commands,pings,marks,meter,write(world,selected,value))
def record_ledger(-W: Type,-H: Data,-C: Type,selected: H,undo: List<&2,Inverse<H>>,commands: List<C>,pings: List<&2,U32>,marks: List<&2,H>,meter: String,result: W & Maybe<&2,U32>) -> Tx<W,H,C>:
  match result:
    case (world,Some{old}): diag_sample(W,H,C,"record_ledger",Tx{world,selected,LedgerInverse{old} <> undo,commands,pings,marks,meter})
    case (world,None{}): diag_sample(W,H,C,"record_ledger",Tx{world,selected,undo,commands,pings,marks,meter})
def tx_set_ledger0(-W: Type,-H: Data,-C: Type,write: W -> U32 -> W & Maybe<&2,U32>,t: Tx<W,H,C>,value: U32) -> Tx<W,H,C>:
  match t:
    case Tx{world,selected,undo,commands,pings,marks,meter}: record_ledger(W,H,C,selected,undo,commands,pings,marks,meter,write(world,value))
def tx_stage_command(-W: Type,-H: Data,-C: Type,t: Tx<W,H,C>,command: C) -> Tx<W,H,C>:
  match t:
    case Tx{world,selected,undo,commands,pings,marks,meter}: diag_sample(W,H,C,"tx_stage_command",Tx{world,selected,undo,command <> commands,pings,marks,meter})
def tx_stage_ping(-W: Type,-H: Data,-C: Type,t: Tx<W,H,C>,code: U32) -> Tx<W,H,C>:
  match t:
    case Tx{world,selected,undo,commands,pings,marks,meter}: diag_sample(W,H,C,"tx_stage_ping",Tx{world,selected,undo,commands,code <> pings,marks,meter})
def tx_finish_success(-W: Type,-H: Data,-C: Type,t: Tx<W,H,C>) -> Finished<W,C,H>:
  match t:
    case Tx{world,_,_,commands,pings,marks,meter}: Committed{world,List.reverse(&1,C,commands),List.reverse(&2,U32,pings),marks,meter ++ "finish-success;"}
def unwind(~W: Type,~H: Data,~restore_main: W -> H -> U32 -> W,
  ~restore_ledger: W -> U32 -> W,undo: List<&2,Inverse<H>>,world: W,+meter: String) -> W & String:
  match undo:
    case Nil{}: (world,meter ++ "unwind:0;")
    case Con{MainInverse{handle,old},+rest}: unwind(W,H,restore_main,restore_ledger,rest,restore_main(world,handle,old),meter ++ "unwind:" ++ Nat.show(List.length(&2,Inverse<H>,rest)) ++ ";")
    case Con{LedgerInverse{old},+rest}: unwind(W,H,restore_main,restore_ledger,rest,restore_ledger(world,old),meter ++ "unwind:" ++ Nat.show(List.length(&2,Inverse<H>,rest)) ++ ";")
def diag_reverted(-W: Type,-C: Type,-H: Data,pair: W & String) -> Finished<W,C,H>:
  match pair:
    case (world,meter): Reverted{world,meter}
def tx_finish_failure(~W: Type,~H: Data,~C: Type,~restore_main: W -> H -> U32 -> W,
  ~restore_ledger: W -> U32 -> W,t: Tx<W,H,C>) -> Finished<W,C,H>:
  match t:
    case Tx{world,_,undo,_,_,_,meter}: diag_reverted(W,C,H,unwind(W,H,restore_main,restore_ledger,undo,world,meter ++ "finish-failure;"))


def read_main_finish(-W: Type,-H: Data,-C: Type,-O: Data,selected: H,undo: List<&2,Inverse<H>>,commands: List<C>,pings: List<&2,U32>,marks: List<&2,H>,meter: String,result: W & T.Access<O>) -> Tx<W,H,C> & T.Access<O>:
  match result:
    case (world,view): (diag_sample(W,H,C,"read_main_finish",Tx{world,selected,undo,commands,pings,marks,meter}),view)
def tx_read_main(-W: Type,-H: Data,-C: Type,-O: Data,read: W -> H -> W & T.Access<O>,t: Tx<W,H,C>) -> Tx<W,H,C> & T.Access<O>:
  match t:
    case Tx{world,+selected,undo,commands,pings,marks,meter}: read_main_finish(W,H,C,O,selected,undo,commands,pings,marks,meter,read(world,selected))
def read_ledger_finish(-W: Type,-H: Data,-C: Type,-O: Data,selected: H,undo: List<&2,Inverse<H>>,commands: List<C>,pings: List<&2,U32>,marks: List<&2,H>,meter: String,result: W & Maybe<&2,O>) -> Tx<W,H,C> & Maybe<&2,O>:
  match result:
    case (world,view): (diag_sample(W,H,C,"read_ledger_finish",Tx{world,selected,undo,commands,pings,marks,meter}),view)

def tx_read_ledger(-W: Type,-H: Data,-C: Type,-O: Data,read: W -> W & Maybe<&2,O>,t: Tx<W,H,C>) -> Tx<W,H,C> & Maybe<&2,O>:
  match t:
    case Tx{world,selected,undo,commands,pings,marks,meter}: read_ledger_finish(W,H,C,O,selected,undo,commands,pings,marks,meter,read(world))

# Concrete store joins. Actual swap operations retain the full Type owner.
def storage_set_main0(~Schema: Data,~M: Type,~A: Type,~F: Data,~L: Type,~Mode: Data,
  ~swap: M -> U32 -> M & U32,world: S.World<Schema,M,A,F,L,Mode>,handle: S.Handle<Schema>,value: U32) -> S.World<Schema,M,A,F,L,Mode> & T.Access<U32>:
  S.with_main(Schema,M,A,F,L,Mode,U32,world,handle,(main => swap(main,value)))
def storage_set_ledger0(~Schema: Data,~M: Type,~A: Type,~F: Data,~L: Type,~Mode: Data,
  ~swap: L -> U32 -> L & U32,world: S.World<Schema,M,A,F,L,Mode>,value: U32) -> S.World<Schema,M,A,F,L,Mode> & Maybe<&2,U32>:
  S.with_ledger(Schema,M,A,F,L,Mode,U32,world,(ledger => swap(ledger,value)))
def discard_access(-W: Type,result: W & T.Access<U32>) -> W:
  match result:
    case (world,_): world
def discard_optional(-W: Type,result: W & Maybe<&2,U32>) -> W:
  match result:
    case (world,_): world
def storage_restore_main0(~Schema: Data,~M: Type,~A: Type,~F: Data,~L: Type,~Mode: Data,
  ~swap: M -> U32 -> M & U32,world: S.World<Schema,M,A,F,L,Mode>,handle: S.Handle<Schema>,value: U32) -> S.World<Schema,M,A,F,L,Mode>:
  discard_access(S.World<Schema,M,A,F,L,Mode>,storage_set_main0(Schema,M,A,F,L,Mode,swap,world,handle,value))
def storage_restore_ledger0(~Schema: Data,~M: Type,~A: Type,~F: Data,~L: Type,~Mode: Data,
  ~swap: L -> U32 -> L & U32,world: S.World<Schema,M,A,F,L,Mode>,value: U32) -> S.World<Schema,M,A,F,L,Mode>:
  discard_optional(S.World<Schema,M,A,F,L,Mode>,storage_set_ledger0(Schema,M,A,F,L,Mode,swap,world,value))

def storage_mark_all(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,
  marks: List<&2,S.Handle<Schema>>,world: S.World<Schema,M,A,F,L,Mode>,+tick: U32,+meter: String) -> S.World<Schema,M,A,F,L,Mode> & String:
  match marks:
    case Nil{}: (world,meter ++ "mark-drain:0;")
    case Con{handle,+rest}: storage_mark_all(Schema,M,A,F,L,Mode,rest,S.mark_main(Schema,M,A,F,L,Mode,world,handle,tick),tick,meter ++ "mark-drain:" ++ Nat.show(List.length(&2,S.Handle<Schema>,rest)) ++ ";")
def diag_publish(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,commands: List<S.Command<M,A,F>>,pings: List<&2,U32>,pair: S.World<Schema,M,A,F,L,Mode> & String) -> S.World<Schema,M,A,F,L,Mode> & (List<&2,U32> & String):
  match pair:
    case (world,meter): (S.publish(Schema,M,A,F,L,Mode,world,List.reverse(&1,S.Command<M,A,F>,commands)),(pings,meter ++ "commit;"))
def diag_storage_commit(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,
  result: Finished<S.World<Schema,M,A,F,L,Mode>,S.Command<M,A,F>,S.Handle<Schema>>,tick: U32) -> S.World<Schema,M,A,F,L,Mode> & (List<&2,U32> & String):
  match result:
    case Committed{world,commands,pings,marks,meter}: diag_publish(Schema,M,A,F,L,Mode,commands,pings,storage_mark_all(Schema,M,A,F,L,Mode,marks,world,tick,meter))
    case Reverted{world,meter}: (world,([],meter ++ "rollback;"))

def reserve_finish(-W: Type,-H: Data,-C: Type,selected: H,undo: List<&2,Inverse<H>>,commands: List<C>,pings: List<&2,U32>,marks: List<&2,H>,meter: String,result: W & Maybe<&2,H>) -> Tx<W,H,C> & Maybe<&2,H>:
  match result:
    case (world,handle): (diag_sample(W,H,C,"reserve_finish",Tx{world,selected,undo,commands,pings,marks,meter}),handle)
def tx_reserve(-W: Type,-H: Data,-C: Type,reserve: W -> W & Maybe<&2,H>,t: Tx<W,H,C>) -> Tx<W,H,C> & Maybe<&2,H>:
  match t:
    case Tx{world,selected,undo,commands,pings,marks,meter}: reserve_finish(W,H,C,selected,undo,commands,pings,marks,meter,reserve(world))


def diag_strip(-W: Type,result: W & (List<&2,U32> & String)) -> W & List<&2,U32>:
  match result:
    case (world,(pings,_)): (world,pings)
def storage_commit(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,result: Finished<S.World<Schema,M,A,F,L,Mode>,S.Command<M,A,F>,S.Handle<Schema>>,tick: U32) -> S.World<Schema,M,A,F,L,Mode> & List<&2,U32>:
  diag_strip(S.World<Schema,M,A,F,L,Mode>,diag_storage_commit(Schema,M,A,F,L,Mode,result,tick))

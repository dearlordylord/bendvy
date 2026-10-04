import Base
import ./types.bend as T

# Trusted adapter-private representation; never passed concretely to clients.
type Inverse<-H: Data> is Data:
  MainInverse{handle: H, old: U32}
  LedgerInverse{old: U32}
type Tx<-W: Type,-H: Data,-C: Type> is Type:
  Tx{world: W, selected: H, undo: List<&2,Inverse<H>>, commands: List<C>, pings: List<&2,U32>, marks: List<&2,H>}
type Finished<-W: Type,-C: Type,-H: Data> is Type:
  Committed{world: W, commands: List<C>, pings: List<&2,U32>, marks: List<&2,H>}
  Reverted{world: W}

def tx_begin(-W: Type,-H: Data,-C: Type, world: W, selected: H) -> Tx<W,H,C>:
  Tx{world,selected,[],[],[],[]}
def record_main(-W: Type,-H: Data,-C: Type,+handle: H,undo: List<&2,Inverse<H>>,commands: List<C>,pings: List<&2,U32>,marks: List<&2,H>,result: W & T.Access<U32>) -> Tx<W,H,C>:
  match result:
    case (world,T.Found{old}): Tx{world,handle,MainInverse{handle,old} <> undo,commands,pings,handle <> marks}
    case (world,_): Tx{world,handle,undo,commands,pings,marks}
def tx_set_main0(-W: Type,-H: Data,-C: Type,write: W -> H -> U32 -> W & T.Access<U32>, t: Tx<W,H,C>,value: U32) -> Tx<W,H,C>:
  match t:
    case Tx{world,+selected,undo,commands,pings,marks}: record_main(W,H,C,selected,undo,commands,pings,marks,write(world,selected,value))
def record_ledger(-W: Type,-H: Data,-C: Type,selected: H,undo: List<&2,Inverse<H>>,commands: List<C>,pings: List<&2,U32>,marks: List<&2,H>,result: W & Maybe<&2,U32>) -> Tx<W,H,C>:
  match result:
    case (world,Some{old}): Tx{world,selected,LedgerInverse{old} <> undo,commands,pings,marks}
    case (world,None{}): Tx{world,selected,undo,commands,pings,marks}
def tx_set_ledger0(-W: Type,-H: Data,-C: Type,write: W -> U32 -> W & Maybe<&2,U32>,t: Tx<W,H,C>,value: U32) -> Tx<W,H,C>:
  match t:
    case Tx{world,selected,undo,commands,pings,marks}: record_ledger(W,H,C,selected,undo,commands,pings,marks,write(world,value))
def tx_stage_command(-W: Type,-H: Data,-C: Type,t: Tx<W,H,C>,command: C) -> Tx<W,H,C>:
  match t:
    case Tx{world,selected,undo,commands,pings,marks}: Tx{world,selected,undo,List.append(&1,C,commands,[command]),pings,marks}
def tx_stage_ping(-W: Type,-H: Data,-C: Type,t: Tx<W,H,C>,code: U32) -> Tx<W,H,C>:
  match t:
    case Tx{world,selected,undo,commands,pings,marks}: Tx{world,selected,undo,commands,List.append(&2,U32,pings,[code]),marks}
def tx_finish_success(-W: Type,-H: Data,-C: Type,t: Tx<W,H,C>) -> Finished<W,C,H>:
  match t:
    case Tx{world,_,_,commands,pings,marks}: Committed{world,commands,pings,marks}
def unwind(~W: Type,~H: Data,~restore_main: W -> H -> U32 -> W,
  ~restore_ledger: W -> U32 -> W,undo: List<&2,Inverse<H>>,world: W) -> W:
  match undo:
    case Nil{}: world
    case Con{MainInverse{handle,old},rest}: unwind(W,H,restore_main,restore_ledger,rest,restore_main(world,handle,old))
    case Con{LedgerInverse{old},rest}: unwind(W,H,restore_main,restore_ledger,rest,restore_ledger(world,old))
def tx_finish_failure(~W: Type,~H: Data,~C: Type,~restore_main: W -> H -> U32 -> W,
  ~restore_ledger: W -> U32 -> W,t: Tx<W,H,C>) -> Finished<W,C,H>:
  match t:
    case Tx{world,_,undo,_,_,_}: Reverted{unwind(W,H,restore_main,restore_ledger,undo,world)}


def read_main_finish(-W: Type,-H: Data,-C: Type,-O: Data,selected: H,undo: List<&2,Inverse<H>>,commands: List<C>,pings: List<&2,U32>,marks: List<&2,H>,result: W & T.Access<O>) -> Tx<W,H,C> & T.Access<O>:
  match result:
    case (world,view): (Tx{world,selected,undo,commands,pings,marks},view)
def tx_read_main(-W: Type,-H: Data,-C: Type,-O: Data,read: W -> H -> W & T.Access<O>,t: Tx<W,H,C>) -> Tx<W,H,C> & T.Access<O>:
  match t:
    case Tx{world,+selected,undo,commands,pings,marks}: read_main_finish(W,H,C,O,selected,undo,commands,pings,marks,read(world,selected))
def read_ledger_finish(-W: Type,-H: Data,-C: Type,-O: Data,selected: H,undo: List<&2,Inverse<H>>,commands: List<C>,pings: List<&2,U32>,marks: List<&2,H>,result: W & Maybe<&2,O>) -> Tx<W,H,C> & Maybe<&2,O>:
  match result:
    case (world,view): (Tx{world,selected,undo,commands,pings,marks},view)

def tx_read_ledger(-W: Type,-H: Data,-C: Type,-O: Data,read: W -> W & Maybe<&2,O>,t: Tx<W,H,C>) -> Tx<W,H,C> & Maybe<&2,O>:
  match t:
    case Tx{world,selected,undo,commands,pings,marks}: read_ledger_finish(W,H,C,O,selected,undo,commands,pings,marks,read(world))
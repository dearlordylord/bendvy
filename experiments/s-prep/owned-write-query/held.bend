import Base
import ./types.bend as T
import ./transaction.bend as X

type Held<-W:Type,-M:Type,-L:Type,-H:Data,-C:Type> is Type:
  Held{world:W,main:M,ledger:L,handle:H,undo:List<&2,X.Inverse<H>>,commands:List<C>,pings:List<&2,U32>,marks:List<&2,H>}

def main_read_done(-W:Type,-M:Type,-L:Type,-H:Data,-C:Type,-V:Data,world:W,ledger:L,handle:H,undo:List<&2,X.Inverse<H>>,commands:List<C>,pings:List<&2,U32>,marks:List<&2,H>,result:M & V) -> Held<W,M,L,H,C> & T.Access<V>:
  match result:
    case (main,view): (Held{world,main,ledger,handle,undo,commands,pings,marks},T.Found{view})
def main_read(-W:Type,-M:Type,-L:Type,-H:Data,-C:Type,-V:Data,get:M -> M & V,owner:Held<W,M,L,H,C>) -> Held<W,M,L,H,C> & T.Access<V>:
  match owner:
    case Held{world,main,ledger,handle,undo,commands,pings,marks}: main_read_done(W,M,L,H,C,V,world,ledger,handle,undo,commands,pings,marks,get(main))

def main_write_done(-W:Type,-M:Type,-L:Type,-H:Data,-C:Type,world:W,ledger:L,+handle:H,undo:List<&2,X.Inverse<H>>,commands:List<C>,pings:List<&2,U32>,marks:List<&2,H>,result:M & U32) -> Held<W,M,L,H,C>:
  match result:
    case (main,old): Held{world,main,ledger,handle,X.MainInverse{handle,old} <> undo,commands,pings,handle <> marks}
def main_write(-W:Type,-M:Type,-L:Type,-H:Data,-C:Type,swap:M -> U32 -> M & U32,owner:Held<W,M,L,H,C>,value:U32) -> Held<W,M,L,H,C>:
  match owner:
    case Held{world,main,ledger,handle,undo,commands,pings,marks}: main_write_done(W,M,L,H,C,world,ledger,handle,undo,commands,pings,marks,swap(main,value))

def ledger_read_done(-W:Type,-M:Type,-L:Type,-H:Data,-C:Type,-V:Data,world:W,main:M,handle:H,undo:List<&2,X.Inverse<H>>,commands:List<C>,pings:List<&2,U32>,marks:List<&2,H>,result:L & V) -> Held<W,M,L,H,C> & Maybe<&2,V>:
  match result:
    case (ledger,view): (Held{world,main,ledger,handle,undo,commands,pings,marks},Some{view})
def ledger_read(-W:Type,-M:Type,-L:Type,-H:Data,-C:Type,-V:Data,get:L -> L & V,owner:Held<W,M,L,H,C>) -> Held<W,M,L,H,C> & Maybe<&2,V>:
  match owner:
    case Held{world,main,ledger,handle,undo,commands,pings,marks}: ledger_read_done(W,M,L,H,C,V,world,main,handle,undo,commands,pings,marks,get(ledger))

def ledger_write_done(-W:Type,-M:Type,-L:Type,-H:Data,-C:Type,world:W,main:M,+handle:H,undo:List<&2,X.Inverse<H>>,commands:List<C>,pings:List<&2,U32>,marks:List<&2,H>,result:L & U32) -> Held<W,M,L,H,C>:
  match result:
    case (ledger,old): Held{world,main,ledger,handle,X.LedgerInverse{old} <> undo,commands,pings,marks}
def ledger_write(-W:Type,-M:Type,-L:Type,-H:Data,-C:Type,swap:L -> U32 -> L & U32,owner:Held<W,M,L,H,C>,value:U32) -> Held<W,M,L,H,C>:
  match owner:
    case Held{world,main,ledger,handle,undo,commands,pings,marks}: ledger_write_done(W,M,L,H,C,world,main,handle,undo,commands,pings,marks,swap(ledger,value))

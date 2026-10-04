import Base
import ./types.bend as T

# Concrete records are trusted adapter state, not callback capabilities.
# All constructors are public; safety does not depend on module privacy.
type Factory is Type:
  Factory{next: U32}
type Handle<-S: Data> is Data:
  Handle{namespace: U32, id: U32}
type Bundle<-M: Type, -A: Type, -F: Data> is Type:
  Bundle{main: Maybe<M>, aux: Maybe<A>, flag: Maybe<&2,F>}
type Row<-M: Type, -A: Type, -F: Data> is Type:
  Row{id: U32, main: Maybe<M>, aux: Maybe<A>, flag: Maybe<&2,F>, added: U32, changed: U32}
type Command<-M: Type, -A: Type, -F: Data> is Type:
  Spawn{id: U32, bundle: Bundle<M,A,F>}
  InsertMain{id: U32, main: M}
  InsertFlag{id: U32, flag: F}
  RemoveMain{id: U32}
  RemoveFlag{id: U32}
  Despawn{id: U32}
type Change<-S: Data> is Data:
  MainAdded{handle: Handle<S>}
  MainChanged{handle: Handle<S>}
  MainRemoved{handle: Handle<S>}
  Despawned{handle: Handle<S>}
type World<-S: Data, -M: Type, -A: Type, -F: Data, -L: Type, -Mode: Data> is Type:
  World{namespace: U32, next: U32, rows: List<Row<M,A,F>>,
    pending: List<Command<M,A,F>>, ledger: Maybe<L>, mode: Mode}
type Taken<-M: Type> is Type:
  Taken{main: M}
  NoMain{}
  NoEntity{}

# Take/put are trusted implementation helpers. The public hook reinserts before
# returning World; application callbacks never obtain these concrete owners.
def take_decide(-M: Type,-A: Type,-F: Data, equal: Bool,row: Row<M,A,F>,rows: List<Row<M,A,F>>,result: Taken<M>) -> List<Row<M,A,F>> & Taken<M>:
  match equal row:
    case False{} r: (r <> rows,result)
    case True{} Row{id,None{},a,f,added,changed}: (Row{id,None{},a,f,added,changed} <> rows,NoMain{})
    case True{} Row{id,Some{main},a,f,added,changed}: (Row{id,None{},a,f,added,changed} <> rows,Taken{main})
def take_result(-M: Type,-A: Type,-F: Data,equal: Bool,row: Row<M,A,F>,tail: List<Row<M,A,F>> & Taken<M>) -> List<Row<M,A,F>> & Taken<M>:
  match tail:
    case (rows,result): take_decide(M,A,F,equal,row,rows,result)
def take_row(-M: Type,-A: Type,-F: Data,target: U32,row: Row<M,A,F>,tail: List<Row<M,A,F>> & Taken<M>) -> List<Row<M,A,F>> & Taken<M>:
  match row:
    case Row{+id,m,a,f,added,changed}: take_result(M,A,F,U32.is_eq(target,id),Row{id,m,a,f,added,changed},tail)
def take_rows(-M: Type,-A: Type,-F: Data,rows: List<Row<M,A,F>>,+target: U32) -> List<Row<M,A,F>> & Taken<M>:
  match rows:
    case Nil{}: ([],NoEntity{})
    case Con{row,tail}: take_row(M,A,F,target,row,take_rows(M,A,F,tail,target))

def put_decide(-M: Type,-A: Type,-F: Data,equal: Bool,row: Row<M,A,F>,rows: List<Row<M,A,F>>,main: Maybe<M>) -> List<Row<M,A,F>> & Maybe<M>:
  match equal row:
    case False{} r: (r <> rows,main)
    case True{} Row{id,_,a,f,added,changed}: (Row{id,main,a,f,added,changed} <> rows,None{})
def put_result(-M: Type,-A: Type,-F: Data,equal: Bool,row: Row<M,A,F>,tail: List<Row<M,A,F>> & Maybe<M>) -> List<Row<M,A,F>> & Maybe<M>:
  match tail:
    case (rows,main): put_decide(M,A,F,equal,row,rows,main)
def put_row(-M: Type,-A: Type,-F: Data,target: U32,row: Row<M,A,F>,tail: List<Row<M,A,F>> & Maybe<M>) -> List<Row<M,A,F>> & Maybe<M>:
  match row:
    case Row{+id,m,a,f,added,changed}: put_result(M,A,F,U32.is_eq(target,id),Row{id,m,a,f,added,changed},tail)
def put_rows(-M: Type,-A: Type,-F: Data,rows: List<Row<M,A,F>>,+target: U32,main: M) -> List<Row<M,A,F>> & Maybe<M>:
  match rows:
    case Nil{}: ([],Some{main})
    case Con{row,tail}: put_row(M,A,F,target,row,put_rows(M,A,F,tail,target,main))
def put_finish(-M: Type,-A: Type,-F: Data,result: List<Row<M,A,F>> & Maybe<M>) -> List<Row<M,A,F>>:
  match result:
    case (rows,_): rows

def hook_return(-S: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,-O: Data,
  namespace: U32,next: U32,rows: List<Row<M,A,F>>,pending: List<Command<M,A,F>>,ledger: Maybe<L>,mode: Mode,
  target: U32,result: M & O) -> World<S,M,A,F,L,Mode> & T.Access<O>:
  match result:
    case (main,observation): (World{namespace,next,put_finish(M,A,F,put_rows(M,A,F,rows,target,main)),pending,ledger,mode},T.Found{observation})
def hook_taken(-S: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,-O: Data,
  namespace: U32,next: U32,pending: List<Command<M,A,F>>,ledger: Maybe<L>,mode: Mode,
  target: U32,transform: M -> M & O,result: List<Row<M,A,F>> & Taken<M>) -> World<S,M,A,F,L,Mode> & T.Access<O>:
  match result:
    case (rows,NoEntity{}): (World{namespace,next,rows,pending,ledger,mode},T.Missing{})
    case (rows,NoMain{}): (World{namespace,next,rows,pending,ledger,mode},T.Mismatch{})
    case (rows,Taken{main}): hook_return(S,M,A,F,L,Mode,O,namespace,next,rows,pending,ledger,mode,target,transform(main))
def hook_checked(-S: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,-O: Data,
  valid: Bool,world: World<S,M,A,F,L,Mode>,+target: U32,transform: M -> M & O) -> World<S,M,A,F,L,Mode> & T.Access<O>:
  match valid world:
    case False{} w: (w,T.Missing{})
    case True{} World{namespace,next,rows,pending,ledger,mode}:
      hook_taken(S,M,A,F,L,Mode,O,namespace,next,pending,ledger,mode,target,transform,take_rows(M,A,F,rows,target))
def with_main(-S: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,-O: Data,
  world: World<S,M,A,F,L,Mode>,handle: Handle<S>,transform: M -> M & O) -> World<S,M,A,F,L,Mode> & T.Access<O>:
  match world handle:
    case World{+namespace,next,rows,pending,ledger,mode} Handle{foreign,id}:
      hook_checked(S,M,A,F,L,Mode,O,U32.is_eq(namespace,foreign),World{namespace,next,rows,pending,ledger,mode},id,transform)
def ledger_return(-S: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,-O: Data,
  namespace: U32,next: U32,rows: List<Row<M,A,F>>,pending: List<Command<M,A,F>>,mode: Mode,result: L & O) -> World<S,M,A,F,L,Mode> & Maybe<&2,O>:
  match result:
    case (ledger,observation): (World{namespace,next,rows,pending,Some{ledger},mode},Some{observation})
def with_ledger(-S: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,-O: Data,
  world: World<S,M,A,F,L,Mode>,transform: L -> L & O) -> World<S,M,A,F,L,Mode> & Maybe<&2,O>:
  match world:
    case World{namespace,next,rows,pending,None{},mode}: (World{namespace,next,rows,pending,None{},mode},None{})
    case World{namespace,next,rows,pending,Some{ledger},mode}: ledger_return(S,M,A,F,L,Mode,O,namespace,next,rows,pending,mode,transform(ledger))

# Staging/pending lists are reverse chronological; reversing once at apply is FIFO.
def publish(-S: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,
  world: World<S,M,A,F,L,Mode>,staged: List<Command<M,A,F>>) -> World<S,M,A,F,L,Mode>:
  match world:
    case World{namespace,next,rows,pending,ledger,mode}:
      World{namespace,next,rows,List.append(&1,Command<M,A,F>,staged,pending),ledger,mode}

def mark_decide(-M: Type,-A: Type,-F: Data,equal: Bool,row: Row<M,A,F>,tick: U32) -> Row<M,A,F>:
  match equal row:
    case False{} r: r
    case True{} Row{id,m,a,f,added,_}: Row{id,m,a,f,added,tick}
def mark_row(-M: Type,-A: Type,-F: Data,target: U32,row: Row<M,A,F>,tick: U32) -> Row<M,A,F>:
  match row:
    case Row{+id,m,a,f,added,changed}: mark_decide(M,A,F,U32.is_eq(target,id),Row{id,m,a,f,added,changed},tick)
def mark_rows(-M: Type,-A: Type,-F: Data,rows: List<Row<M,A,F>>,+target: U32,+tick: U32) -> List<Row<M,A,F>>:
  match rows:
    case Nil{}: []
    case Con{row,tail}: mark_row(M,A,F,target,row,tick) <> mark_rows(M,A,F,tail,target,tick)
def mark_checked(-S: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,
  valid: Bool,world: World<S,M,A,F,L,Mode>,target: U32,tick: U32) -> World<S,M,A,F,L,Mode>:
  match valid world:
    case False{} w: w
    case True{} World{namespace,next,rows,pending,ledger,mode}: World{namespace,next,mark_rows(M,A,F,rows,target,tick),pending,ledger,mode}
def mark_main(-S: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,
  world: World<S,M,A,F,L,Mode>,handle: Handle<S>,tick: U32) -> World<S,M,A,F,L,Mode>:
  match world handle:
    case World{+namespace,next,rows,pending,ledger,mode} Handle{foreign,target}:
      mark_checked(S,M,A,F,L,Mode,U32.is_eq(namespace,foreign),World{namespace,next,rows,pending,ledger,mode},target,tick)

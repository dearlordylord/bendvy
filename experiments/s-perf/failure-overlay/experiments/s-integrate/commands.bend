import Base
import ./types.bend as T
import ./storage.bend as S
import ./identity.bend as I

def reserved(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,
  bundle: S.Bundle<M,A,F>,result: S.World<Schema,M,A,F,L,Mode> & Maybe<&2,S.Handle<Schema>>) -> T.Reservation<S.World<Schema,M,A,F,L,Mode>,S.Handle<Schema>,S.Bundle<M,A,F>>:
  match result:
    case (world,None{}): T.ReserveRejected{world,bundle}
    case (world,Some{S.Handle{namespace,+id}}): T.Reserved{S.publish(Schema,M,A,F,L,Mode,world,[S.Spawn{id,bundle}]),S.Handle{namespace,id}}
def reserve(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,
  world: S.World<Schema,M,A,F,L,Mode>,bundle: S.Bundle<M,A,F>) -> T.Reservation<S.World<Schema,M,A,F,L,Mode>,S.Handle<Schema>,S.Bundle<M,A,F>>:
  reserved(Schema,M,A,F,L,Mode,bundle,I.reserve_id(Schema,M,A,F,L,Mode,world))

def queue_checked(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,-P: Type,
  valid: Bool,world: S.World<Schema,M,A,F,L,Mode>,target: U32,payload: P,build: U32 -> P -> S.Command<M,A,F>) -> T.CommandResult<S.World<Schema,M,A,F,L,Mode>,P>:
  match valid:
    case False{}: T.CommandMissing{world,payload}
    case True{}: T.CommandQueued{S.publish(Schema,M,A,F,L,Mode,world,[build(target,payload)])}
# Trusted generic builder, never supplied to application callbacks.
def queue_owned(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,-P: Type,
  world: S.World<Schema,M,A,F,L,Mode>,handle: S.Handle<Schema>,payload: P,build: U32 -> P -> S.Command<M,A,F>) -> T.CommandResult<S.World<Schema,M,A,F,L,Mode>,P>:
  match world handle:
    case S.World{+namespace,next,rows,pending,ledger,mode} S.Handle{foreign,target}:
      queue_checked(Schema,M,A,F,L,Mode,P,U32.is_eq(namespace,foreign),S.World{namespace,next,rows,pending,ledger,mode},target,payload,build)
def build_main(-M: Type,-A: Type,-F: Data,id: U32,main: M) -> S.Command<M,A,F>:
  S.InsertMain{id,main}
def build_flag(-M: Type,-A: Type,-F: Data,id: U32,flag: F) -> S.Command<M,A,F>:
  S.InsertFlag{id,flag}
def build_remove_main(-M: Type,-A: Type,-F: Data,id: U32,unit: Unit) -> S.Command<M,A,F>:
  S.RemoveMain{id}
def build_remove_flag(-M: Type,-A: Type,-F: Data,id: U32,unit: Unit) -> S.Command<M,A,F>:
  S.RemoveFlag{id}
def build_despawn(-M: Type,-A: Type,-F: Data,id: U32,unit: Unit) -> S.Command<M,A,F>:
  S.Despawn{id}
def insert_main(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,
  world: S.World<Schema,M,A,F,L,Mode>,handle: S.Handle<Schema>,main: M) -> T.CommandResult<S.World<Schema,M,A,F,L,Mode>,M>:
  queue_owned(Schema,M,A,F,L,Mode,M,world,handle,main,build_main(M,A,F))
def insert_flag(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,
  world: S.World<Schema,M,A,F,L,Mode>,handle: S.Handle<Schema>,flag: F) -> T.CommandResult<S.World<Schema,M,A,F,L,Mode>,F>:
  queue_owned(Schema,M,A,F,L,Mode,F,world,handle,flag,build_flag(M,A,F))
def remove_main(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,
  world: S.World<Schema,M,A,F,L,Mode>,handle: S.Handle<Schema>) -> T.CommandResult<S.World<Schema,M,A,F,L,Mode>,Unit>:
  queue_owned(Schema,M,A,F,L,Mode,Unit,world,handle,Unit{},build_remove_main(M,A,F))
def remove_flag(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,
  world: S.World<Schema,M,A,F,L,Mode>,handle: S.Handle<Schema>) -> T.CommandResult<S.World<Schema,M,A,F,L,Mode>,Unit>:
  queue_owned(Schema,M,A,F,L,Mode,Unit,world,handle,Unit{},build_remove_flag(M,A,F))
def despawn(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,
  world: S.World<Schema,M,A,F,L,Mode>,handle: S.Handle<Schema>) -> T.CommandResult<S.World<Schema,M,A,F,L,Mode>,Unit>:
  queue_owned(Schema,M,A,F,L,Mode,Unit,world,handle,Unit{},build_despawn(M,A,F))

type RowEdit<-Schema: Data,-M: Type,-A: Type,-F: Data> is Type:
  RowEdit{row: Maybe<S.Row<M,A,F>>,changes: List<&2,S.Change<Schema>>}
def edit_row(-Schema: Data,-M: Type,-A: Type,-F: Data,+namespace: U32,+tick: U32,command: S.Command<M,A,F>,row: S.Row<M,A,F>) -> RowEdit<Schema,M,A,F>:
  match command row:
    case S.InsertMain{_,main} S.Row{+id,None{},aux,flag,_,_}:
      RowEdit{Some{S.Row{id,Some{main},aux,flag,tick,tick}},[S.MainAdded{S.Handle{namespace,id}},S.MainChanged{S.Handle{namespace,id}}]}
    case S.InsertMain{_,main} S.Row{+id,Some{_},aux,flag,added,_}:
      RowEdit{Some{S.Row{id,Some{main},aux,flag,added,tick}},[S.MainChanged{S.Handle{namespace,id}}]}
    case S.InsertFlag{_,flag} S.Row{id,main,aux,_,added,changed}:
      RowEdit{Some{S.Row{id,main,aux,Some{flag},added,changed}},[]}
    case S.RemoveFlag{_} S.Row{id,main,aux,_,added,changed}:
      RowEdit{Some{S.Row{id,main,aux,None{},added,changed}},[]}
    case S.RemoveMain{_} S.Row{+id,Some{_},aux,flag,_,_}:
      RowEdit{Some{S.Row{id,None{},aux,flag,0,0}},[S.MainRemoved{S.Handle{namespace,id}}]}
    case S.RemoveMain{_} r: RowEdit{Some{r},[]}
    case S.Despawn{_} S.Row{+id,Some{_},_,_,_,_}:
      RowEdit{None{},[S.MainRemoved{S.Handle{namespace,id}},S.Despawned{S.Handle{namespace,id}}]}
    case S.Despawn{_} S.Row{id,None{},_,_,_,_}:
      RowEdit{None{},[S.Despawned{S.Handle{namespace,id}}]}
    case S.Spawn{_,_} r: RowEdit{Some{r},[]}

# The reverse prefix and remaining suffix partition the real affine row owners.
# Keeping the edited target at the suffix head permits repeated writes to it.
type ApplyCursor<-Schema: Data,-M: Type,-A: Type,-F: Data> is Type:
  ApplyCursor{before: List<S.Row<M,A,F>>,remaining: List<S.Row<M,A,F>>,last: U32,reverseChanges: List<&2,S.Change<Schema>>}
type Seeking<-Schema: Data,-M: Type,-A: Type,-F: Data> is Type:
  Seeking{before: List<S.Row<M,A,F>>,reverseChanges: List<&2,S.Change<Schema>>}
  Located{before: List<S.Row<M,A,F>>,row: S.Row<M,A,F>,reverseChanges: List<&2,S.Change<Schema>>}
def seek_decide(-Schema: Data,-M: Type,-A: Type,-F: Data,advance: Bool,row: S.Row<M,A,F>,before: List<S.Row<M,A,F>>,changes: List<&2,S.Change<Schema>>) -> Seeking<Schema,M,A,F>:
  match advance:
    case True{}: Seeking{row <> before,changes}
    case False{}: Located{before,row,changes}
def seek_row(-Schema: Data,-M: Type,-A: Type,-F: Data,target: U32,row: S.Row<M,A,F>,before: List<S.Row<M,A,F>>,changes: List<&2,S.Change<Schema>>) -> Seeking<Schema,M,A,F>:
  match row:
    case S.Row{+id,main,aux,flag,added,changed}:
      seek_decide(Schema,M,A,F,U32.is_lt(id,target),S.Row{id,main,aux,flag,added,changed},before,changes)
# The Located state stops without traversing its remaining tail. Recursion is
# structurally decreasing on rows, with no copied owner or numeric fuel scan.
def seek_rows(-Schema: Data,-M: Type,-A: Type,-F: Data,rows: List<S.Row<M,A,F>>,+target: U32,state: Seeking<Schema,M,A,F>) -> ApplyCursor<Schema,M,A,F>:
  match rows state:
    case rs Located{before,row,changes}: ApplyCursor{before,row <> rs,target,changes}
    case Nil{} Seeking{before,changes}: ApplyCursor{before,[],target,changes}
    case Con{row,tail} Seeking{before,changes}: seek_rows(Schema,M,A,F,tail,target,seek_row(Schema,M,A,F,target,row,before,changes))
def seek_start(-Schema: Data,-M: Type,-A: Type,-F: Data,reset: Bool,target: U32,before: List<S.Row<M,A,F>>,remaining: List<S.Row<M,A,F>>,changes: List<&2,S.Change<Schema>>) -> ApplyCursor<Schema,M,A,F>:
  match reset:
    case False{}: seek_rows(Schema,M,A,F,remaining,target,Seeking{before,changes})
    case True{}: seek_rows(Schema,M,A,F,List.reverse.go(&1,S.Row<M,A,F>,before,remaining),target,Seeking{[],changes})
def seek(-Schema: Data,-M: Type,-A: Type,-F: Data,+target: U32,cursor: ApplyCursor<Schema,M,A,F>) -> ApplyCursor<Schema,M,A,F>:
  match cursor:
    case ApplyCursor{before,remaining,last,changes}: seek_start(Schema,M,A,F,U32.is_lt(target,last),target,before,remaining,changes)

def cursor_edited(-Schema: Data,-M: Type,-A: Type,-F: Data,before: List<S.Row<M,A,F>>,tail: List<S.Row<M,A,F>>,target: U32,reverseChanges: List<&2,S.Change<Schema>>,result: RowEdit<Schema,M,A,F>) -> ApplyCursor<Schema,M,A,F>:
  match result:
    case RowEdit{None{},changes}: ApplyCursor{before,tail,target,List.reverse.go(&2,S.Change<Schema>,changes,reverseChanges)}
    case RowEdit{Some{row},changes}: ApplyCursor{before,row <> tail,target,List.reverse.go(&2,S.Change<Schema>,changes,reverseChanges)}
def cursor_edit_decide(-Schema: Data,-M: Type,-A: Type,-F: Data,namespace: U32,tick: U32,equal: Bool,before: List<S.Row<M,A,F>>,row: S.Row<M,A,F>,tail: List<S.Row<M,A,F>>,target: U32,changes: List<&2,S.Change<Schema>>,command: S.Command<M,A,F>) -> ApplyCursor<Schema,M,A,F>:
  match equal:
    case False{}: ApplyCursor{before,row <> tail,target,changes}
    case True{}: cursor_edited(Schema,M,A,F,before,tail,target,changes,edit_row(Schema,M,A,F,namespace,tick,command,row))
def cursor_edit(-Schema: Data,-M: Type,-A: Type,-F: Data,namespace: U32,tick: U32,cursor: ApplyCursor<Schema,M,A,F>,command: S.Command<M,A,F>) -> ApplyCursor<Schema,M,A,F>:
  match cursor:
    case ApplyCursor{before,Nil{},target,changes}: ApplyCursor{before,[],target,changes}
    case ApplyCursor{before,Con{S.Row{+id,main,aux,flag,added,changed},tail},+target,changes}:
      cursor_edit_decide(Schema,M,A,F,namespace,tick,U32.is_eq(id,target),before,S.Row{id,main,aux,flag,added,changed},tail,target,changes,command)
def cursor_spawn(-Schema: Data,-M: Type,-A: Type,-F: Data,+namespace: U32,+tick: U32,+id: U32,bundle: S.Bundle<M,A,F>,cursor: ApplyCursor<Schema,M,A,F>) -> ApplyCursor<Schema,M,A,F>:
  match bundle cursor:
    case S.Bundle{None{},aux,flag} ApplyCursor{before,remaining,target,changes}:
      ApplyCursor{before,S.Row{id,None{},aux,flag,0,0} <> remaining,target,changes}
    case S.Bundle{Some{main},aux,flag} ApplyCursor{before,remaining,target,changes}:
      ApplyCursor{before,S.Row{id,Some{main},aux,flag,tick,tick} <> remaining,target,S.MainChanged{S.Handle{namespace,id}} <> S.MainAdded{S.Handle{namespace,id}} <> changes}
def cursor_apply(-Schema: Data,-M: Type,-A: Type,-F: Data,namespace: U32,tick: U32,cursor: ApplyCursor<Schema,M,A,F>,command: S.Command<M,A,F>) -> ApplyCursor<Schema,M,A,F>:
  match command:
    case S.Spawn{id,bundle}: cursor_spawn(Schema,M,A,F,namespace,tick,id,bundle,cursor)
    case other: cursor_edit(Schema,M,A,F,namespace,tick,cursor,other)
def targeted(-M: Type,-A: Type,-F: Data,command: S.Command<M,A,F>) -> S.Command<M,A,F> & U32:
  match command:
    case S.Spawn{+id,bundle}: (S.Spawn{id,bundle},id)
    case S.InsertMain{+id,main}: (S.InsertMain{id,main},id)
    case S.InsertFlag{+id,flag}: (S.InsertFlag{id,flag},id)
    case S.RemoveMain{+id}: (S.RemoveMain{id},id)
    case S.RemoveFlag{+id}: (S.RemoveFlag{id},id)
    case S.Despawn{+id}: (S.Despawn{id},id)
def cursor_target(-Schema: Data,-M: Type,-A: Type,-F: Data,namespace: U32,tick: U32,cursor: ApplyCursor<Schema,M,A,F>,target: S.Command<M,A,F> & U32) -> ApplyCursor<Schema,M,A,F>:
  match target:
    case (command,id): cursor_apply(Schema,M,A,F,namespace,tick,seek(Schema,M,A,F,id,cursor),command)
def cursor_step(-Schema: Data,-M: Type,-A: Type,-F: Data,namespace: U32,tick: U32,cursor: ApplyCursor<Schema,M,A,F>,command: S.Command<M,A,F>) -> ApplyCursor<Schema,M,A,F>:
  cursor_target(Schema,M,A,F,namespace,tick,cursor,targeted(M,A,F,command))
def cursor_many(-Schema: Data,-M: Type,-A: Type,-F: Data,commands: List<S.Command<M,A,F>>,+namespace: U32,+tick: U32,cursor: ApplyCursor<Schema,M,A,F>) -> ApplyCursor<Schema,M,A,F>:
  match commands:
    case Nil{}: cursor
    case Con{command,tail}: cursor_many(Schema,M,A,F,tail,namespace,tick,cursor_step(Schema,M,A,F,namespace,tick,cursor,command))
def cursor_finish(-Schema: Data,-M: Type,-A: Type,-F: Data,cursor: ApplyCursor<Schema,M,A,F>) -> List<S.Row<M,A,F>> & List<&2,S.Change<Schema>>:
  match cursor:
    case ApplyCursor{before,remaining,_,changes}: (List.reverse.go(&1,S.Row<M,A,F>,before,remaining),List.reverse(&2,S.Change<Schema>,changes))
def apply_one(-Schema: Data,-M: Type,-A: Type,-F: Data,namespace: U32,tick: U32,rows: List<S.Row<M,A,F>>,command: S.Command<M,A,F>) -> List<S.Row<M,A,F>> & List<&2,S.Change<Schema>>:
  cursor_finish(Schema,M,A,F,cursor_step(Schema,M,A,F,namespace,tick,ApplyCursor{[],rows,0,[]},command))
def apply_many(-Schema: Data,-M: Type,-A: Type,-F: Data,commands: List<S.Command<M,A,F>>,namespace: U32,tick: U32,state: List<S.Row<M,A,F>> & List<&2,S.Change<Schema>>) -> List<S.Row<M,A,F>> & List<&2,S.Change<Schema>>:
  match state:
    case (rows,changes): cursor_finish(Schema,M,A,F,cursor_many(Schema,M,A,F,commands,namespace,tick,ApplyCursor{[],rows,0,List.reverse(&2,S.Change<Schema>,changes)}))
def applied(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,namespace: U32,next: U32,ledger: Maybe<L>,mode: Mode,result: List<S.Row<M,A,F>> & List<&2,S.Change<Schema>>) -> S.World<Schema,M,A,F,L,Mode> & List<&2,S.Change<Schema>>:
  match result:
    case (rows,changes): (S.World{namespace,next,rows,[],ledger,mode},changes)
def apply(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,world: S.World<Schema,M,A,F,L,Mode>,tick: U32) -> S.World<Schema,M,A,F,L,Mode> & List<&2,S.Change<Schema>>:
  match world:
    case S.World{+namespace,next,rows,pending,ledger,mode}:
      applied(Schema,M,A,F,L,Mode,namespace,next,ledger,mode,apply_many(Schema,M,A,F,List.reverse(&1,S.Command<M,A,F>,pending),namespace,tick,(rows,[])))

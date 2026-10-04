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

# Sort at insertion, without copying a Type row. The recursive continuation owns
# the tail and is consumed once in either branch.
def insert_decide(-M: Type,-A: Type,-F: Data,before: Bool,current: S.Row<M,A,F>,fresh: S.Row<M,A,F>,rest: Maybe<S.Row<M,A,F>> -> List<S.Row<M,A,F>>) -> List<S.Row<M,A,F>>:
  match before:
    case True{}: fresh <> current <> rest(None{})
    case False{}: current <> rest(Some{fresh})
def insert_compare(-M: Type,-A: Type,-F: Data,current: S.Row<M,A,F>,fresh: S.Row<M,A,F>,rest: Maybe<S.Row<M,A,F>> -> List<S.Row<M,A,F>>) -> List<S.Row<M,A,F>>:
  match current fresh:
    case S.Row{+id,m,a,f,added,changed} S.Row{+newid,nm,na,nf,nadded,nchanged}:
      insert_decide(M,A,F,U32.is_lt(newid,id),S.Row{id,m,a,f,added,changed},S.Row{newid,nm,na,nf,nadded,nchanged},rest)
def insert_rows(-M: Type,-A: Type,-F: Data,rows: List<S.Row<M,A,F>>,fresh: Maybe<S.Row<M,A,F>>) -> List<S.Row<M,A,F>>:
  match rows fresh:
    case rs None{}: rs
    case Nil{} Some{r}: [r]
    case Con{row,tail} Some{r}: insert_compare(M,A,F,row,r,x => insert_rows(M,A,F,tail,x))

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
type Edit<-Schema: Data,-M: Type,-A: Type,-F: Data> is Type:
  Edit{rows: List<S.Row<M,A,F>>,remaining: Maybe<S.Command<M,A,F>>,changes: List<&2,S.Change<Schema>>}
def edit_join(-Schema: Data,-M: Type,-A: Type,-F: Data,rows: List<S.Row<M,A,F>>,result: RowEdit<Schema,M,A,F>) -> Edit<Schema,M,A,F>:
  match result:
    case RowEdit{None{},changes}: Edit{rows,None{},changes}
    case RowEdit{Some{row},changes}: Edit{row <> rows,None{},changes}
def edit_decide(-Schema: Data,-M: Type,-A: Type,-F: Data,namespace: U32,tick: U32,equal: Bool,row: S.Row<M,A,F>,tail: Edit<Schema,M,A,F>) -> Edit<Schema,M,A,F>:
  match equal tail:
    case False{} Edit{rows,remaining,changes}: Edit{row <> rows,remaining,changes}
    case True{} Edit{rows,None{},changes}: Edit{row <> rows,None{},changes}
    case True{} Edit{rows,Some{command},_}: edit_join(Schema,M,A,F,rows,edit_row(Schema,M,A,F,namespace,tick,command,row))
def edit_compare(-Schema: Data,-M: Type,-A: Type,-F: Data,namespace: U32,tick: U32,target: U32,row: S.Row<M,A,F>,tail: Edit<Schema,M,A,F>) -> Edit<Schema,M,A,F>:
  match row:
    case S.Row{+id,m,a,f,added,changed}: edit_decide(Schema,M,A,F,namespace,tick,U32.is_eq(target,id),S.Row{id,m,a,f,added,changed},tail)
def edit_rows(-Schema: Data,-M: Type,-A: Type,-F: Data,rows: List<S.Row<M,A,F>>,+namespace: U32,+tick: U32,+target: U32,command: S.Command<M,A,F>) -> Edit<Schema,M,A,F>:
  match rows:
    case Nil{}: Edit{[],Some{command},[]}
    case Con{row,tail}: edit_compare(Schema,M,A,F,namespace,tick,target,row,edit_rows(Schema,M,A,F,tail,namespace,tick,target,command))
def edited(-Schema: Data,-M: Type,-A: Type,-F: Data,result: Edit<Schema,M,A,F>) -> List<S.Row<M,A,F>> & List<&2,S.Change<Schema>>:
  match result:
    case Edit{rows,_,changes}: (rows,changes)
def spawned(-Schema: Data,-M: Type,-A: Type,-F: Data,+namespace: U32,+tick: U32,+id: U32,rows: List<S.Row<M,A,F>>,bundle: S.Bundle<M,A,F>) -> List<S.Row<M,A,F>> & List<&2,S.Change<Schema>>:
  match bundle:
    case S.Bundle{None{},a,f}: (insert_rows(M,A,F,rows,Some{S.Row{id,None{},a,f,0,0}}),[])
    case S.Bundle{Some{m},a,f}: (insert_rows(M,A,F,rows,Some{S.Row{id,Some{m},a,f,tick,tick}}),[S.MainAdded{S.Handle{namespace,id}},S.MainChanged{S.Handle{namespace,id}}])
def apply_one(-Schema: Data,-M: Type,-A: Type,-F: Data,namespace: U32,tick: U32,rows: List<S.Row<M,A,F>>,command: S.Command<M,A,F>) -> List<S.Row<M,A,F>> & List<&2,S.Change<Schema>>:
  match command:
    case S.Spawn{id,bundle}: spawned(Schema,M,A,F,namespace,tick,id,rows,bundle)
    case S.InsertMain{+id,main}: edited(Schema,M,A,F,edit_rows(Schema,M,A,F,rows,namespace,tick,id,S.InsertMain{id,main}))
    case S.InsertFlag{+id,flag}: edited(Schema,M,A,F,edit_rows(Schema,M,A,F,rows,namespace,tick,id,S.InsertFlag{id,flag}))
    case S.RemoveMain{+id}: edited(Schema,M,A,F,edit_rows(Schema,M,A,F,rows,namespace,tick,id,S.RemoveMain{id}))
    case S.RemoveFlag{+id}: edited(Schema,M,A,F,edit_rows(Schema,M,A,F,rows,namespace,tick,id,S.RemoveFlag{id}))
    case S.Despawn{+id}: edited(Schema,M,A,F,edit_rows(Schema,M,A,F,rows,namespace,tick,id,S.Despawn{id}))
def append_changes(-Schema: Data,-M: Type,-A: Type,-F: Data,earlier: List<&2,S.Change<Schema>>,result: List<S.Row<M,A,F>> & List<&2,S.Change<Schema>>) -> List<S.Row<M,A,F>> & List<&2,S.Change<Schema>>:
  match result:
    case (rows,later): (rows,List.append(&2,S.Change<Schema>,earlier,later))
def apply_step(-Schema: Data,-M: Type,-A: Type,-F: Data,namespace: U32,tick: U32,command: S.Command<M,A,F>,state: List<S.Row<M,A,F>> & List<&2,S.Change<Schema>>) -> List<S.Row<M,A,F>> & List<&2,S.Change<Schema>>:
  match state:
    case (rows,changes): append_changes(Schema,M,A,F,changes,apply_one(Schema,M,A,F,namespace,tick,rows,command))
def apply_many(-Schema: Data,-M: Type,-A: Type,-F: Data,commands: List<S.Command<M,A,F>>,+namespace: U32,+tick: U32,state: List<S.Row<M,A,F>> & List<&2,S.Change<Schema>>) -> List<S.Row<M,A,F>> & List<&2,S.Change<Schema>>:
  match commands:
    case Nil{}: state
    case Con{command,tail}: apply_many(Schema,M,A,F,tail,namespace,tick,apply_step(Schema,M,A,F,namespace,tick,command,state))
def applied(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,namespace: U32,next: U32,ledger: Maybe<L>,mode: Mode,result: List<S.Row<M,A,F>> & List<&2,S.Change<Schema>>) -> S.World<Schema,M,A,F,L,Mode> & List<&2,S.Change<Schema>>:
  match result:
    case (rows,changes): (S.World{namespace,next,rows,[],ledger,mode},changes)
def apply(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,world: S.World<Schema,M,A,F,L,Mode>,tick: U32) -> S.World<Schema,M,A,F,L,Mode> & List<&2,S.Change<Schema>>:
  match world:
    case S.World{+namespace,next,rows,pending,ledger,mode}:
      applied(Schema,M,A,F,L,Mode,namespace,next,ledger,mode,apply_many(Schema,M,A,F,List.reverse(&1,S.Command<M,A,F>,pending),namespace,tick,(rows,[])))

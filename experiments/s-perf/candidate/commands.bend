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
    case S.InsertFlag{_,flag} S.Row{id,main,aux,_,added,changed}:
      RowEdit{Some{S.Row{id,main,aux,Some{flag},added,changed}},[]}
    case S.RemoveFlag{_} S.Row{id,main,aux,_,added,changed}:
      RowEdit{Some{S.Row{id,main,aux,None{},added,changed}},[]}
    case S.InsertMain{_,_} r: RowEdit{Some{r},[]}
    case S.RemoveMain{_} r: RowEdit{Some{r},[]}
    case S.Despawn{_} S.Row{+id,Some{_},_,_,_,_}:
      RowEdit{None{},[S.MainRemoved{S.Handle{namespace,id}},S.Despawned{S.Handle{namespace,id}}]}
    case S.Despawn{_} S.Row{id,None{},_,_,_,_}:
      RowEdit{None{},[S.Despawned{S.Handle{namespace,id}}]}
    case S.Spawn{_,_} r: RowEdit{Some{r},[]}

# Entire queue is preflighted before the first payload is installed. The affine
# queue is reconstructed in its original order, including on rejection.
type Preflight<-M: Type,-A: Type,-F: Data> is Type:
  Preflight{rows: S.Rows<M,A,F>,commands: List<S.Command<M,A,F>>,valid: Bool}
def preflight_return(-M: Type,-A: Type,-F: Data,command: S.Command<M,A,F>,valid: Bool,result: Preflight<M,A,F>) -> Preflight<M,A,F>:
  match result:
    case Preflight{rows,commands,rest}: Preflight{rows,command <> commands,valid && rest}
def bounded_spawn(-M: Type,-A: Type,-F: Data,id: U32,bundle: S.Bundle<M,A,F>,result: S.Rows<M,A,F> & Bool) -> S.Rows<M,A,F> & (S.Command<M,A,F> & Bool):
  match result:
    case (rows,valid): (rows,(S.Spawn{id,bundle},valid))
def command_bound(-M: Type,-A: Type,-F: Data,rows: S.Rows<M,A,F>,command: S.Command<M,A,F>) -> S.Rows<M,A,F> & (S.Command<M,A,F> & Bool):
  match command:
    case S.Spawn{+id,bundle}:
      bounded_spawn(M,A,F,id,bundle,S.rows_can_place(M,A,F,rows,id))
    case other: (rows,(other,True{}))
def preflight_step(-M: Type,-A: Type,-F: Data,result: S.Rows<M,A,F> & (S.Command<M,A,F> & Bool),recur: S.Rows<M,A,F> -> Preflight<M,A,F>) -> Preflight<M,A,F>:
  match result:
    case (rows,(command,valid)): preflight_return(M,A,F,command,valid,recur(rows))
def preflight(-M: Type,-A: Type,-F: Data,commands: List<S.Command<M,A,F>>,rows: S.Rows<M,A,F>) -> Preflight<M,A,F>:
  match commands:
    case Nil{}: Preflight{rows,[],True{}}
    case Con{command,tail}: preflight_step(M,A,F,command_bound(M,A,F,rows,command),rows => preflight(M,A,F,tail,rows))

type StepResult<-Schema: Data,-M: Type,-A: Type,-F: Data> is Type:
  Stepped{rows: S.Rows<M,A,F>,changes: List<&2,S.Change<Schema>>}
  PlacementFault{rows: S.Rows<M,A,F>,row: S.Row<M,A,F>}
def removed(-Schema: Data,-M: Type,-A: Type,-F: Data,changes: List<&2,S.Change<Schema>>,result: S.Rows<M,A,F> & Maybe<S.Row<M,A,F>>) -> StepResult<Schema,M,A,F>:
  match result:
    case (rows,_): Stepped{rows,changes}
def edited(-Schema: Data,-M: Type,-A: Type,-F: Data,rows: S.Rows<M,A,F>,id: U32,result: RowEdit<Schema,M,A,F>) -> StepResult<Schema,M,A,F>:
  match result:
    case RowEdit{Some{row},changes}: Stepped{S.rows_restore(M,A,F,rows,row),changes}
    case RowEdit{None{},changes}: removed(Schema,M,A,F,changes,S.rows_remove(M,A,F,rows,id))
def extracted(-Schema: Data,-M: Type,-A: Type,-F: Data,namespace: U32,tick: U32,id: U32,command: S.Command<M,A,F>,result: S.Rows<M,A,F> & Maybe<S.Row<M,A,F>>) -> StepResult<Schema,M,A,F>:
  match result:
    case (rows,None{}): Stepped{rows,[]}
    case (rows,Some{row}): edited(Schema,M,A,F,rows,id,edit_row(Schema,M,A,F,namespace,tick,command,row))
def placed(-Schema: Data,-M: Type,-A: Type,-F: Data,changes: List<&2,S.Change<Schema>>,result: S.Placement<M,A,F>) -> StepResult<Schema,M,A,F>:
  match result:
    case S.Placed{rows}: Stepped{rows,changes}
    case S.Rejected{rows,row}: PlacementFault{rows,row}
def spawn(-Schema: Data,-M: Type,-A: Type,-F: Data,+namespace: U32,+tick: U32,+id: U32,rows: S.Rows<M,A,F>,bundle: S.Bundle<M,A,F>) -> StepResult<Schema,M,A,F>:
  match bundle:
    case S.Bundle{None{},aux,flag}: placed(Schema,M,A,F,[],S.rows_place(M,A,F,rows,S.Row{id,None{},aux,flag,0,0}))
    case S.Bundle{Some{main},aux,flag}: placed(Schema,M,A,F,[S.MainAdded{S.Handle{namespace,id}},S.MainChanged{S.Handle{namespace,id}}],S.rows_place(M,A,F,rows,S.Row{id,Some{main},aux,flag,tick,tick}))
def targeted(-M: Type,-A: Type,-F: Data,command: S.Command<M,A,F>) -> S.Command<M,A,F> & U32:
  match command:
    case S.Spawn{+id,bundle}: (S.Spawn{id,bundle},id)
    case S.InsertMain{+id,main}: (S.InsertMain{id,main},id)
    case S.InsertFlag{+id,flag}: (S.InsertFlag{id,flag},id)
    case S.RemoveMain{+id}: (S.RemoveMain{id},id)
    case S.RemoveFlag{+id}: (S.RemoveFlag{id},id)
    case S.Despawn{+id}: (S.Despawn{id},id)
def edit_target(-Schema: Data,-M: Type,-A: Type,-F: Data,namespace: U32,tick: U32,rows: S.Rows<M,A,F>,result: S.Command<M,A,F> & U32) -> StepResult<Schema,M,A,F>:
  match result:
    case (command,+id): extracted(Schema,M,A,F,namespace,tick,id,command,S.rows_extract(M,A,F,rows,id))
def main_effect(-Schema: Data,-M: Type,-A: Type,-F: Data,+namespace: U32,+id: U32,result: S.Rows<M,A,F> & S.MainEffect) -> StepResult<Schema,M,A,F>:
  match result:
    case (rows,S.AddedMain{}): Stepped{rows,[S.MainAdded{S.Handle{namespace,id}},S.MainChanged{S.Handle{namespace,id}}]}
    case (rows,S.ChangedMain{}): Stepped{rows,[S.MainChanged{S.Handle{namespace,id}}]}
    case (rows,S.RemovedMain{}): Stepped{rows,[S.MainRemoved{S.Handle{namespace,id}}]}
    case (rows,S.MissingMainTarget{}): Stepped{rows,[]}
    case (rows,S.NoMainChange{}): Stepped{rows,[]}
def step(-Schema: Data,-M: Type,-A: Type,-F: Data,namespace: U32,tick: U32,rows: S.Rows<M,A,F>,command: S.Command<M,A,F>) -> StepResult<Schema,M,A,F>:
  match command:
    case S.Spawn{id,bundle}: spawn(Schema,M,A,F,namespace,tick,id,rows,bundle)
    case S.InsertMain{+id,main}: main_effect(Schema,M,A,F,namespace,id,S.rows_replace_main(M,A,F,rows,id,Some{main},tick))
    case S.RemoveMain{+id}: main_effect(Schema,M,A,F,namespace,id,S.rows_replace_main(M,A,F,rows,id,None{},tick))
    case other: edit_target(Schema,M,A,F,namespace,tick,rows,targeted(M,A,F,other))
type BatchResult<-Schema: Data,-M: Type,-A: Type,-F: Data> is Type:
  Completed{rows: S.Rows<M,A,F>,changes: List<&2,S.Change<Schema>>}
  BatchFault{rows: S.Rows<M,A,F>,row: S.Row<M,A,F>,remaining: List<S.Command<M,A,F>>,changes: List<&2,S.Change<Schema>>}
type BatchState<-Schema: Data,-M: Type,-A: Type,-F: Data> is Type:
  Running{rows: S.Rows<M,A,F>,reverseChanges: List<&2,S.Change<Schema>>}
  Faulted{rows: S.Rows<M,A,F>,row: S.Row<M,A,F>,reverseRemaining: List<S.Command<M,A,F>>,changes: List<&2,S.Change<Schema>>}
def state_step(-Schema: Data,-M: Type,-A: Type,-F: Data,reverseChanges: List<&2,S.Change<Schema>>,result: StepResult<Schema,M,A,F>) -> BatchState<Schema,M,A,F>:
  match result:
    case Stepped{rows,changes}: Running{rows,List.reverse.go(&2,S.Change<Schema>,changes,reverseChanges)}
    case PlacementFault{rows,row}: Faulted{rows,row,[],List.reverse(&2,S.Change<Schema>,reverseChanges)}
def state_command(-Schema: Data,-M: Type,-A: Type,-F: Data,namespace: U32,tick: U32,command: S.Command<M,A,F>,state: BatchState<Schema,M,A,F>) -> BatchState<Schema,M,A,F>:
  match state:
    case Running{rows,changes}: state_step(Schema,M,A,F,changes,step(Schema,M,A,F,namespace,tick,rows,command))
    case Faulted{rows,row,remaining,changes}: Faulted{rows,row,command <> remaining,changes}
def state_finish(-Schema: Data,-M: Type,-A: Type,-F: Data,state: BatchState<Schema,M,A,F>) -> BatchResult<Schema,M,A,F>:
  match state:
    case Running{rows,changes}: Completed{rows,List.reverse(&2,S.Change<Schema>,changes)}
    case Faulted{rows,row,remaining,changes}: BatchFault{rows,row,List.reverse(&1,S.Command<M,A,F>,remaining),changes}
def batch(-Schema: Data,-M: Type,-A: Type,-F: Data,commands: List<S.Command<M,A,F>>,+namespace: U32,+tick: U32,state: BatchState<Schema,M,A,F>) -> BatchResult<Schema,M,A,F>:
  match commands:
    case Nil{}: state_finish(Schema,M,A,F,state)
    case Con{command,tail}: batch(Schema,M,A,F,tail,namespace,tick,state_command(Schema,M,A,F,namespace,tick,command,state))
type CheckedApply<-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data> is Type:
  Applied{world: S.World<Schema,M,A,F,L,Mode>,changes: List<&2,S.Change<Schema>>}
  CapacityRejected{world: S.World<Schema,M,A,F,L,Mode>}
  InvariantFault{world: S.World<Schema,M,A,F,L,Mode>,row: S.Row<M,A,F>,changes: List<&2,S.Change<Schema>>}
def batch_world(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,namespace: U32,next: U32,ledger: Maybe<L>,mode: Mode,result: BatchResult<Schema,M,A,F>) -> CheckedApply<Schema,M,A,F,L,Mode>:
  match result:
    case Completed{rows,changes}: Applied{S.World{namespace,next,rows,[],ledger,mode},changes}
    case BatchFault{rows,row,remaining,changes}: InvariantFault{S.World{namespace,next,rows,List.reverse(&1,S.Command<M,A,F>,remaining),ledger,mode},row,changes}
def preflight_world(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,+namespace: U32,next: U32,ledger: Maybe<L>,mode: Mode,tick: U32,result: Preflight<M,A,F>) -> CheckedApply<Schema,M,A,F,L,Mode>:
  match result:
    case Preflight{rows,pending,False{}}: CapacityRejected{S.World{namespace,next,rows,pending,ledger,mode}}
    case Preflight{rows,pending,True{}}: batch_world(Schema,M,A,F,L,Mode,namespace,next,ledger,mode,batch(Schema,M,A,F,List.reverse(&1,S.Command<M,A,F>,pending),namespace,tick,Running{rows,[]}))
def apply_checked(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,world: S.World<Schema,M,A,F,L,Mode>,tick: U32) -> CheckedApply<Schema,M,A,F,L,Mode>:
  match world:
    case S.World{namespace,next,rows,pending,ledger,mode}: preflight_world(Schema,M,A,F,L,Mode,namespace,next,ledger,mode,tick,preflight(M,A,F,pending,rows))

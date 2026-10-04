import Base
import ./types.bend as T
import ./storage.bend as S

type QueryRow<-Schema: Data,-V: Data,-AV: Data,-F: Data> is Data:
  QueryRow{handle: S.Handle<Schema>, main: V, aux: Maybe<&2,AV>, flag: Maybe<&2,F>}
type RowView<-V: Data,-AV: Data,-F: Data> is Data:
  RowView{id: U32, main: Maybe<&2,V>, aux: Maybe<&2,AV>, flag: Maybe<&2,F>, added: U32, changed: U32}
type BundleView<-V: Data,-AV: Data,-F: Data> is Data:
  BundleView{main: Maybe<&2,V>, aux: Maybe<&2,AV>, flag: Maybe<&2,F>}
type PendingView<-V: Data,-AV: Data,-F: Data> is Data:
  SpawnView{id: U32, bundle: BundleView<V,AV,F>}
  MainView{id: U32, main: V}
  FlagView{id: U32, flag: F}
  RemoveMainView{id: U32}
  RemoveFlagView{id: U32}
  DespawnView{id: U32}
type WorldView<-V: Data,-AV: Data,-F: Data,-LV: Data,-Mode: Data> is Data:
  WorldView{namespace: U32, next: U32, rows: List<&2,RowView<V,AV,F>>, pending: List<&2,PendingView<V,AV,F>>, ledger: Maybe<&2,LV>, mode: Mode}

def client_aux(-Schema: Data,-P: Type,-U: Type,-V: Data,-AV: Data,-F: Data,
  handle: S.Handle<Schema>,flag: Maybe<&2,F>,owner: P,main: V,result: U & Maybe<&2,AV>) -> P & (U & QueryRow<Schema,V,AV,F>):
  match result:
    case (aux,value): (owner,(aux,QueryRow{handle,main,value,flag}))
def client_main(-Schema: Data,-P: Type,-U: Type,-V: Data,-AV: Data,-F: Data,
  aux_get: U -> U & Maybe<&2,AV>,handle: S.Handle<Schema>,flag: Maybe<&2,F>,aux: U,result: P & V) -> P & (U & QueryRow<Schema,V,AV,F>):
  match result:
    case (owner,value): client_aux(Schema,P,U,V,AV,F,handle,flag,owner,value,aux_get(aux))
def client(~Schema: Data,~Tok: Data,~V: Data,~AV: Data,~F: Data,~token: Tok,
  -P: Type,-U: Type,main_get: P -> Tok -> P & V,aux_get: U -> U & Maybe<&2,AV>,
  handle: S.Handle<Schema>,flag: Maybe<&2,F>,main: P,aux: U) -> P & (U & QueryRow<Schema,V,AV,F>):
  client_main(Schema,P,U,V,AV,F,aux_get,handle,flag,aux,main_get(main,token))

def maybe_present(-Owner: Type,-View: Data,result: Owner & View) -> Maybe<Owner> & Maybe<&2,View>:
  match result:
    case (owner,value): (Some{owner},Some{value})
def maybe_get(~Owner: Type,~View: Data,~get: Owner -> Owner & View,owner: Maybe<Owner>) -> Maybe<Owner> & Maybe<&2,View>:
  match owner:
    case None{}: (None{},None{})
    case Some{owner}: maybe_present(Owner,View,get(owner))

def row_aux(-M: Type,-A: Type,-F: Data,-V: Data,-AV: Data,+id: U32,
  main: Maybe<M>,mainView: Maybe<&2,V>,+flag: Maybe<&2,F>,+added: U32,+changed: U32,
  result: Maybe<A> & Maybe<&2,AV>) -> S.Row<M,A,F> & RowView<V,AV,F>:
  match result:
    case (aux,auxView): (S.Row{id,main,aux,flag,added,changed},RowView{id,mainView,auxView,flag,added,changed})
def row_main(~M: Type,~A: Type,~F: Data,~V: Data,~AV: Data,~aux_get: A -> A & AV,
  id: U32,aux: Maybe<A>,flag: Maybe<&2,F>,added: U32,changed: U32,
  result: Maybe<M> & Maybe<&2,V>) -> S.Row<M,A,F> & RowView<V,AV,F>:
  match result:
    case (main,value): row_aux(M,A,F,V,AV,id,main,value,flag,added,changed,maybe_get(~A,~AV,~aux_get,aux))
def row(~M: Type,~A: Type,~F: Data,~V: Data,~AV: Data,~main_get: M -> M & V,~aux_get: A -> A & AV,
  owner: S.Row<M,A,F>) -> S.Row<M,A,F> & RowView<V,AV,F>:
  match owner:
    case S.Row{id,main,aux,flag,added,changed}:
      row_main(~M,~A,~F,~V,~AV,~aux_get,id,aux,flag,added,changed,maybe_get(~M,~V,~main_get,main))
def rows_tail(-M: Type,-A: Type,-F: Data,-V: Data,-AV: Data,
  owner: S.Row<M,A,F>,value: RowView<V,AV,F>,result: List<S.Row<M,A,F>> & List<&2,RowView<V,AV,F>>) -> List<S.Row<M,A,F>> & List<&2,RowView<V,AV,F>>:
  match result:
    case (tail,values): (owner <> tail,value <> values)
def rows_head(-M: Type,-A: Type,-F: Data,-V: Data,-AV: Data,
  head: S.Row<M,A,F> & RowView<V,AV,F>,tail: List<S.Row<M,A,F>> & List<&2,RowView<V,AV,F>>) -> List<S.Row<M,A,F>> & List<&2,RowView<V,AV,F>>:
  match head:
    case (owner,value): rows_tail(M,A,F,V,AV,owner,value,tail)
def rows_finish(-M:Type,-A:Type,-F:Data,-V:Data,-AV:Data,result:List<S.Row<M,A,F>> & List<&2,RowView<V,AV,F>>) -> List<S.Row<M,A,F>> & List<&2,RowView<V,AV,F>>:
  match result:
    case (owners,values): (List.reverse(&1,S.Row<M,A,F>,owners),List.reverse(&2,RowView<V,AV,F>,values))
def rows_go(~M: Type,~A: Type,~F: Data,~V: Data,~AV: Data,~main_get: M -> M & V,~aux_get: A -> A & AV,
  owners: List<S.Row<M,A,F>>,state: List<S.Row<M,A,F>> & List<&2,RowView<V,AV,F>>) -> List<S.Row<M,A,F>> & List<&2,RowView<V,AV,F>>:
  match owners:
    case Nil{}: rows_finish(M,A,F,V,AV,state)
    case Con{head,tail}: rows_go(~M,~A,~F,~V,~AV,~main_get,~aux_get,tail,rows_head(M,A,F,V,AV,row(~M,~A,~F,~V,~AV,~main_get,~aux_get,head),state))
def rows(~M: Type,~A: Type,~F: Data,~V: Data,~AV: Data,~main_get: M -> M & V,~aux_get: A -> A & AV,
  owners: List<S.Row<M,A,F>>) -> List<S.Row<M,A,F>> & List<&2,RowView<V,AV,F>>:
  rows_go(~M,~A,~F,~V,~AV,~main_get,~aux_get,owners,([],[]))

def bundle_aux(-M: Type,-A: Type,-F: Data,-V: Data,-AV: Data,main: Maybe<M>,value: Maybe<&2,V>,+flag: Maybe<&2,F>,result: Maybe<A> & Maybe<&2,AV>) -> S.Bundle<M,A,F> & BundleView<V,AV,F>:
  match result:
    case (aux,auxView): (S.Bundle{main,aux,flag},BundleView{value,auxView,flag})
def bundle_main(~M: Type,~A: Type,~F: Data,~V: Data,~AV: Data,~aux_get: A -> A & AV,
  aux: Maybe<A>,flag: Maybe<&2,F>,result: Maybe<M> & Maybe<&2,V>) -> S.Bundle<M,A,F> & BundleView<V,AV,F>:
  match result:
    case (main,value): bundle_aux(M,A,F,V,AV,main,value,flag,maybe_get(~A,~AV,~aux_get,aux))
def bundle(~M: Type,~A: Type,~F: Data,~V: Data,~AV: Data,~main_get: M -> M & V,~aux_get: A -> A & AV,owner: S.Bundle<M,A,F>) -> S.Bundle<M,A,F> & BundleView<V,AV,F>:
  match owner:
    case S.Bundle{main,aux,flag}: bundle_main(~M,~A,~F,~V,~AV,~aux_get,aux,flag,maybe_get(~M,~V,~main_get,main))
def command_spawn(-M: Type,-A: Type,-F: Data,-V: Data,-AV: Data,+id: U32,result: S.Bundle<M,A,F> & BundleView<V,AV,F>) -> S.Command<M,A,F> & PendingView<V,AV,F>:
  match result:
    case (owner,value): (S.Spawn{id,owner},SpawnView{id,value})
def command_main(-M: Type,-A: Type,-F: Data,-V: Data,-AV: Data,+id: U32,result: M & V) -> S.Command<M,A,F> & PendingView<V,AV,F>:
  match result:
    case (owner,value): (S.InsertMain{id,owner},MainView{id,value})
def command(~M: Type,~A: Type,~F: Data,~V: Data,~AV: Data,~main_get: M -> M & V,~aux_get: A -> A & AV,owner: S.Command<M,A,F>) -> S.Command<M,A,F> & PendingView<V,AV,F>:
  match owner:
    case S.Spawn{id,value}: command_spawn(M,A,F,V,AV,id,bundle(~M,~A,~F,~V,~AV,~main_get,~aux_get,value))
    case S.InsertMain{id,value}: command_main(M,A,F,V,AV,id,main_get(value))
    case S.InsertFlag{+id,+value}: (S.InsertFlag{id,value},FlagView{id,value})
    case S.RemoveMain{+id}: (S.RemoveMain{id},RemoveMainView{id})
    case S.RemoveFlag{+id}: (S.RemoveFlag{id},RemoveFlagView{id})
    case S.Despawn{+id}: (S.Despawn{id},DespawnView{id})
def commands_tail(-M: Type,-A: Type,-F: Data,-V: Data,-AV: Data,
  owner: S.Command<M,A,F>,value: PendingView<V,AV,F>,result: List<S.Command<M,A,F>> & List<&2,PendingView<V,AV,F>>) -> List<S.Command<M,A,F>> & List<&2,PendingView<V,AV,F>>:
  match result:
    case (tail,values): (owner <> tail,value <> values)
def commands_head(-M: Type,-A: Type,-F: Data,-V: Data,-AV: Data,
  head: S.Command<M,A,F> & PendingView<V,AV,F>,tail: List<S.Command<M,A,F>> & List<&2,PendingView<V,AV,F>>) -> List<S.Command<M,A,F>> & List<&2,PendingView<V,AV,F>>:
  match head:
    case (owner,value): commands_tail(M,A,F,V,AV,owner,value,tail)
def commands(~M: Type,~A: Type,~F: Data,~V: Data,~AV: Data,~main_get: M -> M & V,~aux_get: A -> A & AV,
  owners: List<S.Command<M,A,F>>) -> List<S.Command<M,A,F>> & List<&2,PendingView<V,AV,F>>:
  match owners:
    case Nil{}: ([],[])
    case Con{head,tail}: commands_head(M,A,F,V,AV,command(~M,~A,~F,~V,~AV,~main_get,~aux_get,head),commands(~M,~A,~F,~V,~AV,~main_get,~aux_get,tail))

def world_ledger(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,-V: Data,-AV: Data,-LV: Data,
  +namespace: U32,+next: U32,rows: List<S.Row<M,A,F>>,rowViews: List<&2,RowView<V,AV,F>>,
  pending: List<S.Command<M,A,F>>,pendingViews: List<&2,PendingView<V,AV,F>>,+mode: Mode,
  result: Maybe<L> & Maybe<&2,LV>) -> S.World<Schema,M,A,F,L,Mode> & WorldView<V,AV,F,LV,Mode>:
  match result:
    case (ledger,value): (S.World{namespace,next,rows,pending,ledger,mode},WorldView{namespace,next,rowViews,List.reverse(&2,PendingView<V,AV,F>,pendingViews),value,mode})
def world_commands(~Schema: Data,~M: Type,~A: Type,~F: Data,~L: Type,~Mode: Data,~V: Data,~AV: Data,~LV: Data,
  ~ledger_get: L -> L & LV,namespace: U32,next: U32,rows: List<S.Row<M,A,F>>,rowViews: List<&2,RowView<V,AV,F>>,
  ledger: Maybe<L>,mode: Mode,result: List<S.Command<M,A,F>> & List<&2,PendingView<V,AV,F>>) -> S.World<Schema,M,A,F,L,Mode> & WorldView<V,AV,F,LV,Mode>:
  match result:
    case (pending,values): world_ledger(Schema,M,A,F,L,Mode,V,AV,LV,namespace,next,rows,rowViews,pending,values,mode,maybe_get(~L,~LV,~ledger_get,ledger))
def world_rows(~Schema: Data,~M: Type,~A: Type,~F: Data,~L: Type,~Mode: Data,~V: Data,~AV: Data,~LV: Data,
  ~main_get: M -> M & V,~aux_get: A -> A & AV,~ledger_get: L -> L & LV,
  namespace: U32,next: U32,pending: List<S.Command<M,A,F>>,ledger: Maybe<L>,mode: Mode,
  result: List<S.Row<M,A,F>> & List<&2,RowView<V,AV,F>>) -> S.World<Schema,M,A,F,L,Mode> & WorldView<V,AV,F,LV,Mode>:
  match result:
    case (owners,values): world_commands(~Schema,~M,~A,~F,~L,~Mode,~V,~AV,~LV,~ledger_get,namespace,next,owners,values,ledger,mode,commands(~M,~A,~F,~V,~AV,~main_get,~aux_get,pending))
def world(~Schema: Data,~M: Type,~A: Type,~F: Data,~L: Type,~Mode: Data,~V: Data,~AV: Data,~LV: Data,
  ~main_get: M -> M & V,~aux_get: A -> A & AV,~ledger_get: L -> L & LV,
  owner: S.World<Schema,M,A,F,L,Mode>) -> S.World<Schema,M,A,F,L,Mode> & WorldView<V,AV,F,LV,Mode>:
  match owner:
    case S.World{namespace,next,owners,pending,ledger,mode}:
      world_rows(~Schema,~M,~A,~F,~L,~Mode,~V,~AV,~LV,~main_get,~aux_get,~ledger_get,namespace,next,pending,ledger,mode,rows(~M,~A,~F,~V,~AV,~main_get,~aux_get,owners))

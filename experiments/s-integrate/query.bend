import Base
import ./types.bend as T
import ./storage.bend as S

type Selection is Data:
  Required{}
  Present{}
  Absent{}
  Optional{}
def selected(-F: Data,selection: Selection,flag: Maybe<&2,F>) -> Bool:
  match selection flag:
    case Present{} None{}: False{}
    case Absent{} Some{_}: False{}
    case _ _: True{}
def main_read(~M: Type,~Tok: Data,~V: Data,~get: M -> M & V,owner: M,token: Tok) -> M & V:
  get(owner)
def aux_return(-A: Type,-AV: Data,result: A & AV) -> Maybe<A> & Maybe<&2,AV>:
  match result:
    case (owner,value): (Some{owner},Some{value})
def aux_read(~A: Type,~AV: Data,~get: A -> A & AV,owner: Maybe<A>) -> Maybe<A> & Maybe<&2,AV>:
  match owner:
    case None{}: (None{},None{})
    case Some{owner}: aux_return(A,AV,get(owner))
def restored(-M: Type,-A: Type,-F: Data,-O: Data,id: U32,flag: Maybe<&2,F>,added: U32,changed: U32,result: M & (Maybe<A> & O)) -> S.Row<M,A,F> & O:
  match result:
    case (main,(aux,observation)): (S.Row{id,Some{main},aux,flag,added,changed},observation)
# Only this trusted adapter sees the concrete row. Both abstract providers return.
def read_main(~Schema: Data,~M: Type,~A: Type,~F: Data,~Tok: Data,~V: Data,~AV: Data,~O: Data,~main_get: M -> M & V,~aux_get: A -> A & AV,~client: @-P: Type -> @-U: Type -> (P -> Tok -> P & V) -> (U -> U & Maybe<&2,AV>) -> S.Handle<Schema> -> Maybe<&2,F> -> P -> U -> P & (U & O),namespace: U32,+id: U32,main: M,aux: Maybe<A>,+flag: Maybe<&2,F>,added: U32,changed: U32) -> S.Row<M,A,F> & O:
  restored(M,A,F,O,id,flag,added,changed,client(M,Maybe<A>,main_read(~M,~Tok,~V,~main_get),aux_read(~A,~AV,~aux_get),S.Handle{namespace,id},flag,main,aux))
def included(-M: Type,-A: Type,-F: Data,-O: Data,result: S.Row<M,A,F> & O) -> S.Row<M,A,F> & Maybe<&2,O>:
  match result:
    case (row,value): (row,Some{value})
def read_selected(~Schema: Data,~M: Type,~A: Type,~F: Data,~Tok: Data,~V: Data,~AV: Data,~O: Data,~main_get: M -> M & V,~aux_get: A -> A & AV,~client: @-P: Type -> @-U: Type -> (P -> Tok -> P & V) -> (U -> U & Maybe<&2,AV>) -> S.Handle<Schema> -> Maybe<&2,F> -> P -> U -> P & (U & O),include: Bool,namespace: U32,row: S.Row<M,A,F>) -> S.Row<M,A,F> & Maybe<&2,O>:
  match include row:
    case False{} r: (r,None{})
    case True{} S.Row{id,None{},aux,flag,added,changed}: (S.Row{id,None{},aux,flag,added,changed},None{})
    case True{} S.Row{id,Some{main},aux,flag,added,changed}:
      included(M,A,F,O,read_main(~Schema,~M,~A,~F,~Tok,~V,~AV,~O,~main_get,~aux_get,~client,namespace,id,main,aux,flag,added,changed))
def read_row(~Schema: Data,~M: Type,~A: Type,~F: Data,~Tok: Data,~V: Data,~AV: Data,~O: Data,~main_get: M -> M & V,~aux_get: A -> A & AV,~client: @-P: Type -> @-U: Type -> (P -> Tok -> P & V) -> (U -> U & Maybe<&2,AV>) -> S.Handle<Schema> -> Maybe<&2,F> -> P -> U -> P & (U & O),selection: Selection,namespace: U32,row: S.Row<M,A,F>) -> S.Row<M,A,F> & Maybe<&2,O>:
  match row:
    case S.Row{id,main,aux,+flag,added,changed}:
      read_selected(~Schema,~M,~A,~F,~Tok,~V,~AV,~O,~main_get,~aux_get,~client,selected(F,selection,flag),namespace,S.Row{id,main,aux,flag,added,changed})
def join_empty(-M: Type,-A: Type,-F: Data,-O: Data,row: S.Row<M,A,F>,tail: List<S.Row<M,A,F>> & List<&2,O>) -> List<S.Row<M,A,F>> & List<&2,O>:
  match tail:
    case (rows,values): (row <> rows,values)
def join_value(-M: Type,-A: Type,-F: Data,-O: Data,row: S.Row<M,A,F>,value: O,tail: List<S.Row<M,A,F>> & List<&2,O>) -> List<S.Row<M,A,F>> & List<&2,O>:
  match tail:
    case (rows,values): (row <> rows,value <> values)
def row_join(-M: Type,-A: Type,-F: Data,-O: Data,result: S.Row<M,A,F> & Maybe<&2,O>,tail: List<S.Row<M,A,F>> & List<&2,O>) -> List<S.Row<M,A,F>> & List<&2,O>:
  match result:
    case (row,None{}): join_empty(M,A,F,O,row,tail)
    case (row,Some{value}): join_value(M,A,F,O,row,value,tail)
def read_rows_finish(-M:Type,-A:Type,-F:Data,-O:Data,result:List<S.Row<M,A,F>> & List<&2,O>) -> List<S.Row<M,A,F>> & List<&2,O>:
  match result:
    case (rows,values): (List.reverse(&1,S.Row<M,A,F>,rows),List.reverse(&2,O,values))
def read_rows_go(~Schema: Data,~M: Type,~A: Type,~F: Data,~Tok: Data,~V: Data,~AV: Data,~O: Data,~main_get: M -> M & V,~aux_get: A -> A & AV,~client: @-P: Type -> @-U: Type -> (P -> Tok -> P & V) -> (U -> U & Maybe<&2,AV>) -> S.Handle<Schema> -> Maybe<&2,F> -> P -> U -> P & (U & O),rows: List<S.Row<M,A,F>>,+selection: Selection,+namespace: U32,state: List<S.Row<M,A,F>> & List<&2,O>) -> List<S.Row<M,A,F>> & List<&2,O>:
  match rows:
    case Nil{}: read_rows_finish(M,A,F,O,state)
    case Con{row,tail}: read_rows_go(~Schema,~M,~A,~F,~Tok,~V,~AV,~O,~main_get,~aux_get,~client,tail,selection,namespace,row_join(M,A,F,O,read_row(~Schema,~M,~A,~F,~Tok,~V,~AV,~O,~main_get,~aux_get,~client,selection,namespace,row),state))
def read_rows(~Schema: Data,~M: Type,~A: Type,~F: Data,~Tok: Data,~V: Data,~AV: Data,~O: Data,~main_get: M -> M & V,~aux_get: A -> A & AV,~client: @-P: Type -> @-U: Type -> (P -> Tok -> P & V) -> (U -> U & Maybe<&2,AV>) -> S.Handle<Schema> -> Maybe<&2,F> -> P -> U -> P & (U & O),rows: List<S.Row<M,A,F>>,+selection: Selection,+namespace: U32) -> List<S.Row<M,A,F>> & List<&2,O>:
  read_rows_go(~Schema,~M,~A,~F,~Tok,~V,~AV,~O,~main_get,~aux_get,~client,rows,selection,namespace,([],[]))
def each_return(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,-O: Data,namespace: U32,next: U32,pending: List<S.Command<M,A,F>>,ledger: Maybe<L>,mode: Mode,result: List<S.Row<M,A,F>> & List<&2,O>) -> S.World<Schema,M,A,F,L,Mode> & List<&2,O>:
  match result:
    case (rows,observations): (S.World{namespace,next,rows,pending,ledger,mode},observations)
def each(~Schema: Data,~M: Type,~A: Type,~F: Data,~Tok: Data,~V: Data,~AV: Data,~O: Data,~L: Type,~Mode: Data,~main_get: M -> M & V,~aux_get: A -> A & AV,~client: @-P: Type -> @-U: Type -> (P -> Tok -> P & V) -> (U -> U & Maybe<&2,AV>) -> S.Handle<Schema> -> Maybe<&2,F> -> P -> U -> P & (U & O),selection: Selection,world: S.World<Schema,M,A,F,L,Mode>) -> S.World<Schema,M,A,F,L,Mode> & List<&2,O>:
  match world:
    case S.World{+namespace,next,rows,pending,ledger,mode}:
      each_return(Schema,M,A,F,L,Mode,O,namespace,next,pending,ledger,mode,read_rows(~Schema,~M,~A,~F,~Tok,~V,~AV,~O,~main_get,~aux_get,~client,rows,selection,namespace))

# The scan carries each unmatched affine row in a reversed prefix. Once a
# matching owner returns, the untouched suffix joins without recursive unwinding.
type LookupScan<-M: Type,-A: Type,-F: Data,-O: Data> is Type:
  LookupSeeking{before: List<S.Row<M,A,F>>}
  LookupRead{before: List<S.Row<M,A,F>>,row: S.Row<M,A,F>,access: T.Access<O>}
def lookup_read(-M: Type,-A: Type,-F: Data,-O: Data,before: List<S.Row<M,A,F>>,result: S.Row<M,A,F> & Maybe<&2,O>) -> LookupScan<M,A,F,O>:
  match result:
    case (row,None{}): LookupRead{before,row,T.Mismatch{}}
    case (row,Some{value}): LookupRead{before,row,T.Found{value}}
def lookup_decide(~Schema: Data,~M: Type,~A: Type,~F: Data,~Tok: Data,~V: Data,~AV: Data,~O: Data,~main_get: M -> M & V,~aux_get: A -> A & AV,~client: @-P: Type -> @-U: Type -> (P -> Tok -> P & V) -> (U -> U & Maybe<&2,AV>) -> S.Handle<Schema> -> Maybe<&2,F> -> P -> U -> P & (U & O),equal: Bool,selection: Selection,namespace: U32,before: List<S.Row<M,A,F>>,row: S.Row<M,A,F>) -> LookupScan<M,A,F,O>:
  match equal:
    case False{}: LookupSeeking{row <> before}
    case True{}: lookup_read(M,A,F,O,before,read_row(~Schema,~M,~A,~F,~Tok,~V,~AV,~O,~main_get,~aux_get,~client,selection,namespace,row))
def lookup_row(~Schema: Data,~M: Type,~A: Type,~F: Data,~Tok: Data,~V: Data,~AV: Data,~O: Data,~main_get: M -> M & V,~aux_get: A -> A & AV,~client: @-P: Type -> @-U: Type -> (P -> Tok -> P & V) -> (U -> U & Maybe<&2,AV>) -> S.Handle<Schema> -> Maybe<&2,F> -> P -> U -> P & (U & O),selection: Selection,namespace: U32,target: U32,before: List<S.Row<M,A,F>>,row: S.Row<M,A,F>) -> LookupScan<M,A,F,O>:
  match row:
    case S.Row{+id,main,aux,flag,added,changed}:
      lookup_decide(~Schema,~M,~A,~F,~Tok,~V,~AV,~O,~main_get,~aux_get,~client,U32.is_eq(target,id),selection,namespace,before,S.Row{id,main,aux,flag,added,changed})
def lookup_scan(~Schema: Data,~M: Type,~A: Type,~F: Data,~Tok: Data,~V: Data,~AV: Data,~O: Data,~main_get: M -> M & V,~aux_get: A -> A & AV,~client: @-P: Type -> @-U: Type -> (P -> Tok -> P & V) -> (U -> U & Maybe<&2,AV>) -> S.Handle<Schema> -> Maybe<&2,F> -> P -> U -> P & (U & O),rows: List<S.Row<M,A,F>>,+selection: Selection,+namespace: U32,+target: U32,state: LookupScan<M,A,F,O>) -> List<S.Row<M,A,F>> & T.Access<O>:
  match rows state:
    case tail LookupRead{before,row,access}: (List.reverse.go(&1,S.Row<M,A,F>,before,row <> tail),access)
    case Nil{} LookupSeeking{before}: (List.reverse(&1,S.Row<M,A,F>,before),T.Missing{})
    case Con{row,tail} LookupSeeking{before}:
      lookup_scan(~Schema,~M,~A,~F,~Tok,~V,~AV,~O,~main_get,~aux_get,~client,tail,selection,namespace,target,lookup_row(~Schema,~M,~A,~F,~Tok,~V,~AV,~O,~main_get,~aux_get,~client,selection,namespace,target,before,row))
def lookup_rows(~Schema: Data,~M: Type,~A: Type,~F: Data,~Tok: Data,~V: Data,~AV: Data,~O: Data,~main_get: M -> M & V,~aux_get: A -> A & AV,~client: @-P: Type -> @-U: Type -> (P -> Tok -> P & V) -> (U -> U & Maybe<&2,AV>) -> S.Handle<Schema> -> Maybe<&2,F> -> P -> U -> P & (U & O),rows: List<S.Row<M,A,F>>,selection: Selection,namespace: U32,target: U32) -> List<S.Row<M,A,F>> & T.Access<O>:
  lookup_scan(~Schema,~M,~A,~F,~Tok,~V,~AV,~O,~main_get,~aux_get,~client,rows,selection,namespace,target,LookupSeeking{[]})
def lookup_return(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,-O: Data,namespace: U32,next: U32,pending: List<S.Command<M,A,F>>,ledger: Maybe<L>,mode: Mode,result: List<S.Row<M,A,F>> & T.Access<O>) -> S.World<Schema,M,A,F,L,Mode> & T.Access<O>:
  match result:
    case (rows,observation): (S.World{namespace,next,rows,pending,ledger,mode},observation)
def lookup_checked(~Schema: Data,~M: Type,~A: Type,~F: Data,~Tok: Data,~V: Data,~AV: Data,~O: Data,~L: Type,~Mode: Data,~main_get: M -> M & V,~aux_get: A -> A & AV,~client: @-P: Type -> @-U: Type -> (P -> Tok -> P & V) -> (U -> U & Maybe<&2,AV>) -> S.Handle<Schema> -> Maybe<&2,F> -> P -> U -> P & (U & O),valid: Bool,selection: Selection,world: S.World<Schema,M,A,F,L,Mode>,target: U32) -> S.World<Schema,M,A,F,L,Mode> & T.Access<O>:
  match valid world:
    case False{} w: (w,T.Missing{})
    case True{} S.World{+namespace,next,rows,pending,ledger,mode}:
      lookup_return(Schema,M,A,F,L,Mode,O,namespace,next,pending,ledger,mode,lookup_rows(~Schema,~M,~A,~F,~Tok,~V,~AV,~O,~main_get,~aux_get,~client,rows,selection,namespace,target))
def lookup(~Schema: Data,~M: Type,~A: Type,~F: Data,~Tok: Data,~V: Data,~AV: Data,~O: Data,~L: Type,~Mode: Data,~main_get: M -> M & V,~aux_get: A -> A & AV,~client: @-P: Type -> @-U: Type -> (P -> Tok -> P & V) -> (U -> U & Maybe<&2,AV>) -> S.Handle<Schema> -> Maybe<&2,F> -> P -> U -> P & (U & O),selection: Selection,world: S.World<Schema,M,A,F,L,Mode>,handle: S.Handle<Schema>) -> S.World<Schema,M,A,F,L,Mode> & T.Access<O>:
  match world handle:
    case S.World{+namespace,next,rows,pending,ledger,mode} S.Handle{foreign,target}:
      lookup_checked(~Schema,~M,~A,~F,~Tok,~V,~AV,~O,~L,~Mode,~main_get,~aux_get,~client,U32.is_eq(namespace,foreign),selection,S.World{namespace,next,rows,pending,ledger,mode},target)

import Base
import ./cache.bend as CC
import ./cached-payload.bend as CP
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
# Indexed traversal restores every affine row before visiting the next logical ID.
def read_rows_step(-M: Type,-A: Type,-F: Data,-O: Data,owners: S.Rows<M,A,F>,result: S.Row<M,A,F> & Maybe<&2,O>,values: List<&2,O>) -> S.Rows<M,A,F> & List<&2,O>:
  match result:
    case (owner,None{}): (S.rows_restore(M,A,F,owners,owner),values)
    case (owner,Some{value}): (S.rows_restore(M,A,F,owners,owner),value <> values)
def read_rows_slot(~Schema: Data,~M: Type,~A: Type,~F: Data,~Tok: Data,~V: Data,~AV: Data,~O: Data,~main_get: M -> M & V,~aux_get: A -> A & AV,~client: @-P: Type -> @-U: Type -> (P -> Tok -> P & V) -> (U -> U & Maybe<&2,AV>) -> S.Handle<Schema> -> Maybe<&2,F> -> P -> U -> P & (U & O),selection: Selection,namespace: U32,result: S.Rows<M,A,F> & Maybe<S.Row<M,A,F>>,values: List<&2,O>) -> S.Rows<M,A,F> & List<&2,O>:
  match result:
    case (owners,None{}): (owners,values)
    case (owners,Some{owner}): read_rows_step(M,A,F,O,owners,read_row(~Schema,~M,~A,~F,~Tok,~V,~AV,~O,~main_get,~aux_get,~client,selection,namespace,owner),values)
def read_rows_finish(-M: Type,-A: Type,-F: Data,-O: Data,state: S.Rows<M,A,F> & List<&2,O>) -> S.Rows<M,A,F> & List<&2,O>:
  match state:
    case (owners,values): (owners,List.reverse(&2,O,values))
def read_rows_advance(~Schema: Data,~M: Type,~A: Type,~F: Data,~Tok: Data,~V: Data,~AV: Data,~O: Data,~main_get: M -> M & V,~aux_get: A -> A & AV,~client: @-P: Type -> @-U: Type -> (P -> Tok -> P & V) -> (U -> U & Maybe<&2,AV>) -> S.Handle<Schema> -> Maybe<&2,F> -> P -> U -> P & (U & O),id: U32,selection: Selection,namespace: U32,state: S.Rows<M,A,F> & List<&2,O>) -> S.Rows<M,A,F> & List<&2,O>:
  match state:
    case (owners,values): read_rows_slot(~Schema,~M,~A,~F,~Tok,~V,~AV,~O,~main_get,~aux_get,~client,selection,namespace,S.rows_extract(M,A,F,owners,id),values)
def read_rows_go(~Schema: Data,~M: Type,~A: Type,~F: Data,~Tok: Data,~V: Data,~AV: Data,~O: Data,~main_get: M -> M & V,~aux_get: A -> A & AV,~client: @-P: Type -> @-U: Type -> (P -> Tok -> P & V) -> (U -> U & Maybe<&2,AV>) -> S.Handle<Schema> -> Maybe<&2,F> -> P -> U -> P & (U & O),remaining: Nat,+id: U32,+selection: Selection,+namespace: U32,state: S.Rows<M,A,F> & List<&2,O>) -> S.Rows<M,A,F> & List<&2,O>:
  match remaining:
    case 0n: read_rows_finish(M,A,F,O,state)
    case 1n++remaining: read_rows_go(~Schema,~M,~A,~F,~Tok,~V,~AV,~O,~main_get,~aux_get,~client,remaining,U32.add(id,1),selection,namespace,read_rows_advance(~Schema,~M,~A,~F,~Tok,~V,~AV,~O,~main_get,~aux_get,~client,id,selection,namespace,state))
def read_rows_start(~Schema: Data,~M: Type,~A: Type,~F: Data,~Tok: Data,~V: Data,~AV: Data,~O: Data,~main_get: M -> M & V,~aux_get: A -> A & AV,~client: @-P: Type -> @-U: Type -> (P -> Tok -> P & V) -> (U -> U & Maybe<&2,AV>) -> S.Handle<Schema> -> Maybe<&2,F> -> P -> U -> P & (U & O),selection: Selection,namespace: U32,result: S.Rows<M,A,F> & U32) -> S.Rows<M,A,F> & List<&2,O>:
  match result:
    case (owners,high): read_rows_go(~Schema,~M,~A,~F,~Tok,~V,~AV,~O,~main_get,~aux_get,~client,U32.to_nat(high),1,selection,namespace,(owners,[]))
# Fused indexed traversal: physical metadata remains unchanged by read callbacks.
# Original per-ID capacity guards remain. Metadata columns must have aligned depths;
# rows_empty/grow preserve this invariant. Public malformed constructors are not validated.
type StructIdxState<-M: Type,-A: Type,-F: Data,-O: Data> is Type:
  StructIdxState{main: Array<Maybe<M>>,aux: Array<Maybe<A>>,metadata: S.MetadataColumns<F>,values: List<&2,O>}
def struct_idx_return(-M: Type,-A: Type,-F: Data,-O: Data,+index: U32,main: Array<Maybe<M>>,aux: Array<Maybe<A>>,metadata: S.MetadataColumns<F>,values: List<&2,O>,result: M & (Maybe<A> & O)) -> StructIdxState<M,A,F,O>:
  match result:
    case (m,(a,value)): StructIdxState{Array.set(Maybe<M>,main,index,Some{m}),Array.set(Maybe<A>,aux,index,a),metadata,value <> values}
def struct_idx_aux(~Schema: Data,~M: Type,~A: Type,~F: Data,~Tok: Data,~V: Data,~AV: Data,~O: Data,~main_get: M -> M & V,~aux_get: A -> A & AV,~client: @-P: Type -> @-U: Type -> (P -> Tok -> P & V) -> (U -> U & Maybe<&2,AV>) -> S.Handle<Schema> -> Maybe<&2,F> -> P -> U -> P & (U & O),+id: U32,namespace: U32,main: Array<Maybe<M>>,owner: M,metadata: S.MetadataColumns<F>,values: List<&2,O>,flag: Maybe<&2,F>,result: Array<Maybe<A>> & Maybe<A>) -> StructIdxState<M,A,F,O>:
  match result:
    case (aux,a): struct_idx_return(M,A,F,O,U32.sub(id,1),main,aux,metadata,values,client(M,Maybe<A>,main_read(~M,~Tok,~V,~main_get),aux_read(~A,~AV,~aux_get),S.Handle{namespace,id},flag,owner,a))
def struct_idx_main(~Schema: Data,~M: Type,~A: Type,~F: Data,~Tok: Data,~V: Data,~AV: Data,~O: Data,~main_get: M -> M & V,~aux_get: A -> A & AV,~client: @-P: Type -> @-U: Type -> (P -> Tok -> P & V) -> (U -> U & Maybe<&2,AV>) -> S.Handle<Schema> -> Maybe<&2,F> -> P -> U -> P & (U & O),+id: U32,namespace: U32,aux: Array<Maybe<A>>,metadata: S.MetadataColumns<F>,values: List<&2,O>,flag: Maybe<&2,F>,result: Array<Maybe<M>> & Maybe<M>) -> StructIdxState<M,A,F,O>:
  match result:
    case (main,None{}): StructIdxState{main,aux,metadata,values}
    case (main,Some{owner}): struct_idx_aux(~Schema,~M,~A,~F,~Tok,~V,~AV,~O,~main_get,~aux_get,~client,id,namespace,main,owner,metadata,values,flag,Array.swap(Maybe<A>,aux,U32.sub(id,1),None{}))
def struct_idx_selected(~Schema: Data,~M: Type,~A: Type,~F: Data,~Tok: Data,~V: Data,~AV: Data,~O: Data,~main_get: M -> M & V,~aux_get: A -> A & AV,~client: @-P: Type -> @-U: Type -> (P -> Tok -> P & V) -> (U -> U & Maybe<&2,AV>) -> S.Handle<Schema> -> Maybe<&2,F> -> P -> U -> P & (U & O),include: Bool,+id: U32,namespace: U32,main: Array<Maybe<M>>,aux: Array<Maybe<A>>,metadata: S.MetadataColumns<F>,values: List<&2,O>,flag: Maybe<&2,F>) -> StructIdxState<M,A,F,O>:
  match include:
    case False{}: StructIdxState{main,aux,metadata,values}
    case True{}: struct_idx_main(~Schema,~M,~A,~F,~Tok,~V,~AV,~O,~main_get,~aux_get,~client,id,namespace,aux,metadata,values,flag,Array.swap(Maybe<M>,main,U32.sub(id,1),None{}))
def struct_idx_metadata(~Schema: Data,~M: Type,~A: Type,~F: Data,~Tok: Data,~V: Data,~AV: Data,~O: Data,~main_get: M -> M & V,~aux_get: A -> A & AV,~client: @-P: Type -> @-U: Type -> (P -> Tok -> P & V) -> (U -> U & Maybe<&2,AV>) -> S.Handle<Schema> -> Maybe<&2,F> -> P -> U -> P & (U & O),id: U32,namespace: U32,selection: Selection,main: Array<Maybe<M>>,aux: Array<Maybe<A>>,values: List<&2,O>,result: S.MetadataColumns<F> & S.Membership<F>) -> StructIdxState<M,A,F,O>:
  match result:
    case (metadata,S.Membership{False{},_}): StructIdxState{main,aux,metadata,values}
    case (metadata,S.Membership{True{},+flag}): struct_idx_selected(~Schema,~M,~A,~F,~Tok,~V,~AV,~O,~main_get,~aux_get,~client,selected(F,selection,flag),id,namespace,main,aux,metadata,values,flag)
def struct_idx_advance(~Schema: Data,~M: Type,~A: Type,~F: Data,~Tok: Data,~V: Data,~AV: Data,~O: Data,~main_get: M -> M & V,~aux_get: A -> A & AV,~client: @-P: Type -> @-U: Type -> (P -> Tok -> P & V) -> (U -> U & Maybe<&2,AV>) -> S.Handle<Schema> -> Maybe<&2,F> -> P -> U -> P & (U & O),valid: Bool,+id: U32,namespace: U32,selection: Selection,state: StructIdxState<M,A,F,O>) -> StructIdxState<M,A,F,O>:
  match valid state:
    case False{} state: state
    case True{} StructIdxState{main,aux,metadata,values}:
      struct_idx_metadata(~Schema,~M,~A,~F,~Tok,~V,~AV,~O,~main_get,~aux_get,~client,id,namespace,selection,main,aux,values,S.metadata_membership(F,metadata,U32.sub(id,1)))
def struct_idx_finish(-M: Type,-A: Type,-F: Data,-O: Data,capacity: U32,depth: Nat,high: U32,state: StructIdxState<M,A,F,O>) -> S.Rows<M,A,F> & List<&2,O>:
  match state:
    case StructIdxState{main,aux,metadata,values}: (S.Rows{main,aux,metadata,capacity,depth,high},List.reverse(&2,O,values))
def struct_idx_go(~Schema: Data,~M: Type,~A: Type,~F: Data,~Tok: Data,~V: Data,~AV: Data,~O: Data,~main_get: M -> M & V,~aux_get: A -> A & AV,~client: @-P: Type -> @-U: Type -> (P -> Tok -> P & V) -> (U -> U & Maybe<&2,AV>) -> S.Handle<Schema> -> Maybe<&2,F> -> P -> U -> P & (U & O),remaining: Nat,+id: U32,+capacity: U32,+depth: Nat,+high: U32,+selection: Selection,+namespace: U32,state: StructIdxState<M,A,F,O>) -> S.Rows<M,A,F> & List<&2,O>:
  match remaining:
    case 0n: struct_idx_finish(M,A,F,O,capacity,depth,high,state)
    case 1n++rest: struct_idx_go(~Schema,~M,~A,~F,~Tok,~V,~AV,~O,~main_get,~aux_get,~client,rest,U32.add(id,1),capacity,depth,high,selection,namespace,struct_idx_advance(~Schema,~M,~A,~F,~Tok,~V,~AV,~O,~main_get,~aux_get,~client,Bool.and((0 < id : U32),(id <= capacity : U32)),id,namespace,selection,state))
def read_rows(~Schema: Data,~M: Type,~A: Type,~F: Data,~Tok: Data,~V: Data,~AV: Data,~O: Data,~main_get: M -> M & V,~aux_get: A -> A & AV,~client: @-P: Type -> @-U: Type -> (P -> Tok -> P & V) -> (U -> U & Maybe<&2,AV>) -> S.Handle<Schema> -> Maybe<&2,F> -> P -> U -> P & (U & O),rows: S.Rows<M,A,F>,selection: Selection,namespace: U32) -> S.Rows<M,A,F> & List<&2,O>:
  match rows:
    case S.Rows{main,aux,metadata,capacity,depth,+high}:
      struct_idx_go(~Schema,~M,~A,~F,~Tok,~V,~AV,~O,~main_get,~aux_get,~client,U32.to_nat(high),1,capacity,depth,high,selection,namespace,StructIdxState{main,aux,metadata,[]})
def each_return(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,-O: Data,namespace: U32,next: U32,pending: List<S.Command<M,A,F>>,ledger: Maybe<L>,mode: Mode,result: S.Rows<M,A,F> & List<&2,O>) -> S.World<Schema,M,A,F,L,Mode> & List<&2,O>:
  match result:
    case (rows,observations): (S.World{namespace,next,rows,pending,ledger,mode},observations)
def each(~Schema: Data,~M: Type,~A: Type,~F: Data,~Tok: Data,~V: Data,~AV: Data,~O: Data,~L: Type,~Mode: Data,~main_get: M -> M & V,~aux_get: A -> A & AV,~client: @-P: Type -> @-U: Type -> (P -> Tok -> P & V) -> (U -> U & Maybe<&2,AV>) -> S.Handle<Schema> -> Maybe<&2,F> -> P -> U -> P & (U & O),selection: Selection,world: S.World<Schema,M,A,F,L,Mode>) -> S.World<Schema,M,A,F,L,Mode> & List<&2,O>:
  match world:
    case S.World{+namespace,next,rows,pending,ledger,mode}:
      each_return(Schema,M,A,F,L,Mode,O,namespace,next,pending,ledger,mode,read_rows(~Schema,~M,~A,~F,~Tok,~V,~AV,~O,~main_get,~aux_get,~client,rows,selection,namespace))

# Lookup extracts one indexed slot, independently of the live population.
def lookup_read(-M: Type,-A: Type,-F: Data,-O: Data,owners: S.Rows<M,A,F>,result: S.Row<M,A,F> & Maybe<&2,O>) -> S.Rows<M,A,F> & T.Access<O>:
  match result:
    case (owner,None{}): (S.rows_restore(M,A,F,owners,owner),T.Mismatch{})
    case (owner,Some{value}): (S.rows_restore(M,A,F,owners,owner),T.Found{value})
def lookup_slot(~Schema: Data,~M: Type,~A: Type,~F: Data,~Tok: Data,~V: Data,~AV: Data,~O: Data,~main_get: M -> M & V,~aux_get: A -> A & AV,~client: @-P: Type -> @-U: Type -> (P -> Tok -> P & V) -> (U -> U & Maybe<&2,AV>) -> S.Handle<Schema> -> Maybe<&2,F> -> P -> U -> P & (U & O),selection: Selection,namespace: U32,result: S.Rows<M,A,F> & Maybe<S.Row<M,A,F>>) -> S.Rows<M,A,F> & T.Access<O>:
  match result:
    case (owners,None{}): (owners,T.Missing{})
    case (owners,Some{owner}): lookup_read(M,A,F,O,owners,read_row(~Schema,~M,~A,~F,~Tok,~V,~AV,~O,~main_get,~aux_get,~client,selection,namespace,owner))
def lookup_rows(~Schema: Data,~M: Type,~A: Type,~F: Data,~Tok: Data,~V: Data,~AV: Data,~O: Data,~main_get: M -> M & V,~aux_get: A -> A & AV,~client: @-P: Type -> @-U: Type -> (P -> Tok -> P & V) -> (U -> U & Maybe<&2,AV>) -> S.Handle<Schema> -> Maybe<&2,F> -> P -> U -> P & (U & O),rows: S.Rows<M,A,F>,selection: Selection,namespace: U32,target: U32) -> S.Rows<M,A,F> & T.Access<O>:
  lookup_slot(~Schema,~M,~A,~F,~Tok,~V,~AV,~O,~main_get,~aux_get,~client,selection,namespace,S.rows_extract(M,A,F,rows,target))
def lookup_return(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,-O: Data,namespace: U32,next: U32,pending: List<S.Command<M,A,F>>,ledger: Maybe<L>,mode: Mode,result: S.Rows<M,A,F> & T.Access<O>) -> S.World<Schema,M,A,F,L,Mode> & T.Access<O>:
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

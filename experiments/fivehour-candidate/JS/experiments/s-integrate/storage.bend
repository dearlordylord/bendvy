import Base
import ./cache.bend as CC
import ./cached-payload.bend as CP
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
type Metadata<-F: Data> is Data:
  Metadata{live: Bool, flag: Maybe<&2,F>, added: U32, changed: U32}
# Affine metadata transport: primitive leaves remain inline in each aligned array.
# Trusted lifecycle helpers preserve equal depths. Public detached constructors
# can violate alignment; arbitrary malformed shapes are outside this probe.
type MetadataColumns<-F: Data> is Type:
  MetadataColumns{live: Array<Bool>, flags: Array<Maybe<&2,F>>, added: Array<U32>, changed: Array<U32>}
def metadata_empty(-F: Data,+depth: Nat) -> MetadataColumns<F>:
  MetadataColumns{[False{} : Bool^depth],[None{} : Maybe<&2,F>^depth],[0 : U32^depth],[0 : U32^depth]}
def metadata_grow(-F: Data,columns: MetadataColumns<F>,+depth: Nat) -> MetadataColumns<F>:
  match columns:
    case MetadataColumns{live,flags,added,changed}: MetadataColumns{ANode{live,[False{} : Bool^depth]},ANode{flags,[None{} : Maybe<&2,F>^depth]},ANode{added,[0 : U32^depth]},ANode{changed,[0 : U32^depth]}}
def metadata_get_changed(-F: Data,live: Array<Bool>,flags: Array<Maybe<&2,F>>,added: Array<U32>,l: Bool,f: Maybe<&2,F>,a: U32,result: Array<U32> & U32) -> MetadataColumns<F> & Metadata<F>:
  match result:
    case (changed,c): (MetadataColumns{live,flags,added,changed},Metadata{l,f,a,c})
def metadata_get_added(-F: Data,live: Array<Bool>,flags: Array<Maybe<&2,F>>,changed: Array<U32>,index: U32,l: Bool,f: Maybe<&2,F>,result: Array<U32> & U32) -> MetadataColumns<F> & Metadata<F>:
  match result:
    case (added,a): metadata_get_changed(F,live,flags,added,l,f,a,Array.get(U32,changed,index))
def metadata_get_flags(-F: Data,live: Array<Bool>,added: Array<U32>,changed: Array<U32>,+index: U32,l: Bool,result: Array<Maybe<&2,F>> & Maybe<&2,F>) -> MetadataColumns<F> & Metadata<F>:
  match result:
    case (flags,f): metadata_get_added(F,live,flags,changed,index,l,f,Array.get(U32,added,index))
def metadata_get_live(-F: Data,flags: Array<Maybe<&2,F>>,added: Array<U32>,changed: Array<U32>,+index: U32,result: Array<Bool> & Bool) -> MetadataColumns<F> & Metadata<F>:
  match result:
    case (live,l): metadata_get_flags(F,live,added,changed,index,l,Array.get(Maybe<&2,F>,flags,index))
def metadata_get(-F: Data,columns: MetadataColumns<F>,+index: U32) -> MetadataColumns<F> & Metadata<F>:
  match columns:
    case MetadataColumns{live,flags,added,changed}: metadata_get_live(F,flags,added,changed,index,Array.get(Bool,live,index))
# Query selection observes membership/flag only; stamps remain owned and untouched.
type Membership<-F: Data> is Data:
  Membership{live: Bool, flag: Maybe<&2,F>}
def metadata_membership_flags(-F: Data,live: Array<Bool>,added: Array<U32>,changed: Array<U32>,value: Bool,result: Array<Maybe<&2,F>> & Maybe<&2,F>) -> MetadataColumns<F> & Membership<F>:
  match result:
    case (flags,flag): (MetadataColumns{live,flags,added,changed},Membership{value,flag})
def metadata_membership_live(-F: Data,flags: Array<Maybe<&2,F>>,added: Array<U32>,changed: Array<U32>,index: U32,result: Array<Bool> & Bool) -> MetadataColumns<F> & Membership<F>:
  match result:
    case (live,value): metadata_membership_flags(F,live,added,changed,value,Array.get(Maybe<&2,F>,flags,index))
def metadata_membership(-F: Data,columns: MetadataColumns<F>,+index: U32) -> MetadataColumns<F> & Membership<F>:
  match columns:
    case MetadataColumns{live,flags,added,changed}: metadata_membership_live(F,flags,added,changed,index,Array.get(Bool,live,index))
def metadata_live_done(-F: Data,flags: Array<Maybe<&2,F>>,added: Array<U32>,changed: Array<U32>,result: Array<Bool> & Bool) -> MetadataColumns<F> & Bool:
  match result:
    case (live,value): (MetadataColumns{live,flags,added,changed},value)
def metadata_live(-F: Data,columns: MetadataColumns<F>,index: U32) -> MetadataColumns<F> & Bool:
  match columns:
    case MetadataColumns{live,flags,added,changed}: metadata_live_done(F,flags,added,changed,Array.get(Bool,live,index))
def metadata_mark(-F: Data,columns: MetadataColumns<F>,index: U32,tick: U32) -> MetadataColumns<F>:
  match columns:
    case MetadataColumns{live,flags,added,changed}: MetadataColumns{live,flags,added,Array.set(U32,changed,index,tick)}
def metadata_set(-F: Data,columns: MetadataColumns<F>,+index: U32,meta: Metadata<F>) -> MetadataColumns<F>:
  match columns meta:
    case MetadataColumns{live,flags,added,changed} Metadata{l,f,a,c}: MetadataColumns{Array.set(Bool,live,index,l),Array.set(Maybe<&2,F>,flags,index,f),Array.set(U32,added,index,a),Array.set(U32,changed,index,c)}
type Rows<-M: Type,-A: Type,-F: Data> is Type:
  Rows{main: Array<Maybe<M>>, aux: Array<Maybe<A>>, metadata: MetadataColumns<F>, capacity: U32, depth: Nat, high_water: U32}
type Placement<-M: Type,-A: Type,-F: Data> is Type:
  Placed{rows: Rows<M,A,F>}
  Rejected{rows: Rows<M,A,F>, row: Row<M,A,F>}
type World<-S: Data, -M: Type, -A: Type, -F: Data, -L: Type, -Mode: Data> is Type:
  World{namespace: U32, next: U32, rows: Rows<M,A,F>,
    pending: List<Command<M,A,F>>, ledger: Maybe<L>, mode: Mode}
type Taken<-M: Type> is Type:
  Taken{main: M}
  NoMain{}
  NoEntity{}

# Supported finite domain: IDs 1..131072, balanced capacities 1..131072.
# All index arithmetic follows an explicit nonzero/in-capacity guard.
def slots_empty(-P: Type,+depth: Nat) -> Array<Maybe<P>>:
  match depth:
    case 0n: ALeaf{None{}}
    case 1n+d: ANode{slots_empty(P,d),slots_empty(P,d)}
def rows_empty(-M: Type,-A: Type,-F: Data) -> Rows<M,A,F>:
  Rows{ALeaf{None{}},ALeaf{None{}},metadata_empty(F,0n),1,0n,0}
def rows_high_water(-M: Type,-A: Type,-F: Data,rows: Rows<M,A,F>) -> Rows<M,A,F> & U32:
  match rows:
    case Rows{m,a,f,c,d,+h}: (Rows{m,a,f,c,d,h},h)
def rows_can_place(-M: Type,-A: Type,-F: Data,rows: Rows<M,A,F>,+id: U32) -> Rows<M,A,F> & Bool:
  (rows,Bool.and((0 < id : U32),(id <= 131072 : U32)))
def grow_decide(-M: Type,-A: Type,-F: Data,needed: Bool,rows: Rows<M,A,F>,recurse: Rows<M,A,F> -> Rows<M,A,F>) -> Rows<M,A,F>:
  match needed rows:
    case False{} rows: rows
    case True{} Rows{m,a,f,+c,+d,h}:
      recurse(Rows{ANode{m,slots_empty(M,d)},ANode{a,slots_empty(A,d)},metadata_grow(F,f,d),U32.add(c,c),1n+d,h})
def grow(fuel: Nat,-M: Type,-A: Type,-F: Data,+id: U32,rows: Rows<M,A,F>) -> Rows<M,A,F>:
  match fuel rows:
    case 0n rows: rows
    case 1n+n Rows{m,a,f,+c,d,h}: grow_decide(M,A,F,Bool.and((c < id : U32),(c <= 65536 : U32)),Rows{m,a,f,c,d,h},(grown => grow(n,M,A,F,id,grown)))
def extract_row(-M: Type,-A: Type,-F: Data,id: U32,main: Array<Maybe<M>>,value: Maybe<M>,aux: Array<Maybe<A>>,av: Maybe<A>,metadata: MetadataColumns<F>,capacity: U32,depth: Nat,high: U32,meta: Metadata<F>) -> Rows<M,A,F> & Maybe<Row<M,A,F>>:
  match meta:
    case Metadata{_,flag,added,changed}: (Rows{main,aux,metadata,capacity,depth,high},Some{Row{id,value,av,flag,added,changed}})
def extract_aux(-M: Type,-A: Type,-F: Data,id: U32,main: Array<Maybe<M>>,value: Maybe<M>,metadata: MetadataColumns<F>,capacity: U32,depth: Nat,high: U32,meta: Metadata<F>,result: Array<Maybe<A>> & Maybe<A>) -> Rows<M,A,F> & Maybe<Row<M,A,F>>:
  match result:
    case (aux,av): extract_row(M,A,F,id,main,value,aux,av,metadata,capacity,depth,high,meta)
def extract_main(-M: Type,-A: Type,-F: Data,+id: U32,aux: Array<Maybe<A>>,metadata: MetadataColumns<F>,capacity: U32,depth: Nat,high: U32,meta: Metadata<F>,result: Array<Maybe<M>> & Maybe<M>) -> Rows<M,A,F> & Maybe<Row<M,A,F>>:
  match result:
    case (main,mv): extract_aux(M,A,F,id,main,mv,metadata,capacity,depth,high,meta,Array.swap(Maybe<A>,aux,U32.sub(id,1),None{}))
def extract_meta(-M: Type,-A: Type,-F: Data,+id: U32,main: Array<Maybe<M>>,aux: Array<Maybe<A>>,capacity: U32,depth: Nat,high: U32,result: MetadataColumns<F> & Metadata<F>) -> Rows<M,A,F> & Maybe<Row<M,A,F>>:
  match result:
    case (metadata,Metadata{False{},flag,added,changed}): (Rows{main,aux,metadata,capacity,depth,high},None{})
    case (metadata,Metadata{True{},flag,added,changed}): extract_main(M,A,F,id,aux,metadata,capacity,depth,high,Metadata{True{},flag,added,changed},Array.swap(Maybe<M>,main,U32.sub(id,1),None{}))
def extract_checked(-M: Type,-A: Type,-F: Data,valid: Bool,+id: U32,rows: Rows<M,A,F>) -> Rows<M,A,F> & Maybe<Row<M,A,F>>:
  match valid rows:
    case False{} rows: (rows,None{})
    case True{} Rows{main,aux,metadata,capacity,depth,high}: extract_meta(M,A,F,id,main,aux,capacity,depth,high,metadata_get(F,metadata,U32.sub(id,1)))
def rows_extract(-M: Type,-A: Type,-F: Data,rows: Rows<M,A,F>,+id: U32) -> Rows<M,A,F> & Maybe<Row<M,A,F>>:
  match rows:
    case Rows{main,aux,metadata,+capacity,depth,+high}: extract_checked(M,A,F,Bool.and((0 < id : U32),Bool.and((id <= capacity : U32),(id <= high : U32))),id,Rows{main,aux,metadata,capacity,depth,high})
def rows_restore(-M: Type,-A: Type,-F: Data,rows: Rows<M,A,F>,row: Row<M,A,F>) -> Rows<M,A,F>:
  match rows row:
    case Rows{main,aux,metadata,capacity,depth,high} Row{+id,m,a,f,added,changed}:
      Rows{Array.set(Maybe<M>,main,U32.sub(id,1),m),Array.set(Maybe<A>,aux,U32.sub(id,1),a),metadata_set(F,metadata,U32.sub(id,1),Metadata{True{},f,added,changed}),capacity,depth,high}
def remove_done(-M: Type,-A: Type,-F: Data,+id: U32,result: Rows<M,A,F> & Maybe<Row<M,A,F>>) -> Rows<M,A,F> & Maybe<Row<M,A,F>>:
  match result:
    case (rows,None{}): (rows,None{})
    case (Rows{m,a,f,c,d,h},Some{row}): (Rows{m,a,metadata_set(F,f,U32.sub(id,1),Metadata{False{},None{},0,0}),c,d,h},Some{row})
def rows_remove(-M: Type,-A: Type,-F: Data,rows: Rows<M,A,F>,+id: U32) -> Rows<M,A,F> & Maybe<Row<M,A,F>>:
  remove_done(M,A,F,id,rows_extract(M,A,F,rows,id))
def place_status(-M: Type,-A: Type,-F: Data,main: Array<Maybe<M>>,aux: Array<Maybe<A>>,metadata: MetadataColumns<F>,capacity: U32,depth: Nat,+high: U32,live: Bool,row: Row<M,A,F>) -> Placement<M,A,F>:
  match live row:
    case True{} row: Rejected{Rows{main,aux,metadata,capacity,depth,high},row}
    case False{} Row{+id,m,a,f,added,changed}: Placed{Rows{Array.set(Maybe<M>,main,U32.sub(id,1),m),Array.set(Maybe<A>,aux,U32.sub(id,1),a),metadata_set(F,metadata,U32.sub(id,1),Metadata{True{},f,added,changed}),capacity,depth,U32.max(high,id)}}
def place_metadata(-M: Type,-A: Type,-F: Data,main: Array<Maybe<M>>,aux: Array<Maybe<A>>,metadata: MetadataColumns<F>,capacity: U32,depth: Nat,high: U32,row: Row<M,A,F>,meta: Bool) -> Placement<M,A,F>:
  match meta:
    case live: place_status(M,A,F,main,aux,metadata,capacity,depth,high,live,row)
def place_meta(-M: Type,-A: Type,-F: Data,main: Array<Maybe<M>>,aux: Array<Maybe<A>>,capacity: U32,depth: Nat,high: U32,row: Row<M,A,F>,result: MetadataColumns<F> & Bool) -> Placement<M,A,F>:
  match result:
    case (metadata,meta): place_metadata(M,A,F,main,aux,metadata,capacity,depth,high,row,meta)
def place_capacity(-M: Type,-A: Type,-F: Data,valid: Bool,rows: Rows<M,A,F>,row: Row<M,A,F>) -> Placement<M,A,F>:
  match valid rows row:
    case False{} rows row: Rejected{rows,row}
    case True{} Rows{m,a,f,c,d,h} Row{+id,main,aux,flag,added,changed}: place_meta(M,A,F,m,a,c,d,h,Row{id,main,aux,flag,added,changed},metadata_live(F,f,U32.sub(id,1)))
def place_grown(-M: Type,-A: Type,-F: Data,rows: Rows<M,A,F>,row: Row<M,A,F>) -> Placement<M,A,F>:
  match rows row:
    case Rows{m,a,f,+c,d,h} Row{+id,main,aux,flag,added,changed}: place_capacity(M,A,F,Bool.and((0 < id : U32),(id <= c : U32)),Rows{m,a,f,c,d,h},Row{id,main,aux,flag,added,changed})
def place_checked(-M: Type,-A: Type,-F: Data,valid: Bool,rows: Rows<M,A,F>,row: Row<M,A,F>) -> Placement<M,A,F>:
  match valid row:
    case False{} row: Rejected{rows,row}
    case True{} Row{+id,m,a,f,added,changed}: place_grown(M,A,F,grow(17n,M,A,F,id,rows),Row{id,m,a,f,added,changed})
def rows_place(-M: Type,-A: Type,-F: Data,rows: Rows<M,A,F>,row: Row<M,A,F>) -> Placement<M,A,F>:
  match row:
    case Row{+id,m,a,f,added,changed}: place_checked(M,A,F,Bool.and((0 < id : U32),(id <= 131072 : U32)),rows,Row{id,m,a,f,added,changed})
# Main-only point access never extracts Aux or constructs a Row.
def take_main_done(-M: Type,-A: Type,-F: Data,aux: Array<Maybe<A>>,metadata: MetadataColumns<F>,capacity: U32,depth: Nat,high: U32,result: Array<Maybe<M>> & Maybe<M>) -> Rows<M,A,F> & Taken<M>:
  match result:
    case (main,None{}): (Rows{main,aux,metadata,capacity,depth,high},NoMain{})
    case (main,Some{value}): (Rows{main,aux,metadata,capacity,depth,high},Taken{value})
def take_meta(-M: Type,-A: Type,-F: Data,id: U32,main: Array<Maybe<M>>,aux: Array<Maybe<A>>,metadata: MetadataColumns<F>,capacity: U32,depth: Nat,high: U32,meta: Bool) -> Rows<M,A,F> & Taken<M>:
  match meta:
    case False{}: (Rows{main,aux,metadata,capacity,depth,high},NoEntity{})
    case True{}: take_main_done(M,A,F,aux,metadata,capacity,depth,high,Array.swap(Maybe<M>,main,U32.sub(id,1),None{}))
def take_meta_done(-M: Type,-A: Type,-F: Data,id: U32,main: Array<Maybe<M>>,aux: Array<Maybe<A>>,capacity: U32,depth: Nat,high: U32,result: MetadataColumns<F> & Bool) -> Rows<M,A,F> & Taken<M>:
  match result:
    case (metadata,meta): take_meta(M,A,F,id,main,aux,metadata,capacity,depth,high,meta)
def take_checked(-M: Type,-A: Type,-F: Data,valid: Bool,+id: U32,rows: Rows<M,A,F>) -> Rows<M,A,F> & Taken<M>:
  match valid rows:
    case False{} rows: (rows,NoEntity{})
    case True{} Rows{main,aux,metadata,capacity,depth,high}: take_meta_done(M,A,F,id,main,aux,capacity,depth,high,metadata_live(F,metadata,U32.sub(id,1)))
def take_rows(-M: Type,-A: Type,-F: Data,rows: Rows<M,A,F>,+target: U32) -> Rows<M,A,F> & Taken<M>:
  match rows:
    case Rows{main,aux,metadata,+capacity,depth,+high}: take_checked(M,A,F,Bool.and((0 < target : U32),Bool.and((target <= capacity : U32),(target <= high : U32))),target,Rows{main,aux,metadata,capacity,depth,high})
def put_meta(-M: Type,-A: Type,-F: Data,id: U32,main: Array<Maybe<M>>,aux: Array<Maybe<A>>,metadata: MetadataColumns<F>,capacity: U32,depth: Nat,high: U32,value: M,meta: Bool) -> Rows<M,A,F> & Maybe<M>:
  match meta:
    case False{}: (Rows{main,aux,metadata,capacity,depth,high},Some{value})
    case True{}: (Rows{Array.set(Maybe<M>,main,U32.sub(id,1),Some{value}),aux,metadata,capacity,depth,high},None{})
def put_meta_done(-M: Type,-A: Type,-F: Data,id: U32,main: Array<Maybe<M>>,aux: Array<Maybe<A>>,capacity: U32,depth: Nat,high: U32,value: M,result: MetadataColumns<F> & Bool) -> Rows<M,A,F> & Maybe<M>:
  match result:
    case (metadata,meta): put_meta(M,A,F,id,main,aux,metadata,capacity,depth,high,value,meta)
def put_checked(-M: Type,-A: Type,-F: Data,valid: Bool,+id: U32,rows: Rows<M,A,F>,value: M) -> Rows<M,A,F> & Maybe<M>:
  match valid rows:
    case False{} rows: (rows,Some{value})
    case True{} Rows{main,aux,metadata,capacity,depth,high}: put_meta_done(M,A,F,id,main,aux,capacity,depth,high,value,metadata_live(F,metadata,U32.sub(id,1)))
def put_rows(-M: Type,-A: Type,-F: Data,rows: Rows<M,A,F>,+target: U32,main: M) -> Rows<M,A,F> & Maybe<M>:
  match rows:
    case Rows{m,a,f,+c,d,+h}: put_checked(M,A,F,Bool.and((0 < target : U32),Bool.and((target <= c : U32),(target <= h : U32))),target,Rows{m,a,f,c,d,h},main)
def put_finish(-M: Type,-A: Type,-F: Data,result: Rows<M,A,F> & Maybe<M>) -> Rows<M,A,F>:
  match result:
    case (rows,_): rows
def hook_return(-S: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,-O: Data,
  namespace: U32,next: U32,rows: Rows<M,A,F>,pending: List<Command<M,A,F>>,ledger: Maybe<L>,mode: Mode,
  target: U32,result: M & O) -> World<S,M,A,F,L,Mode> & T.Access<O>:
  match result:
    case (main,observation): (World{namespace,next,put_finish(M,A,F,put_rows(M,A,F,rows,target,main)),pending,ledger,mode},T.Found{observation})
def hook_taken(-S: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,-O: Data,
  namespace: U32,next: U32,pending: List<Command<M,A,F>>,ledger: Maybe<L>,mode: Mode,
  target: U32,transform: M -> M & O,result: Rows<M,A,F> & Taken<M>) -> World<S,M,A,F,L,Mode> & T.Access<O>:
  match result:
    case (rows,NoEntity{}): (World{namespace,next,rows,pending,ledger,mode},T.Missing{})
    case (rows,NoMain{}): (World{namespace,next,rows,pending,ledger,mode},T.Mismatch{})
    case (rows,Taken{main}): hook_return(S,M,A,F,L,Mode,O,namespace,next,rows,pending,ledger,mode,target,transform(main))
# Fused trusted point hook: one bounds/liveness check, no Aux extraction.
def fuse_return(-S: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,-O: Data,namespace: U32,next: U32,aux: Array<Maybe<A>>,metadata: MetadataColumns<F>,capacity: U32,depth: Nat,high: U32,pending: List<Command<M,A,F>>,ledger: Maybe<L>,mode: Mode,main: Array<Maybe<M>>,index: U32,result: M & O) -> World<S,M,A,F,L,Mode> & T.Access<O>:
  match result:
    case (value,observation): (World{namespace,next,Rows{Array.set(Maybe<M>,main,index,Some{value}),aux,metadata,capacity,depth,high},pending,ledger,mode},T.Found{observation})
def fuse_taken(-S: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,-O: Data,namespace: U32,next: U32,aux: Array<Maybe<A>>,metadata: MetadataColumns<F>,capacity: U32,depth: Nat,high: U32,pending: List<Command<M,A,F>>,ledger: Maybe<L>,mode: Mode,index: U32,transform: M -> M & O,result: Array<Maybe<M>> & Maybe<M>) -> World<S,M,A,F,L,Mode> & T.Access<O>:
  match result:
    case (main,None{}): (World{namespace,next,Rows{main,aux,metadata,capacity,depth,high},pending,ledger,mode},T.Mismatch{})
    case (main,Some{value}): fuse_return(S,M,A,F,L,Mode,O,namespace,next,aux,metadata,capacity,depth,high,pending,ledger,mode,main,index,transform(value))
def fuse_live(-S: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,-O: Data,namespace: U32,next: U32,aux: Array<Maybe<A>>,metadata: MetadataColumns<F>,capacity: U32,depth: Nat,high: U32,pending: List<Command<M,A,F>>,ledger: Maybe<L>,mode: Mode,main: Array<Maybe<M>>,+index: U32,transform: M -> M & O,meta: Bool) -> World<S,M,A,F,L,Mode> & T.Access<O>:
  match meta:
    case False{}: (World{namespace,next,Rows{main,aux,metadata,capacity,depth,high},pending,ledger,mode},T.Missing{})
    case True{}: fuse_taken(S,M,A,F,L,Mode,O,namespace,next,aux,metadata,capacity,depth,high,pending,ledger,mode,index,transform,Array.swap(Maybe<M>,main,index,None{}))
def fuse_meta(-S: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,-O: Data,namespace: U32,next: U32,main: Array<Maybe<M>>,aux: Array<Maybe<A>>,capacity: U32,depth: Nat,high: U32,pending: List<Command<M,A,F>>,ledger: Maybe<L>,mode: Mode,index: U32,transform: M -> M & O,result: MetadataColumns<F> & Bool) -> World<S,M,A,F,L,Mode> & T.Access<O>:
  match result:
    case (metadata,meta): fuse_live(S,M,A,F,L,Mode,O,namespace,next,aux,metadata,capacity,depth,high,pending,ledger,mode,main,index,transform,meta)
def fuse_bounds(-S: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,-O: Data,valid: Bool,world: World<S,M,A,F,L,Mode>,+target: U32,transform: M -> M & O) -> World<S,M,A,F,L,Mode> & T.Access<O>:
  match valid world:
    case False{} world: (world,T.Missing{})
    case True{} World{namespace,next,Rows{main,aux,metadata,capacity,depth,high},pending,ledger,mode}:
      fuse_meta(S,M,A,F,L,Mode,O,namespace,next,main,aux,capacity,depth,high,pending,ledger,mode,U32.sub(target,1),transform,metadata_live(F,metadata,U32.sub(target,1)))
def hook_checked(-S: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,-O: Data,
  valid: Bool,world: World<S,M,A,F,L,Mode>,+target: U32,transform: M -> M & O) -> World<S,M,A,F,L,Mode> & T.Access<O>:
  match valid world:
    case False{} w: (w,T.Missing{})
    case True{} World{namespace,next,Rows{main,aux,metadata,+capacity,depth,+high},pending,ledger,mode}:
      fuse_bounds(S,M,A,F,L,Mode,O,Bool.and((0 < target : U32),Bool.and((target <= capacity : U32),(target <= high : U32))),World{namespace,next,Rows{main,aux,metadata,capacity,depth,high},pending,ledger,mode},target,transform)
def with_main(-S: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,-O: Data,
  world: World<S,M,A,F,L,Mode>,handle: Handle<S>,transform: M -> M & O) -> World<S,M,A,F,L,Mode> & T.Access<O>:
  match world handle:
    case World{+namespace,next,rows,pending,ledger,mode} Handle{foreign,id}:
      hook_checked(S,M,A,F,L,Mode,O,U32.is_eq(namespace,foreign),World{namespace,next,rows,pending,ledger,mode},id,transform)
def ledger_return(-S: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,-O: Data,
  namespace: U32,next: U32,rows: Rows<M,A,F>,pending: List<Command<M,A,F>>,mode: Mode,result: L & O) -> World<S,M,A,F,L,Mode> & Maybe<&2,O>:
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
      World{namespace,next,rows,List.reverse.go(&1,Command<M,A,F>,List.reverse(&1,Command<M,A,F>,staged),pending),ledger,mode}

def mark_meta(-M: Type,-A: Type,-F: Data,id: U32,tick: U32,main: Array<Maybe<M>>,aux: Array<Maybe<A>>,metadata: MetadataColumns<F>,capacity: U32,depth: Nat,high: U32,meta: Bool) -> Rows<M,A,F>:
  match meta:
    case False{}: Rows{main,aux,metadata,capacity,depth,high}
    case True{}: Rows{main,aux,metadata_mark(F,metadata,U32.sub(id,1),tick),capacity,depth,high}
def mark_meta_done(-M: Type,-A: Type,-F: Data,id: U32,tick: U32,main: Array<Maybe<M>>,aux: Array<Maybe<A>>,capacity: U32,depth: Nat,high: U32,result: MetadataColumns<F> & Bool) -> Rows<M,A,F>:
  match result:
    case (metadata,meta): mark_meta(M,A,F,id,tick,main,aux,metadata,capacity,depth,high,meta)
def mark_rows_checked(-M: Type,-A: Type,-F: Data,valid: Bool,+id: U32,tick: U32,rows: Rows<M,A,F>) -> Rows<M,A,F>:
  match valid rows:
    case False{} rows: rows
    case True{} Rows{main,aux,metadata,capacity,depth,high}: mark_meta_done(M,A,F,id,tick,main,aux,capacity,depth,high,metadata_live(F,metadata,U32.sub(id,1)))
def mark_rows(-M: Type,-A: Type,-F: Data,rows: Rows<M,A,F>,+target: U32,tick: U32) -> Rows<M,A,F>:
  match rows:
    case Rows{m,a,f,+c,d,+h}: mark_rows_checked(M,A,F,Bool.and((0 < target : U32),Bool.and((target <= c : U32),(target <= h : U32))),target,tick,Rows{m,a,f,c,d,h})
def mark_checked(-S: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,
  valid: Bool,world: World<S,M,A,F,L,Mode>,target: U32,tick: U32) -> World<S,M,A,F,L,Mode>:
  match valid world:
    case False{} w: w
    case True{} World{namespace,next,rows,pending,ledger,mode}: World{namespace,next,mark_rows(M,A,F,rows,target,tick),pending,ledger,mode}
# Private transport-only publication path: every mark retains the original guards.
def prototype_mark_world_meta(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,
  namespace: U32,next: U32,main: Array<Maybe<M>>,aux: Array<Maybe<A>>,metadata: MetadataColumns<F>,capacity: U32,depth: Nat,high: U32,pending: List<Command<M,A,F>>,ledger: Maybe<L>,mode: Mode,id: U32,tick: U32,meta: Bool) -> World<Schema,M,A,F,L,Mode>:
  match meta:
    case False{}: World{namespace,next,Rows{main,aux,metadata,capacity,depth,high},pending,ledger,mode}
    case True{}: World{namespace,next,Rows{main,aux,metadata_mark(F,metadata,U32.sub(id,1),tick),capacity,depth,high},pending,ledger,mode}
def prototype_mark_world_result(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,
  namespace: U32,next: U32,main: Array<Maybe<M>>,aux: Array<Maybe<A>>,capacity: U32,depth: Nat,high: U32,pending: List<Command<M,A,F>>,ledger: Maybe<L>,mode: Mode,id: U32,tick: U32,result: MetadataColumns<F> & Bool) -> World<Schema,M,A,F,L,Mode>:
  match result:
    case (metadata,meta): prototype_mark_world_meta(Schema,M,A,F,L,Mode,namespace,next,main,aux,metadata,capacity,depth,high,pending,ledger,mode,id,tick,meta)
def prototype_mark_world_checked(-Schema: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,
  valid: Bool,namespace: U32,next: U32,main: Array<Maybe<M>>,aux: Array<Maybe<A>>,metadata: MetadataColumns<F>,capacity: U32,depth: Nat,high: U32,pending: List<Command<M,A,F>>,ledger: Maybe<L>,mode: Mode,+id: U32,tick: U32) -> World<Schema,M,A,F,L,Mode>:
  match valid:
    case False{}: World{namespace,next,Rows{main,aux,metadata,capacity,depth,high},pending,ledger,mode}
    case True{}: prototype_mark_world_result(Schema,M,A,F,L,Mode,namespace,next,main,aux,capacity,depth,high,pending,ledger,mode,id,tick,metadata_live(F,metadata,U32.sub(id,1)))
def mark_main(-S: Data,-M: Type,-A: Type,-F: Data,-L: Type,-Mode: Data,
  world: World<S,M,A,F,L,Mode>,handle: Handle<S>,tick: U32) -> World<S,M,A,F,L,Mode>:
  match world handle:
    case World{+namespace,next,Rows{main,aux,metadata,+capacity,depth,+high},pending,ledger,mode} Handle{foreign,+target}:
      prototype_mark_world_checked(S,M,A,F,L,Mode,Bool.and(U32.is_eq(namespace,foreign),Bool.and((0 < target : U32),Bool.and((target <= capacity : U32),(target <= high : U32)))),namespace,next,main,aux,metadata,capacity,depth,high,pending,ledger,mode,target,tick)
# Structural Main edits use only Main+metadata; stale applied payloads are dropped
# exactly as in the baseline command semantics. No Aux extraction is performed.
type MainEffect is Data:
  MissingMainTarget{}
  AddedMain{}
  ChangedMain{}
  RemovedMain{}
  NoMainChange{}
def replace_main_effect(-M: Type,-A: Type,-F: Data,id: U32,+tick: U32,main: Array<Maybe<M>>,aux: Array<Maybe<A>>,metadata: MetadataColumns<F>,capacity: U32,depth: Nat,high: U32,flag: Maybe<&2,F>,added: U32,changed: U32,insert: Bool,old: Maybe<M>) -> Rows<M,A,F> & MainEffect:
  match insert old:
    case False{} None{}: (Rows{main,aux,metadata,capacity,depth,high},NoMainChange{})
    case False{} Some{_}: (Rows{main,aux,metadata_set(F,metadata,U32.sub(id,1),Metadata{True{},flag,0,0}),capacity,depth,high},RemovedMain{})
    case True{} None{}: (Rows{main,aux,metadata_set(F,metadata,U32.sub(id,1),Metadata{True{},flag,tick,tick}),capacity,depth,high},AddedMain{})
    case True{} Some{_}: (Rows{main,aux,metadata_set(F,metadata,U32.sub(id,1),Metadata{True{},flag,added,tick}),capacity,depth,high},ChangedMain{})
def replace_main_done(-M: Type,-A: Type,-F: Data,id: U32,tick: U32,aux: Array<Maybe<A>>,metadata: MetadataColumns<F>,capacity: U32,depth: Nat,high: U32,flag: Maybe<&2,F>,added: U32,changed: U32,insert: Bool,result: Array<Maybe<M>> & Maybe<M>) -> Rows<M,A,F> & MainEffect:
  match result:
    case (main,old): replace_main_effect(M,A,F,id,tick,main,aux,metadata,capacity,depth,high,flag,added,changed,insert,old)
def replace_main_slot(-M: Type,-A: Type,-F: Data,+id: U32,tick: U32,main: Array<Maybe<M>>,aux: Array<Maybe<A>>,metadata: MetadataColumns<F>,capacity: U32,depth: Nat,high: U32,flag: Maybe<&2,F>,added: U32,changed: U32,replacement: Maybe<M>) -> Rows<M,A,F> & MainEffect:
  match replacement:
    case None{}: replace_main_done(M,A,F,id,tick,aux,metadata,capacity,depth,high,flag,added,changed,False{},Array.swap(Maybe<M>,main,U32.sub(id,1),None{}))
    case Some{value}: replace_main_done(M,A,F,id,tick,aux,metadata,capacity,depth,high,flag,added,changed,True{},Array.swap(Maybe<M>,main,U32.sub(id,1),Some{value}))
def replace_main_meta(-M: Type,-A: Type,-F: Data,id: U32,tick: U32,main: Array<Maybe<M>>,aux: Array<Maybe<A>>,metadata: MetadataColumns<F>,capacity: U32,depth: Nat,high: U32,replacement: Maybe<M>,meta: Metadata<F>) -> Rows<M,A,F> & MainEffect:
  match meta:
    case Metadata{False{},_,_,_}: (Rows{main,aux,metadata,capacity,depth,high},MissingMainTarget{})
    case Metadata{True{},flag,added,changed}: replace_main_slot(M,A,F,id,tick,main,aux,metadata,capacity,depth,high,flag,added,changed,replacement)
def replace_main_meta_done(-M: Type,-A: Type,-F: Data,id: U32,tick: U32,main: Array<Maybe<M>>,aux: Array<Maybe<A>>,capacity: U32,depth: Nat,high: U32,replacement: Maybe<M>,result: MetadataColumns<F> & Metadata<F>) -> Rows<M,A,F> & MainEffect:
  match result:
    case (metadata,meta): replace_main_meta(M,A,F,id,tick,main,aux,metadata,capacity,depth,high,replacement,meta)
def replace_main_checked(-M: Type,-A: Type,-F: Data,valid: Bool,+id: U32,tick: U32,rows: Rows<M,A,F>,replacement: Maybe<M>) -> Rows<M,A,F> & MainEffect:
  match valid rows:
    case False{} rows: (rows,MissingMainTarget{})
    case True{} Rows{m,a,f,c,d,h}: replace_main_meta_done(M,A,F,id,tick,m,a,c,d,h,replacement,metadata_get(F,f,U32.sub(id,1)))
def rows_replace_main(-M: Type,-A: Type,-F: Data,rows: Rows<M,A,F>,+id: U32,replacement: Maybe<M>,tick: U32) -> Rows<M,A,F> & MainEffect:
  match rows:
    case Rows{m,a,f,+c,d,+h}: replace_main_checked(M,A,F,Bool.and((0 < id : U32),Bool.and((id <= c : U32),(id <= h : U32))),id,tick,Rows{m,a,f,c,d,h},replacement)

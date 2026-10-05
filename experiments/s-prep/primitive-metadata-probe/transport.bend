import Base

type Metadata<-F: Data> is Data:
  Metadata{live: Bool, flag: Maybe<&2,F>, added: U32, changed: U32}
type Original<-M: Type,-A: Type,-F: Data> is Type:
  Original{main: Array<Maybe<M>>, aux: Array<Maybe<A>>, metadata: Array<Metadata<F>>, capacity: U32, depth: Nat, high: U32}
type Columns<-M: Type,-A: Type,-F: Data> is Type:
  Columns{main: Array<Maybe<M>>, aux: Array<Maybe<A>>, live: Array<Bool>, flags: Array<Maybe<&2,F>>, added: Array<U32>, changed: Array<U32>, capacity: U32, depth: Nat, high: U32}

def original_mark_meta(-M: Type,-A: Type,-F: Data,tick: U32,index: U32,m: Array<Maybe<M>>,a: Array<Maybe<A>>,c: U32,d: Nat,h: U32,r: Array<Metadata<F>> & Metadata<F>) -> Original<M,A,F>:
  match r:
    case (meta,Metadata{False{},f,ad,ch}): Original{m,a,meta,c,d,h}
    case (meta,Metadata{True{},f,ad,ch}): Original{m,a,Array.set(Metadata<F>,meta,index,Metadata{True{},f,ad,tick}),c,d,h}
def original_mark_guard(-M: Type,-A: Type,-F: Data,valid: Bool,+id: U32,tick: U32,r: Original<M,A,F>) -> Original<M,A,F>:
  match valid r:
    case False{} r: r
    case True{} Original{m,a,meta,c,d,h}: original_mark_meta(M,A,F,tick,U32.sub(id,1),m,a,c,d,h,Array.get(Metadata<F>,meta,U32.sub(id,1)))
def original_mark(-M: Type,-A: Type,-F: Data,r: Original<M,A,F>,+id: U32,tick: U32) -> Original<M,A,F>:
  match r:
    case Original{m,a,meta,+c,d,+h}: original_mark_guard(M,A,F,Bool.and((0 < id : U32),Bool.and((id <= c : U32),(id <= h : U32))),id,tick,Original{m,a,meta,c,d,h})

def columns_mark_live(-M: Type,-A: Type,-F: Data,index: U32,tick: U32,m: Array<Maybe<M>>,a: Array<Maybe<A>>,flags: Array<Maybe<&2,F>>,added: Array<U32>,changed: Array<U32>,c: U32,d: Nat,h: U32,r: Array<Bool> & Bool) -> Columns<M,A,F>:
  match r:
    case (live,False{}): Columns{m,a,live,flags,added,changed,c,d,h}
    case (live,True{}): Columns{m,a,live,flags,added,Array.set(U32,changed,index,tick),c,d,h}
def columns_mark_guard(-M: Type,-A: Type,-F: Data,valid: Bool,+id: U32,tick: U32,r: Columns<M,A,F>) -> Columns<M,A,F>:
  match valid r:
    case False{} r: r
    case True{} Columns{m,a,live,f,ad,ch,c,d,h}: columns_mark_live(M,A,F,U32.sub(id,1),tick,m,a,f,ad,ch,c,d,h,Array.get(Bool,live,U32.sub(id,1)))
def columns_mark(-M: Type,-A: Type,-F: Data,r: Columns<M,A,F>,+id: U32,tick: U32) -> Columns<M,A,F>:
  match r:
    case Columns{m,a,l,f,ad,ch,+c,d,+h}: columns_mark_guard(M,A,F,Bool.and((0 < id : U32),Bool.and((id <= c : U32),(id <= h : U32))),id,tick,Columns{m,a,l,f,ad,ch,c,d,h})

# Read returns the owners unchanged together with an optional metadata observation.
def original_read_done(-M: Type,-A: Type,-F: Data,m: Array<Maybe<M>>,a: Array<Maybe<A>>,c: U32,d: Nat,h: U32,r: Array<Metadata<F>> & Metadata<F>) -> Original<M,A,F> & Maybe<&2,Metadata<F>>:
  match r:
    case (meta,value): (Original{m,a,meta,c,d,h},Some{value})
def original_read_guard(-M: Type,-A: Type,-F: Data,valid: Bool,+id: U32,r: Original<M,A,F>) -> Original<M,A,F> & Maybe<&2,Metadata<F>>:
  match valid r:
    case False{} r: (r,None{})
    case True{} Original{m,a,meta,c,d,h}: original_read_done(M,A,F,m,a,c,d,h,Array.get(Metadata<F>,meta,U32.sub(id,1)))
def original_read(-M: Type,-A: Type,-F: Data,r: Original<M,A,F>,+id: U32) -> Original<M,A,F> & Maybe<&2,Metadata<F>>:
  match r:
    case Original{m,a,meta,+c,d,h}: original_read_guard(M,A,F,Bool.and((0 < id : U32),(id <= c : U32)),id,Original{m,a,meta,c,d,h})
def columns_read_changed(-M: Type,-A: Type,-F: Data,m: Array<Maybe<M>>,a: Array<Maybe<A>>,l: Array<Bool>,f: Array<Maybe<&2,F>>,ad: Array<U32>,c: U32,d: Nat,h: U32,lv: Bool,fv: Maybe<&2,F>,av: U32,r: Array<U32> & U32) -> Columns<M,A,F> & Maybe<&2,Metadata<F>>:
  match r:
    case (ch,cv): (Columns{m,a,l,f,ad,ch,c,d,h},Some{Metadata{lv,fv,av,cv}})
def columns_read_added(-M: Type,-A: Type,-F: Data,+i: U32,m: Array<Maybe<M>>,a: Array<Maybe<A>>,l: Array<Bool>,f: Array<Maybe<&2,F>>,ch: Array<U32>,c: U32,d: Nat,h: U32,lv: Bool,fv: Maybe<&2,F>,r: Array<U32> & U32) -> Columns<M,A,F> & Maybe<&2,Metadata<F>>:
  match r:
    case (ad,av): columns_read_changed(M,A,F,m,a,l,f,ad,c,d,h,lv,fv,av,Array.get(U32,ch,i))
def columns_read_flags(-M: Type,-A: Type,-F: Data,+i: U32,m: Array<Maybe<M>>,a: Array<Maybe<A>>,l: Array<Bool>,ad: Array<U32>,ch: Array<U32>,c: U32,d: Nat,h: U32,lv: Bool,r: Array<Maybe<&2,F>> & Maybe<&2,F>) -> Columns<M,A,F> & Maybe<&2,Metadata<F>>:
  match r:
    case (f,fv): columns_read_added(M,A,F,i,m,a,l,f,ch,c,d,h,lv,fv,Array.get(U32,ad,i))
def columns_read_live(-M: Type,-A: Type,-F: Data,+i: U32,m: Array<Maybe<M>>,a: Array<Maybe<A>>,f: Array<Maybe<&2,F>>,ad: Array<U32>,ch: Array<U32>,c: U32,d: Nat,h: U32,r: Array<Bool> & Bool) -> Columns<M,A,F> & Maybe<&2,Metadata<F>>:
  match r:
    case (l,lv): columns_read_flags(M,A,F,i,m,a,l,ad,ch,c,d,h,lv,Array.get(Maybe<&2,F>,f,i))
def columns_read_guard(-M: Type,-A: Type,-F: Data,valid: Bool,+id: U32,r: Columns<M,A,F>) -> Columns<M,A,F> & Maybe<&2,Metadata<F>>:
  match valid r:
    case False{} r: (r,None{})
    case True{} Columns{m,a,l,f,ad,ch,c,d,h}: columns_read_live(M,A,F,U32.sub(id,1),m,a,f,ad,ch,c,d,h,Array.get(Bool,l,U32.sub(id,1)))
def columns_read(-M: Type,-A: Type,-F: Data,r: Columns<M,A,F>,+id: U32) -> Columns<M,A,F> & Maybe<&2,Metadata<F>>:
  match r:
    case Columns{m,a,l,f,ad,ch,+c,d,h}: columns_read_guard(M,A,F,Bool.and((0 < id : U32),(id <= c : U32)),id,Columns{m,a,l,f,ad,ch,c,d,h})

# Destructive initialization seam: carry both Type payload owners without copying.
type MetaColumns<-F: Data> is Type:
  MetaColumns{live: Array<Bool>, flags: Array<Maybe<&2,F>>, added: Array<U32>, changed: Array<U32>}
def split_join(-F: Data,left: MetaColumns<F>,right: MetaColumns<F>) -> MetaColumns<F>:
  match left right:
    case MetaColumns{ll,lf,la,lc} MetaColumns{rl,rf,ra,rc}: MetaColumns{ANode{ll,rl},ANode{lf,rf},ANode{la,ra},ANode{lc,rc}}
def split_metadata(-F: Data,meta: Array<Metadata<F>>) -> MetaColumns<F>:
  match meta:
    case ALeaf{Metadata{l,f,a,c}}: MetaColumns{ALeaf{l},ALeaf{f},ALeaf{a},ALeaf{c}}
    case ANode{left,right}: split_join(F,split_metadata(F,left),split_metadata(F,right))
def from_original_done(-M: Type,-A: Type,-F: Data,m: Array<Maybe<M>>,a: Array<Maybe<A>>,capacity: U32,depth: Nat,high: U32,meta: MetaColumns<F>) -> Columns<M,A,F>:
  match meta:
    case MetaColumns{l,f,ad,ch}: Columns{m,a,l,f,ad,ch,capacity,depth,high}
def from_original(-M: Type,-A: Type,-F: Data,rows: Original<M,A,F>) -> Columns<M,A,F>:
  match rows:
    case Original{m,a,meta,c,d,h}: from_original_done(M,A,F,m,a,c,d,h,split_metadata(F,meta))

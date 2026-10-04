import Base
# Finite structural/ownership probe; no ECS candidate or laws.
type Schema is Data:
  Motion{}
  Health{}
type Handle<-S: Data> is Data:
  Handle{namespace: U32, id: U32}
type Main is Type:
  Main{a: U32, b: U32}
type Aux is Type:
  Aux{x: U32, y: U32}
type Occupied is Data:
  Leaf{live: Bool}
  Node{count: U32, left: Occupied, right: Occupied}
type ProbeResult<-M: Type,-A: Type> is Type:
  ProbeResult{main: Array<Maybe<M>>, aux: Array<Maybe<A>>, values: List<&2,U32>, valid: Bool}
# Same field shape as candidate/storage.bend Metadata<U32>, independently authored.
type PhysicalMetadata is Data:
  PhysicalMetadata{live: Bool, flag: Maybe<&2,U32>, added: U32, changed: U32}
type MetadataAudit is Type:
  MetadataAudit{metadata: Array<PhysicalMetadata>, count: U32, valid: Bool}
type Complete is Type:
  Complete{result: ProbeResult<Main,Aux>, metadata: Array<PhysicalMetadata>}
def main_get(owner: Main) -> Main & U32:
  match owner:
    case Main{+a,+b}: (Main{a,b},U32.add(a,b))
def main_set(owner: Main) -> Main:
  match owner:
    case Main{_,b}: Main{0,b}
def aux_get(owner: Aux) -> Aux & U32:
  match owner:
    case Aux{+x,+y}: (Aux{x,y},U32.add(x,y))
def main_view(~M: Type,~get: M -> M & U32,owner: M,token: Unit) -> M & U32:
  get(owner)
def aux_some(-A: Type,pair: A & U32) -> Maybe<A> & Maybe<&2,U32>:
  match pair:
    case (owner,value): (Some{owner},Some{value})
def aux_view(~A: Type,~get: A -> A & U32,owner: Maybe<A>) -> Maybe<A> & Maybe<&2,U32>:
  match owner:
    case None{}: (None{},None{})
    case Some{owner}: aux_some(A,get(owner))
def client_value(-P: Type,-U: Type,p: P,u: U,m: U32,value: Maybe<&2,U32>) -> P & (U & U32):
  match value:
    case None{}: (p,(u,m))
    case Some{a}: (p,(u,U32.add(m,a)))
def client_aux(-P: Type,-U: Type,p: P,m: U32,pair: U & Maybe<&2,U32>) -> P & (U & U32):
  match pair:
    case (u,a): client_value(P,U,p,u,m,a)
def client_main(-P: Type,-U: Type,aux: U -> U & Maybe<&2,U32>,u: U,pair: P & U32) -> P & (U & U32):
  match pair:
    case (p,m): client_aux(P,U,p,m,aux(u))
def client(~P: Type,~U: Type,get: P -> Unit -> P & U32,aux: U -> U & Maybe<&2,U32>,handle: Handle<Schema>,flag: Maybe<&2,U32>,p: P,u: U) -> P & (U & U32):
  client_main(P,U,aux,u,get(p,Unit{}))
def leaf_return(-M: Type,-A: Type,+id: U32,pair: M & (Maybe<A> & U32)) -> ProbeResult<M,A>:
  match pair:
    case (main,(aux,value)): ProbeResult{ALeaf{Some{main}},ALeaf{aux},[id,value],True{}}
def leaf(~M: Type,~A: Type,~mg: M -> M & U32,~ag: A -> A & U32,~use: @-P: Type -> @-U: Type -> (P -> Unit -> P & U32) -> (U -> U & Maybe<&2,U32>) -> Handle<Schema> -> Maybe<&2,U32> -> P -> U -> P & (U & U32),+id: U32,main: Maybe<M>,aux: Maybe<A>,live: Bool) -> ProbeResult<M,A>:
  match main live:
    case Some{owner} True{}: leaf_return(M,A,id,use(M,Maybe<A>,main_view(~M,~mg),aux_view(~A,~ag),Handle{7,id},None{},owner,aux))
    case other _: ProbeResult{ALeaf{other},ALeaf{aux},[],True{}}
def count(occupied: Occupied) -> U32:
  match occupied:
    case Leaf{True{}}: 1
    case Leaf{False{}}: 0
    case Node{_,left,right}: U32.add(count(left),count(right))
def consistent(occupied: Occupied) -> Bool:
  match occupied:
    case Leaf{_}: True{}
    case Node{+n,+left,+right}: Bool.and(U32.is_eq(n,U32.add(count(left),count(right))),Bool.and(consistent(left),consistent(right)))
def join(-M: Type,-A: Type,left: ProbeResult<M,A>,right: ProbeResult<M,A>) -> ProbeResult<M,A>:
  match left right:
    case ProbeResult{lm,la,lv,lg} ProbeResult{rm,ra,rv,rg}: ProbeResult{ANode{lm,rm},ANode{la,ra},List.append(&2,U32,lv,rv),Bool.and(lg,rg)}
def offset(+depth: Nat) -> U32:
  match depth:
    case 0n: 1
    case 1n+d: U32.add(offset(d),offset(d))
def walk(~M: Type,~A: Type,~mg: M -> M & U32,~ag: A -> A & U32,~use: @-P: Type -> @-U: Type -> (P -> Unit -> P & U32) -> (U -> U & Maybe<&2,U32>) -> Handle<Schema> -> Maybe<&2,U32> -> P -> U -> P & (U & U32),+depth: Nat,+id: U32,main: Array<Maybe<M>>,aux: Array<Maybe<A>>,occupied: Occupied) -> ProbeResult<M,A>:
  match depth main aux occupied:
    case 0n ALeaf{m} ALeaf{a} Leaf{live}: leaf(~M,~A,~mg,~ag,~use,id,m,a,live)
    case 1n++rest ANode{lm,rm} ANode{la,ra} Node{0,_,_}: ProbeResult{ANode{lm,rm},ANode{la,ra},[],True{}}
    case 1n++rest ANode{lm,rm} ANode{la,ra} Node{_,lo,ro}: join(M,A,walk(~M,~A,~mg,~ag,~use,rest,id,lm,la,lo),walk(~M,~A,~mg,~ag,~use,rest,U32.add(id,offset(rest)),rm,ra,ro))
    case _ m a _: ProbeResult{m,a,[],False{}}
def shape(-M: Type,-A: Type,depth: Nat,main: Array<Maybe<M>>,aux: Array<Maybe<A>>,occupied: Occupied) -> ProbeResult<M,A>:
  match depth main aux occupied:
    case 0n ALeaf{m} ALeaf{a} Leaf{_}: ProbeResult{ALeaf{m},ALeaf{a},[],True{}}
    case 1n++rest ANode{lm,rm} ANode{la,ra} Node{_,lo,ro}: join(M,A,shape(M,A,rest,lm,la,lo),shape(M,A,rest,rm,ra,ro))
    case _ m a _: ProbeResult{m,a,[],False{}}
def guarded(~M: Type,~A: Type,~mg: M -> M & U32,~ag: A -> A & U32,~use: @-P: Type -> @-U: Type -> (P -> Unit -> P & U32) -> (U -> U & Maybe<&2,U32>) -> Handle<Schema> -> Maybe<&2,U32> -> P -> U -> P & (U & U32),+depth: Nat,+id: U32,main: Array<Maybe<M>>,aux: Array<Maybe<A>>,valid: Bool,occupied: Occupied) -> ProbeResult<M,A>:
  match valid:
    case False{}: ProbeResult{main,aux,[],False{}}
    case True{}: walk(~M,~A,~mg,~ag,~use,depth,id,main,aux,occupied)
def shaped(~M: Type,~A: Type,~mg: M -> M & U32,~ag: A -> A & U32,~use: @-P: Type -> @-U: Type -> (P -> Unit -> P & U32) -> (U -> U & Maybe<&2,U32>) -> Handle<Schema> -> Maybe<&2,U32> -> P -> U -> P & (U & U32),depth: Nat,id: U32,+occupied: Occupied,pair: ProbeResult<M,A>) -> ProbeResult<M,A>:
  match pair:
    case ProbeResult{main,aux,_,False{}}: ProbeResult{main,aux,[],False{}}
    case ProbeResult{main,aux,_,True{}}: guarded(~M,~A,~mg,~ag,~use,depth,id,main,aux,consistent(occupied),occupied)
def check(~M: Type,~A: Type,~mg: M -> M & U32,~ag: A -> A & U32,~use: @-P: Type -> @-U: Type -> (P -> Unit -> P & U32) -> (U -> U & Maybe<&2,U32>) -> Handle<Schema> -> Maybe<&2,U32> -> P -> U -> P & (U & U32),+depth: Nat,+id: U32,main: Array<Maybe<M>>,aux: Array<Maybe<A>>,+occupied: Occupied) -> ProbeResult<M,A>:
  shaped(~M,~A,~mg,~ag,~use,depth,id,occupied,shape(M,A,depth,main,aux,occupied))
def emit(result: ProbeResult<Main,Aux>) -> IO(Unit):
  match result:
    case ProbeResult{_,_,+values,valid}: IO.print(List.show(~&2,~U32,~U32.show,values) ++ ":" ++ Bool.show(valid))
def tree() -> Array<Maybe<Main>>:
  ANode{ANode{ALeaf{Some{Main{10,11}}},ALeaf{Some{Main{20,21}}}},ANode{ALeaf{None{}},ALeaf{Some{Main{40,41}}}}}
def auxiliaries() -> Array<Maybe<Aux>>:
  ANode{ANode{ALeaf{Some{Aux{100,101}}},ALeaf{Some{Aux{200,201}}}},ANode{ALeaf{Some{Aux{300,301}}},ALeaf{Some{Aux{400,401}}}}}
def occupancy() -> Occupied:
  Node{3,Node{1,Leaf{True{}},Leaf{False{}}},Node{2,Leaf{True{}},Leaf{True{}}}}
def replay(result: ProbeResult<Main,Aux>) -> IO(Unit):
  match result:
    case ProbeResult{main,aux,_,_}: emit(check(~Main,~Aux,~main_get,~aux_get,~client,2n,1,main,aux,occupancy()))
def bounds(valid: Bool,main: Array<Maybe<Main>>,aux: Array<Maybe<Aux>>) -> ProbeResult<Main,Aux>:
  guarded(~Main,~Aux,~main_get,~aux_get,~client,2n,1,main,aux,valid,occupancy())
def empty_slots(-M: Type,depth: Nat) -> Array<Maybe<M>>:
  match depth:
    case 0n: ALeaf{None{}}
    case 1n++rest: ANode{empty_slots(M,rest),empty_slots(M,rest)}
def expand(-M: Type,main: Array<Maybe<M>>,depth: Nat) -> Array<Maybe<M>>:
  ANode{main,empty_slots(M,depth)}
def grow_main() -> Array<Maybe<Main>>:
  expand(Main,expand(Main,ALeaf{Some{Main{1,2}}},0n),1n)
def grow_aux() -> Array<Maybe<Aux>>:
  expand(Aux,expand(Aux,ALeaf{Some{Aux{3,4}}},0n),1n)
def bit(live: Bool) -> U32:
  match live:
    case True{}: 1
    case False{}: 0
def audit_leaf(metadata: PhysicalMetadata,occupied: Bool) -> MetadataAudit:
  match metadata:
    case PhysicalMetadata{+live,flag,added,changed}: MetadataAudit{ALeaf{PhysicalMetadata{live,flag,added,changed}},bit(live),U32.is_eq(bit(live),bit(occupied))}
def audit_join(cached: U32,left: MetadataAudit,right: MetadataAudit) -> MetadataAudit:
  match left right:
    case MetadataAudit{lm,+lc,lv} MetadataAudit{rm,+rc,rv}: MetadataAudit{ANode{lm,rm},U32.add(lc,rc),Bool.and(U32.is_eq(cached,U32.add(lc,rc)),Bool.and(lv,rv))}
def physical_audit(depth: Nat,metadata: Array<PhysicalMetadata>,occupied: Occupied) -> MetadataAudit:
  match depth metadata occupied:
    case 0n ALeaf{m} Leaf{live}: audit_leaf(m,live)
    case 1n++rest ANode{lm,rm} Node{cached,lo,ro}: audit_join(cached,physical_audit(rest,lm,lo),physical_audit(rest,rm,ro))
    case _ m _: MetadataAudit{m,0,False{}}
def physical_ready(depth: Nat,main: Array<Maybe<Main>>,aux: Array<Maybe<Aux>>,occupied: Occupied,audit: MetadataAudit) -> Complete:
  match audit:
    case MetadataAudit{metadata,_,False{}}: Complete{ProbeResult{main,aux,[],False{}},metadata}
    case MetadataAudit{metadata,_,True{}}: Complete{check(~Main,~Aux,~main_get,~aux_get,~client,depth,1,main,aux,occupied),metadata}
def physical_check(+depth: Nat,main: Array<Maybe<Main>>,aux: Array<Maybe<Aux>>,metadata: Array<PhysicalMetadata>,+occupied: Occupied) -> Complete:
  physical_ready(depth,main,aux,occupied,physical_audit(depth,metadata,occupied))
def metadata() -> Array<PhysicalMetadata>:
  ANode{ANode{ALeaf{PhysicalMetadata{True{},Some{11},101,201}},ALeaf{PhysicalMetadata{False{},Some{12},102,202}}},ANode{ALeaf{PhysicalMetadata{True{},None{},103,203}},ALeaf{PhysicalMetadata{True{},Some{14},104,204}}}}
def flag_text(flag: Maybe<&2,U32>) -> String:
  match flag:
    case None{}: "none"
    case Some{n}: U32.show(n)
def dump_join(pair: (Array<PhysicalMetadata> & String) & (Array<PhysicalMetadata> & String)) -> Array<PhysicalMetadata> & String:
  match pair:
    case ((lm,lt),(rm,rt)): (ANode{lm,rm},"(" ++ lt ++ "," ++ rt ++ ")")
def dump(metadata: Array<PhysicalMetadata>) -> Array<PhysicalMetadata> & String:
  match metadata:
    case ALeaf{PhysicalMetadata{+live,+flag,+added,+changed}}: (ALeaf{PhysicalMetadata{live,flag,added,changed}},Bool.show(live) ++ ":" ++ flag_text(flag) ++ ":" ++ U32.show(added) ++ ":" ++ U32.show(changed))
    case ANode{left,right}: dump_join((dump(left),dump(right)))
def metadata_print(pair: Array<PhysicalMetadata> & String) -> IO(Unit):
  match pair:
    case (_,text): IO.print("META:" ++ text)
def complete_emit(owner: Complete) -> IO(Unit):
  match owner:
    case Complete{result,metadata}:
      do IO<Unit>:
        emit(result)
        metadata_print(dump(metadata))
def main() -> IO(Unit):
  do IO<Unit>:
    emit(check(~Main,~Aux,~main_get,~aux_get,~client,0n,1,ALeaf{Some{Main{1,2}}},ALeaf{Some{Aux{3,4}}},Leaf{True{}}))
    emit(check(~Main,~Aux,~main_get,~aux_get,~client,2n,1,tree(),auxiliaries(),occupancy()))
    replay(check(~Main,~Aux,~main_get,~aux_get,~client,2n,1,tree(),auxiliaries(),occupancy()))
    emit(check(~Main,~Aux,~main_get,~aux_get,~client,2n,1,tree(),auxiliaries(),Node{0,Node{0,Leaf{False{}},Leaf{False{}}},Node{0,Leaf{False{}},Leaf{False{}}}}))
    emit(check(~Main,~Aux,~main_get,~aux_get,~client,2n,1,ALeaf{None{}},ALeaf{None{}},occupancy()))
    emit(check(~Main,~Aux,~main_get,~aux_get,~client,2n,1,grow_main(),grow_aux(),Node{1,Node{1,Leaf{True{}},Leaf{False{}}},Node{0,Leaf{False{}},Leaf{False{}}}}))
    emit(check(~Main,~Aux,~main_get,~aux_get,~client,2n,1,ANode{ALeaf{None{}},ALeaf{None{}}},ANode{ALeaf{None{}},ALeaf{None{}}},Node{0,Node{0,Leaf{False{}},Leaf{False{}}},Node{0,Leaf{False{}},Leaf{False{}}}}))
    emit(bounds(Bool.and(U32.is_eq(7,8),(0 < 1 : U32)),tree(),auxiliaries()))
    emit(bounds(Bool.and((0 < 0 : U32),(0 <= 4 : U32)),tree(),auxiliaries()))
    emit(bounds(Bool.and((0 < 5 : U32),(5 <= 4 : U32)),tree(),auxiliaries()))
    complete_emit(physical_check(2n,tree(),auxiliaries(),metadata(),occupancy()))
    complete_emit(physical_check(2n,tree(),auxiliaries(),metadata(),Node{2,Node{0,Leaf{False{}},Leaf{False{}}},Node{2,Leaf{True{}},Leaf{True{}}}}))
    complete_emit(physical_check(2n,tree(),auxiliaries(),ANode{ALeaf{PhysicalMetadata{False{},None{},0,0}},ALeaf{PhysicalMetadata{False{},None{},0,0}}},Node{0,Node{0,Leaf{False{}},Leaf{False{}}},Node{0,Leaf{False{}},Leaf{False{}}}}))

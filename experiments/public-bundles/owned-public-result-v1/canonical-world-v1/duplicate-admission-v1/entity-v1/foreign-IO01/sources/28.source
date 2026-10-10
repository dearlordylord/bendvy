import Base

# Source-derived from exact concrete-v3 closure a4672d11; see extraction.json.
type Selection is Data:
  Required{}
  Present{}
  Absent{}
  Optional{}
type MetadataColumns<-F: Data> is Type:
  MetadataColumns{live: Array<Bool>, flags: Array<Maybe<&2,F>>, added: Array<U32>, changed: Array<U32>}
type Rows<-M: Type,-A: Type,-F: Data> is Type:
  Rows{main: Array<Maybe<M>>, aux: Array<Maybe<A>>, metadata: MetadataColumns<F>, capacity: U32, depth: Nat, high_water: U32}

def selected(-F: Data,selection: Selection,flag: Maybe<&2,F>) -> Bool:
  match selection flag:
    case Present{} None{}: False{}
    case Absent{} Some{_}: False{}
    case _ _: True{}
type PrototypeHandoffRows<-Schema:Data,-M:Type> is Type:
  HandoffNil{}
  HandoffCon{id:U32,owner:M,rest:PrototypeHandoffRows<Schema,M>}
type PrototypeHandoffState<-Schema:Data,-M:Type,-A:Type,-F:Data> is Type:
  PrototypeHandoffState{main:Array<Maybe<M>>,aux:Array<Maybe<A>>,live:Array<Bool>,flags:Array<Maybe<&2,F>>,added:Array<U32>,changed:Array<U32>,values:PrototypeHandoffRows<Schema,M>}
def prototype_handoff_restore_state(-Schema:Data,-M:Type,-A:Type,-F:Data,+id:U32,+namespace:U32,aux:Array<Maybe<A>>,live:Array<Bool>,flags:Array<Maybe<&2,F>>,added:Array<U32>,changed:Array<U32>,values:PrototypeHandoffRows<Schema,M>,result:Array<Maybe<M>> & Maybe<M>) -> PrototypeHandoffState<Schema,M,A,F>:
  match result:
    case Tuple{main,None{}}: PrototypeHandoffState{main,aux,live,flags,added,changed,values}
    case Tuple{main,Some{owner}}: PrototypeHandoffState{main,aux,live,flags,added,changed,HandoffCon{id,owner,values}}
def prototype_handoff_inspect_state(-Schema:Data,-M:Type,-A:Type,-F:Data,+id:U32,+namespace:U32,main:Array<Maybe<M>>,aux:Array<Maybe<A>>,live:Array<Bool>,flags:Array<Maybe<&2,F>>,added:Array<U32>,changed:Array<U32>,values:PrototypeHandoffRows<Schema,M>) -> PrototypeHandoffState<Schema,M,A,F>:
  prototype_handoff_restore_state(Schema,M,A,F,id,namespace,aux,live,flags,added,changed,values,Array.swap(Maybe<M>,main,U32.sub(id,1),None{}))

def prototype_handoff_struct_idx_selected(~Schema: Data,~M: Type,~A: Type,~F: Data,include: Bool,+id: U32,namespace: U32,main: Array<Maybe<M>>,aux: Array<Maybe<A>>,live: Array<Bool>,flags: Array<Maybe<&2,F>>,added: Array<U32>,changed: Array<U32>,values: PrototypeHandoffRows<Schema,M>,flag: Maybe<&2,F>) -> PrototypeHandoffState<Schema,M,A,F>:
  match include:
    case False{}: PrototypeHandoffState{main,aux,live,flags,added,changed,values}
    case True{}: prototype_handoff_inspect_state(Schema,M,A,F,id,namespace,main,aux,live,flags,added,changed,values)

def prototype_handoff_struct_idx_metadata(~Schema: Data,~M: Type,~A: Type,~F: Data,id: U32,namespace: U32,selection: Selection,main: Array<Maybe<M>>,aux: Array<Maybe<A>>,values: PrototypeHandoffRows<Schema,M>,live: Array<Bool>,added: Array<U32>,changed: Array<U32>,value: Bool,result: Array<Maybe<&2,F>> & Maybe<&2,F>) -> PrototypeHandoffState<Schema,M,A,F>:
  match value result:
    case False{} Tuple{flags,_}: PrototypeHandoffState{main,aux,live,flags,added,changed,values}
    case True{} Tuple{flags,+flag}: prototype_handoff_struct_idx_selected(~Schema,~M,~A,~F,selected(F,selection,flag),id,namespace,main,aux,live,flags,added,changed,values,flag)

def prototype_handoff_struct_cols_live(~Schema: Data,~M: Type,~A: Type,~F: Data,+id: U32,namespace: U32,selection: Selection,main: Array<Maybe<M>>,aux: Array<Maybe<A>>,values: PrototypeHandoffRows<Schema,M>,flags: Array<Maybe<&2,F>>,added: Array<U32>,changed: Array<U32>,result: Array<Bool> & Bool) -> PrototypeHandoffState<Schema,M,A,F>:
  match result:
    case Tuple{live,False{}}: PrototypeHandoffState{main,aux,live,flags,added,changed,values}
    case Tuple{live,True{}}: prototype_handoff_struct_idx_metadata(~Schema,~M,~A,~F,id,namespace,selection,main,aux,values,live,added,changed,True{},Array.get(Maybe<&2,F>,flags,U32.sub(id,1)))

def prototype_handoff_struct_idx_advance(~Schema: Data,~M: Type,~A: Type,~F: Data,valid: Bool,+id: U32,namespace: U32,selection: Selection,state: PrototypeHandoffState<Schema,M,A,F>) -> PrototypeHandoffState<Schema,M,A,F>:
  match valid state:
    case False{} state: state
    case True{} PrototypeHandoffState{main,aux,live,flags,added,changed,values}:
      prototype_handoff_struct_cols_live(~Schema,~M,~A,~F,id,namespace,selection,main,aux,values,flags,added,changed,Array.get(Bool,live,U32.sub(id,1)))

def prototype_handoff_finish_forward(-Schema:Data,-M:Type,-A:Type,-F:Data,capacity:U32,depth:Nat,high:U32,state:PrototypeHandoffState<Schema,M,A,F>) -> Rows<M,A,F> & PrototypeHandoffRows<Schema,M>:
  match state:
    case PrototypeHandoffState{main,aux,live,flags,added,changed,values}: (Rows{main,aux,MetadataColumns{live,flags,added,changed},capacity,depth,high},values)
def prototype_handoff_struct_idx_go(~Schema: Data,~M: Type,~A: Type,~F: Data,remaining: Nat,+id: U32,+capacity: U32,+depth: Nat,+high: U32,+selection: Selection,+namespace: U32,state: PrototypeHandoffState<Schema,M,A,F>) -> Rows<M,A,F> & PrototypeHandoffRows<Schema,M>:
  match remaining:
    case 0n: prototype_handoff_finish_forward(Schema,M,A,F,capacity,depth,high,state)
    case 1n++rest: prototype_handoff_struct_idx_go(~Schema,~M,~A,~F,rest,U32.sub(id,1),capacity,depth,high,selection,namespace,prototype_handoff_struct_idx_advance(~Schema,~M,~A,~F,Bool.and((0 < id : U32),(id <= capacity : U32)),id,namespace,selection,state))

def prototype_handoff_read_rows(~Schema: Data,~M: Type,~A: Type,~F: Data,rows: Rows<M,A,F>,selection: Selection,namespace: U32) -> Rows<M,A,F> & PrototypeHandoffRows<Schema,M>:
  match rows:
    case Rows{main,aux,MetadataColumns{live,flags,added,changed},capacity,depth,+high}:
      prototype_handoff_struct_idx_go(~Schema,~M,~A,~F,U32.to_nat(high),high,capacity,depth,high,selection,namespace,PrototypeHandoffState{main,aux,live,flags,added,changed,HandoffNil{}})


def prototype_handoff_recover_go(-Schema:Data,-M:Type,rows:PrototypeHandoffRows<Schema,M>,columns:Array<Maybe<M>>,ids:List<&2,U32>) -> Array<Maybe<M>> & List<&2,U32>:
  match rows:
    case HandoffNil{}: (columns,List.reverse(&2,U32,ids))
    case HandoffCon{+id,owner,rest}: prototype_handoff_recover_go(Schema,M,rest,Array.set(Maybe<M>,columns,U32.sub(id,1),Some{owner}),id <> ids)
def prototype_handoff_recover(-Schema:Data,-M:Type,rows:PrototypeHandoffRows<Schema,M>,columns:Array<Maybe<M>>) -> Array<Maybe<M>> & List<&2,U32>:
  prototype_handoff_recover_go(Schema,M,rows,columns,[])




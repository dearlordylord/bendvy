import Base
import /tmp/bendvy-query-frozen-provider-native-v3/experiments/s-integrate/storage.bend as S
import /tmp/bendvy-query-frozen-provider-native-v3/experiments/s-integrate/types.bend as T

def closed_metadata_empty(~F: Data,+depth: Nat) -> S.MetadataColumns<F>:
  S.MetadataColumns{[False{} : Bool^depth],[None{} : Maybe<&2,F>^depth],[0 : U32^depth],[0 : U32^depth]}

def closed_metadata_grow(~F: Data,columns: S.MetadataColumns<F>,+depth: Nat) -> S.MetadataColumns<F>:
  match columns:
    case S.MetadataColumns{live,flags,added,changed}: S.MetadataColumns{ANode{live,[False{} : Bool^depth]},ANode{flags,[None{} : Maybe<&2,F>^depth]},ANode{added,[0 : U32^depth]},ANode{changed,[0 : U32^depth]}}

def closed_metadata_get_changed(~F: Data,live: Array<Bool>,flags: Array<Maybe<&2,F>>,added: Array<U32>,l: Bool,f: Maybe<&2,F>,a: U32,result: Array<U32> & U32) -> S.MetadataColumns<F> & S.Metadata<F>:
  match result:
    case (changed,c): (S.MetadataColumns{live,flags,added,changed},S.Metadata{l,f,a,c})

def closed_metadata_get_added(~F: Data,live: Array<Bool>,flags: Array<Maybe<&2,F>>,changed: Array<U32>,index: U32,l: Bool,f: Maybe<&2,F>,result: Array<U32> & U32) -> S.MetadataColumns<F> & S.Metadata<F>:
  match result:
    case (added,a): closed_metadata_get_changed(~F,live,flags,added,l,f,a,Array.get(U32,changed,index))

def closed_metadata_get_flags(~F: Data,live: Array<Bool>,added: Array<U32>,changed: Array<U32>,+index: U32,l: Bool,result: Array<Maybe<&2,F>> & Maybe<&2,F>) -> S.MetadataColumns<F> & S.Metadata<F>:
  match result:
    case (flags,f): closed_metadata_get_added(~F,live,flags,changed,index,l,f,Array.get(U32,added,index))

def closed_metadata_get_live(~F: Data,flags: Array<Maybe<&2,F>>,added: Array<U32>,changed: Array<U32>,+index: U32,result: Array<Bool> & Bool) -> S.MetadataColumns<F> & S.Metadata<F>:
  match result:
    case (live,l): closed_metadata_get_flags(~F,live,added,changed,index,l,Array.get(Maybe<&2,F>,flags,index))

def closed_metadata_get(~F: Data,columns: S.MetadataColumns<F>,+index: U32) -> S.MetadataColumns<F> & S.Metadata<F>:
  match columns:
    case S.MetadataColumns{live,flags,added,changed}: closed_metadata_get_live(~F,flags,added,changed,index,Array.get(Bool,live,index))
# Query selection observes membership/flag only; stamps remain owned and untouched.

def closed_slots_empty(~P: Type,+depth: Nat) -> Array<Maybe<P>>:
  match depth:
    case 0n: ALeaf{None{}}
    case 1n+d: ANode{closed_slots_empty(~P,d),closed_slots_empty(~P,d)}

def closed_rows_empty(~M: Type,~A: Type,~F: Data) -> S.Rows<M,A,F>:
  S.Rows{ALeaf{None{}},ALeaf{None{}},closed_metadata_empty(~F,0n),1,0n,0}

def closed_grow_decide(~M: Type,~A: Type,~F: Data,needed: Bool,rows: S.Rows<M,A,F>,recurse: S.Rows<M,A,F> -> S.Rows<M,A,F>) -> S.Rows<M,A,F>:
  match needed rows:
    case False{} rows: rows
    case True{} S.Rows{m,a,f,+c,+d,h}:
      recurse(S.Rows{ANode{m,closed_slots_empty(M,d)},ANode{a,closed_slots_empty(A,d)},closed_metadata_grow(~F,f,d),U32.add(c,c),1n+d,h})

def closed_grow(~M: Type,~A: Type,~F: Data,fuel: Nat,+id: U32,rows: S.Rows<M,A,F>) -> S.Rows<M,A,F>:
  match fuel rows:
    case 0n rows: rows
    case 1n+n S.Rows{m,a,f,+c,d,h}: closed_grow_decide(~M,~A,~F,Bool.and((c < id : U32),(c <= 65536 : U32)),S.Rows{m,a,f,c,d,h},(grown => closed_grow(~M,~A,~F,n,id,grown)))

type Raw is Type:
  Raw{payload:Array<U32>}
def inspected(result:S.MetadataColumns<T.Selected> & S.Metadata<T.Selected>) -> U32:
  match result:
    case (_,S.Metadata{_,_,_,stamp}): stamp
def grown(rows:S.Rows<Raw,Raw,T.Selected>) -> U32:
  match rows:
    case S.Rows{_,_,columns,_,_,_}: inspected(closed_metadata_get(~T.Selected,columns,1))
def main() -> U32:
  grown(closed_grow(~Raw,~Raw,~T.Selected,17n,2,closed_rows_empty(~Raw,~Raw,~T.Selected)))

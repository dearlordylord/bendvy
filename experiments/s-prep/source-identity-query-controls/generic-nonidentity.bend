import Base
import ./storage.bend as S
import ./query.bend as Q

type Schema is Data:
  Schema{}
type Other is Data:
  Other{}
type Owned is Type:
  Owned{items:Array<U32>,scalar:U32}
def words_leaf(+value:U32) -> Array<U32> & String: (ALeaf{value},U32.show(value))
def words_join(result:(Array<U32> & String) & (Array<U32> & String)) -> Array<U32> & String:
  match result:
    case ((left,lt),(right,rt)): (ANode{left,right},"(" ++ lt ++ "," ++ rt ++ ")")
def words(array:Array<U32>) -> Array<U32> & String:
  match array:
    case ALeaf{value}: words_leaf(value)
    case ANode{left,right}: words_join((words(left),words(right)))
def owned_words(+scalar:U32,result:Array<U32> & String) -> Owned & String:
  match result:
    case (items,text): (Owned{items,scalar},text ++ "@" ++ U32.show(scalar))
def owned(owner:Owned) -> Owned & String:
  match owner:
    case Owned{items,scalar}: owned_words(scalar,words(items))
def maybe_owned(result:Owned & String) -> Array<Maybe<Owned>> & String:
  match result:
    case (owner,text): (ALeaf{Some{owner}},text)
def owners_join(result:(Array<Maybe<Owned>> & String) & (Array<Maybe<Owned>> & String)) -> Array<Maybe<Owned>> & String:
  match result:
    case ((left,lt),(right,rt)): (ANode{left,right},"(" ++ lt ++ "," ++ rt ++ ")")
def owners(array:Array<Maybe<Owned>>) -> Array<Maybe<Owned>> & String:
  match array:
    case ALeaf{None{}}: (ALeaf{None{}},"none")
    case ALeaf{Some{owner}}: maybe_owned(owned(owner))
    case ANode{left,right}: owners_join((owners(left),owners(right)))
def handles(values:List<&2,S.Handle<Schema>>) -> String:
  match values:
    case Nil{}: "end"
    case Con{S.Handle{ns,id},tail}: U32.show(ns) ++ ":" ++ U32.show(id) ++ ";" ++ handles(tail)
def flags(values:Array<Maybe<&2,Unit>>) -> String:
  match values:
    case ALeaf{None{}}: "0"
    case ALeaf{Some{_}}: "1"
    case ANode{left,right}: "(" ++ flags(left) ++ "," ++ flags(right) ++ ")"
def bools(values:Array<Bool>) -> String:
  match values:
    case ALeaf{False{}}: "0"
    case ALeaf{True{}}: "1"
    case ANode{left,right}: "(" ++ bools(left) ++ "," ++ bools(right) ++ ")"
def words_text(result:Array<U32> & String) -> String:
  match result:
    case (_,text): text
def snapshot_fields(+ns:U32,next:U32,capacity:U32,depth:Nat,high:U32,live:Array<Bool>,flag:Array<Maybe<&2,Unit>>,added:Array<U32>,changed:Array<U32>,mode:U32,values:List<&2,S.Handle<Schema>>,parts:(Array<Maybe<Owned>> & String) & ((Array<Maybe<Owned>> & String) & (Owned & String))) -> String:
  match parts:
    case ((main,mt),((aux,at),(ledger,lt))): U32.show(ns) ++ ":" ++ U32.show(next) ++ "|" ++ U32.show(capacity) ++ ":" ++ Nat.show(depth) ++ ":" ++ U32.show(high) ++ "|" ++ mt ++ "|" ++ at ++ "|" ++ bools(live) ++ "|" ++ flags(flag) ++ "|" ++ words_text(words(added)) ++ "|" ++ words_text(words(changed)) ++ "|" ++ lt ++ "|" ++ U32.show(mode) ++ "|" ++ handles(values)
def snapshot_rows(ns:U32,next:U32,ledger:Owned,mode:U32,values:List<&2,S.Handle<Schema>>,rows:S.Rows<Owned,Owned,Unit>) -> String:
  match rows:
    case S.Rows{main,aux,S.MetadataColumns{live,flag,added,changed},capacity,depth,high}: snapshot_fields(ns,next,capacity,depth,high,live,flag,added,changed,mode,values,(owners(main),(owners(aux),owned(ledger))))
def snapshot(result:S.World<Schema,Owned,Owned,Unit,Owned,U32> & List<&2,S.Handle<Schema>>) -> String:
  match result:
    case (S.World{ns,next,rows,Nil{},Some{ledger},mode},values): snapshot_rows(ns,next,ledger,mode,values,rows)
    case _: "unexpected-context"
def bump_return(+scalar:U32,result:Array<U32> & U32) -> Owned & String:
  match result:
    case (items,value): owned(Owned{Array.set(U32,items,0,U32.add(value,1)),U32.add(scalar,1)})
def getter(owner:Owned) -> Owned & String:
  match owner:
    case Owned{items,scalar}: bump_return(scalar,Array.get(U32,items,0))
def client_finish(~P:Type,~U:Type,p:P,first:String,second:String,auxfirst:Maybe<&2,String>,result:U & Maybe<&2,String>) -> P & (U & String):
  match auxfirst result:
    case Some{af} Tuple{u,Some{asecond}}: (p,(u,first ++ "/" ++ second ++ "/" ++ af ++ "/" ++ asecond))
    case _ Tuple{u,_}: (p,(u,"unexpected-aux"))
def client_aux(~P:Type,~U:Type,~ag:U -> U & Maybe<&2,String>,p:P,first:String,second:String,result:U & Maybe<&2,String>) -> P & (U & String):
  match result:
    case (u,af): client_finish(~P,~U,p,first,second,af,ag(u))
def client_second(~P:Type,~U:Type,~ag:U -> U & Maybe<&2,String>,u:U,first:String,result:P & String) -> P & (U & String):
  match result:
    case (p,second): client_aux(~P,~U,~ag,p,first,second,ag(u))
def client_first(~P:Type,~U:Type,~get:P -> Unit -> P & String,~ag:U -> U & Maybe<&2,String>,u:U,result:P & String) -> P & (U & String):
  match result:
    case (p,first): client_second(~P,~U,~ag,u,first,get(p,Unit{}))
def client(~P:Type,~U:Type,~get:P -> Unit -> P & String,~ag:U -> U & Maybe<&2,String>,handle:S.Handle<Schema>,flag:Maybe<&2,Unit>,p:P,u:U) -> P & (U & String):
  client_first(~P,~U,~get,~ag,u,get(p,Unit{}))
def returned(result:S.World<Schema,Owned,Owned,Unit,Owned,U32> & List<&2,String>) -> String:
  match result:
    case (world,Con{text,Nil{}}): text ++ "|" ++ snapshot((world,[]))
    case _: "unexpected-result"
def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(returned(Q.each(Schema,Owned,Owned,Unit,Unit,String,String,String,Owned,U32,getter,getter,client,Q.Required{},S.World{7,2,S.Rows{ALeaf{Some{Owned{ALeaf{1000},1}}},ALeaf{Some{Owned{ALeaf{101000},101}}},S.MetadataColumns{ALeaf{True{}},ALeaf{Some{Unit{}}},ALeaf{100},ALeaf{200}},1,0n,1},[],Some{Owned{ALeaf{999000},999}},123})))
    return Unit{}

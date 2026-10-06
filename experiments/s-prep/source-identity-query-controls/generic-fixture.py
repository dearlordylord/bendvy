import pathlib
H=pathlib.Path(__file__).resolve().parent
src=(H/'full-shape.bend').read_text();src=src[:src.index('def world0')]
src+='''def bump_return(+scalar:U32,result:Array<U32> & U32) -> Owned & String:
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
'''
(H/'generic-nonidentity.bend').write_text(src)
(H/'generic-nonidentity-expected.txt').write_text('1001@2/1002@3/101001@102/101002@103|7:2|1:0:1|1002@3|101002@103|1|1|100|200|999000@999|123|end\n')

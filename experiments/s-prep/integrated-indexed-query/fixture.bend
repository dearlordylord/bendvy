import Base
import ./query.bend as Q
import ./storage.bend as S
type Schema is Data:
  Schema{}
type Main is Type:
  Main{a: U32,b: U32}
type Aux is Type:
  Aux{x: U32,y: U32}
def main_get(owner: Main) -> Main & U32:
  match owner:
    case Main{+a,+b}: (Main{a,b},U32.add(a,b))
def aux_get(owner: Aux) -> Aux & U32:
  match owner:
    case Aux{+x,+y}: (Aux{x,y},U32.add(x,y))
def flag_value(flag: Maybe<&2,U32>) -> U32:
  match flag:
    case None{}: 0
    case Some{value}: value
def aux_value(aux: Maybe<&2,U32>) -> U32:
  match aux:
    case None{}: 0
    case Some{value}: value
def client_aux(-P: Type,-U: Type,p: P,m: U32,id: U32,f: U32,result: U & Maybe<&2,U32>) -> P & (U & U32):
  match result:
    case (u,a): (p,(u,U32.add(U32.mul(id,100000),U32.add(m,U32.add(aux_value(a),f)))))
def client_main(-P: Type,-U: Type,get: U -> U & Maybe<&2,U32>,u: U,id: U32,f: U32,result: P & U32) -> P & (U & U32):
  match result:
    case (p,m): client_aux(P,U,p,m,id,f,get(u))
def client(~P: Type,~U: Type,get: P -> Unit -> P & U32,aux: U -> U & Maybe<&2,U32>,handle: S.Handle<Schema>,flag: Maybe<&2,U32>,p: P,u: U) -> P & (U & U32):
  match handle:
    case S.Handle{_,id}: client_main(P,U,aux,u,id,flag_value(flag),get(p,Unit{}))
def rows() -> S.Rows<Main,Aux,U32>:
  S.Rows{
    ANode{ANode{ALeaf{Some{Main{10,11}}},ALeaf{Some{Main{20,21}}}},ANode{ALeaf{None{}},ALeaf{Some{Main{40,41}}}}},
    ANode{ANode{ALeaf{Some{Aux{100,101}}},ALeaf{Some{Aux{200,201}}}},ANode{ALeaf{Some{Aux{300,301}}},ALeaf{Some{Aux{400,401}}}}},
    ANode{ANode{ALeaf{S.Metadata{True{},Some{7},1,2}},ALeaf{S.Metadata{False{},None{},0,0}}},ANode{ALeaf{S.Metadata{True{},Some{9},3,4}},ALeaf{S.Metadata{True{},None{},5,6}}}},4,2n,4}
def show(result: S.Rows<Main,Aux,U32> & List<&2,U32>) -> IO(Unit):
  match result:
    case (_,values): IO.print(List.show(~&2,~U32,~U32.show,values))
def reread(result: S.Rows<Main,Aux,U32> & List<&2,U32>) -> IO(Unit):
  match result:
    case (rows,values):
      do IO<Unit>:
        IO.print(List.show(~&2,~U32,~U32.show,values))
        show(Q.read_rows(~Schema,~Main,~Aux,~U32,~Unit,~U32,~U32,~U32,~main_get,~aux_get,~client,rows,Q.Optional{},7))
def malformed(result: S.Rows<Main,Aux,U32>) -> S.Rows<Main,Aux,U32>:
  match result:
    case S.Rows{m,a,_,c,d,h}: S.Rows{m,a,ALeaf{S.Metadata{False{},None{},0,0}},c,d,h}
def main_leaf(owner: Maybe<Main>) -> U32:
  match owner:
    case None{}: 0
    case Some{Main{a,b}}: U32.add(a,b)
def main_sum(array: Array<Maybe<Main>>) -> U32:
  match array:
    case ALeaf{owner}: main_leaf(owner)
    case ANode{left,right}: U32.add(main_sum(left),main_sum(right))
def aux_leaf(owner: Maybe<Aux>) -> U32:
  match owner:
    case None{}: 0
    case Some{Aux{x,y}}: U32.add(x,y)
def aux_sum(array: Array<Maybe<Aux>>) -> U32:
  match array:
    case ALeaf{owner}: aux_leaf(owner)
    case ANode{left,right}: U32.add(aux_sum(left),aux_sum(right))
def owners(result: S.Rows<Main,Aux,U32> & List<&2,U32>) -> IO(Unit):
  match result:
    case (S.Rows{m,a,_,_,_,_},values): IO.print(List.show(~&2,~U32,~U32.show,values) ++ ":" ++ U32.show(main_sum(m)) ++ ":" ++ U32.show(aux_sum(a)))
def main() -> IO(Unit):
  do IO<Unit>:
    reread(Q.read_rows(~Schema,~Main,~Aux,~U32,~Unit,~U32,~U32,~U32,~main_get,~aux_get,~client,rows(),Q.Required{},7))
    show(Q.read_rows(~Schema,~Main,~Aux,~U32,~Unit,~U32,~U32,~U32,~main_get,~aux_get,~client,rows(),Q.Present{},7))
    show(Q.read_rows(~Schema,~Main,~Aux,~U32,~Unit,~U32,~U32,~U32,~main_get,~aux_get,~client,rows(),Q.Absent{},7))
    owners(Q.read_rows(~Schema,~Main,~Aux,~U32,~Unit,~U32,~U32,~U32,~main_get,~aux_get,~client,malformed(rows()),Q.Optional{},7))

import Base
import /tmp/bendvy-fourhour-closed-reservation-v2-probe/experiments/s-integrate/storage.bend as S
import /tmp/bendvy-fourhour-closed-reservation-v2-probe/experiments/s-integrate/commands.bend as C
import /tmp/bendvy-fourhour-closed-reservation-v2-probe/experiments/s-integrate/types.bend as T

type Raw is Type:
  Raw{payload:Array<U32>}
type Report is Data:
  Report{code:U32,main:List<&2,U32>,aux:List<&2,U32>,ledger:List<&2,U32>}
def cell3(+a:U32,+b:U32,+c:U32,result:Array<U32> & U32) -> List<&2,U32>:
  match result:
    case (_,d): [a,b,c,d]
def cell2(+a:U32,+b:U32,result:Array<U32> & U32) -> List<&2,U32>:
  match result:
    case (payload,c): cell3(a,b,c,Array.get(U32,payload,3))
def cell1(+a:U32,result:Array<U32> & U32) -> List<&2,U32>:
  match result:
    case (payload,b): cell2(a,b,Array.get(U32,payload,2))
def cell0(result:Array<U32> & U32) -> List<&2,U32>:
  match result:
    case (payload,a): cell1(a,Array.get(U32,payload,1))
def cells(owner:Raw) -> List<&2,U32>:
  match owner:
    case Raw{payload}: cell0(Array.get(U32,payload,0))
def success(result:T.Reservation<S.World<T.HealthSchema,Raw,Raw,U32,Raw,U32>,S.Handle<T.HealthSchema>,S.Bundle<Raw,Raw,U32>>) -> Report:
  match result:
    case T.Reserved{S.World{7,2,S.Rows{ALeaf{None{}},ALeaf{None{}},S.MetadataColumns{ALeaf{False{}},ALeaf{None{}},ALeaf{0},ALeaf{0}},1,0n,0},Con{S.Spawn{1,S.Bundle{Some{main},Some{aux},Some{17}}},Con{S.RemoveFlag{9},Nil{}}},Some{ledger},9},S.Handle{7,1}}: Report{1,cells(main),cells(aux),cells(ledger)}
    case _: Report{0,[],[],[]}
def rejected(result:T.Reservation<S.World<T.HealthSchema,Raw,Raw,U32,Raw,U32>,S.Handle<T.HealthSchema>,S.Bundle<Raw,Raw,U32>>) -> Report:
  match result:
    case T.ReserveRejected{S.World{7,4294967295,S.Rows{ALeaf{None{}},ALeaf{None{}},S.MetadataColumns{ALeaf{False{}},ALeaf{None{}},ALeaf{0},ALeaf{0}},1,0n,0},Con{S.RemoveFlag{9},Nil{}},Some{ledger},9},S.Bundle{Some{main},Some{aux},Some{17}}}: Report{2,cells(main),cells(aux),cells(ledger)}
    case _: Report{0,[],[],[]}
def foreign(result:T.CommandResult<S.World<T.HealthSchema,Raw,Raw,U32,Raw,U32>,Raw>) -> Report:
  match result:
    case T.CommandMissing{S.World{7,3,S.Rows{ALeaf{None{}},ALeaf{None{}},S.MetadataColumns{ALeaf{False{}},ALeaf{None{}},ALeaf{0},ALeaf{0}},1,0n,0},Con{S.RemoveFlag{9},Nil{}},Some{ledger},9},main}: Report{3,cells(main),[],cells(ledger)}
    case _: Report{0,[],[],[]}
def raw(+base:U32) -> Raw:
  Raw{ANode{ANode{ALeaf{base},ALeaf{(base + 1 : U32)}},ANode{ALeaf{(base + 2 : U32)},ALeaf{(base + 3 : U32)}}}}
def world(+next:U32) -> S.World<T.HealthSchema,Raw,Raw,U32,Raw,U32>:
  S.World{7,next,S.prototype_closed_rows_empty(~Raw,~Raw,~U32),[S.RemoveFlag{9}],Some{raw(201)},9}
def main() -> Report & (Report & Report):
  (success(C.prototype_closed_reserve(~Raw,~Raw,~U32,T.HealthSchema,Raw,U32,world(1),S.Bundle{Some{raw(41)},Some{raw(101)},Some{17}})),(rejected(C.prototype_closed_reserve(~Raw,~Raw,~U32,T.HealthSchema,Raw,U32,world(4294967295),S.Bundle{Some{raw(41)},Some{raw(101)},Some{17}})),foreign(C.insert_main(T.HealthSchema,Raw,Raw,U32,Raw,U32,world(3),S.Handle{8,1},raw(41)))))

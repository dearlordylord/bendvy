import Base
import ../../examples/query-composition/schema.bend as S
import ../../examples/query-composition/scenario-ops.bend as Ops
import ../../examples/query-composition/declarations.bend as D
import ../../examples/query-composition/gameplay.bend as G
import ../../examples/query-composition/observe.bend as O
import ../../examples/query-composition/json.bend as J
import ../../src/ecs/query-contract.bend as QC
import ../../src/ecs/world.bend as W
import ../../src/ecs/transaction.bend as T

def final(observed: S.World() & List<&2,String>) -> String:
  (_,rows) = observed
  J.array(rows)
def observed(result: QC.Executed<S.World(),G.Error,Unit>) -> String:
  match result:
    case QC.Executed{world,Done{_}}: final(O.all(world))
    case QC.Executed{_,Fail{_}}: "null"
def created(+values: List<&2,U32>,creation: W.Creation<S.Schema,S.Store,Unit,Unit>) -> String:
  match creation:
    case W.Created{_,world}: observed(QC.single(~S.Schema,~S.Store,~Unit,~Unit,~G.WorkOps,~D.work_plan(),~Unit,~G.Error,~Unit,~G.work_body,Unit{},W.barrier(~S.Schema,~S.Store,~Unit,~Unit,Ops.commit(Ops.spawn(T.begin(~S.World(),~Unit,world),S.Bundle{Some{S.stock_owner(S.StockView{10,values})},Some{S.recipe_payload(20)},None{},Some{S.Enabled{}},None{}}))),0))
    case W.CreateRejected{_,_}: "null"
def test(values: List<&2,U32>) -> String:
  created(values,S.create(W.factory()))
def main() -> IO(Unit):
  IO.print("[" ++ test([]) ++ "," ++ test([1,2,3,4,5,6,7,8,9]) ++ "," ++ test([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17]) ++ "]")

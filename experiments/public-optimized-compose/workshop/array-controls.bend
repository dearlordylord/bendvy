import Base
import schema.bend as S
import json.bend as J
import ../../../src/ecs/component.bend as C

def observed(result: S.Stock & S.StockView) -> String:
  (_,view) = result
  J.stock(C.Found{view})
def cells(+values: List<&2,U32>) -> String:
  observed(S.project_stock(S.stock_owner(S.StockView{99,values})))
def main() -> IO(Unit):
  IO.print("[" ++ cells([]) ++ "," ++ cells([1,2,3,4,5,6,7,8,9]) ++ "," ++ cells([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17]) ++ "]")

import Base
import /tmp/bendvy-closed-frontier-reproduced/experiments/s-integrate/storage.bend as S

type Raw is Type:
  Raw{payload:Array<U32>}
def value(result:Array<U32> & U32) -> U32:
  match result:
    case (_,v): v
def extracted(result:S.Rows<Raw,Raw,U32> & Maybe<S.Row<Raw,Raw,U32>>) -> U32:
  match result:
    case (_,None{}): 0
    case (_,Some{S.Row{_,None{},_,_,_,_}}): 0
    case (_,Some{S.Row{_,Some{Raw{payload}},_,_,_,_}}): value(Array.get(U32,payload,0))
def placed(result:S.Placement<Raw,Raw,U32>) -> U32:
  match result:
    case S.Placed{rows}: extracted(S.prototype_closed_rows_extract(~Raw,~Raw,~U32,rows,2))
    case S.Rejected{_,_}: 99
def main() -> U32:
  placed(S.prototype_closed_rows_place(~Raw,~Raw,~U32,S.prototype_closed_rows_empty(~Raw,~Raw,~U32),S.Row{2,Some{Raw{ALeaf{42}}},None{},Some{7},3,4}))

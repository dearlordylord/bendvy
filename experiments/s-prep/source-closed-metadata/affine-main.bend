import Base
import /tmp/bendvy-metadata-cps-reproduced/experiments/s-integrate/storage.bend as S

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
def main() -> U32:
  extracted(S.rows_extract(Raw,Raw,U32,S.Rows{ALeaf{Some{Raw{ALeaf{42}}}},ALeaf{None{}},S.metadata_set(U32,S.metadata_empty(U32,0n),0,S.Metadata{True{},Some{7},3,4}),1,0n,1},1))

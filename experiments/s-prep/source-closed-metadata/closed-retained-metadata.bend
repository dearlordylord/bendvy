import Base
import /tmp/bendvy-closed-frontier-reproduced/experiments/s-integrate/storage.bend as S
def done(result:S.MetadataColumns<U32> & S.Metadata<U32>,old:S.Metadata<U32>) -> U32 & U32:
  match result old:
    case (_,S.Metadata{_,_,_,changed}) S.Metadata{_,_,_,before}: (before,changed)
def marked(result:S.MetadataColumns<U32> & S.Metadata<U32>) -> U32 & U32:
  match result:
    case (columns,old): done(S.prototype_closed_metadata_get(~U32,S.metadata_mark(U32,columns,0,9),0),old)
def live(result:S.MetadataColumns<U32> & Bool) -> U32 & U32:
  match result:
    case (columns,_): marked(S.prototype_closed_metadata_get(~U32,columns,0))
def main() -> U32 & U32:
  live(S.prototype_closed_metadata_live(~U32,S.prototype_closed_metadata_set(~U32,S.prototype_closed_metadata_empty(~U32,0n),0,S.Metadata{True{},Some{7},3,4}),0))

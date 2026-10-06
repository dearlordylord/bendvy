import Base
import ./query.bend as Q
import ./storage.bend as S

type Schema is Data:
  Schema{}
type Other is Data:
  Other{}
type Owned is Type:
  Owned{items:Array<U32>,scalar:U32}
def bad(owner:Owned) -> Owned & Owned: (owner,owner)

import Base
import ./query.bend as Q
import ./storage.bend as S

type Schema is Data:
  Schema{}
type Other is Data:
  Other{}
type Owned is Type:
  Owned{items:Array<U32>,scalar:U32}
def bad(world:S.World<Schema,Owned,Owned,Unit,Owned,U32>) -> S.World<Schema,U32,Owned,Unit,Owned,U32> & List<&2,S.Handle<Schema>>:
  Q.prototype_identity_each(Schema,U32,Owned,Unit,Owned,U32,Q.Required{},world)

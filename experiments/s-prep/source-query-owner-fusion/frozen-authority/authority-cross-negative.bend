import Base
import ./storage.bend as S
import ./query.bend as Q
import ./types.bend as T
import ./owners.bend as A
import ./getter-control.bend as F

type OtherQuerySchema is Data:
  OtherQuerySchema{}
def bad(world:S.World<F.QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit>) -> S.World<F.QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> & T.Access<String>:
  Q.lookup(F.QuerySchemaOne,A.Motion,A.Health,Unit,Unit,String,String,String,Unit,Unit,A.motion_observe,A.health_observe,F.callback,Q.Required{},world,{S.Handle{7,1}: S.Handle<OtherQuerySchema>})

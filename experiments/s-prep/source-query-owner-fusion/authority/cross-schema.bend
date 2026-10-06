import Base
import ./query.bend as Q
import ./storage.bend as S
import ./owners.bend as A
import ./getter-control-flat.bend as F

type OtherSchema is Data:
  OtherSchema{}
def client(~P:Type,~U:Type,~get:P -> Unit -> P & String,~ag:U -> U & Maybe<&2,String>,handle:S.Handle<OtherSchema>,flag:Maybe<&2,Unit>,p:P,u:U) -> Q.PrototypeOwnerResult<P,U,String>:
  Q.PrototypeOwnerResult{p,u,"cross"}
def bad(world:S.World<F.QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit>) -> S.World<F.QuerySchemaOne,A.Motion,A.Health,Unit,Unit,Unit> & List<&2,String>:
  Q.prototype_owner_each(F.QuerySchemaOne,A.Motion,A.Health,Unit,Unit,String,String,String,Unit,Unit,A.motion_observe,A.health_observe,client,Q.Required{},world)

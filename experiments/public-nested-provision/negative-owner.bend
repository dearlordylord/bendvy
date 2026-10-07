import Base
import app.bend as A
import ../../src/ecs/schedule-provision.bend as P
def duplicate(owner:P.Provisioned<A.Schema,A.Store,A.Resources,U32,A.Owners>) -> P.Provisioned<A.Schema,A.Store,A.Resources,U32,A.Owners> & P.Provisioned<A.Schema,A.Store,A.Resources,U32,A.Owners>:
  (owner,owner)

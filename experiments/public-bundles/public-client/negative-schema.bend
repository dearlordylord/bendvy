import Base
import ../public.bend as P
import ../combined-control.bend as A
import ../combined-other.bend as B
import ../prototype.bend as Pack
import ../constructor-control.bend as K
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/world.bend as W
import trusted.bend as T
def bad(world:W.World<B.Schema,B.Store,B.Mail,U32>,payload:Pack.Pack<K.Raw<Array<U32>>,Pack.Pack<K.Raw<U32>,Pack.Pack<K.Raw<K.Tag>,Pack.Pack<K.Raw<K.QueueOwner>,Unit>>>>) -> W.World<A.Schema,A.Store,A.Mail,U32> & T.Observation:
  T.request(world,payload)

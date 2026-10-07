import Base
import ../public.bend as P
import ../combined-control.bend as A
import ../combined-other.bend as B
import ../prototype.bend as Pack
import ../constructor-control.bend as K
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/world.bend as W
import trusted.bend as T
import ../../../src/ecs/schema-fragments.bend as SF
def make(owners:W.World<A.Schema,A.Store,A.Mail,U32> & Pack.Pack<K.Raw<Array<U32>>,Pack.Pack<K.Raw<U32>,Pack.Pack<K.Raw<K.Tag>,Pack.Pack<K.Raw<K.QueueOwner>,Unit>>>>) -> W.World<A.Schema,A.Store,A.Mail,U32> & Pack.Pack<K.Raw<Array<U32>>,Pack.Pack<K.Raw<U32>,Pack.Pack<K.Raw<K.Tag>,Pack.Pack<K.Raw<K.QueueOwner>,Unit>>>>:
  owners
def bad(fragment:SF.Fragment<B.Schema,W.World<A.Schema,A.Store,A.Mail,U32> & Pack.Pack<K.Raw<Array<U32>>,Pack.Pack<K.Raw<U32>,Pack.Pack<K.Raw<K.Tag>,Pack.Pack<K.Raw<K.QueueOwner>,Unit>>>>>) -> SF.Bound<A.Schema,W.World<A.Schema,A.Store,A.Mail,U32> & Pack.Pack<K.Raw<Array<U32>>,Pack.Pack<K.Raw<U32>,Pack.Pack<K.Raw<K.Tag>,Pack.Pack<K.Raw<K.QueueOwner>,Unit>>>>,W.World<A.Schema,A.Store,A.Mail,U32> & Pack.Pack<K.Raw<Array<U32>>,Pack.Pack<K.Raw<U32>,Pack.Pack<K.Raw<K.Tag>,Pack.Pack<K.Raw<K.QueueOwner>,Unit>>>>>:
  P.provision_declared(~A.Schema,~(W.World<A.Schema,A.Store,A.Mail,U32> & Pack.Pack<K.Raw<Array<U32>>,Pack.Pack<K.Raw<U32>,Pack.Pack<K.Raw<K.Tag>,Pack.Pack<K.Raw<K.QueueOwner>,Unit>>>>),~(W.World<A.Schema,A.Store,A.Mail,U32> & Pack.Pack<K.Raw<Array<U32>>,Pack.Pack<K.Raw<U32>,Pack.Pack<K.Raw<K.Tag>,Pack.Pack<K.Raw<K.QueueOwner>,Unit>>>>),~make,fragment,[])

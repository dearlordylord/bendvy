import Base
import ../public.bend as P
import ../combined-control.bend as A
import ../combined-other.bend as B
import ../prototype.bend as Pack
import ../constructor-control.bend as K
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/world.bend as W
import trusted.bend as T
def bad(-H:Type,cap:Cap.Read<H,String>,payload:Pack.Pack<K.Raw<Array<U32>>,Pack.Pack<K.Raw<U32>,Pack.Pack<K.Raw<K.Tag>,Pack.Pack<K.Raw<K.QueueOwner>,Unit>>>>,ctx:H) -> H & T.Observation:
  P.apply(H,Pack.Pack<K.Raw<Array<U32>>,Pack.Pack<K.Raw<U32>,Pack.Pack<K.Raw<K.Tag>,Pack.Pack<K.Raw<K.QueueOwner>,Unit>>>>,T.Observation,cap,payload,ctx)

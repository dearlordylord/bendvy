import Base
import ../public.bend as P
import trusted-other.bend as T
import ../prototype.bend as Pack
import ../constructor-control.bend as K
import ../../../src/ecs/capabilities.bend as Cap
def done(-H:Type,observed:H & T.Observation) -> H & Unit:
  match observed:
    case (ctx,observation): (ctx,Unit{})
def run(-H:Type,cap:Cap.Request<H,Pack.Pack<K.Raw<Array<U32>>,Pack.Pack<K.Raw<U32>,Pack.Pack<K.Raw<K.Tag>,Pack.Pack<K.Raw<K.QueueOwner>,Unit>>>>,T.Observation>,payload:Pack.Pack<K.Raw<Array<U32>>,Pack.Pack<K.Raw<U32>,Pack.Pack<K.Raw<K.Tag>,Pack.Pack<K.Raw<K.QueueOwner>,Unit>>>>,ctx:H) -> H & Unit:
  done(H,P.apply(H,Pack.Pack<K.Raw<Array<U32>>,Pack.Pack<K.Raw<U32>,Pack.Pack<K.Raw<K.Tag>,Pack.Pack<K.Raw<K.QueueOwner>,Unit>>>>,T.Observation,cap,payload,ctx))

import Base
import ../../../public-bundles/public.bend as Public
import ../../../../src/ecs/capabilities.bend as Cap
def bad(-H:Type,cap:Cap.Read<H,Unit>,payload:Array<U32>,ctx:H) -> H & Unit:
  Public.apply(H,Array<U32>,Unit,cap,payload,ctx)

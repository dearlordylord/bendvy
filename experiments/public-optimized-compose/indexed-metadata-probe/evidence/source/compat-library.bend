import Base
import ../../../src/ecs/lifecycle.bend as L
type Carrier<-C:Type> is Type:
  Owned{owner:C}
  Wrapped{inner:Carrier<C>}
type Column<-C:Type> is Type:
  Column{owner:C,stamps:List<&2,L.Entry>}
  Prepared{carrier:Carrier<C>}
type Nominal is Type:
  Nominal{owner:Array<U32>}

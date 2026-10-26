import Base
import ../declarations.bend as D
import ../payloads.bend as P
import ../../../src/ecs/execution-builder.bend as Build
import ../../../src/ecs/execution-access.bend as Access
import ../../../src/ecs/execution-projection.bend as Projection
import ../../../src/ecs/ordinary-schema.bend as Schema

type Nominal is Data:
  Nominal{}
def Ops(H:Type) -> Type:Access.ResourceWrite<H,P.Counter,String>
def reset(~H:Type,~B:Type,result:B & Ops(H)) -> B & Ops(H):
  match result:
    case (_,caps):(Build.Book{[]},caps)
def selection(~H:Type,~B:Type,~component_read:Build.ComponentRead(~Nominal,~D.Store(~Nominal),~D.Resources(~Nominal),~H,~B),~component_write:Build.ComponentWrite(~Nominal,~D.Store(~Nominal),~D.Resources(~Nominal),~H,~B),~resource_read:Build.ResourceRead(~Nominal,~D.Store(~Nominal),~D.Resources(~Nominal),~H,~B),~resource_write:Build.ResourceWrite(~Nominal,~D.Store(~Nominal),~D.Resources(~Nominal),~H,~B),~query:Build.Query(~Nominal,~D.Store(~Nominal),~D.Resources(~Nominal),~H,~B),book:B) -> B & Ops(H):
  reset(~H,~B,resource_write(D.resource_layout(),D.first_route(),{==},{==},book))
def declaration(~H:Type,~B:Type,~builder:Build.Builder(~Nominal,~D.Store(~Nominal),~D.Resources(~Nominal),~H,~B),book:B) -> B & Ops(H):
  builder(Ops,selection(~H,~B),book)

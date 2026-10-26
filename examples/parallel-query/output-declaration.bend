import Base
import ./declarations.bend as D
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/execution-composer-layout.bend as Layout

def route() -> Layout.Route:Layout.InLeft{Layout.AtLeaf{}}
def Ops(~S:Data,H:Type) -> Type:Q.OutputEach<S,H,D.layout(),route(),String>
def selection(~S:Data,~mode:Q.Mode,~H:Type,~B:Type,~component_read:Build.ComponentRead(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~component_write:Build.ComponentWrite(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~resource_read:Build.ResourceRead(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~resource_write:Build.ResourceWrite(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~query:Build.Query(~S,~D.Store(~S),~D.Resources(~S),~H,~B),book:B) -> B & Ops(~S,H):
  Build.output_query(~S,~D.Store(~S),~D.Resources(~S),~D.layout(),~route(),~{==},~{==},~{==},~String,~mode,~H,~B,~query,book)
def declaration(~S:Data,~mode:Q.Mode,~H:Type,~B:Type,~builder:Build.Builder(~S,~D.Store(~S),~D.Resources(~S),~H,~B),book:B) -> B & Ops(~S,H):
  builder(Ops(~S),selection(~S,~mode,~H,~B),book)

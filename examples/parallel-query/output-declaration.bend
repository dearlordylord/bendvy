import Base
import ./payloads.bend as P
import ./command-row.bend as Row
import ../../src/ecs/execution-command-local.bend as Local
import ./declarations.bend as D
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/execution-composer-layout.bend as Layout

def route() -> Layout.Route:Layout.InLeft{Layout.AtLeaf{}}
def Ops(~S:Data,H:Type,O:Type) -> Type:Q.OutputEach<S,H,O,String>
def selection(~S:Data,~WC:Type,~mode:Q.Mode,~H:Type,~O:Type,~commands:Local.Commands<O,S,P.Output>,~B:Type,~component_read:Build.ComponentRead(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~component_write:Build.ComponentWrite(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~resource_read:Build.ResourceRead(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~resource_write:Build.ResourceWrite(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~query:Build.Query(~S,~WC,~D.Store(~S),~D.Resources(~S),~H,~B),~lifecycle:Build.Lifecycle(~S,~WC,~D.Store(~S),~D.Resources(~S),~H,~B),book:B) -> B & Ops(~S,H,O):
  Build.output_query(~S,~WC,~D.Store(~S),~D.Resources(~S),~D.layout(),~route(),~{==},~{==},~{==},~O,~String,~Local.split_field(~O,~S,~P.Output,commands),~Local.merge_field(~O,~S,~P.Output,commands),~Row.row(~S,~O,~commands),~mode,~H,~B,~query,book)
def declaration(~S:Data,~WC:Type,~mode:Q.Mode,~H:Type,~O:Type,~commands:Local.Commands<O,S,P.Output>,~B:Type,~builder:Build.Builder(~S,~WC,~D.Store(~S),~D.Resources(~S),~H,~B),book:B) -> B & Ops(~S,H,O):
  builder(Q.OutputOps(~S,~O,~String),selection(~S,~WC,~mode,~H,~O,~commands,~B),book)

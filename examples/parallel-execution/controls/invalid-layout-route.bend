import Base
import ../../../src/ecs/execution-resource-policy.bend as Policy
import ../../../src/ecs/execution-builder.bend as Build
import ../../../src/ecs/execution-composer-layout.bend as Layout
import ../../../src/ecs/execution-projection.bend as Projection
import ../../../src/ecs/execution-access.bend as Access

type Nominal is Data:Nominal{}
def project(owner:Array<U32>) -> Array<U32> & U32:Array.get(U32,owner,0)
def actual() -> Layout.Layout:Layout.LayoutPair{Layout.LayoutLeaf{Array<U32>,U32,project,"public",Policy.Ordinary{}},Layout.LayoutLeaf{Array<U32>,U32,project,"secret",Policy.Ordinary{}}}
def claimed() -> Layout.Layout:actual()
def route() -> Layout.Route:Layout.AtLeaf{}
def Resources() -> Type:Layout.resources(~Nominal,actual())
def Ops(H:Type) -> Type:Access.ResourceRead<H,U32>

def selection(~H:Type,~B:Type,~component_read:Build.ComponentRead(~Nominal,~Unit,~Resources(),~H,~B),~component_write:Build.ComponentWrite(~Nominal,~Unit,~Resources(),~H,~B),~resource_read:Build.ResourceRead(~Nominal,~Unit,~Resources(),~H,~B),~resource_write:Build.ResourceWrite(~Nominal,~Unit,~Resources(),~H,~B),~query:Build.Query(~Nominal,~Unit,~Unit,~Resources(),~H,~B),~lifecycle:Build.Lifecycle(~Nominal,~Unit,~Unit,~Resources(),~H,~B),book:B) -> B & Ops(H):
  Build.basic_resource_read(~Nominal,~Unit,~Resources(),~H,~B,~claimed(),~route(),~{==},~{==},~resource_read,book)
def declaration(~H:Type,~B:Type,~builder:Build.Builder(~Nominal,~Unit,~Unit,~Resources(),~H,~B),book:B) -> B & Ops(H):
  builder(Ops,selection(~H,~B),book)

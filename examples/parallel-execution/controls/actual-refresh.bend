import Base
import ../../../src/ecs/execution-builder.bend as Build
import ../../../src/ecs/execution-composer-layout.bend as Layout
import ../../../src/ecs/execution-projection.bend as Projection
import ../../../src/ecs/execution-access.bend as Access

type Nominal is Data:Nominal{}
def project(owner:Array<U32>) -> Array<U32> & U32:Array.get(U32,owner,0)
def actual() -> Layout.Layout:Layout.LayoutPair{Layout.LayoutLeaf{Array<U32>,U32,project,"public"},Layout.LayoutLeaf{Array<U32>,U32,project,"secret"}}
def alternate(owner:Array<U32>) -> Array<U32> & U32:(owner,999)
def claimed() -> Layout.Layout:actual()
def route() -> Layout.Route:Layout.InRight{Layout.AtLeaf{}}
def Resources() -> Type:Layout.resources(~Nominal,actual())
def Ops(H:Type) -> Type:Access.ResourceWrite<H,Array<U32>,U32>

def selection(~H:Type,~B:Type,~component_read:Build.ComponentRead(~Nominal,~Unit,~Resources(),~H,~B),~component_write:Build.ComponentWrite(~Nominal,~Unit,~Resources(),~H,~B),~resource_read:Build.ResourceRead(~Nominal,~Unit,~Resources(),~H,~B),~resource_write:Build.ResourceWrite(~Nominal,~Unit,~Resources(),~H,~B),~query:Build.Query(~Nominal,~Unit,~Resources(),~H,~B),book:B) -> B & Ops(H):
  resource_write(claimed(),route(),{==},{==},book)
def declaration(~H:Type,~B:Type,~builder:Build.Builder(~Nominal,~Unit,~Resources(),~H,~B),book:B) -> B & Ops(H):
  builder(Ops,selection(~H,~B),book)

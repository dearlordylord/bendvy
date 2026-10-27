import Base
import ./payloads.bend as P
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-resource-policy.bend as Policy
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-access.bend as A
import ../../src/ecs/owner-product.bend as Product
def left_layout() -> Layout.Layout:Layout.LayoutLeaf{P.Counter,String,P.counter,"counter",Policy.Ordinary{}}
def LeftStore(~S:Data) -> Type:Unit
def LeftResource(~S:Data) -> Type:Layout.resources(~S,left_layout())
def LeftOps(~S:Data,Permit:Data,H:Type) -> Type:A.ResourceWrites(~P.Counter,~String)(H)
def left_selection(~S:Data,~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~Unit,~LeftResource(~S),~H,~B),~cw:Build.ComponentWrite(~S,~Unit,~LeftResource(~S),~H,~B),~rr:Build.ResourceRead(~S,~Unit,~LeftResource(~S),~H,~B),~rw:Build.ResourceWrite(~S,~Unit,~LeftResource(~S),~H,~B),~query:Build.Query(~S,~Product.Owner<Unit,Unit>,~Unit,~LeftResource(~S),~H,~B),~lifecycle:Build.Lifecycle(~S,~Product.Owner<Unit,Unit>,~Unit,~LeftResource(~S),~H,~B),book:B) -> B & LeftOps(~S,Permit,H):
  Build.basic_resource_write(~S,~Unit,~LeftResource(~S),~H,~B,~left_layout(),~Layout.AtLeaf{},~{==},~{==},~rw,book)
def left(~S:Data,~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~Product.Owner<Unit,Unit>,~Unit,~LeftResource(~S),~Permit,~H,~B),book:B) -> B & LeftOps(~S,Permit,H):
  builder(LeftOps(~S),left_selection(~S,~Permit,~H,~B),book)
def right_layout() -> Layout.Layout:Layout.LayoutLeaf{P.Score,String,P.score,"score",Policy.Ordinary{}}
def RightStore(~S:Data) -> Type:Unit
def RightResource(~S:Data) -> Type:Layout.resources(~S,right_layout())
def RightOps(~S:Data,Permit:Data,H:Type) -> Type:A.ResourceWrites(~P.Score,~String)(H)
def right_selection(~S:Data,~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~Unit,~RightResource(~S),~H,~B),~cw:Build.ComponentWrite(~S,~Unit,~RightResource(~S),~H,~B),~rr:Build.ResourceRead(~S,~Unit,~RightResource(~S),~H,~B),~rw:Build.ResourceWrite(~S,~Unit,~RightResource(~S),~H,~B),~query:Build.Query(~S,~Product.Owner<Unit,Unit>,~Unit,~RightResource(~S),~H,~B),~lifecycle:Build.Lifecycle(~S,~Product.Owner<Unit,Unit>,~Unit,~RightResource(~S),~H,~B),book:B) -> B & RightOps(~S,Permit,H):
  Build.basic_resource_write(~S,~Unit,~RightResource(~S),~H,~B,~right_layout(),~Layout.AtLeaf{},~{==},~{==},~rw,book)
def right(~S:Data,~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~Product.Owner<Unit,Unit>,~Unit,~RightResource(~S),~Permit,~H,~B),book:B) -> B & RightOps(~S,Permit,H):
  builder(RightOps(~S),right_selection(~S,~Permit,~H,~B),book)
def Store(~S:Data) -> Type:Product.Owner<Unit,Unit>
def Resources(~S:Data) -> Type:Product.Owner<LeftResource(~S),RightResource(~S)>
def empty(~S:Data,_:Unit) -> Store(~S):Product.Owner{Unit{},Unit{}}
def resources(~S:Data) -> Resources(~S):Product.Owner{Layout.ResourceSlot{Layout.initialize(left_layout(),Layout.AtLeaf{},P.Counter{ALeaf{301},0}),Layout.unknown_stamp()},Layout.ResourceSlot{Layout.initialize(right_layout(),Layout.AtLeaf{},P.Score{ALeaf{401},0}),Layout.unknown_stamp()}}

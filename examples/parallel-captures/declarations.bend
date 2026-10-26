import Base
import ./payloads.bend as P
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-access.bend as A
import ../../src/ecs/owner-product.bend as Product
def left_layout() -> Layout.Layout:Layout.LayoutLeaf{P.Counter,String,P.counter,"counter"}
def LeftStore(~S:Data) -> Type:Unit
def LeftResource(~S:Data) -> Type:Layout.resources(~S,left_layout())
def LeftOps(~S:Data) -> Type -> Type:A.ResourceWrites(~P.Counter,~String)
def left_selection(~S:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~Unit,~LeftResource(~S),~H,~B),~cw:Build.ComponentWrite(~S,~Unit,~LeftResource(~S),~H,~B),~rr:Build.ResourceRead(~S,~Unit,~LeftResource(~S),~H,~B),~rw:Build.ResourceWrite(~S,~Unit,~LeftResource(~S),~H,~B),~query:Build.Query(~S,~Unit,~LeftResource(~S),~H,~B),book:B) -> B & LeftOps(~S)(H):
  rw(left_layout(),Layout.AtLeaf{},{==},{==},book)
def left(~S:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~Unit,~LeftResource(~S),~H,~B),book:B) -> B & LeftOps(~S)(H):
  builder(LeftOps(~S),left_selection(~S,~H,~B),book)
def right_layout() -> Layout.Layout:Layout.LayoutLeaf{P.Score,String,P.score,"score"}
def RightStore(~S:Data) -> Type:Unit
def RightResource(~S:Data) -> Type:Layout.resources(~S,right_layout())
def RightOps(~S:Data) -> Type -> Type:A.ResourceWrites(~P.Score,~String)
def right_selection(~S:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~Unit,~RightResource(~S),~H,~B),~cw:Build.ComponentWrite(~S,~Unit,~RightResource(~S),~H,~B),~rr:Build.ResourceRead(~S,~Unit,~RightResource(~S),~H,~B),~rw:Build.ResourceWrite(~S,~Unit,~RightResource(~S),~H,~B),~query:Build.Query(~S,~Unit,~RightResource(~S),~H,~B),book:B) -> B & RightOps(~S)(H):
  rw(right_layout(),Layout.AtLeaf{},{==},{==},book)
def right(~S:Data,~H:Type,~B:Type,~builder:Build.Builder(~S,~Unit,~RightResource(~S),~H,~B),book:B) -> B & RightOps(~S)(H):
  builder(RightOps(~S),right_selection(~S,~H,~B),book)
def Store(~S:Data) -> Type:Product.Owner<Unit,Unit>
def Resources(~S:Data) -> Type:Product.Owner<LeftResource(~S),RightResource(~S)>
def empty(~S:Data,_:Unit) -> Store(~S):Product.Owner{Unit{},Unit{}}
def resources(~S:Data) -> Resources(~S):Product.Owner{Layout.ResourceSlot{Layout.initialize(left_layout(),Layout.AtLeaf{},P.Counter{ALeaf{301},0})},Layout.ResourceSlot{Layout.initialize(right_layout(),Layout.AtLeaf{},P.Score{ALeaf{401},0})}}

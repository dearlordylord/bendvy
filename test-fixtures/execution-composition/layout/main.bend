import Base
import ../../../src/ecs/execution-composer-layout.bend as Layout
import ../../../src/ecs/owner-product.bend as Product

def project(owner:Array<U32>) -> Array<U32> & U32:Array.get(U32,owner,0)
def shape() -> Layout.Layout:
  Layout.LayoutPair{Layout.LayoutLeaf{Array<U32>,U32,project,"public"},Layout.LayoutLeaf{Array<U32>,U32,project,"secret"}}
def path() -> Layout.Route:Layout.InRight{Layout.AtLeaf{}}
def swapped(result:Array<U32> & U32) -> Array<U32>:
  match result:
    case (owner,_):owner
def changed(result:Layout.resource_rest(~Unit,shape(),path()) & Layout.ResourceSlot<Unit,Layout.stored(shape(),path()),Layout.key(shape(),path()),Layout.origin(shape(),path())>) -> Layout.resources(~Unit,shape()):
  match result:
    case (rest,Layout.ResourceSlot{Layout.Viewed{owner,_},_}):Layout.resource_put(~Unit,shape(),path(),rest,Layout.ResourceSlot{Layout.initialize(shape(),path(),swapped(Array.swap(U32,owner,0,99))),Layout.unknown_stamp()})
def observed(left:Array<U32> & U32,right:Array<U32> & U32) -> String:
  match left right:
    case (_,a), (_,b):U32.show(a) ++ "," ++ U32.show(b)
def inspect(owner:Layout.resources(~Unit,shape())) -> String:
  match owner:
    case Product.Owner{Layout.ResourceSlot{Layout.Viewed{left,_},_},Layout.ResourceSlot{Layout.Viewed{right,_},_}}:observed(Array.get(U32,left,0),Array.get(U32,right,0))
def allocated(owner:Layout.columns(~Unit,shape())) -> String:
  match owner:
    case Product.Owner{_,_}:"allocated"
def main() -> IO(Unit):
  IO.print(allocated(Layout.empty_columns(~Unit,shape())) ++ ";" ++ Layout.key(shape(),path()) ++ ":" ++ inspect(changed(Layout.resource_take(~Unit,shape(),path(),Product.Owner{Layout.ResourceSlot{Layout.initialize(shape(),Layout.InLeft{Layout.AtLeaf{}},ALeaf{11}),Layout.unknown_stamp()},Layout.ResourceSlot{Layout.initialize(shape(),path(),ALeaf{22}),Layout.unknown_stamp()}}))))

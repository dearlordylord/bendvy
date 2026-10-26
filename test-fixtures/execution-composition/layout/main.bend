import Base
import ../../../src/ecs/execution-composer-layout.bend as Layout
import ../../../src/ecs/owner-product.bend as Product

def shape() -> Layout.Layout:
  Layout.LayoutPair{Layout.LayoutLeaf{Array<U32>,"public"},Layout.LayoutLeaf{Array<U32>,"secret"}}
def path() -> Layout.Route:Layout.InRight{Layout.AtLeaf{}}
def swapped(result:Array<U32> & U32) -> Array<U32>:
  match result:
    case (owner,_):owner
def changed(result:Layout.resource_rest(~Unit,shape(),path()) & Layout.ResourceSlot<Unit,Layout.payload(shape(),path()),Layout.key(shape(),path())>) -> Layout.resources(~Unit,shape()):
  match result:
    case (rest,Layout.ResourceSlot{owner}):Layout.resource_put(~Unit,shape(),path(),rest,Layout.ResourceSlot{swapped(Array.swap(U32,owner,0,99))})
def observed(left:Array<U32> & U32,right:Array<U32> & U32) -> String:
  match left right:
    case (_,a), (_,b):U32.show(a) ++ "," ++ U32.show(b)
def inspect(owner:Layout.resources(~Unit,shape())) -> String:
  match owner:
    case Product.Owner{Layout.ResourceSlot{left},Layout.ResourceSlot{right}}:observed(Array.get(U32,left,0),Array.get(U32,right,0))
def allocated(owner:Layout.columns(~Unit,shape())) -> String:
  match owner:
    case Product.Owner{_,_}:"allocated"
def main() -> IO(Unit):
  IO.print(allocated(Layout.empty_columns(~Unit,shape())) ++ ";" ++ Layout.key(shape(),path()) ++ ":" ++ inspect(changed(Layout.resource_take(~Unit,shape(),path(),Product.Owner{Layout.ResourceSlot{ALeaf{11}},Layout.ResourceSlot{ALeaf{22}}}))))

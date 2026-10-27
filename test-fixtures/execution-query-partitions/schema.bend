import Base
import ../../src/ecs/chunk-column.bend as Col
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/lifecycle.bend as L
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/schema-fragments.bend as Fragment
import ../../src/ecs/owner-product.bend as Product

type SchemaA is Data:
  SchemaA{}
type SchemaB is Data:
  SchemaB{}
type Position is Type:
  Position{values:Array<U32>}
type Shield is Type:
  Shield{label:String,values:Array<U32>}
def position_cached(result:Array<U32> & U32) -> Position & U32:
  match result:
    case (values,value):(Position{values},value)
def position_view(owner:Position) -> Position & U32:
  match owner:
    case Position{values}:position_cached(Array.get(U32,values,0))
def shield_cached(label:String,result:Array<U32> & U32) -> Shield & U32:
  match result:
    case (values,value):(Shield{label,values},value)
def shield_view(owner:Shield) -> Shield & U32:
  match owner:
    case Shield{label,values}:shield_cached(label,Array.get(U32,values,0))
def positions() -> Layout.Layout:Layout.LayoutLeaf{Position,U32,position_view,"Position"}
def shields() -> Layout.Layout:Layout.ClassifiedLayoutLeaf{Shield,U32,shield_view,"Shield",Fragment.Plain{}}
def changed_origin() -> Layout.Layout:Layout.LayoutLeaf{Position,U32,position_view,"OtherPosition"}
def position(+n:U32) -> Layout.Viewed<Position,U32>:Layout.Viewed{Position{[n : U32^1n]},n}
def shield(+n:U32) -> Layout.Viewed<Shield,U32>:Layout.Viewed{Shield{"shield",[n : U32^2n]},n}
def position_leaf(~S:Data,+n:U32) -> Col.Column<S,Layout.Viewed<Position,U32>>:
  Col.Leaf{Array.set(Maybe<&1,Layout.Viewed<Position,U32>>,Array.set(Maybe<&1,Layout.Viewed<Position,U32>>,Array.set(Maybe<&1,Layout.Viewed<Position,U32>>,Array.set(Maybe<&1,Layout.Viewed<Position,U32>>,Col.absent(~Layout.Viewed<Position,U32>,3n),0,Some{position(n)}),1,Some{position(U32.add(n,1))}),2,Some{position(U32.add(n,2))}),3,Some{position(U32.add(n,3))}),[L.Stamp{Some{Tick.Tick{0n,1}},Some{Tick.Tick{0n,1}}} : L.Stamp^3n]}
def shield_leaf(~S:Data,+n:U32) -> Col.Column<S,Layout.Viewed<Shield,U32>>:
  Col.Leaf{Array.set(Maybe<&1,Layout.Viewed<Shield,U32>>,Array.set(Maybe<&1,Layout.Viewed<Shield,U32>>,Col.absent(~Layout.Viewed<Shield,U32>,3n),0,Some{shield(n)}),2,Some{shield(U32.add(n,2))}),[L.Stamp{None{},None{}} : L.Stamp^3n]}
def position_tree(~S:Data) -> Col.Column<S,Layout.Viewed<Position,U32>>:
  Col.Branch{16,Col.Branch{8,position_leaf(~S,0),position_leaf(~S,8)},Col.Branch{8,position_leaf(~S,16),position_leaf(~S,24)}}
def shield_tree(~S:Data) -> Col.Column<S,Layout.Viewed<Shield,U32>>:
  Col.Branch{8,shield_leaf(~S,0),shield_leaf(~S,8)}
def moved(owner:Position) -> Position & Unit:
  match owner:
    case Position{values}:(Position{Array.set(U32,values,0,99)},Unit{})
def shielded(owner:Shield) -> Shield & Unit:
  match owner:
    case Shield{label,values}:(Shield{label,Array.set(U32,values,0,77)},Unit{})

def layout_a() -> Layout.Layout:Layout.LayoutPair{positions(),shields()}
def layout_b() -> Layout.Layout:Layout.LayoutPair{shields(),Layout.LayoutPair{positions(),changed_origin()}}
def full_a() -> Layout.columns(~SchemaA,layout_a()):
  Product.Owner{Layout.ColumnSlot{position_tree(~SchemaA)},Layout.ColumnSlot{shield_tree(~SchemaA)}}
def full_b() -> Layout.columns(~SchemaB,layout_b()):
  Product.Owner{Layout.ColumnSlot{shield_tree(~SchemaB)},Product.Owner{Layout.ColumnSlot{position_tree(~SchemaB)},Layout.ColumnSlot{position_tree(~SchemaB)}}}

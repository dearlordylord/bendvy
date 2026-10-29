import Base
import ./schema.bend as S
import ../../src/ecs/execution-query-schema.bend as Schema
import ../../src/ecs/execution-query-identity.bend as Id
import ../../src/ecs/execution-query-domain.bend as D
import ../../src/ecs/execution-query-matches.bend as Q
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/world.bend as W

def full_b_same_schema() -> L.columns(~S.SchemaA,S.layout_b()):
  Product.Owner{L.ColumnSlot{S.shield_tree(~S.SchemaA)},Product.Owner{L.ColumnSlot{S.position_tree(~S.SchemaA)},L.ColumnSlot{S.position_tree(~S.SchemaA)}}}
def left_a() -> Schema.Book<S.SchemaA,S.layout_a()>:
  Schema.Book{[Schema.Entry{L.InLeft{L.AtLeaf{}},Q.Write{D.Domain{[0,2,8,18]}}},Schema.Entry{L.InRight{L.AtLeaf{}},Q.Read{D.Domain{[0,1,8,9]}}}]}
def right_a() -> Schema.Book<S.SchemaA,S.layout_a()>:
  Schema.Book{[Schema.Entry{L.InLeft{L.AtLeaf{}},Q.Write{D.Domain{[1,3,9,19]}}},Schema.Entry{L.InRight{L.AtLeaf{}},Q.Read{D.Domain{[0,1,8,9]}}}]}
def left_b() -> Schema.Book<S.SchemaA,S.layout_b()>:
  Schema.Book{[Schema.Entry{L.InRight{L.InLeft{L.AtLeaf{}}},Q.Write{D.Domain{[0,8]}}},Schema.Entry{L.InLeft{L.AtLeaf{}},Q.Read{D.Domain{[0,1,8,9]}}}]}
def right_b() -> Schema.Book<S.SchemaA,S.layout_b()>:
  Schema.Book{[Schema.Entry{L.InRight{L.InRight{L.AtLeaf{}}},Q.Write{D.Domain{[0,8]}}},Schema.Entry{L.InLeft{L.AtLeaf{}},Q.Read{D.Domain{[0,1,8,9]}}}]}
def generic_a() -> Schema.Partition<S.SchemaA,S.layout_a()>:
  Schema.cut(~S.SchemaA,~S.layout_a(),left_a(),right_a(),S.full_a())
def generic_b() -> Schema.Partition<S.SchemaA,S.layout_b()>:
  Schema.cut(~S.SchemaA,~S.layout_b(),left_b(),right_b(),full_b_same_schema())
def restored_a() -> Schema.Assembly<S.SchemaA,S.layout_a()>:Schema.rejoin(~S.SchemaA,~S.layout_a(),generic_a())
def restored_b() -> Schema.Assembly<S.SchemaA,S.layout_b()>:Schema.rejoin(~S.SchemaA,~S.layout_b(),generic_b())
def bad_route() -> Schema.Partition<S.SchemaA,S.layout_a()>:
  Schema.cut(~S.SchemaA,~S.layout_a(),Schema.Book{[Schema.Entry{L.AtLeaf{},Q.Read{D.Domain{[0]}}}]},right_a(),S.full_a())
def broad_excluded_read_conflict() -> Schema.Partition<S.SchemaA,S.layout_a()>:
  Schema.cut(~S.SchemaA,~S.layout_a(),Schema.Book{[Schema.Entry{L.InLeft{L.AtLeaf{}},Q.Read{D.Domain{[0,1,2,3,8,9,18,19]}}}]},right_a(),S.full_a())
def full_world_identity(world:W.World<S.SchemaA,L.columns(~S.SchemaA,S.layout_a()),Unit,Unit>,handle:W.Handle<S.SchemaA>) -> W.World<S.SchemaA,L.columns(~S.SchemaA,S.layout_a()),Unit,Unit> & Id.Offset<S.SchemaA>:
  Id.world_offset(~S.SchemaA,~L.columns(~S.SchemaA,S.layout_a()),~Unit,~Unit,world,32,handle)
def exceptional_bound(namespace:U32,handles:List<&2,W.Handle<S.SchemaA>>,handle:W.Handle<S.SchemaA>) -> Id.Offset<S.SchemaA>:
  Id.checked_offset(~S.SchemaA,namespace,handles,4294967295,handle)

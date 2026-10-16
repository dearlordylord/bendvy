import Base
import bundle.bend as B
import resources.bend as R
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/resource-field.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
def ArrayLookup() -> Type:
  I.Lookup<I.Frame<B.AuditWorkshop,B.Store,R.Resources(),U32>,B.AuditWorkshop,List<&2,U32>>
def array_lookup() -> ArrayLookup():
  I.read_family(~B.AuditWorkshop,~B.Store,~R.Resources(),~U32,~Col.Column<B.AuditWorkshop,U32>,~Array<U32>,~List<&2,U32>,~B.ArrayToken,~B.take_array,~B.put_array,~B.project_array,~B.array_family())
def ScalarLookup() -> Type:
  I.Lookup<I.Frame<B.AuditWorkshop,B.Store,R.Resources(),U32>,B.AuditWorkshop,U32>
def scalar_lookup() -> ScalarLookup():
  I.read_family(~B.AuditWorkshop,~B.Store,~R.Resources(),~U32,~Col.Column<B.AuditWorkshop,Array<U32>>,~U32,~U32,~B.ScalarToken,~B.take_scalar,~B.put_scalar,~B.project_scalar,~B.scalar_family())
type Views is Data:
  Views{cursor:U32,arrays:I.Value<List<&2,U32>>,scalar:I.Value<U32>,counter:List<&2,U32>}
def scalar_read(~H:Type,arrays:I.Value<List<&2,U32>>,result:H & I.Value<U32>) -> H & (I.Value<List<&2,U32>> & I.Value<U32>):
  match result:
    case (owner,scalar):(owner,(arrays,scalar))
def array_read(~H:Type,~array:I.Lookup<H,B.AuditWorkshop,List<&2,U32>>,~scalar:I.Lookup<H,B.AuditWorkshop,U32>,target:W.Handle<B.AuditWorkshop>,result:H & I.Value<List<&2,U32>>) -> H & (I.Value<List<&2,U32>> & I.Value<U32>):
  match result:
    case (owner,arrays):scalar_read(~H,arrays,I.lookup(~H,~B.AuditWorkshop,~U32,~scalar,owner,target))
def body(~H:Type,~array:I.Lookup<H,B.AuditWorkshop,List<&2,U32>>,~scalar:I.Lookup<H,B.AuditWorkshop,U32>,+target:W.Handle<B.AuditWorkshop>,owner:H) -> H & (I.Value<List<&2,U32>> & I.Value<U32>):
  array_read(~H,~array,~scalar,target,I.lookup(~H,~B.AuditWorkshop,~List<&2,U32>,~array,owner,target))
def counter_project(resource:R.Resources()) -> R.Resources() & List<&2,U32>:
  Field.project(~R.Resources(),~Array<U32>,~Unit & Product.Owner<Array<U32>,R.Receipts>,~List<&2,U32>,~R.lens(),~R.project,resource)
def counter_cap() -> Cap.ValueRead<I.Frame<B.AuditWorkshop,B.Store,R.Resources(),U32>,List<&2,U32>>:
  I.read_resource(~B.AuditWorkshop,~B.Store,~R.Resources(),~U32,~List<&2,U32>,~counter_project)
def counter_read(~H:Type,arrays:I.Value<List<&2,U32>>,scalar:I.Value<U32>,result:H & List<&2,U32>) -> H & (I.Value<List<&2,U32>> & (I.Value<U32> & List<&2,U32>)):
  match result:
    case (owner,counter):(owner,(arrays,(scalar,counter)))
def counter_from(~H:Type,~counter:Cap.ValueRead<H,List<&2,U32>>,result:H & (I.Value<List<&2,U32>> & I.Value<U32>)) -> H & (I.Value<List<&2,U32>> & (I.Value<U32> & List<&2,U32>)):
  match result:
    case (owner,(arrays,scalar)):counter_read(~H,arrays,scalar,Cap.value_read(~H,~List<&2,U32>,~counter,owner))
def observed(result:I.Frame<B.AuditWorkshop,B.Store,R.Resources(),U32> & (I.Value<List<&2,U32>> & (I.Value<U32> & List<&2,U32>))) -> B.World(R.Resources()) & Views:
  match result:
    case (I.Frame{world,+cursor},(arrays,(scalar,counter))):(world,Views{cursor,arrays,scalar,counter})
def snapshot(world:B.World(R.Resources()),target:W.Handle<B.AuditWorkshop>) -> B.World(R.Resources()) & Views:
  observed(counter_from(~I.Frame<B.AuditWorkshop,B.Store,R.Resources(),U32>,~counter_cap(),body(~I.Frame<B.AuditWorkshop,B.Store,R.Resources(),U32>,~array_lookup(),~scalar_lookup(),target,I.Frame{world,0})))

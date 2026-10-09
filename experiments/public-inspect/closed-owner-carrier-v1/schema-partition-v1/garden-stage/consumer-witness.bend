import Base
import selection.bend as Selection
import query.bend as Q
import traversal.bend as Traversal
import family-witness.bend as D
import schema-families.bend as Families
import core-v1/src/ecs/inspector.bend as I
import core-v1/src/ecs/world.bend as W
import core-v1/src/ecs/component.bend as C
import core-v1/src/ecs/inspector-query.bend as Errors

type Reads<-H:Type,-S:Data,-V:Data> is Type:
  Reads{query:Q.ReadQuery<H,S,V>}
type Snapshot<S:Data,V:Data> is Data:
  Snapshot{each:List<&2,Q.Row<S,V>>,get:Result<&2,&2,Errors.LookupError,Q.Row<S,V>>,single:Result<&2,&2,Errors.SingleError,Q.Row<S,V>>,singleOptional:Result<&2,&2,Errors.SingleError,Maybe<&2,Q.Row<S,V>>>}
def query_field(~H:Type,~S:Data,~V:Data,value:Reads<H,S,V>) -> Q.ReadQuery<H,S,V>:
  match value:
    case Reads{query}:query
def final(~H:Type,~S:Data,~V:Data,rows:List<&2,Q.Row<S,V>>,get:Result<&2,&2,Errors.LookupError,Q.Row<S,V>>,single:Result<&2,&2,Errors.SingleError,Q.Row<S,V>>,observed:H & Result<&2,&2,Errors.SingleError,Maybe<&2,Q.Row<S,V>>>) -> H & Result<&2,&2,Unit,Snapshot<S,V>>:
  (owner,optional)=observed
  (owner,Done{Snapshot{rows,get,single,optional}})
def after_single(~H:Type,~S:Data,~V:Data,~caps:Reads<H,S,V>,rows:List<&2,Q.Row<S,V>>,get:Result<&2,&2,Errors.LookupError,Q.Row<S,V>>,observed:H & Result<&2,&2,Errors.SingleError,Q.Row<S,V>>) -> H & Result<&2,&2,Unit,Snapshot<S,V>>:
  (owner,single)=observed
  final(~H,~S,~V,rows,get,single,Q.single_optional(~H,~S,~V,~query_field(~H,~S,~V,caps),owner))
def after_get(~H:Type,~S:Data,~V:Data,~caps:Reads<H,S,V>,rows:List<&2,Q.Row<S,V>>,observed:H & Result<&2,&2,Errors.LookupError,Q.Row<S,V>>) -> H & Result<&2,&2,Unit,Snapshot<S,V>>:
  (owner,get)=observed
  after_single(~H,~S,~V,~caps,rows,get,Q.single(~H,~S,~V,~query_field(~H,~S,~V,caps),owner))
def after_each(~H:Type,~S:Data,~V:Data,~caps:Reads<H,S,V>,target:W.Handle<S>,observed:H & List<&2,Q.Row<S,V>>) -> H & Result<&2,&2,Unit,Snapshot<S,V>>:
  (owner,rows)=observed
  after_get(~H,~S,~V,~caps,rows,Q.get(~H,~S,~V,~query_field(~H,~S,~V,caps),owner,target))
def body(~H:Type,~S:Data,~V:Data,~caps:Reads<H,S,V>,target:W.Handle<S>,owner:H) -> H & Result<&2,&2,Unit,Snapshot<S,V>>:
  after_each(~H,~S,~V,~caps,target,Q.each(~H,~S,~V,~query_field(~H,~S,~V,caps),owner))
def garden_ops(H:Type) -> Type:
  Reads<H,Families.Garden,Selection.Product<Selection.Product<Selection.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>>
def garden_plan() -> I.Plan<Families.Garden,Families.Store<Families.Garden>,Unit,U32,garden_ops>:
  I.Plan{Reads{Q.grant(~I.Frame<Families.Garden,Families.Store<Families.Garden>,Unit,U32>,~Families.Garden,~Selection.Product<Selection.Product<Selection.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~D.inspect_declaration(~Families.Garden),~Traversal.inspect_world(~Families.Garden,~Families.Store<Families.Garden>,~Unit,~U32))}}
def garden_body(~H:Type,~caps:Reads<H,Families.Garden,Selection.Product<Selection.Product<Selection.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>>,target:W.Handle<Families.Garden>,owner:H) -> H & Result<&2,&2,Unit,Snapshot<Families.Garden,Selection.Product<Selection.Product<Selection.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>>>:
  body(~H,~Families.Garden,~Selection.Product<Selection.Product<Selection.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~caps,target,owner)
def garden(world:W.World<Families.Garden,Families.Store<Families.Garden>,Unit,U32>,instance:I.Instance<Families.Garden>,target:W.Handle<Families.Garden>) -> I.Observed<Families.Garden,Families.Store<Families.Garden>,Unit,U32,Unit,Snapshot<Families.Garden,Selection.Product<Selection.Product<Selection.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>>>:
  I.run(~Families.Garden,~Families.Store<Families.Garden>,~Unit,~U32,~garden_ops,~W.Handle<Families.Garden>,~Unit,~Snapshot<Families.Garden,Selection.Product<Selection.Product<Selection.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>>,~garden_plan(),~garden_body,instance,target,world)
def main() -> Unit:
  Unit{}

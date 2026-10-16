import Base
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/owner-product.bend as Product
import ../../../src/ecs/ordinary-component-binding.bend as Binding
import ../../../src/ecs/ordinary-declaration.bend as Identity
import ../../../src/ecs/ordinary-schema.bend as Schema
# Existing trusted provisioning uses canonical product paths; gameplay gets grants.
type FirstToken is Data:FirstToken{}
type SecondToken is Data:SecondToken{}
def Store(~S:Data) -> Type:Product.Owner<Col.Column<S,Array<Array<U32>>>,Col.Column<S,Array<U32>>>
def first_take(~S:Data,store:Store(~S)) -> Col.Column<S,Array<U32>> & Col.Column<S,Array<Array<U32>>>:
  Product.take(~Col.Column<S,Array<Array<U32>>>,~Col.Column<S,Array<U32>>,Product.Left{},store)
def first_put(~S:Data,rest:Col.Column<S,Array<U32>>,column:Col.Column<S,Array<Array<U32>>>) -> Store(~S):
  Product.put(~Col.Column<S,Array<Array<U32>>>,~Col.Column<S,Array<U32>>,Product.Left{},rest,column)
def first_view(value:Array<Array<U32>>) -> Array<Array<U32>> & Unit:(value,Unit{})
def first_identity(~S:Data) -> Identity.Declaration<S,Array<Array<U32>>>:Identity.component(~S,~Array<Array<U32>>,"Payload")
def first_binding(~S:Data) -> Binding.Binding<S,Store(~S),Col.Column<S,Array<U32>>,Array<Array<U32>>,Unit,FirstToken,first_take(~S),first_put(~S),first_view>:
  Binding.bind(~S,~Store(~S),~Col.Column<S,Array<U32>>,~Array<Array<U32>>,~Unit,~FirstToken,~first_take(~S),~first_put(~S),~first_view,first_identity(~S))
def second_take(~S:Data,store:Store(~S)) -> Col.Column<S,Array<Array<U32>>> & Col.Column<S,Array<U32>>:
  Product.take(~Col.Column<S,Array<Array<U32>>>,~Col.Column<S,Array<U32>>,Product.Right{},store)
def second_put(~S:Data,rest:Col.Column<S,Array<Array<U32>>>,column:Col.Column<S,Array<U32>>) -> Store(~S):
  Product.put(~Col.Column<S,Array<Array<U32>>>,~Col.Column<S,Array<U32>>,Product.Right{},rest,column)
def second_view(value:Array<U32>) -> Array<U32> & Unit:(value,Unit{})
def second_identity(~S:Data) -> Identity.Declaration<S,Array<U32>>:Identity.component(~S,~Array<U32>,"Flags")
def second_binding(~S:Data) -> Binding.Binding<S,Store(~S),Col.Column<S,Array<Array<U32>>>,Array<U32>,Unit,SecondToken,second_take(~S),second_put(~S),second_view>:
  Binding.bind(~S,~Store(~S),~Col.Column<S,Array<Array<U32>>>,~Array<U32>,~Unit,~SecondToken,~second_take(~S),~second_put(~S),~second_view,second_identity(~S))
def schema(~S:Data) -> Schema.Schema<S,Store(~S),Product.Owner<Unit,Unit>>:
  Schema.product(~S,~Col.Column<S,Array<Array<U32>>>,~Unit,~Col.Column<S,Array<U32>>,~Unit,Schema.component(~S,~Array<Array<U32>>,first_identity(~S)),Schema.component(~S,~Array<U32>,second_identity(~S)))
def empty(~S:Data,unit:Unit) -> Store(~S):Product.Owner{Col.empty(~S,~Array<Array<U32>>),Col.empty(~S,~Array<U32>)}

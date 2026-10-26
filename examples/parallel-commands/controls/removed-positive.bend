import Base
import ../../../src/ecs/chunk-column.bend as Column
import ../../../test-fixtures/common/column-observation.bend as Observe
import ../../../src/ecs/schema-fragments.bend as Fragment
import ./positive.bend as P
import ./registered.bend as Registered
import ../../../src/ecs/execution-composer-layout.bend as Layout
import ../../../src/ecs/execution-command-removed.bend as Removed
import ../../../src/ecs/owner-product.bend as Product

type Schema is Data:Schema{}
type Other is Type:Other{owner:Array<U32>}
def other_done(result:Array<U32> & U32) -> Other & U32:
  match result:
    case (owner,+value):(Other{Array.set(U32,owner,0,U32.add(value,1))},U32.add(value,1))
def refresh_other(owner:Other) -> Other & U32:
  match owner:
    case Other{owner}:other_done(Array.get(U32,owner,0))
def layout() -> Layout.Layout:Layout.LayoutPair{Registered.layout(),Layout.ClassifiedLayoutLeaf{Other,U32,refresh_other,"other",Fragment.Plain{}}}

def take(owner:Layout.columns(~Schema,layout())) -> Layout.columns(~Schema,layout()) & Product.Owner<Maybe<&1,P.Token>,Maybe<&1,Other>>:
  Removed.take(~Schema,layout())(1,owner)

def token_text(result:Array<U32> & U32) -> String:
  match result:
    case (_,value):U32.show(value)
def token(owner:P.Token) -> String:
  match owner:
    case P.Token{owner}:token_text(Array.get(U32,owner,0))
def other(owner:Other) -> String:
  match owner:
    case Other{owner}:token_text(Array.get(U32,owner,0))
def maybe_token(value:Maybe<&1,P.Token>) -> String:
  match value:
    case None{}:"none"
    case Some{value}:token(value)
def maybe_other(value:Maybe<&1,Other>) -> String:
  match value:
    case None{}:"none"
    case Some{value}:other(value)
def receipt(value:Product.Owner<Maybe<&1,P.Token>,Maybe<&1,Other>>) -> String:
  match value:
    case Product.Owner{left,right}:maybe_token(left) ++ ":" ++ maybe_other(right)
def token_project_done(+cached:U32,result:Array<U32> & U32) -> Layout.Viewed<P.Token,U32> & String:
  match result:
    case (owner,+raw):(Layout.Viewed{P.Token{owner},cached},U32.show(raw) ++ "/cache=" ++ U32.show(cached))
def token_project(value:Layout.Viewed<P.Token,U32>) -> Layout.Viewed<P.Token,U32> & String:
  match value:
    case Layout.Viewed{P.Token{owner},cached}:token_project_done(cached,Array.get(U32,owner,0))
def other_project_done(+cached:U32,result:Array<U32> & U32) -> Layout.Viewed<Other,U32> & String:
  match result:
    case (owner,+raw):(Layout.Viewed{Other{owner},cached},U32.show(raw) ++ "/cache=" ++ U32.show(cached))
def other_project(value:Layout.Viewed<Other,U32>) -> Layout.Viewed<Other,U32> & String:
  match value:
    case Layout.Viewed{Other{owner},cached}:other_project_done(cached,Array.get(U32,owner,0))
def observed(prefix:String,result:Layout.columns(~Schema,layout()) & Removed.Removed(layout())) -> String:
  match result:
    case (Product.Owner{Layout.ColumnSlot{left},Layout.ColumnSlot{right}},removed):prefix ++ ";high=" ++ receipt(removed) ++ "|left=" ++ Observe.capacity_done(~Schema,~(Layout.Viewed<P.Token,U32>),~token_project,Column.capacity(~Schema,~(Layout.Viewed<P.Token,U32>),left)) ++ "|right=" ++ Observe.capacity_done(~Schema,~(Layout.Viewed<Other,U32>),~other_project,Column.capacity(~Schema,~(Layout.Viewed<Other,U32>),right))
def missing(prefix:String,result:Layout.columns(~Schema,layout()) & Removed.Removed(layout())) -> String:
  match result:
    case (owner,removed):observed(prefix ++ ";missing=" ++ receipt(removed),Removed.take(~Schema,layout())(99,owner))
def present(result:Layout.columns(~Schema,layout()) & Removed.Removed(layout())) -> String:
  match result:
    case (owner,removed):missing("present=" ++ receipt(removed),Removed.take(~Schema,layout())(1,owner))
def token_column(result:Column.SwapOutcome<Schema,Layout.Viewed<P.Token,U32>>) -> Column.Column<Schema,Layout.Viewed<P.Token,U32>>:
  match result:
    case Column.Accepted{column,_}:column
    case Column.Rejected{column,_}:column
def other_column(result:Column.SwapOutcome<Schema,Layout.Viewed<Other,U32>>) -> Column.Column<Schema,Layout.Viewed<Other,U32>>:
  match result:
    case Column.Accepted{column,_}:column
    case Column.Rejected{column,_}:column
def main() -> IO(Unit):
  IO.print(present(take(Product.Owner{Layout.ColumnSlot{token_column(Column.swap(~Schema,~(Layout.Viewed<P.Token,U32>),Column.empty(~Schema,~(Layout.Viewed<P.Token,U32>)),1,Some{Layout.Viewed{P.Token{ALeaf{71}},900}}))},Layout.ColumnSlot{other_column(Column.swap(~Schema,~(Layout.Viewed<Other,U32>),Column.empty(~Schema,~(Layout.Viewed<Other,U32>)),1,Some{Layout.Viewed{Other{ALeaf{81}},901}}))}})))

import Base
import ./schema.bend as S
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/execution-query-interpreter.bend as Interpret
import ../../src/ecs/execution-query-store.bend as Store
import ../../src/ecs/execution-query-recipe.bend as Recipe
import ../../src/ecs/execution-query-matches.bend as Match
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-state.bend as State
import ../../src/ecs/world.bend as W

type Output is Type:
  Output{arrays:List<&1,Array<U32>>}
def split(output:Output) -> Output & Output:
  match output:
    case Output{[]}:(Output{[]},Output{[]})
    case Output{head <> tail}:(Output{[head]},Output{tail})
def merge(left:Output,right:Output) -> Output:
  match left right:
    case Output{left} Output{right}:Output{List.append(&1,Array<U32>,left,right)}
def row_owned(handle:W.Handle<S.SchemaA>,+view:U32,owner:S.Position,output:Output) -> S.Position & (Output & Maybe<&2,String>):
  match owner output:
    case S.Position{values} Output{arrays}:(S.Position{Array.set(U32,values,0,U32.add(view,1))},(Output{[view : U32^1n] <> arrays},None{}))
def row(handle:W.Handle<S.SchemaA>,view:U32,owner:S.Position,output:Output) -> S.Position & (Output & Maybe<&2,String>):
  row_owned(handle,view,owner,output)
def present(value:Maybe<&2,U32>) -> Bool:
  match value:
    case None{}:False{}
    case Some{_}:True{}
def WC() -> Type:L.columns(~S.SchemaA,S.positions())
def Storage() -> Type:Store.Storage<S.SchemaA,S.positions()>
def Caps(H:Type) -> Type:Q.GeneralOutputWriter<S.SchemaA,H,S.Position,U32,Output,String>
def declaration() -> Build.Book & Caps(State.Scope<S.SchemaA,Storage(),Unit>):
  Build.general_output_query(~S.SchemaA,~WC(),~Storage(),~Unit,~S.positions(),~L.AtLeaf{},~{==},~{==},~Store.Sparse{},~{==},~Recipe.AllLive{},~Match.Required{},~present,~Output,~String,~split,~merge,~row,~State.Scope<S.SchemaA,Storage(),Unit>,~Build.Book,~Build.query_provision_with(~S.SchemaA,~WC(),~Storage(),~Unit,~Interpret.provider_dictionary(~S.SchemaA,~WC(),~Storage(),~Unit)),Build.Book{[],[],[],True{}})
def invoke(-H:Type,cap:Q.GeneralOutputWriter<S.SchemaA,H,S.Position,U32,Output,String>,scope:H,output:Output,handle:W.Handle<S.SchemaA>) -> H & (Output & Q.Report<String>):
  match cap:
    case Q.GeneralOutputWriter{_,_,traverse}:traverse(Q.Parallel{},scope,output,Q.ExplicitHandles{[handle]})
    case Q.UnsupportedOutputWriter{}:(scope,(output,Q.LayoutRefused{}))
def accessor(cap:Caps(Output),scope:Output,output:Output,handle:W.Handle<S.SchemaA>) -> Output & (Output & Q.Report<String>):
  Q.general_traverse(~S.SchemaA,~Output,~S.Position,~U32,~Output,~String,cap,Q.Parallel{},scope,output,Q.ExplicitHandles{[handle]})

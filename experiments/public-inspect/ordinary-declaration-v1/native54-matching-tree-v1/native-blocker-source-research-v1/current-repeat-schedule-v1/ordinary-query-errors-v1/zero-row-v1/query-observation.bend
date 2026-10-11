import Base
import ../../ordinary-app-v1/observation.bend as Old
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-inspector-declaration.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as Rows
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-composer.bend as Build
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-population-v1/frontend-public.bend as Front
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/ordinary-population-v1/setup-public.bend as Setup
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-recipe.bend as Tree
def Frame(~S:Data) -> Type:I.Frame<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>
def required(~S:Data) -> D.Declaration<S,Frame(~S),U32>:
  D.changed(~S,~Setup.store(~S,~Array<U32>),~Setup.rest(~S,~Array<U32>),~Array<U32>,~U32,~Setup.Token<S,Array<U32>>,~Setup.component_take(~S,~Array<U32>),~Setup.component_put(~S,~Array<U32>),~Front.value_view,~Setup.resources(~Array<U32>),~U32,~Setup.component_binding(~S,~Array<U32>,~Array<U32>,~U32,~Front.value_view,~Front.declarations(~S)))
def optional(~S:Data) -> D.Declaration<S,Frame(~S),U32>:
  D.optional(~S,~Setup.store(~S,~Array<U32>),~Setup.rest(~S,~Array<U32>),~Array<U32>,~U32,~Setup.Token<S,Array<U32>>,~Setup.component_take(~S,~Array<U32>),~Setup.component_put(~S,~Array<U32>),~Front.value_view,~Setup.resources(~Array<U32>),~U32,~Setup.component_binding(~S,~Array<U32>,~Array<U32>,~U32,~Front.value_view,~Front.declarations(~S)))
def required_query(~S:Data) -> Query.ReadQuery<Frame(~S),S,U32>:D.query(~S,~Frame(~S),~U32,required(~S))
def optional_query(~S:Data) -> Query.ReadQuery<Frame(~S),S,U32>:D.query(~S,~Frame(~S),~U32,optional(~S))
def boolean(value:Bool) -> String:
  match value:
    case True{}:"True"
    case False{}:"False"
def access(value:C.Access<U32>) -> String:
  match value:
    case C.Found{value}:"Found{" ++ U32.show(value) ++ "}"
    case C.ComponentAbsent{}:"ComponentAbsent{}"
    case C.MissingEntity{}:"MissingEntity{}"
def row(~S:Data,value:Rows.Row<S,U32>) -> String:
  match value:
    case Rows.Row{W.Handle{ns,id},I.Value{value,added,changed}}:"Row{" ++ U32.show(ns) ++ "," ++ U32.show(id) ++ "," ++ access(value) ++ "," ++ boolean(added) ++ "," ++ boolean(changed) ++ "}"
def lookup(~S:Data,value:Result<&2,&2,Query.LookupError,Rows.Row<S,U32>>) -> String:
  match value:
    case Done{value}:"Done{" ++ row(~S,value) ++ "}"
    case Fail{Query.MissingEntity{id}}:"Fail{MissingEntity{" ++ U32.show(id) ++ "}}"
    case Fail{Query.QueryMismatch{id}}:"Fail{QueryMismatch{" ++ U32.show(id) ++ "}}"
def single(~S:Data,value:Result<&2,&2,Query.SingleError,Rows.Row<S,U32>>) -> String:
  match value:
    case Done{value}:"Done{" ++ row(~S,value) ++ "}"
    case Fail{Query.NoEntities{}}:"Fail{NoEntities{}}"
    case Fail{Query.MultipleEntities{count}}:"Fail{MultipleEntities{" ++ Nat.show(count) ++ "}}"
def maybe_row(~S:Data,value:Maybe<&2,Rows.Row<S,U32>>) -> String:
  match value:
    case None{}:"None{}"
    case Some{value}:"Some{" ++ row(~S,value) ++ "}"
def single_optional(~S:Data,value:Result<&2,&2,Query.SingleError,Maybe<&2,Rows.Row<S,U32>>>) -> String:
  match value:
    case Done{value}:"Done{" ++ maybe_row(~S,value) ++ "}"
    case Fail{Query.NoEntities{}}:"Fail{NoEntities{}}"
    case Fail{Query.MultipleEntities{count}}:"Fail{MultipleEntities{" ++ Nat.show(count) ++ "}}"
def zero_optional(~S:Data,prefix:String,result:Frame(~S) & Result<&2,&2,Query.SingleError,Maybe<&2,Rows.Row<S,U32>>>) -> Old.World(~S) & String:
  match result:
    case (I.Frame{world,cursor},value):(world,prefix ++ "|zeroSingleOptional=" ++ single_optional(~S,value) ++ "|queryFrameCursor=" ++ U32.show(cursor))
def zero_single(~S:Data,result:Frame(~S) & Result<&2,&2,Query.SingleError,Rows.Row<S,U32>>) -> Old.World(~S) & String:
  match result:
    case (owner,value):zero_optional(~S,"zeroSingle=" ++ single(~S,value),Query.single_optional(~Frame(~S),~S,~U32,~required_query(~S),owner))
def inspect_world(~S:Data,value:Old.World(~S)) -> Old.World(~S) & String:
  zero_single(~S,Query.single(~Frame(~S),~S,~U32,~required_query(~S),I.Frame{value,1}))
def joined(~S:Data,text:String,result:Old.Application(~S) & String) -> Old.Application(~S) & String:
  match result:
    case (app,physical):(app,physical ++ "|queryErrors{" ++ text ++ "}")
def observed(~S:Data,schema:Schema.Schema<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>)>,owners:Front.owners(~S),flag:Bool,result:Old.World(~S) & String) -> Old.Application(~S) & String:
  match result:
    case (world,text):joined(~S,text,Old.described(~S,True{},App.Application{schema,Build.Registered{world,owners,Tree.Recipe{},flag}}))
def describe(~S:Data,value:Old.Application(~S)) -> Old.Application(~S) & String:
  match value:
    case App.Application{schema,Build.Registered{world,owners,_,flag}}:observed(~S,schema,owners,flag,inspect_world(~S,world))

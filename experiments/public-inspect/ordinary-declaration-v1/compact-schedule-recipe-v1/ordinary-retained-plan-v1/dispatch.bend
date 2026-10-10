import Base
import ./frontend.bend as Front
import ./fixture.bend as F
import ./outcome-conversion.bend as Convert
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-dispatch-result.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-leaf-run.bend as Run
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Leaf
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Records
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-system.bend as Ord
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-field-system.bend as Field
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-resource-field-declaration.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-schema-product.bend as Setup
def component_args(value:Unit & U32) -> D.Arguments<Unit,Unit>:
  D.ComponentArgs{value}
def resource_args(value:Unit) -> D.Arguments<Unit,Unit>:
  D.ResourceArgs{value}
def identity(~S:Data,fields:Records.Fields<S>) -> U32:
  match fields:
    case Records.Fields{_,id,_,_,_,_,_,_}:id
def component(~S:Data,unit:Unit,first:Leaf.Record<S,Records.Token<Front.ComponentRegistry(~S)>>,second:Leaf.Record<S,Records.Token<Front.ResourceRegistry(~S)>>,world:W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>) -> D.DispatchResult<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Front.owners(~S),D.Arguments<Unit,Unit>,D.Error<Q.Error<Unit>,Front.Error>,D.Output<Unit,Unit>>:
  Run.component(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.owners(~S),~Q.Error<Unit>,~Unit,~Front.Error,~Unit,~Ord.observable_runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.component_ops,~Unit,~Unit,~Unit,~C.Access<U32>,~Front.query(~S),~Front.component_body),leaf=>((unit,leaf),second),Convert.component_outcome(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Q.Error<Unit>,~Unit,~Front.Error,~Unit),component_args,first,world)
def resource(~S:Data,unit:Unit,first:Leaf.Record<S,Records.Token<Front.ComponentRegistry(~S)>>,second:Leaf.Record<S,Records.Token<Front.ResourceRegistry(~S)>>,world:W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>) -> D.DispatchResult<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Front.owners(~S),D.Arguments<Unit,Unit>,D.Error<Q.Error<Unit>,Front.Error>,D.Output<Unit,Unit>>:
  Run.invoke(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.owners(~S),~Unit,~Front.Error,~Unit,~Field.runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.resource_ops(~S),~Unit,~Front.Error,~Unit,~Decl.ordinary(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.resource_ops(~S),~U32,Front.resource_declaration(~S)),~Front.resource_body(~S)),~Unit,~Q.Error<Unit>,~Front.Error,~Unit,leaf=>((unit,first),leaf),Convert.resource_outcome(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Q.Error<Unit>,~Unit,~Front.Error,~Unit),resource_args,second,world,Unit{})
def second_selected(~S:Data,allowed:Bool,unit:Unit,first:Leaf.Record<S,Records.Token<Front.ComponentRegistry(~S)>>,second:Leaf.Record<S,Records.Token<Front.ResourceRegistry(~S)>>,world:W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>,id:U32) -> D.DispatchResult<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Front.owners(~S),D.Arguments<Unit,Unit>,D.Error<Q.Error<Unit>,Front.Error>,D.Output<Unit,Unit>>:
  match allowed:
    case True{}:resource(~S,unit,first,second,world)
    case False{}:D.UnknownSystem{((unit,first),second),world,id}
def second_route(~S:Data,unit:Unit,first:Leaf.Record<S,Records.Token<Front.ComponentRegistry(~S)>>,second:Leaf.Record<S,Records.Token<Front.ResourceRegistry(~S)>>,world:W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>,+id:U32) -> D.DispatchResult<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Front.owners(~S),D.Arguments<Unit,Unit>,D.Error<Q.Error<Unit>,Front.Error>,D.Output<Unit,Unit>>:
  match second:
    case Leaf.Record{token,+fields}:second_selected(~S,U32.is_eq(id,identity(~S,fields)),unit,first,Leaf.Record{token,fields},world,id)
def first_selected(~S:Data,allowed:Bool,unit:Unit,first:Leaf.Record<S,Records.Token<Front.ComponentRegistry(~S)>>,second:Leaf.Record<S,Records.Token<Front.ResourceRegistry(~S)>>,world:W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>,id:U32) -> D.DispatchResult<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Front.owners(~S),D.Arguments<Unit,Unit>,D.Error<Q.Error<Unit>,Front.Error>,D.Output<Unit,Unit>>:
  match allowed:
    case True{}:component(~S,unit,first,second,world)
    case False{}:second_route(~S,unit,first,second,world,id)
def dispatch(~S:Data,owners:Front.owners(~S),world:W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>,id:U32) -> D.DispatchResult<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Front.owners(~S),D.Arguments<Unit,Unit>,D.Error<Q.Error<Unit>,Front.Error>,D.Output<Unit,Unit>>:
  match owners:
    case ((unit,Leaf.Record{token,+fields}),second):
      +actual=id
      first_selected(~S,U32.is_eq(actual,identity(~S,fields)),unit,Leaf.Record{token,fields},second,world,actual)

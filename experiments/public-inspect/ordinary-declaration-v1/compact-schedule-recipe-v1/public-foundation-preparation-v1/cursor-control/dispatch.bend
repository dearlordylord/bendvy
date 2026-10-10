import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-focus.bend as Focus
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-resource-declaration.bend as ResourceDeclaration
import /workspace/formal-proofs/bendvy-worktrees/schedule-observation-v1/experiments/public-inspect/ordinary-declaration-v1/schedule-app-observation-v1/component-fixture.bend as Fixture
import ./fixture-full.bend as Full
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-system.bend as P
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/operational-v1/unit-bodies.bend as Bodies
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-system.bend as Ord
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query-projection.bend as Projection
import /workspace/formal-proofs/bendvy-worktrees/ordinary-schedule-debug-v1/experiments/public-inspect/ordinary-declaration-v1/compact-schedule-recipe-v1/recipe-tree-v1/ordinary-unit.bend as Ordinary
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/component.bend as Caller
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v2/input.bend as Input
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-public-v2/fixture.bend as RF
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import Base
import ./declarations.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-records.bend as Leaf
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-leaf-run.bend as Run
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-registration-fields.bend as Stored
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-dispatch-result.bend as D
import ./fixture-outcomes.bend as Convert
def component_args(value:Unit & U32) -> D.Arguments<Unit,Input.Args>:
  D.ComponentArgs{value}
def resource_args(value:Input.Args) -> D.Arguments<Unit,Input.Args>:
  D.ResourceArgs{value}
def identity(~S:Data,fields:Stored.Fields<S>) -> U32:
  match fields:
    case Stored.Fields{_,id,_,_,_,_,_,_}:id
def invoke_first(~S:Data,unit:Unit,first:Decl.First(~S),resource:Decl.Resource(~S),last:Decl.Last(~S),world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>) -> D.DispatchResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Decl.Owners(~S),D.Arguments<Unit,Input.Args>,D.Error<Q.Error<Unit>,RF.Error>,D.Output<Unit,RF.Output>>:
  Run.component(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Decl.Owners(~S),~Q.Error<Unit>,~Input.Args,~RF.Error,~RF.Output,~Ord.observable_runner(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.read_ops,~Unit,~Unit,~Unit,~Projection.Product<C.Access<U32>,Unit>,~Ordinary.component_query(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.read_ops,~Projection.Product<C.Access<U32>,Unit>,~Full.component_declaration(~S)),~Bodies.component),leaf=>Focus.put_left(~((Unit & Decl.First(~S)) & Decl.Resource(~S)),~(Unit & Decl.Resource(~S)),~Decl.First(~S),~Decl.Last(~S),previous=>item=>Focus.put_left(~(Unit & Decl.First(~S)),~Unit,~Decl.First(~S),~Decl.Resource(~S),base=>selected=>Focus.put_first(~Unit,~Decl.First(~S),base,selected),previous,item),((unit,resource),last),leaf),Convert.component_outcome(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Q.Error<Unit>,~Unit,~RF.Error,~RF.Output),component_args,first,world)
def invoke_last(~S:Data,unit:Unit,first:Decl.First(~S),resource:Decl.Resource(~S),last:Decl.Last(~S),world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>) -> D.DispatchResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Decl.Owners(~S),D.Arguments<Unit,Input.Args>,D.Error<Q.Error<Unit>,RF.Error>,D.Output<Unit,RF.Output>>:
  Run.component(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Decl.Owners(~S),~Q.Error<Unit>,~Input.Args,~RF.Error,~RF.Output,~Ord.observable_runner(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.no_ops,~Unit,~Unit,~Unit,~Unit,~Ordinary.component_query(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Fixture.no_ops,~Unit,~Decl.absent(~S)),~Fixture.absent_body),leaf=>Focus.put_last(~((Unit & Decl.First(~S)) & Decl.Resource(~S)),~Decl.Last(~S),((unit,first),resource),leaf),Convert.component_outcome(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Q.Error<Unit>,~Unit,~RF.Error,~RF.Output),component_args,last,world)
def invoke_resource(~S:Data,unit:Unit,first:Decl.First(~S),resource:Decl.Resource(~S),last:Decl.Last(~S),world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>) -> D.DispatchResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Decl.Owners(~S),D.Arguments<Unit,Input.Args>,D.Error<Q.Error<Unit>,RF.Error>,D.Output<Unit,RF.Output>>:
  Run.invoke(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Decl.Owners(~S),~Input.Args,~RF.Error,~RF.Output,~P.runner(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~ResourceDeclaration.write_ops(~Array<U32>,~U32),~Input.Args,~RF.Error,~RF.Output,~ResourceDeclaration.ordinary(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~ResourceDeclaration.write_ops(~Array<U32>,~U32),~U32,Full.declaration(~S)),~Full.body),~Input.Args,~Q.Error<Unit>,~RF.Error,~RF.Output,leaf=>Focus.put_left(~((Unit & Decl.First(~S)) & Decl.Resource(~S)),~(Unit & Decl.First(~S)),~Decl.Resource(~S),~Decl.Last(~S),previous=>item=>Focus.put_last(~(Unit & Decl.First(~S)),~Decl.Resource(~S),previous,item),((unit,first),last),leaf),Convert.resource_outcome(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~Q.Error<Unit>,~Unit,~RF.Error,~RF.Output),resource_args,resource,world,Input.Args{Array.new(Bool,2n,False{})})

def focused_first(~S:Data,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,selected:((Unit & Decl.Resource(~S)) & Decl.Last(~S)) & Decl.First(~S)) -> D.DispatchResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Decl.Owners(~S),D.Arguments<Unit,Input.Args>,D.Error<Q.Error<Unit>,RF.Error>,D.Output<Unit,RF.Output>>:
  match selected:
    case (((unit,resource),last),first):invoke_first(~S,unit,first,resource,last,world)
def run_first(~S:Data,unit:Unit,first:Decl.First(~S),resource:Decl.Resource(~S),last:Decl.Last(~S),world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>) -> D.DispatchResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Decl.Owners(~S),D.Arguments<Unit,Input.Args>,D.Error<Q.Error<Unit>,RF.Error>,D.Output<Unit,RF.Output>>:
  focused_first(~S,world,Focus.take_left(~((Unit & Decl.First(~S)) & Decl.Resource(~S)),~(Unit & Decl.Resource(~S)),~Decl.First(~S),~Decl.Last(~S),left=>Focus.take_left(~(Unit & Decl.First(~S)),~Unit,~Decl.First(~S),~Decl.Resource(~S),part=>Focus.take_first(~Unit,~Decl.First(~S),part),left),(((unit,first),resource),last)))

def focused_resource(~S:Data,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,selected:((Unit & Decl.First(~S)) & Decl.Last(~S)) & Decl.Resource(~S)) -> D.DispatchResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Decl.Owners(~S),D.Arguments<Unit,Input.Args>,D.Error<Q.Error<Unit>,RF.Error>,D.Output<Unit,RF.Output>>:
  match selected:
    case (((unit,first),last),resource):invoke_resource(~S,unit,first,resource,last,world)
def run_resource(~S:Data,unit:Unit,first:Decl.First(~S),resource:Decl.Resource(~S),last:Decl.Last(~S),world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>) -> D.DispatchResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Decl.Owners(~S),D.Arguments<Unit,Input.Args>,D.Error<Q.Error<Unit>,RF.Error>,D.Output<Unit,RF.Output>>:
  focused_resource(~S,world,Focus.take_left(~((Unit & Decl.First(~S)) & Decl.Resource(~S)),~(Unit & Decl.First(~S)),~Decl.Resource(~S),~Decl.Last(~S),left=>Focus.take_last(~(Unit & Decl.First(~S)),~Decl.Resource(~S),left),(((unit,first),resource),last)))

def focused_last(~S:Data,world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,selected:Decl.Owners(~S)) -> D.DispatchResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Decl.Owners(~S),D.Arguments<Unit,Input.Args>,D.Error<Q.Error<Unit>,RF.Error>,D.Output<Unit,RF.Output>>:
  match selected:
    case (((unit,first),resource),last):invoke_last(~S,unit,first,resource,last,world)

def run_last(~S:Data,unit:Unit,first:Decl.First(~S),resource:Decl.Resource(~S),last:Decl.Last(~S),world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>) -> D.DispatchResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Decl.Owners(~S),D.Arguments<Unit,Input.Args>,D.Error<Q.Error<Unit>,RF.Error>,D.Output<Unit,RF.Output>>:
  focused_last(~S,world,Focus.take_last(~((Unit & Decl.First(~S)) & Decl.Resource(~S)),~Decl.Last(~S),(((unit,first),resource),last)))

def last_selected(~S:Data,allowed:Bool,unit:Unit,first:Decl.First(~S),resource:Decl.Resource(~S),last:Decl.Last(~S),world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,id:U32) -> D.DispatchResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Decl.Owners(~S),D.Arguments<Unit,Input.Args>,D.Error<Q.Error<Unit>,RF.Error>,D.Output<Unit,RF.Output>>:
  match allowed:
    case True{}:run_last(~S,unit,first,resource,last,world)
    case False{}:D.UnknownSystem{(((unit,first),resource),last),world,id}
def route_last(~S:Data,unit:Unit,first:Decl.First(~S),resource:Decl.Resource(~S),last:Decl.Last(~S),world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,+id:U32) -> D.DispatchResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Decl.Owners(~S),D.Arguments<Unit,Input.Args>,D.Error<Q.Error<Unit>,RF.Error>,D.Output<Unit,RF.Output>>:
  match last:
    case Leaf.Record{token,+fields}:last_selected(~S,U32.is_eq(id,identity(~S,fields)),unit,first,resource,Leaf.Record{token,fields},world,id)
def resource_selected(~S:Data,allowed:Bool,unit:Unit,first:Decl.First(~S),resource:Decl.Resource(~S),last:Decl.Last(~S),world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,id:U32) -> D.DispatchResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Decl.Owners(~S),D.Arguments<Unit,Input.Args>,D.Error<Q.Error<Unit>,RF.Error>,D.Output<Unit,RF.Output>>:
  match allowed:
    case True{}:run_resource(~S,unit,first,resource,last,world)
    case False{}:route_last(~S,unit,first,resource,last,world,id)
def route_resource(~S:Data,unit:Unit,first:Decl.First(~S),resource:Decl.Resource(~S),last:Decl.Last(~S),world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,+id:U32) -> D.DispatchResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Decl.Owners(~S),D.Arguments<Unit,Input.Args>,D.Error<Q.Error<Unit>,RF.Error>,D.Output<Unit,RF.Output>>:
  match resource:
    case Leaf.Record{token,+fields}:resource_selected(~S,U32.is_eq(id,identity(~S,fields)),unit,first,Leaf.Record{token,fields},last,world,id)
def first_selected(~S:Data,allowed:Bool,unit:Unit,first:Decl.First(~S),resource:Decl.Resource(~S),last:Decl.Last(~S),world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,id:U32) -> D.DispatchResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Decl.Owners(~S),D.Arguments<Unit,Input.Args>,D.Error<Q.Error<Unit>,RF.Error>,D.Output<Unit,RF.Output>>:
  match allowed:
    case True{}:run_first(~S,unit,first,resource,last,world)
    case False{}:route_resource(~S,unit,first,resource,last,world,id)
def dispatch(~S:Data,owners:Decl.Owners(~S),world:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32>,+id:U32) -> D.DispatchResult<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,Decl.Owners(~S),D.Arguments<Unit,Input.Args>,D.Error<Q.Error<Unit>,RF.Error>,D.Output<Unit,RF.Output>>:
  match owners:
    case (((unit,Leaf.Record{token,+fields}),resource),last):first_selected(~S,U32.is_eq(id,identity(~S,fields)),unit,Leaf.Record{token,fields},resource,last,world,id)

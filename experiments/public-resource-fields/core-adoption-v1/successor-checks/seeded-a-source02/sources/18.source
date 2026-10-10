import Base
import /workspace/formal-proofs/bendvy-worktrees/resource-field-integration/src/ecs/resource-field-binding.bend as B
import /workspace/formal-proofs/bendvy-worktrees/resource-field-integration/experiments/public-resource-fields/core-adoption-v1/source/schema-a.bend as A
import /workspace/formal-proofs/bendvy-worktrees/resource-field-integration/experiments/public-resource-fields/core-adoption-v1/source/operations.bend as O
import /workspace/formal-proofs/bendvy-worktrees/resource-field-integration/experiments/public-resource-fields/core-adoption-v1/seeded-v1/seed.bend as Seed
import /workspace/formal-proofs/bendvy-worktrees/resource-field-integration/experiments/public-resource-fields/core-adoption-v1/seeded-v1/consumer-engine.bend as Engine
import /workspace/formal-proofs/bendvy-worktrees/resource-field-integration/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy-worktrees/resource-field-integration/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy-worktrees/resource-field-integration/src/ecs/schema-fragments.bend as Fragment
import /workspace/formal-proofs/bendvy-worktrees/resource-field-integration/src/ecs/ordinary-schema.bend as Schema
def World() -> Type:
  Engine.World(~A.A,~A.Resources())
def identity(world:World()) -> World():
  world
def error(value:Fragment.Error) -> String:
  match value:
    case Fragment.DuplicateKey{_,key}:"DuplicateKey{" ++ key ++ "}"
    case Fragment.DuplicateName{_,name}:"DuplicateName{" ++ name ++ "}"
    case Fragment.UndeclaredDescriptor{_,key,name}:"UndeclaredDescriptor{" ++ key ++ ":" ++ name ++ "}"
def validation(value:Fragment.Validation) -> String:
  match value:
    case Fragment.Valid{}:"Valid"
    case Fragment.Invalid{value}:error(value)
def after(before:String,label:String,result:World() & String) -> String:
  match result:
    case (_,text):label ++ "|Before{" ++ before ++ "}|After{" ++ text ++ "}"
def bound(before:String,result:Fragment.Bound<A.A,World(),World()>) -> String:
  match result:
    case Fragment.Built{world}:after(before,"BUILD_REACHED",Engine.observe_world(~A.A,~A.Resources(),~A.resource_view,world))
    case Fragment.BindRejected{reason,Fragment.Fragment{_,world}}:after(before,error(reason),Engine.observe_world(~A.A,~A.Resources(),~A.resource_view,world))
def observed(+available:List<&2,Fragment.Entry<A.A>>,+required:List<&2,Fragment.Entry<A.A>>,result:World() & String) -> String:
  match result:
    case (world,before):bound(before,Fragment.bind_declared(~A.A,~World(),~World(),~identity,Fragment.Fragment{available,world},required))
def created(+available:List<&2,Fragment.Entry<A.A>>,+required:List<&2,Fragment.Entry<A.A>>,result:W.Creation<A.A,Col.Column<A.A,Unit>,A.Resources(),U32>) -> String:
  match result:
    case W.Created{_,world}:observed(available,required,Engine.observe_world(~A.A,~A.Resources(),~A.resource_view,Seed.world(~A.A,~A.Resources(),world)))
    case W.CreateRejected{_,_}:"CREATE_REJECTED"
def scenario(+available:List<&2,Fragment.Entry<A.A>>,+required:List<&2,Fragment.Entry<A.A>>) -> String:
  created(available,required,W.create(~A.A,~Col.Column<A.A,Unit>,~A.Resources(),~U32,~Engine.empty(~A.A),W.factory(),A.initial()))
def duplicate_layout() -> B.Built<A.A,A.Resources(),A.Index()>:
  B.joined(~A.A,~O.Counter,~O.Counter,~Schema.Resource<A.A,O.Counter>,~Schema.Resource<A.A,O.Counter>,B.leaf(~A.A,~O.Counter,A.first()),B.leaf(~A.A,~O.Counter,A.first()))
def main() -> String:
  duplicate=B.entries(~A.A,~A.Resources(),~A.Index(),duplicate_layout())
  +normal=B.entries(~A.A,~A.Resources(),~A.Index(),A.layout())
  first=B.entries(~A.A,~O.Counter,~Schema.Resource<A.A,O.Counter>,B.leaf(~A.A,~O.Counter,A.first()))
  "CanonicalValidation=" ++ validation(B.validate(~A.A,~A.Resources(),~A.Index(),duplicate_layout())) ++ "\nOrdinaryEntry=" ++ Engine.scenario(~A.A,~A.Resources(),~A.Ops,~A.declaration(),~A.body,~A.resource_view,B.validate(~A.A,~A.Resources(),~A.Index(),duplicate_layout()),A.initial()) ++ "\n" ++ scenario(duplicate,normal) ++ "\n" ++ scenario(first,normal) ++ "\n" ++ scenario(normal,normal)

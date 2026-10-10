import Base
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-observation-v1/bridge.bend as B
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-observation-v1/observable-resource.bend as D
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-system-v1/provider.bend as P
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/resource-app-observation-v1/fixture.bend as C
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/app.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
type Other is Data:
  Other{}
type Args is Type:
  Args{flags:Array<Bool>}
def duplicate_rejected(~Application:Type,result:B.RunResult<Application,Args,C.Error,C.Output>) -> Args & Args:
  match result:
    case B.RegistrationRejected{_,args}:(args,args)
    case B.Completed{_,_}:(Args{Array.new(Bool,0n,False{})},Args{Array.new(Bool,0n,False{})})

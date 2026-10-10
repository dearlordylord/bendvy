import Base
import ./composer.bend as Build
import ./component.bend as Component
import ../recipe-tree-v1/ordinary-unit.bend as Ordinary
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/presentation.bend as Presented
import ../recipe-tree-v1/tree.bend as Tree
import ../recipe-tree-v1/leaves.bend as Leaves
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-system.bend as System
import /workspace/formal-proofs/bendvy/src/ecs/compose.bend as Q
import /workspace/formal-proofs/bendvy/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as IQ
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-observable.bend as O
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/app.bend as DTO
def register(~S:Data,~C:Type,~R:Type,~E:Data,~Owners:Type,~Rows:Data,~observe:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~describe:Owners -> Owners & List<&2,DTO.Binding<S>>,~Ops:Type -> Type,~Args:Data,~Error:Data,~Out:Data,~Value:Data,~component:Unit -> Presented.Declaration<S,Q.Frame<S,C,R,E>,Ops(Q.Frame<S,C,R,E>),I.Frame<S,C,R,E>,Value>,~body:@-H:Type -> @-caps:Ops(H) -> Args -> H -> H & (T.Outcome<Error> & Out),~Output:Type,~done:@-NextOwners:Type -> @-NextRows:Data -> @-nextObserve:(W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<NextRows>) -> @-nextDescribe:(NextOwners -> NextOwners & List<&2,DTO.Binding<S>>) -> Build.Registered<S,W.World<S,C,R,E>,NextOwners,NextRows,nextObserve,nextDescribe> -> Output,failed:Build.Registered<S,W.World<S,C,R,E>,Owners,Rows,observe,describe> -> Output,app:Build.Registered<S,W.World<S,C,R,E>,Owners,Rows,observe,describe>,name:String,slot:String) -> Output:
  Component.register(~S,~C,~R,~E,~Owners,~Rows,~observe,~describe,~Ops,~Args,~Error,~Out,~Value,~Ordinary.component_query(~S,~C,~R,~E,~Ops,~Value,~component),~Ordinary.component_presenter(~S,~C,~R,~E,~Ops,~Value,~component),~body,~Output,~done,failed,app,name,slot)

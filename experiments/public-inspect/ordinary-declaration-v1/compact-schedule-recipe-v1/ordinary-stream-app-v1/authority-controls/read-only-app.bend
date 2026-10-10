import Base
import ../consumer-public.bend as Consumer
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-app-stream.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/inspector-transition-projection.bend as T
import /workspace/formal-proofs/bendvy/src/ecs/inspector-failure-projection.bend as Fail
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/relation-commands.bend as A
import /workspace/formal-proofs/bendvy-worktrees/graph-stream-public-bridge-v1/experiments/public-inspect/graph-stream-public-bridge-v1/state.bend as State
import ../resources.bend as Resources
def body(~S:Data,~H:Type,~cap:Cap.ValueRead<H,T.TransitionLog<S,State.FlowToken,U32>>,owner:H) -> Consumer.Application(~S) & App.Values<S,State.FlowToken,U32,U32>:
  App.read_app(~S,~State.FlowToken,~U32,~A.Store<S,State.Components<S>>,~State.Resources<S>,~U32,~Unit,~Resources.take(~S),~Resources.declaration(~S),~Consumer.failure_declaration(~S),owner)

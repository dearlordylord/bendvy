import Base
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/app.bend as App
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/component.bend as Caller
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/inspector-query.bend as IQ
def wrong(~S:Data,~H:Type,~Rows:Data,~fold:W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> -> W.World<S,Col.Column<S,Caller.Payload>,Array<U32>,U32> & App.Observation<Rows>,~describe:H -> H & List<&2,App.Binding<S>>,app:App.ApplicationType<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,Rows,fold,describe>) -> App.ApplicationType<S,Col.Column<S,Caller.Payload>,Array<U32>,U32,H,Rows,fold,describe> & IQ.ComposedReadQuery<H,S,Unit>:
  App.snapshot(~S,~Col.Column<S,Caller.Payload>,~Array<U32>,~U32,~H,~Rows,~fold,~describe,app)

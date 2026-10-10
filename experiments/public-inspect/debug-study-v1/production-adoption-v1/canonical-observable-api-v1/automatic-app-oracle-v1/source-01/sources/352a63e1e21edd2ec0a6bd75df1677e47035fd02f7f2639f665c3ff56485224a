import Base
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/app.bend as App
import /workspace/formal-proofs/bendvy-worktrees/ordinary-app-generated-observation-v1/experiments/public-inspect/ordinary-declaration-v1/automatic-app-observation-v1/component.bend as Caller
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def wrong(~H:Type,~Rows:Data,~fold:W.World<Caller.A,Col.Column<Caller.A,Caller.Payload>,Array<U32>,U32> -> W.World<Caller.A,Col.Column<Caller.A,Caller.Payload>,Array<U32>,U32> & App.Observation<Rows>,~otherFold:W.World<Caller.Other,Col.Column<Caller.Other,Caller.Payload>,Array<U32>,U32> -> W.World<Caller.Other,Col.Column<Caller.Other,Caller.Payload>,Array<U32>,U32> & App.Observation<Rows>,~describe:H -> H & List<&2,App.Binding<Caller.A>>,~otherDescribe:H -> H & List<&2,App.Binding<Caller.Other>>,app:App.ApplicationType<Caller.A,Col.Column<Caller.A,Caller.Payload>,Array<U32>,U32,H,Rows,fold,describe>) -> App.ApplicationType<Caller.Other,Col.Column<Caller.Other,Caller.Payload>,Array<U32>,U32,H,Rows,otherFold,otherDescribe>:
  app

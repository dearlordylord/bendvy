import Base
import ./schema.bend as Schema
import ./save.bend as Save
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/fixture.bend as F
import /workspace/formal-proofs/bendvy/experiments/public-snapshot/persistence-gate-v1/basic-world-v1/export.bend as Export
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col

def refused(world:W.World<F.Workshop,Col.Column<F.Workshop,F.Payload>,Unit,Unit>) -> W.World<F.Workshop,Col.Column<F.Workshop,F.Payload>,Unit,Unit> & Export.Snapshot:
  Save.save(~F.Workshop,~Col.Column<F.Workshop,F.Payload>,~Unit,~Unit,~Schema.plain_component_fields(~F.Workshop,~F.Payload),~Schema.unit_resource,Schema.plain_component(~F.Workshop,~F.Payload,~F.declaration(~F.Workshop)),world)
def main() -> U32:
  0

import Base
import ../../../../../../src/ecs/snapshot-schema.bend as Schema
import ../../../../../../src/ecs/snapshot.bend as Save
import ./legacy-fixture.bend as F
import ../../../../../../src/ecs/snapshot-data.bend as Export
import ../../../../../../src/ecs/world.bend as W
import ../../../../../../src/ecs/column.bend as Col

def refused(world:W.World<F.Workshop,Col.Column<F.Workshop,F.Payload>,Unit,Unit>) -> W.World<F.Workshop,Col.Column<F.Workshop,F.Payload>,Unit,Unit> & Export.Snapshot:
  Save.save(~F.Workshop,~Col.Column<F.Workshop,F.Payload>,~Unit,~Unit,~Schema.plain_component_fields(~F.Workshop,~F.Payload),~Schema.unit_resource,Schema.plain_component(~F.Workshop,~F.Payload,~F.declaration(~F.Workshop)),world)
def main() -> U32:
  0

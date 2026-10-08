import Base
import ../library/snapshot-schema.bend as Schema
import ../library/snapshot.bend as Save
import ./legacy-fixture.bend as F
import ../library/snapshot-data.bend as Export
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W

def wrong(world:W.World<F.Workshop,Unit,F.Payload,Unit>) -> W.World<F.Workshop,Unit,F.Payload,Unit> & Export.Snapshot:
  Save.save(~F.Workshop,~Unit,~F.Payload,~Unit,~Schema.unit_component,~Schema.plain_resource_fields(~F.Payload),Schema.plain_resource(~F.Workshop,~F.Payload,~F.declaration(~F.Workshop)),world)
def main() -> U32:
  0

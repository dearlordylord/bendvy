import Base
import ../library/snapshot-schema.bend as Schema
import ../library/snapshot-leaf.bend as Leaf
import ../library/snapshot.bend as Save
import ./legacy-fixture.bend as F
import ../library/snapshot-data.bend as Export
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W

def garden(world:W.World<F.Garden,Leaf.Component<F.Garden,F.Payload,F.declaration(~F.Garden),F.project>,Unit,Unit>) -> W.World<F.Garden,Leaf.Component<F.Garden,F.Payload,F.declaration(~F.Garden),F.project>,Unit,Unit> & Export.Snapshot:
  Save.save(~F.Garden,~Leaf.Component<F.Garden,F.Payload,F.declaration(~F.Garden),F.project>,~Unit,~Unit,~Leaf.component_fields(~F.Garden,~F.Payload,~F.declaration(~F.Garden),~F.project),~Schema.unit_resource,Schema.component(~F.Garden,~F.Payload,~F.declaration(~F.Garden),~F.project),world)
def main() -> U32:
  0

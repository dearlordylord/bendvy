import Base
import ./schema.bend as Schema
import ./leaf.bend as Leaf
import ./save.bend as Save
import ../fixture.bend as F
import ../export.bend as Export
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W

def garden(world:W.World<F.Garden,Leaf.Component<F.Garden,F.Payload,F.declaration(~F.Garden),F.project>,Unit,Unit>) -> W.World<F.Garden,Leaf.Component<F.Garden,F.Payload,F.declaration(~F.Garden),F.project>,Unit,Unit> & Export.Snapshot:
  Save.save(~F.Garden,~Leaf.Component<F.Garden,F.Payload,F.declaration(~F.Garden),F.project>,~Unit,~Unit,~Leaf.component_fields(~F.Garden,~F.Payload,~F.declaration(~F.Garden),~F.project),~Schema.unit_resource,Schema.component(~F.Garden,~F.Payload,~F.declaration(~F.Garden),~F.project),world)
def main() -> U32:
  0

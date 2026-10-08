import Base
import ./schema.bend as Schema
import ./leaf.bend as Leaf
import ./save.bend as Save
import ../fixture.bend as F
import ../export.bend as Export
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W

def workshop(world:W.World<F.Workshop,Leaf.Component<F.Workshop,F.Payload,F.declaration(~F.Workshop),F.project>,Unit,Unit>) -> W.World<F.Workshop,Leaf.Component<F.Workshop,F.Payload,F.declaration(~F.Workshop),F.project>,Unit,Unit> & Export.Snapshot:
  Save.save(~F.Workshop,~Leaf.Component<F.Workshop,F.Payload,F.declaration(~F.Workshop),F.project>,~Unit,~Unit,~Leaf.component_fields(~F.Workshop,~F.Payload,~F.declaration(~F.Workshop),~F.project),~Schema.unit_resource,Schema.component(~F.Workshop,~F.Payload,~F.declaration(~F.Workshop),~F.project),world)
def main() -> U32:
  0

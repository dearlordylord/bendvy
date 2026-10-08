import Base
import ../library/snapshot-schema.bend as Schema
import ../library/snapshot-leaf.bend as Leaf
import ../library/snapshot.bend as Save
import ./legacy-fixture.bend as F
import ../library/snapshot-data.bend as Export
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W

def workshop(world:W.World<F.Workshop,Leaf.Component<F.Workshop,F.Payload,F.declaration(~F.Workshop),F.project>,Unit,Unit>) -> W.World<F.Workshop,Leaf.Component<F.Workshop,F.Payload,F.declaration(~F.Workshop),F.project>,Unit,Unit> & Export.Snapshot:
  Save.save(~F.Workshop,~Leaf.Component<F.Workshop,F.Payload,F.declaration(~F.Workshop),F.project>,~Unit,~Unit,~Leaf.component_fields(~F.Workshop,~F.Payload,~F.declaration(~F.Workshop),~F.project),~Schema.unit_resource,Schema.component(~F.Workshop,~F.Payload,~F.declaration(~F.Workshop),~F.project),world)
def ignored(first:W.World<F.Workshop,Leaf.Component<F.Workshop,F.Payload,F.declaration(~F.Workshop),F.project>,Unit,Unit> & Export.Snapshot,second:W.World<F.Workshop,Leaf.Component<F.Workshop,F.Payload,F.declaration(~F.Workshop),F.project>,Unit,Unit> & Export.Snapshot) -> Unit:
  Unit{}
def wrong(world:W.World<F.Workshop,Leaf.Component<F.Workshop,F.Payload,F.declaration(~F.Workshop),F.project>,Unit,Unit>) -> Unit:
  ignored(workshop(world),workshop(world))
def main() -> U32:
  0

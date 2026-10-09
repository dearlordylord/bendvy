import Base
import ./handle-fixture.bend as Handle
import ../canonical-v1/source/fixture.bend as Input
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D

type Item is Data:ComponentFirst{label:String,value:Handle.Report<Input.First>} ComponentSecond{label:String,value:Handle.Report<Input.Second>} ResourceFirst{label:String,value:Input.ResourceReport} ResourceSecond{label:String,value:Input.ResourceReport}
def main() -> List<&2,Item>:
  [
    ComponentFirst{"spawn",Handle.run(~Input.First,Handle.Spawn{})},
    ComponentFirst{"insert",Handle.run(~Input.First,Handle.Insert{})},
    ComponentFirst{"failure",Handle.run(~Input.First,Handle.Failure{})},
    ComponentFirst{"failedInsert",Handle.run(~Input.First,Handle.FailedInsert{})},
    ComponentFirst{"invalid",Handle.run(~Input.First,Handle.Invalid{})},
    ComponentFirst{"invalidSpawn",Handle.run(~Input.First,Handle.InvalidSpawn{})},
    ComponentFirst{"lateMissing",Handle.run(~Input.First,Handle.LateMissing{})},
    ComponentFirst{"skip",Handle.run(~Input.First,Handle.Skip{})},
    ComponentSecond{"spawn",Handle.run(~Input.Second,Handle.Spawn{})},
    ComponentSecond{"insert",Handle.run(~Input.Second,Handle.Insert{})},
    ComponentSecond{"failure",Handle.run(~Input.Second,Handle.Failure{})},
    ComponentSecond{"failedInsert",Handle.run(~Input.Second,Handle.FailedInsert{})},
    ComponentSecond{"invalid",Handle.run(~Input.Second,Handle.Invalid{})},
    ComponentSecond{"invalidSpawn",Handle.run(~Input.Second,Handle.InvalidSpawn{})},
    ComponentSecond{"lateMissing",Handle.run(~Input.Second,Handle.LateMissing{})},
    ComponentSecond{"skip",Handle.run(~Input.Second,Handle.Skip{})},
    ResourceFirst{"valid",Input.resource(~Input.First,~D.HandleValue{1},D.Handle{1,4},False{})},
    ResourceFirst{"invalid",Input.resource(~Input.First,~D.HandleValue{1},D.Handle{2,4},False{})},
    ResourceFirst{"rollback",Input.resource(~Input.First,~D.HandleValue{1},D.Handle{1,4},True{})},
    ResourceSecond{"valid",Input.resource(~Input.Second,~D.HandleValue{1},D.Handle{1,4},False{})},
    ResourceSecond{"invalid",Input.resource(~Input.Second,~D.HandleValue{1},D.Handle{2,4},False{})},
    ResourceSecond{"rollback",Input.resource(~Input.Second,~D.HandleValue{1},D.Handle{1,4},True{})}
  ]

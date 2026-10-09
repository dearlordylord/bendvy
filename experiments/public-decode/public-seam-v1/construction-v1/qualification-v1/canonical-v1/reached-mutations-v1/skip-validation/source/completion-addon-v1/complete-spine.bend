import Base
import ../fixture.bend as Input
import ./materialization-fixture.bend as Material
import ./resource-admission-fixture.bend as Admission
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
type Item is Data:
  MaterialFirst{label:String,value:Material.Report<Input.First>}
  MaterialSecond{label:String,value:Material.Report<Input.Second>}
  AdmissionFirst{value:Admission.Report<Input.First>}
  AdmissionSecond{value:Admission.Report<Input.Second>}
def done_15(previous:List<&2,Item>,value:Item) -> List<&2,Item>:List.reverse(&2,Item,value <> previous)
def step_15(previous:List<&2,Item>) -> List<&2,Item>:done_15(previous,AdmissionSecond{Admission.run(~Input.Second,D.Number{7},False{})})
def done_14(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_15(value <> previous)
def step_14(previous:List<&2,Item>) -> List<&2,Item>:done_14(previous,AdmissionFirst{Admission.run(~Input.First,D.Number{7},False{})})
def done_13(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_14(value <> previous)
def step_13(previous:List<&2,Item>) -> List<&2,Item>:done_13(previous,MaterialSecond{"skip",Material.run(~Input.Second,Material.Skip{})})
def done_12(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_13(value <> previous)
def step_12(previous:List<&2,Item>) -> List<&2,Item>:done_12(previous,MaterialSecond{"lateMissing",Material.run(~Input.Second,Material.LateMissing{})})
def done_11(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_12(value <> previous)
def step_11(previous:List<&2,Item>) -> List<&2,Item>:done_11(previous,MaterialSecond{"invalid",Material.run(~Input.Second,Material.Invalid{})})
def done_10(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_11(value <> previous)
def step_10(previous:List<&2,Item>) -> List<&2,Item>:done_10(previous,MaterialSecond{"failedInsert",Material.run(~Input.Second,Material.FailedInsert{})})
def done_9(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_10(value <> previous)
def step_9(previous:List<&2,Item>) -> List<&2,Item>:done_9(previous,MaterialSecond{"failure",Material.run(~Input.Second,Material.Failure{})})
def done_8(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_9(value <> previous)
def step_8(previous:List<&2,Item>) -> List<&2,Item>:done_8(previous,MaterialSecond{"insert",Material.run(~Input.Second,Material.Insert{})})
def done_7(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_8(value <> previous)
def step_7(previous:List<&2,Item>) -> List<&2,Item>:done_7(previous,MaterialSecond{"spawn",Material.run(~Input.Second,Material.Spawn{})})
def done_6(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_7(value <> previous)
def step_6(previous:List<&2,Item>) -> List<&2,Item>:done_6(previous,MaterialFirst{"skip",Material.run(~Input.First,Material.Skip{})})
def done_5(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_6(value <> previous)
def step_5(previous:List<&2,Item>) -> List<&2,Item>:done_5(previous,MaterialFirst{"lateMissing",Material.run(~Input.First,Material.LateMissing{})})
def done_4(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_5(value <> previous)
def step_4(previous:List<&2,Item>) -> List<&2,Item>:done_4(previous,MaterialFirst{"invalid",Material.run(~Input.First,Material.Invalid{})})
def done_3(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_4(value <> previous)
def step_3(previous:List<&2,Item>) -> List<&2,Item>:done_3(previous,MaterialFirst{"failedInsert",Material.run(~Input.First,Material.FailedInsert{})})
def done_2(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_3(value <> previous)
def step_2(previous:List<&2,Item>) -> List<&2,Item>:done_2(previous,MaterialFirst{"failure",Material.run(~Input.First,Material.Failure{})})
def done_1(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_2(value <> previous)
def step_1(previous:List<&2,Item>) -> List<&2,Item>:done_1(previous,MaterialFirst{"insert",Material.run(~Input.First,Material.Insert{})})
def done_0(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_1(value <> previous)
def step_0(previous:List<&2,Item>) -> List<&2,Item>:done_0(previous,MaterialFirst{"spawn",Material.run(~Input.First,Material.Spawn{})})
def main() -> List<&2,Item>:step_0([])

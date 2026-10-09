import Base
import ../fixture.bend as Input
import ./request-fixture.bend as Request
import ./resource-fixture.bend as Resource
import ./local-refusal-fixture.bend as Refusal
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
import /workspace/formal-proofs/bendvy/src/ecs/bundle-requests.bend as Commands
type Item is Data:
  OwnedRequest{schema:String,label:String,value:Request.Report}
  ResourceWrite{schema:String,label:String,value:Resource.Report}
  RefusalFirst{label:String,value:Refusal.Report<Input.First>}
  RefusalSecond{label:String,value:Refusal.Report<Input.Second>}
def done_19(previous:List<&2,Item>,value:Item) -> List<&2,Item>:List.reverse(&2,Item,value <> previous)
def step_19(previous:List<&2,Item>) -> List<&2,Item>:done_19(previous,RefusalSecond{"missingRegistration",Refusal.run(~Input.Second,False{})})
def done_18(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_19(value <> previous)
def step_18(previous:List<&2,Item>) -> List<&2,Item>:done_18(previous,RefusalSecond{"foreign",Refusal.run(~Input.Second,True{})})
def done_17(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_18(value <> previous)
def step_17(previous:List<&2,Item>) -> List<&2,Item>:done_17(previous,RefusalFirst{"missingRegistration",Refusal.run(~Input.First,False{})})
def done_16(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_17(value <> previous)
def step_16(previous:List<&2,Item>) -> List<&2,Item>:done_16(previous,RefusalFirst{"foreign",Refusal.run(~Input.First,True{})})
def done_15(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_16(value <> previous)
def step_15(previous:List<&2,Item>) -> List<&2,Item>:done_15(previous,ResourceWrite{"Second","abort",Resource.run(~Input.Second,D.Number{7},True{})})
def done_14(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_15(value <> previous)
def step_14(previous:List<&2,Item>) -> List<&2,Item>:done_14(previous,ResourceWrite{"Second","refused",Resource.run(~Input.Second,D.Text{"wrong"},False{})})
def done_13(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_14(value <> previous)
def step_13(previous:List<&2,Item>) -> List<&2,Item>:done_13(previous,ResourceWrite{"Second","denied",Resource.run(~Input.Second,D.Number{403},False{})})
def done_12(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_13(value <> previous)
def step_12(previous:List<&2,Item>) -> List<&2,Item>:done_12(previous,ResourceWrite{"Second","success",Resource.run(~Input.Second,D.Number{7},False{})})
def done_11(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_12(value <> previous)
def step_11(previous:List<&2,Item>) -> List<&2,Item>:done_11(previous,ResourceWrite{"First","abort",Resource.run(~Input.First,D.Number{7},True{})})
def done_10(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_11(value <> previous)
def step_10(previous:List<&2,Item>) -> List<&2,Item>:done_10(previous,ResourceWrite{"First","refused",Resource.run(~Input.First,D.Text{"wrong"},False{})})
def done_9(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_10(value <> previous)
def step_9(previous:List<&2,Item>) -> List<&2,Item>:done_9(previous,ResourceWrite{"First","denied",Resource.run(~Input.First,D.Number{403},False{})})
def done_8(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_9(value <> previous)
def step_8(previous:List<&2,Item>) -> List<&2,Item>:done_8(previous,ResourceWrite{"First","success",Resource.run(~Input.First,D.Number{7},False{})})
def done_7(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_8(value <> previous)
def step_7(previous:List<&2,Item>) -> List<&2,Item>:done_7(previous,OwnedRequest{"Second","invalidSpawn",Request.run(~Input.Second,~D.Integer{},Commands.Spawn{},D.Text{"wrong"})})
def done_6(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_7(value <> previous)
def step_6(previous:List<&2,Item>) -> List<&2,Item>:done_6(previous,OwnedRequest{"Second","foreignInsert",Request.foreign(~Input.Second)})
def done_5(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_6(value <> previous)
def step_5(previous:List<&2,Item>) -> List<&2,Item>:done_5(previous,OwnedRequest{"Second","constructorDenied",Request.run(~Input.Second,~D.Integer{},Commands.Spawn{},D.Number{403})})
def done_4(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_5(value <> previous)
def step_4(previous:List<&2,Item>) -> List<&2,Item>:done_4(previous,OwnedRequest{"Second","spawnAbort",Request.run(~Input.Second,~D.Integer{},Commands.Spawn{},D.Number{7})})
def done_3(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_4(value <> previous)
def step_3(previous:List<&2,Item>) -> List<&2,Item>:done_3(previous,OwnedRequest{"First","invalidSpawn",Request.run(~Input.First,~D.Integer{},Commands.Spawn{},D.Text{"wrong"})})
def done_2(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_3(value <> previous)
def step_2(previous:List<&2,Item>) -> List<&2,Item>:done_2(previous,OwnedRequest{"First","foreignInsert",Request.foreign(~Input.First)})
def done_1(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_2(value <> previous)
def step_1(previous:List<&2,Item>) -> List<&2,Item>:done_1(previous,OwnedRequest{"First","constructorDenied",Request.run(~Input.First,~D.Integer{},Commands.Spawn{},D.Number{403})})
def done_0(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_1(value <> previous)
def step_0(previous:List<&2,Item>) -> List<&2,Item>:done_0(previous,OwnedRequest{"First","spawnAbort",Request.run(~Input.First,~D.Integer{},Commands.Spawn{},D.Number{7})})
def main() -> List<&2,Item>:step_0([])

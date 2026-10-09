import Base
import ../deferred-assembly-v1/fixture.bend as Fixture

type Case is Data:Spawn{} Insert{} Failure{} Foreign{} LateMissing{} Invalid{} FailedInsert{} FailedInvalid{}
type Item is Data:Item{label:Case,value:Fixture.Report}
def done_7(previous:List<&2,Item>,value:Item) -> List<&2,Item>:List.reverse(&2,Item,value <> previous)
def step_7(previous:List<&2,Item>) -> List<&2,Item>:done_7(previous,Item{FailedInvalid{},Fixture.run(Fixture.Invalid{},True{})})
def done_6(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_7(value <> previous)
def step_6(previous:List<&2,Item>) -> List<&2,Item>:done_6(previous,Item{FailedInsert{},Fixture.run(Fixture.Inserts{},True{})})
def done_5(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_6(value <> previous)
def step_5(previous:List<&2,Item>) -> List<&2,Item>:done_5(previous,Item{Invalid{},Fixture.run(Fixture.Invalid{},False{})})
def done_4(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_5(value <> previous)
def step_4(previous:List<&2,Item>) -> List<&2,Item>:done_4(previous,Item{LateMissing{},Fixture.run(Fixture.LateMissing{},False{})})
def done_3(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_4(value <> previous)
def step_3(previous:List<&2,Item>) -> List<&2,Item>:done_3(previous,Item{Foreign{},Fixture.foreign()})
def done_2(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_3(value <> previous)
def step_2(previous:List<&2,Item>) -> List<&2,Item>:done_2(previous,Item{Failure{},Fixture.run(Fixture.Spawns{},True{})})
def done_1(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_2(value <> previous)
def step_1(previous:List<&2,Item>) -> List<&2,Item>:done_1(previous,Item{Insert{},Fixture.run(Fixture.Inserts{},False{})})
def done_0(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_1(value <> previous)
def step_0(previous:List<&2,Item>) -> List<&2,Item>:done_0(previous,Item{Spawn{},Fixture.run(Fixture.Spawns{},False{})})
def main() -> List<&2,Item>:step_0([])

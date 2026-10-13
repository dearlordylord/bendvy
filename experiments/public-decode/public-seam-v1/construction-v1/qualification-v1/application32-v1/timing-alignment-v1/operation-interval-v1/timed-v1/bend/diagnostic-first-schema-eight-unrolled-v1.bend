import Base
import ../../../application.bend as Gameplay
import ../../../owner.bend as Owner
import ../../../cases.bend as Cases
import ../../../public.bend as Public

type Item is Data:Workshop{name:String,value:Public.View}
def workshop(name:String,value:Gameplay.Report<Owner.First>) -> Item:Workshop{name,Public.view(~Owner.First,value)}
def done_7(previous:List<&2,Item>,value:Item) -> List<&2,Item>:List.reverse(&2,Item,value <> previous)
def step_7(previous:List<&2,Item>) -> List<&2,Item>:done_7(previous,workshop("nestedMissing",Gameplay.run(~Owner.First,~Cases.codec(Cases.nested_missing()),Gameplay.Insert{},Cases.input(Cases.nested_missing()),Cases.resource(Cases.nested_missing()))))
def done_6(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_7(value <> previous)
def step_6(previous:List<&2,Item>) -> List<&2,Item>:done_6(previous,workshop("nestedValid",Gameplay.run(~Owner.First,~Cases.codec(Cases.nested_valid()),Gameplay.Insert{},Cases.input(Cases.nested_valid()),Cases.resource(Cases.nested_valid()))))
def done_5(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_6(value <> previous)
def step_5(previous:List<&2,Item>) -> List<&2,Item>:done_5(previous,workshop("nullableNull",Gameplay.run(~Owner.First,~Cases.codec(Cases.nullable_null()),Gameplay.Insert{},Cases.input(Cases.nullable_null()),Cases.resource(Cases.nullable_null()))))
def done_4(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_5(value <> previous)
def step_4(previous:List<&2,Item>) -> List<&2,Item>:done_4(previous,workshop("struct64",Gameplay.run(~Owner.First,~Cases.codec(Cases.struct64()),Gameplay.Insert{},Cases.input(Cases.struct64()),Cases.resource(Cases.struct64()))))
def done_3(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_4(value <> previous)
def step_3(previous:List<&2,Item>) -> List<&2,Item>:done_3(previous,workshop("lateInvalid",Gameplay.run(~Owner.First,~Cases.codec(Cases.late_invalid()),Gameplay.Insert{},Cases.input(Cases.late_invalid()),Cases.resource(Cases.late_invalid()))))
def done_2(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_3(value <> previous)
def step_2(previous:List<&2,Item>) -> List<&2,Item>:done_2(previous,workshop("array256",Gameplay.run(~Owner.First,~Cases.codec(Cases.array256()),Gameplay.Insert{},Cases.input(Cases.array256()),Cases.resource(Cases.array256()))))
def done_1(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_2(value <> previous)
def step_1(previous:List<&2,Item>) -> List<&2,Item>:done_1(previous,workshop("array128",Gameplay.run(~Owner.First,~Cases.codec(Cases.array128()),Gameplay.Insert{},Cases.input(Cases.array128()),Cases.resource(Cases.array128()))))
def done_0(previous:List<&2,Item>,value:Item) -> List<&2,Item>:step_1(value <> previous)
def step_0(previous:List<&2,Item>) -> List<&2,Item>:done_0(previous,workshop("array3",Gameplay.run(~Owner.First,~Cases.codec(Cases.array3()),Gameplay.Insert{},Cases.input(Cases.array3()),Cases.resource(Cases.array3()))))
def main() -> List<&2,Item>:step_0([])

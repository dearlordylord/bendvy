import Base
import ./format.bend as Format
import /workspace/formal-proofs/bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/application32-v1/timing-alignment-v1/serialize.bend as Encode
import /workspace/formal-proofs/bendvy/experiments/public-relations/timing/current-qualification-v1/trace-value.bend as J
import /workspace/formal-proofs/bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/application32-v1/timing-alignment-v1/application.bend as Gameplay
import /workspace/formal-proofs/bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/application32-v1/timing-alignment-v1/owner.bend as Owner
import /workspace/formal-proofs/bendvy/experiments/public-decode/public-seam-v1/construction-v1/qualification-v1/application32-v1/timing-alignment-v1/cases.bend as Cases

# Exact32 registered gameplay operations; detached full observers become Strings.
def tail(values:List<&2,String>) -> String:
  match values:
    case []:""
    case value <> rest:"," ++ value ++ tail(rest)
def joined(values:List<&2,String>) -> String:
  match values:
    case []:"[]"
    case value <> rest:"[" ++ value ++ tail(rest) ++ "]"
def workshop(operation:String,name:String,value:Gameplay.Report<Owner.First>) -> String:Format.completed(Encode.encode(Format.record("Workshop",[J.Field{"operation",J.Text{operation}},J.Field{"name",J.Text{name}},J.Field{"value",Format.whole(~Owner.First,value)}])))
def garden(operation:String,name:String,value:Gameplay.Report<Owner.Second>) -> String:Format.completed(Encode.encode(Format.record("Garden",[J.Field{"operation",J.Text{operation}},J.Field{"name",J.Text{name}},J.Field{"value",Format.whole(~Owner.Second,value)}])))
def done_31(previous:List<&2,String>,value:String) -> String:joined(List.reverse(&2,String,value <> previous))
def step_31(previous:List<&2,String>) -> String:done_31(previous,garden("insert","nestedMissing",Gameplay.run(~Owner.Second,~Cases.codec(Cases.nested_missing()),Gameplay.Insert{},Cases.input(Cases.nested_missing()),Cases.resource(Cases.nested_missing()))))
def done_30(previous:List<&2,String>,value:String) -> String:step_31(value <> previous)
def step_30(previous:List<&2,String>) -> String:done_30(previous,garden("insert","nestedValid",Gameplay.run(~Owner.Second,~Cases.codec(Cases.nested_valid()),Gameplay.Insert{},Cases.input(Cases.nested_valid()),Cases.resource(Cases.nested_valid()))))
def done_29(previous:List<&2,String>,value:String) -> String:step_30(value <> previous)
def step_29(previous:List<&2,String>) -> String:done_29(previous,garden("insert","nullableNull",Gameplay.run(~Owner.Second,~Cases.codec(Cases.nullable_null()),Gameplay.Insert{},Cases.input(Cases.nullable_null()),Cases.resource(Cases.nullable_null()))))
def done_28(previous:List<&2,String>,value:String) -> String:step_29(value <> previous)
def step_28(previous:List<&2,String>) -> String:done_28(previous,garden("insert","struct64",Gameplay.run(~Owner.Second,~Cases.codec(Cases.struct64()),Gameplay.Insert{},Cases.input(Cases.struct64()),Cases.resource(Cases.struct64()))))
def done_27(previous:List<&2,String>,value:String) -> String:step_28(value <> previous)
def step_27(previous:List<&2,String>) -> String:done_27(previous,garden("insert","lateInvalid",Gameplay.run(~Owner.Second,~Cases.codec(Cases.late_invalid()),Gameplay.Insert{},Cases.input(Cases.late_invalid()),Cases.resource(Cases.late_invalid()))))
def done_26(previous:List<&2,String>,value:String) -> String:step_27(value <> previous)
def step_26(previous:List<&2,String>) -> String:done_26(previous,garden("insert","array256",Gameplay.run(~Owner.Second,~Cases.codec(Cases.array256()),Gameplay.Insert{},Cases.input(Cases.array256()),Cases.resource(Cases.array256()))))
def done_25(previous:List<&2,String>,value:String) -> String:step_26(value <> previous)
def step_25(previous:List<&2,String>) -> String:done_25(previous,garden("insert","array128",Gameplay.run(~Owner.Second,~Cases.codec(Cases.array128()),Gameplay.Insert{},Cases.input(Cases.array128()),Cases.resource(Cases.array128()))))
def done_24(previous:List<&2,String>,value:String) -> String:step_25(value <> previous)
def step_24(previous:List<&2,String>) -> String:done_24(previous,garden("insert","array3",Gameplay.run(~Owner.Second,~Cases.codec(Cases.array3()),Gameplay.Insert{},Cases.input(Cases.array3()),Cases.resource(Cases.array3()))))
def done_23(previous:List<&2,String>,value:String) -> String:step_24(value <> previous)
def step_23(previous:List<&2,String>) -> String:done_23(previous,workshop("resource","nestedMissing",Gameplay.run(~Owner.First,~Cases.codec(Cases.nested_missing()),Gameplay.ResourceWrite{},Cases.input(Cases.nested_missing()),Cases.resource(Cases.nested_missing()))))
def done_22(previous:List<&2,String>,value:String) -> String:step_23(value <> previous)
def step_22(previous:List<&2,String>) -> String:done_22(previous,workshop("resource","nestedValid",Gameplay.run(~Owner.First,~Cases.codec(Cases.nested_valid()),Gameplay.ResourceWrite{},Cases.input(Cases.nested_valid()),Cases.resource(Cases.nested_valid()))))
def done_21(previous:List<&2,String>,value:String) -> String:step_22(value <> previous)
def step_21(previous:List<&2,String>) -> String:done_21(previous,workshop("resource","nullableNull",Gameplay.run(~Owner.First,~Cases.codec(Cases.nullable_null()),Gameplay.ResourceWrite{},Cases.input(Cases.nullable_null()),Cases.resource(Cases.nullable_null()))))
def done_20(previous:List<&2,String>,value:String) -> String:step_21(value <> previous)
def step_20(previous:List<&2,String>) -> String:done_20(previous,workshop("resource","struct64",Gameplay.run(~Owner.First,~Cases.codec(Cases.struct64()),Gameplay.ResourceWrite{},Cases.input(Cases.struct64()),Cases.resource(Cases.struct64()))))
def done_19(previous:List<&2,String>,value:String) -> String:step_20(value <> previous)
def step_19(previous:List<&2,String>) -> String:done_19(previous,workshop("resource","lateInvalid",Gameplay.run(~Owner.First,~Cases.codec(Cases.late_invalid()),Gameplay.ResourceWrite{},Cases.input(Cases.late_invalid()),Cases.resource(Cases.late_invalid()))))
def done_18(previous:List<&2,String>,value:String) -> String:step_19(value <> previous)
def step_18(previous:List<&2,String>) -> String:done_18(previous,workshop("resource","array256",Gameplay.run(~Owner.First,~Cases.codec(Cases.array256()),Gameplay.ResourceWrite{},Cases.input(Cases.array256()),Cases.resource(Cases.array256()))))
def done_17(previous:List<&2,String>,value:String) -> String:step_18(value <> previous)
def step_17(previous:List<&2,String>) -> String:done_17(previous,workshop("resource","array128",Gameplay.run(~Owner.First,~Cases.codec(Cases.array128()),Gameplay.ResourceWrite{},Cases.input(Cases.array128()),Cases.resource(Cases.array128()))))
def done_16(previous:List<&2,String>,value:String) -> String:step_17(value <> previous)
def step_16(previous:List<&2,String>) -> String:done_16(previous,workshop("resource","array3",Gameplay.run(~Owner.First,~Cases.codec(Cases.array3()),Gameplay.ResourceWrite{},Cases.input(Cases.array3()),Cases.resource(Cases.array3()))))
def done_15(previous:List<&2,String>,value:String) -> String:step_16(value <> previous)
def step_15(previous:List<&2,String>) -> String:done_15(previous,workshop("spawn","nestedMissing",Gameplay.run(~Owner.First,~Cases.codec(Cases.nested_missing()),Gameplay.Spawn{},Cases.input(Cases.nested_missing()),Cases.resource(Cases.nested_missing()))))
def done_14(previous:List<&2,String>,value:String) -> String:step_15(value <> previous)
def step_14(previous:List<&2,String>) -> String:done_14(previous,workshop("spawn","nestedValid",Gameplay.run(~Owner.First,~Cases.codec(Cases.nested_valid()),Gameplay.Spawn{},Cases.input(Cases.nested_valid()),Cases.resource(Cases.nested_valid()))))
def done_13(previous:List<&2,String>,value:String) -> String:step_14(value <> previous)
def step_13(previous:List<&2,String>) -> String:done_13(previous,workshop("spawn","nullableNull",Gameplay.run(~Owner.First,~Cases.codec(Cases.nullable_null()),Gameplay.Spawn{},Cases.input(Cases.nullable_null()),Cases.resource(Cases.nullable_null()))))
def done_12(previous:List<&2,String>,value:String) -> String:step_13(value <> previous)
def step_12(previous:List<&2,String>) -> String:done_12(previous,workshop("spawn","struct64",Gameplay.run(~Owner.First,~Cases.codec(Cases.struct64()),Gameplay.Spawn{},Cases.input(Cases.struct64()),Cases.resource(Cases.struct64()))))
def done_11(previous:List<&2,String>,value:String) -> String:step_12(value <> previous)
def step_11(previous:List<&2,String>) -> String:done_11(previous,workshop("spawn","lateInvalid",Gameplay.run(~Owner.First,~Cases.codec(Cases.late_invalid()),Gameplay.Spawn{},Cases.input(Cases.late_invalid()),Cases.resource(Cases.late_invalid()))))
def done_10(previous:List<&2,String>,value:String) -> String:step_11(value <> previous)
def step_10(previous:List<&2,String>) -> String:done_10(previous,workshop("spawn","array256",Gameplay.run(~Owner.First,~Cases.codec(Cases.array256()),Gameplay.Spawn{},Cases.input(Cases.array256()),Cases.resource(Cases.array256()))))
def done_9(previous:List<&2,String>,value:String) -> String:step_10(value <> previous)
def step_9(previous:List<&2,String>) -> String:done_9(previous,workshop("spawn","array128",Gameplay.run(~Owner.First,~Cases.codec(Cases.array128()),Gameplay.Spawn{},Cases.input(Cases.array128()),Cases.resource(Cases.array128()))))
def done_8(previous:List<&2,String>,value:String) -> String:step_9(value <> previous)
def step_8(previous:List<&2,String>) -> String:done_8(previous,workshop("spawn","array3",Gameplay.run(~Owner.First,~Cases.codec(Cases.array3()),Gameplay.Spawn{},Cases.input(Cases.array3()),Cases.resource(Cases.array3()))))
def done_7(previous:List<&2,String>,value:String) -> String:step_8(value <> previous)
def step_7(previous:List<&2,String>) -> String:done_7(previous,workshop("insert","nestedMissing",Gameplay.run(~Owner.First,~Cases.codec(Cases.nested_missing()),Gameplay.Insert{},Cases.input(Cases.nested_missing()),Cases.resource(Cases.nested_missing()))))
def done_6(previous:List<&2,String>,value:String) -> String:step_7(value <> previous)
def step_6(previous:List<&2,String>) -> String:done_6(previous,workshop("insert","nestedValid",Gameplay.run(~Owner.First,~Cases.codec(Cases.nested_valid()),Gameplay.Insert{},Cases.input(Cases.nested_valid()),Cases.resource(Cases.nested_valid()))))
def done_5(previous:List<&2,String>,value:String) -> String:step_6(value <> previous)
def step_5(previous:List<&2,String>) -> String:done_5(previous,workshop("insert","nullableNull",Gameplay.run(~Owner.First,~Cases.codec(Cases.nullable_null()),Gameplay.Insert{},Cases.input(Cases.nullable_null()),Cases.resource(Cases.nullable_null()))))
def done_4(previous:List<&2,String>,value:String) -> String:step_5(value <> previous)
def step_4(previous:List<&2,String>) -> String:done_4(previous,workshop("insert","struct64",Gameplay.run(~Owner.First,~Cases.codec(Cases.struct64()),Gameplay.Insert{},Cases.input(Cases.struct64()),Cases.resource(Cases.struct64()))))
def done_3(previous:List<&2,String>,value:String) -> String:step_4(value <> previous)
def step_3(previous:List<&2,String>) -> String:done_3(previous,workshop("insert","lateInvalid",Gameplay.run(~Owner.First,~Cases.codec(Cases.late_invalid()),Gameplay.Insert{},Cases.input(Cases.late_invalid()),Cases.resource(Cases.late_invalid()))))
def done_2(previous:List<&2,String>,value:String) -> String:step_3(value <> previous)
def step_2(previous:List<&2,String>) -> String:done_2(previous,workshop("insert","array256",Gameplay.run(~Owner.First,~Cases.codec(Cases.array256()),Gameplay.Insert{},Cases.input(Cases.array256()),Cases.resource(Cases.array256()))))
def done_1(previous:List<&2,String>,value:String) -> String:step_2(value <> previous)
def step_1(previous:List<&2,String>) -> String:done_1(previous,workshop("insert","array128",Gameplay.run(~Owner.First,~Cases.codec(Cases.array128()),Gameplay.Insert{},Cases.input(Cases.array128()),Cases.resource(Cases.array128()))))
def done_0(previous:List<&2,String>,value:String) -> String:step_1(value <> previous)
def step_0(previous:List<&2,String>) -> String:done_0(previous,workshop("insert","array3",Gameplay.run(~Owner.First,~Cases.codec(Cases.array3()),Gameplay.Insert{},Cases.input(Cases.array3()),Cases.resource(Cases.array3()))))
def main() -> String:step_0([])

import Base
import ../../../application.bend as Gameplay
import ../../../owner.bend as Owner
import ../../../cases.bend as Cases
import ../../../public.bend as Public

type Item is Data:Workshop{operation:String,name:String,value:Public.View} Garden{operation:String,name:String,value:Public.View}

# One concrete helper body per schema and codec; operation and data remain per invocation.
def first_run(~codec:D.Codec,operation:String,name:String,mode:Gameplay.Mode,input:D.Raw,seed:D.Raw) -> Item:
  Workshop{operation,name,Public.view(~Owner.First,Gameplay.run(~Owner.First,~codec,mode,input,seed))}
def second_run(~codec:D.Codec,operation:String,name:String,mode:Gameplay.Mode,input:D.Raw,seed:D.Raw) -> Item:
  Garden{operation,name,Public.view(~Owner.Second,Gameplay.run(~Owner.Second,~codec,mode,input,seed))}

def first_insert() -> List<&2,Item>:
  first_run(~Cases.codec(Cases.array3()),"insert","array3",Gameplay.Insert{},Cases.input(Cases.array3()),Cases.resource(Cases.array3()))
 <>
  first_run(~Cases.codec(Cases.array128()),"insert","array128",Gameplay.Insert{},Cases.input(Cases.array128()),Cases.resource(Cases.array128()))
 <>
  first_run(~Cases.codec(Cases.array256()),"insert","array256",Gameplay.Insert{},Cases.input(Cases.array256()),Cases.resource(Cases.array256()))
 <>
  first_run(~Cases.codec(Cases.late_invalid()),"insert","lateInvalid",Gameplay.Insert{},Cases.input(Cases.late_invalid()),Cases.resource(Cases.late_invalid()))
 <>
  first_run(~Cases.codec(Cases.struct64()),"insert","struct64",Gameplay.Insert{},Cases.input(Cases.struct64()),Cases.resource(Cases.struct64()))
 <>
  first_run(~Cases.codec(Cases.nullable_null()),"insert","nullableNull",Gameplay.Insert{},Cases.input(Cases.nullable_null()),Cases.resource(Cases.nullable_null()))
 <>
  first_run(~Cases.codec(Cases.nested_valid()),"insert","nestedValid",Gameplay.Insert{},Cases.input(Cases.nested_valid()),Cases.resource(Cases.nested_valid()))
 <>
  first_run(~Cases.codec(Cases.nested_missing()),"insert","nestedMissing",Gameplay.Insert{},Cases.input(Cases.nested_missing()),Cases.resource(Cases.nested_missing()))

def first_spawn() -> List<&2,Item>:
  first_run(~Cases.codec(Cases.array3()),"spawn","array3",Gameplay.Spawn{},Cases.input(Cases.array3()),Cases.resource(Cases.array3()))
 <>
  first_run(~Cases.codec(Cases.array128()),"spawn","array128",Gameplay.Spawn{},Cases.input(Cases.array128()),Cases.resource(Cases.array128()))
 <>
  first_run(~Cases.codec(Cases.array256()),"spawn","array256",Gameplay.Spawn{},Cases.input(Cases.array256()),Cases.resource(Cases.array256()))
 <>
  first_run(~Cases.codec(Cases.late_invalid()),"spawn","lateInvalid",Gameplay.Spawn{},Cases.input(Cases.late_invalid()),Cases.resource(Cases.late_invalid()))
 <>
  first_run(~Cases.codec(Cases.struct64()),"spawn","struct64",Gameplay.Spawn{},Cases.input(Cases.struct64()),Cases.resource(Cases.struct64()))
 <>
  first_run(~Cases.codec(Cases.nullable_null()),"spawn","nullableNull",Gameplay.Spawn{},Cases.input(Cases.nullable_null()),Cases.resource(Cases.nullable_null()))
 <>
  first_run(~Cases.codec(Cases.nested_valid()),"spawn","nestedValid",Gameplay.Spawn{},Cases.input(Cases.nested_valid()),Cases.resource(Cases.nested_valid()))
 <>
  first_run(~Cases.codec(Cases.nested_missing()),"spawn","nestedMissing",Gameplay.Spawn{},Cases.input(Cases.nested_missing()),Cases.resource(Cases.nested_missing()))

def first_resource() -> List<&2,Item>:
  first_run(~Cases.codec(Cases.array3()),"resource","array3",Gameplay.ResourceWrite{},Cases.input(Cases.array3()),Cases.resource(Cases.array3()))
 <>
  first_run(~Cases.codec(Cases.array128()),"resource","array128",Gameplay.ResourceWrite{},Cases.input(Cases.array128()),Cases.resource(Cases.array128()))
 <>
  first_run(~Cases.codec(Cases.array256()),"resource","array256",Gameplay.ResourceWrite{},Cases.input(Cases.array256()),Cases.resource(Cases.array256()))
 <>
  first_run(~Cases.codec(Cases.late_invalid()),"resource","lateInvalid",Gameplay.ResourceWrite{},Cases.input(Cases.late_invalid()),Cases.resource(Cases.late_invalid()))
 <>
  first_run(~Cases.codec(Cases.struct64()),"resource","struct64",Gameplay.ResourceWrite{},Cases.input(Cases.struct64()),Cases.resource(Cases.struct64()))
 <>
  first_run(~Cases.codec(Cases.nullable_null()),"resource","nullableNull",Gameplay.ResourceWrite{},Cases.input(Cases.nullable_null()),Cases.resource(Cases.nullable_null()))
 <>
  first_run(~Cases.codec(Cases.nested_valid()),"resource","nestedValid",Gameplay.ResourceWrite{},Cases.input(Cases.nested_valid()),Cases.resource(Cases.nested_valid()))
 <>
  first_run(~Cases.codec(Cases.nested_missing()),"resource","nestedMissing",Gameplay.ResourceWrite{},Cases.input(Cases.nested_missing()),Cases.resource(Cases.nested_missing()))

def second_insert() -> List<&2,Item>:
  second_run(~Cases.codec(Cases.array3()),"insert","array3",Gameplay.Insert{},Cases.input(Cases.array3()),Cases.resource(Cases.array3()))
 <>
  second_run(~Cases.codec(Cases.array128()),"insert","array128",Gameplay.Insert{},Cases.input(Cases.array128()),Cases.resource(Cases.array128()))
 <>
  second_run(~Cases.codec(Cases.array256()),"insert","array256",Gameplay.Insert{},Cases.input(Cases.array256()),Cases.resource(Cases.array256()))
 <>
  second_run(~Cases.codec(Cases.late_invalid()),"insert","lateInvalid",Gameplay.Insert{},Cases.input(Cases.late_invalid()),Cases.resource(Cases.late_invalid()))
 <>
  second_run(~Cases.codec(Cases.struct64()),"insert","struct64",Gameplay.Insert{},Cases.input(Cases.struct64()),Cases.resource(Cases.struct64()))
 <>
  second_run(~Cases.codec(Cases.nullable_null()),"insert","nullableNull",Gameplay.Insert{},Cases.input(Cases.nullable_null()),Cases.resource(Cases.nullable_null()))
 <>
  second_run(~Cases.codec(Cases.nested_valid()),"insert","nestedValid",Gameplay.Insert{},Cases.input(Cases.nested_valid()),Cases.resource(Cases.nested_valid()))
 <>
  second_run(~Cases.codec(Cases.nested_missing()),"insert","nestedMissing",Gameplay.Insert{},Cases.input(Cases.nested_missing()),Cases.resource(Cases.nested_missing()))

# Preserve the original operation-major and case-major observation order.
def main() -> List<&2,Item>:
  List.append(&2,Item,first_insert(),List.append(&2,Item,first_spawn(),List.append(&2,Item,first_resource(),second_insert())))

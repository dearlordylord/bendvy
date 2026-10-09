import Base
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D

type Case is Data:Case{name:String,codec:D.Codec,input:D.Raw,seed:D.Raw}
def ones(count:Nat) -> List<&2,D.Raw>:
  match count:
    case Zero{}:[]
    case Succ{rest}:D.Number{1} <> ones(rest)
def fields(remaining:Nat,+count:U32) -> List<&2,D.NamedCodec>:
  match remaining:
    case Zero{}:[]
    case Succ{rest}:D.NamedCodec{String.append("f",U32.show(count)),D.Integer{}} <> fields(rest,U32.add(count,1))
def values(remaining:Nat,+count:U32) -> List<&2,D.Field>:
  match remaining:
    case Zero{}:[]
    case Succ{rest}:D.Field{String.append("f",U32.show(count)),D.Number{count}} <> values(rest,U32.add(count,1))
def nested() -> D.Codec:D.Struct{[D.NamedCodec{"items",D.Nullable{D.ArrayValue{D.Struct{[D.NamedCodec{"value",D.Integer{}}]}}}}]}
def seed() -> D.Raw:D.Object{[D.Field{"items",D.Null{}}]}
def array3() -> Case:Case{"array3",D.ArrayValue{D.Integer{}},D.Array{ones(3n)},D.Array{[]}}
def array128() -> Case:Case{"array128",D.ArrayValue{D.Integer{}},D.Array{ones(128n)},D.Array{[]}}
def array256() -> Case:Case{"array256",D.ArrayValue{D.Integer{}},D.Array{ones(256n)},D.Array{[]}}
def late_invalid() -> Case:Case{"lateInvalid",D.ArrayValue{D.Integer{}},D.Array{List.append(&2,D.Raw,ones(127n),[D.Text{"late-invalid"}])},D.Array{[]}}
def struct64() -> Case:Case{"struct64",D.Struct{fields(64n,0)},D.Object{List.append(&2,D.Field,values(64n,0),[D.Field{"extra",D.Text{"drop-me"}}])},D.Object{values(64n,0)}}
def nullable_null() -> Case:Case{"nullableNull",nested(),seed(),seed()}
def nested_valid() -> Case:Case{"nestedValid",nested(),D.Object{[D.Field{"items",D.Array{[D.Object{[D.Field{"value",D.Number{1}}]},D.Object{[D.Field{"value",D.Number{2}}]}]}}]},seed()}
def nested_missing() -> Case:Case{"nestedMissing",nested(),D.Object{[D.Field{"items",D.Array{[D.Object{[D.Field{"value",D.Number{1}}]},D.Object{[]}]}}]},seed()}
def codec(value:Case) -> D.Codec:
  match value:
    case Case{_,codec,_,_}:codec
def input(value:Case) -> D.Raw:
  match value:
    case Case{_,_,input,_}:input
def resource(value:Case) -> D.Raw:
  match value:
    case Case{_,_,_,resource}:resource

import Base
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D

type Owner is Type: Owner{value:D.Raw,sentinel:Array<U32>}
type Observation is Data: Observation{originalRaw:D.Raw,sentinel:List<&2,U32>,checked:D.Checked}
type Report is Data:
  Report{array3:Observation,array128:Observation,array256:Observation,lateInvalid:Observation,struct64:Observation,nullableNull:Observation,nestedValid:Observation,nestedMissing:Observation}
def project(owner:Owner) -> Owner & D.Raw:
  match owner:
    case Owner{+raw,sentinel}: (Owner{raw,sentinel},raw)
def sentinel(owner:Array<U32>) -> List<&2,U32>:
  match owner:
    case ALeaf{value}: [value]
    case ANode{left,right}: List.append(&2,U32,sentinel(left),sentinel(right))
def observed(result:D.Receipt<Owner>) -> Observation:
  match result:
    case D.Receipt{Owner{raw,owner},checked}: Observation{raw,sentinel(owner),checked}
def run(codec:D.Codec,raw:D.Raw) -> Observation:
  observed(D.decode_owner(~Owner,~project,128n,codec,Owner{raw,ANode{ALeaf{111},ALeaf{222}}}))
def items(count:Nat,tail:List<&2,D.Raw>) -> List<&2,D.Raw>:
  match count:
    case 0n: tail
    case 1n+rest: D.Number{1} <> items(rest,tail)
def codecs(count:Nat,+index:U32) -> List<&2,D.NamedCodec>:
  match count:
    case 0n: []
    case 1n+rest: D.NamedCodec{"f" ++ U32.show(index),D.Integer{}} <> codecs(rest,U32.add(index,1))
def fields(count:Nat,+index:U32,tail:List<&2,D.Field>) -> List<&2,D.Field>:
  match count:
    case 0n: tail
    case 1n+rest: D.Field{"f" ++ U32.show(index),D.Number{index}} <> fields(rest,U32.add(index,1),tail)
def nested_codec() -> D.Codec:
  D.Struct{[D.NamedCodec{"items",D.Nullable{D.ArrayValue{D.Struct{[D.NamedCodec{"value",D.Integer{}}]}}}}]}
def main() -> Report:
  Report{run(D.ArrayValue{D.Integer{}},D.Array{items(3n,[])}),
    run(D.ArrayValue{D.Integer{}},D.Array{items(128n,[])}),
    run(D.ArrayValue{D.Integer{}},D.Array{items(256n,[])}),
    run(D.ArrayValue{D.Integer{}},D.Array{items(127n,[D.Text{"late-invalid"}])}),
    run(D.Struct{codecs(64n,0)},D.Object{fields(64n,0,[D.Field{"extra",D.Text{"drop-me"}}])}),
    run(nested_codec(),D.Object{[D.Field{"items",D.Null{}}]}),
    run(nested_codec(),D.Object{[D.Field{"items",D.Array{[D.Object{[D.Field{"value",D.Number{1}}]},D.Object{[D.Field{"value",D.Number{2}}]}]}}]}),
    run(nested_codec(),D.Object{[D.Field{"items",D.Array{[D.Object{[D.Field{"value",D.Number{1}}]},D.Object{[]}]}}]})}

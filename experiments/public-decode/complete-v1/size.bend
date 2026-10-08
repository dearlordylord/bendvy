import Base
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D

def codec_size(codec:D.Codec) -> Nat:
  match codec:
    case D.Nullable{inner}: Nat.add(1n,codec_size(inner))
    case D.ArrayValue{inner}: Nat.add(1n,codec_size(inner))
    case D.Struct{[]}: 1n
    case D.Struct{D.NamedCodec{_,child} <> rest}: Nat.add(1n,Nat.add(codec_size(child),codec_size(D.Struct{rest})))
    case _: 1n

def raw_size(raw:D.Raw) -> Nat:
  match raw:
    case D.Array{[]}: 1n
    case D.Array{head <> rest}: Nat.add(raw_size(head),raw_size(D.Array{rest}))
    case D.Object{[]}: 1n
    case D.Object{D.Field{_,child} <> rest}: Nat.add(raw_size(child),raw_size(D.Object{rest}))
    case _: 1n

def budget(codec:D.Codec,raw:D.Raw) -> Nat:
  Nat.mul(4n,Nat.mul(codec_size(codec),Nat.add(raw_size(raw),1n)))

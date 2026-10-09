import Base
import ./utf16.bend as Utf16
# Raw is a typed Data description. Arbitrary affine payload ownership is a
# separate explicit receipt; this validator never invents an inverse Raw -> C.
type Raw is Data:
  Missing{}
  Null{}
  Number{value:U32}
  SignedInteger{negative:Bool,magnitude:Nat}
  Float{value:F32}
  Binary64{high:U32,low:U32}
  Text{value:String}
  Utf16Text{units:List<&2,U32>}
  Boolean{value:Bool}
  Handle{namespace:U32,id:U32}
  Array{items:List<&2,Raw>}
  Object{fields:List<&2,Field>}
type Field is Data:
  Field{name:String,value:Raw}
type Codec is Data:
  FiniteNumber{}
  Integer{}
  StringValue{}
  BoolValue{}
  Literal{value:Raw}
  LiteralValues{values:List<&2,Raw>}
  LiteralRendered{values:List<&2,Raw>,expected:String}
  Nullable{inner:Codec}
  ArrayValue{inner:Codec}
  Struct{fields:List<&2,NamedCodec>}
  HandleValue{namespace:U32}
type NamedCodec is Data:
  NamedCodec{name:String,codec:Codec}
type Error is Data:
  Invalid{path:String,expected:String,actual:Raw}
  FuelExhausted{path:String}
type Checked is Data:
  Accepted{value:Raw}
  Rejected{error:Error}
type Owned<Owner:Type> is Type:
  Owned{owner:Owner,description:Raw}
type Receipt<Owner:Type> is Type:
  Receipt{owner:Owner,checked:Checked}
def field_choose(equal:Bool,value:Raw,next:Unit -> Raw) -> Raw:
  match equal:
    case True{}: value
    case False{}: next(Unit{})
def field(+name:String,fields:List<&2,Field>) -> Raw:
  match fields:
    case []: Missing{}
    case Field{key,value} <> rest: field_choose(String.eq(name,key),value,_ => field(name,rest))
type Work is Data:
  Work{codec:Codec,raw:Raw,path:String}
type Step is Data:
  Continue{work:List<&2,Work>}
  Stop{error:Error}
# Exact SameValueZero numeric equality uses a 53-bit mantissa pair, avoiding
# impossible runtime Nat immediates above Bend's 2^48-1 emitter limit.
type Numeric is Data:
  Finite{negative:Bool,high:U32,low:U32,exponent:U32}
  Infinity{negative:Bool}
  NotNumber{}
  NaN{}
def normalize_checked(fuel:Nat,+negative:Bool,+high:U32,+low:U32,+exponent:U32,zero:Bool,even:Bool) -> Numeric:
  match fuel zero even:
    case _ True{} _: Finite{False{},0,0,0}
    case _ False{} False{}: Finite{negative,high,low,exponent}
    case 0n False{} True{}: Finite{negative,high,low,exponent}
    case 1n+more False{} True{}: normalize_checked(more,negative,U32.div(high,2),U32.add(U32.div(low,2),U32.mul(U32.mod(high,2),2147483648)),U32.add(exponent,1),False{},U32.is_eq(U32.mod(U32.div(low,2),2),0))
def normalize(fuel:Nat,+negative:Bool,+high:U32,+low:U32,+exponent:U32) -> Numeric:
  normalize_checked(fuel,negative,high,low,exponent,U32.is_eq(high,0) && U32.is_eq(low,0),U32.is_eq(U32.mod(low,2),0))
def numeric_special(negative:Bool,infinite:Bool) -> Numeric:
  match infinite:
    case True{}: Infinity{negative}
    case False{}: NaN{}
def float_parts(+bits:U32,+exponent:U32,+fraction:U32,special:Bool,zero:Bool) -> Numeric:
  match special zero:
    case True{} _: numeric_special(U32.is_ge(bits,2147483648),U32.is_eq(fraction,0))
    case False{} True{}: normalize(64n,U32.is_ge(bits,2147483648),0,fraction,925)
    case False{} False{}: normalize(64n,U32.is_ge(bits,2147483648),0,U32.add(fraction,8388608),U32.add(exponent,924))
def float_numeric(+bits:U32) -> Numeric:
  float_parts(bits,U32.mod(U32.div(bits,8388608),256),U32.mod(bits,8388608),U32.is_eq(U32.mod(U32.div(bits,8388608),256),255),U32.is_eq(U32.mod(U32.div(bits,8388608),256),0))
def binary_parts(+negative:Bool,+exponent:U32,+high:U32,+low:U32,special:Bool,zero:Bool) -> Numeric:
  match special zero:
    case True{} _: numeric_special(negative,U32.is_eq(high,0) && U32.is_eq(low,0))
    case False{} True{}: normalize(64n,negative,high,low,0)
    case False{} False{}: normalize(64n,negative,U32.add(high,1048576),low,U32.sub(exponent,1))
def binary_numeric(+high:U32,+low:U32) -> Numeric:
  binary_parts(U32.is_ge(high,2147483648),U32.mod(U32.div(high,1048576),2048),U32.mod(high,1048576),low,U32.is_eq(U32.mod(U32.div(high,1048576),2048),2047),U32.is_eq(U32.mod(U32.div(high,1048576),2048),0))
def numeric(raw:Raw) -> Numeric:
  match raw:
    case Number{value}: normalize(64n,False{},0,value,1074)
    case SignedInteger{negative,+value}: normalize(64n,negative,U32.from_nat(Nat.div(value,Nat.mul(65536n,65536n))),U32.from_nat(Nat.mod(value,Nat.mul(65536n,65536n))),1074)
    case Float{value}: float_numeric(F32.bits(value))
    case Binary64{high,low}: binary_numeric(high,low)
    case _: NotNumber{}
def same_bool(a:Bool,b:Bool) -> Bool:
  match a b:
    case True{} True{}: True{}
    case False{} False{}: True{}
    case _ _: False{}
def same_numeric(a:Numeric,b:Numeric) -> Bool:
  match a b:
    case Finite{an,ah,al,ae} Finite{bn,bh,bl,be}: same_bool(an,bn) && U32.is_eq(ah,bh) && U32.is_eq(al,bl) && U32.is_eq(ae,be)
    case Infinity{a} Infinity{b}: same_bool(a,b)
    case NaN{} NaN{}: True{}
    case _ _: False{}
def equal(+a:Raw,+b:Raw) -> Bool:
  match a b:
    case Null{} Null{}: True{}
    case Text{a} Text{b}: String.eq(a,b)
    case Utf16Text{a} Utf16Text{b}: Utf16.checked(a,b)
    case Utf16Text{a} Text{b}: Utf16.checked(a,Utf16.text(b))
    case Text{a} Utf16Text{b}: Utf16.checked(Utf16.text(a),b)
    case Boolean{a} Boolean{b}: same_bool(a,b)
    case _ _: same_numeric(numeric(a),numeric(b))
def alternatives(values:List<&2,Raw>,+raw:Raw) -> Bool:
  match values:
    case []: False{}
    case value <> tail: equal(value,raw) || alternatives(tail,raw)
def choose_checked(valid:Bool,+path:String,+expected:String,raw:Raw,rest:List<&2,Work>) -> Step:
  match valid:
    case True{}: Continue{rest}
    case False{}: Stop{Invalid{path,expected,raw}}
def array_work(+codec:Codec,items:List<&2,Raw>,+path:String,+index:U32,rest:List<&2,Work>) -> List<&2,Work>:
  match items:
    case []: rest
    case value <> tail: Work{codec,value,path ++ "[" ++ U32.show(index) ++ "]"} <> array_work(codec,tail,path,U32.add(index,1),rest)
def struct_work(fields:List<&2,NamedCodec>,+values:List<&2,Field>,+path:String,rest:List<&2,Work>) -> List<&2,Work>:
  match fields:
    case []: rest
    case NamedCodec{+name,codec} <> tail: Work{codec,field(name,values),path ++ "." ++ name} <> struct_work(tail,values,path,rest)
def binary64_exponent(high:U32) -> U32:
  U32.mod(U32.div(high,1048576),2048)
def binary_integer_normal(result:Numeric) -> Bool:
  match result:
    case Finite{_,high,low,+exponent}: (U32.is_eq(high,0) && U32.is_eq(low,0)) || (U32.is_ge(exponent,1074) && U32.is_le(exponent,1126))
    case _: False{}
def binary_integer_checked(result:Numeric,small:Bool) -> Bool:
  small && binary_integer_normal(result)
def binary_integer(+high:U32,+low:U32) -> Bool:
  binary_integer_checked(binary_numeric(high,low),U32.is_lt(binary64_exponent(high),1076))
def expand(codec:Codec,+raw:Raw,+path:String,rest:List<&2,Work>) -> Step:
  match codec raw:
    case Integer{} Number{_}: Continue{rest}
    case Integer{} SignedInteger{_,magnitude}: choose_checked(Nat.is_lt(Nat.div(magnitude,Nat.mul(65536n,65536n)),2097152n),path,"integer",raw,rest)
    case Integer{} Float{+value}: choose_checked(F32.is_eq(F32.floor(value),value) && F32.is_lt(F32.abs(value),9007199254740992.0),path,"integer",raw,rest)
    case Integer{} Binary64{high,low}: choose_checked(binary_integer(high,low),path,"integer",raw,rest)
    case FiniteNumber{} Number{_}: Continue{rest}
    case FiniteNumber{} SignedInteger{_,_}: Continue{rest}
    case FiniteNumber{} Float{value}: choose_checked(F32.is_le(F32.abs(value),3.4028234e38),path,"finite number",raw,rest)
    case FiniteNumber{} Binary64{high,_}: choose_checked(U32.is_lt(binary64_exponent(high),2047),path,"finite number",raw,rest)
    case StringValue{} Text{_}: Continue{rest}
    case StringValue{} Utf16Text{units}: choose_checked(Utf16.valid(units),path,"string",raw,rest)
    case BoolValue{} Boolean{_}: Continue{rest}
    case Literal{value} _: choose_checked(equal(value,raw),path,"literal",raw,rest)
    case LiteralValues{values} _: choose_checked(alternatives(values,raw),path,"literal",raw,rest)
    case LiteralRendered{values,expected} _: choose_checked(alternatives(values,raw),path,expected,raw,rest)
    case Nullable{_} Null{}: Continue{rest}
    case Nullable{inner} _: Continue{Work{inner,raw,path} <> rest}
    case ArrayValue{inner} Array{items}: Continue{array_work(inner,items,path,0,rest)}
    case Struct{fields} Object{values}: Continue{struct_work(fields,values,path,rest)}
    case HandleValue{ns} Handle{actual,id}: choose_checked(U32.is_eq(ns,actual) && U32.is_gt(id,0),path,"same-world handle",raw,rest)
    case Integer{} _: Stop{Invalid{path,"integer",raw}}
    case FiniteNumber{} _: Stop{Invalid{path,"finite number",raw}}
    case StringValue{} _: Stop{Invalid{path,"string",raw}}
    case BoolValue{} _: Stop{Invalid{path,"boolean",raw}}
    case ArrayValue{_} _: Stop{Invalid{path,"array",raw}}
    case Struct{_} _: Stop{Invalid{path,"object",raw}}
    case HandleValue{_} _: Stop{Invalid{path,"same-world handle",raw}}
def validate(fuel:Nat,step:Step,+original:Raw) -> Checked:
  match fuel step:
    case _ Stop{error}: Rejected{error}
    case _ Continue{[]}: Accepted{original}
    case 0n Continue{Work{_,_,path} <> _}: Rejected{FuelExhausted{path}}
    case 1n+more Continue{Work{codec,raw,path} <> rest}: validate(more,expand(codec,raw,path,rest),original)
def owned(~Owner:Type,fuel:Nat,codec:Codec,input:Owned<Owner>) -> Receipt<Owner>:
  match input:
    case Owned{owner,+description}: Receipt{owner,validate(fuel,Continue{[Work{codec,description,"$"}]},description)}

def associated(~Owner:Type,fuel:Nat,codec:Codec,observed:Owner & Raw) -> Receipt<Owner>:
  match observed:
    case (owner,description): owned(~Owner,fuel,codec,Owned{owner,description})
# The closed schema projection must inspect the actual owner. It returns that
# owner rather than caller-supplied unrelated metadata. Its semantics are trusted.
def validate_owner(~Owner:Type,~project:Owner -> Owner & Raw,fuel:Nat,codec:Codec,owner:Owner) -> Receipt<Owner>:
  associated(~Owner,fuel,codec,project(owner))

def canonical_array_join(head:Raw,tail:Raw) -> Raw:
  match tail:
    case Array{values}: Array{head <> values}
    case other: other
def canonical_struct_join(name:String,head:Raw,tail:Raw) -> Raw:
  match tail:
    case Object{fields}: Object{Field{name,head} <> fields}
    case other: other
def canonical(fuel:Nat,codec:Codec,raw:Raw) -> Raw:
  match fuel codec raw:
    case 0n _ raw: raw
    case 1n+more Nullable{inner} Null{}: Null{}
    case 1n+more Nullable{inner} raw: canonical(more,inner,raw)
    case 1n+more ArrayValue{_} Array{[]}: Array{[]}
    case 1n++more ArrayValue{+inner} Array{head <> tail}: canonical_array_join(canonical(more,inner,head),canonical(more,ArrayValue{inner},Array{tail}))
    case 1n+more Struct{[]} Object{_}: Object{[]}
    case 1n++more Struct{NamedCodec{+name,codec} <> rest} Object{+values}: canonical_struct_join(name,canonical(more,codec,field(name,values)),canonical(more,Struct{rest},Object{values}))
    case _ _ raw: raw
def normalized(~Owner:Type,+fuel:Nat,+codec:Codec,result:Receipt<Owner>) -> Receipt<Owner>:
  match result:
    case Receipt{owner,Accepted{value}}: Receipt{owner,Accepted{canonical(fuel,codec,value)}}
    case Receipt{owner,Rejected{error}}: Receipt{owner,Rejected{error}}
def decode_owner(~Owner:Type,~project:Owner -> Owner & Raw,+fuel:Nat,+codec:Codec,owner:Owner) -> Receipt<Owner>:
  normalized(~Owner,fuel,codec,validate_owner(~Owner,~project,fuel,codec,owner))

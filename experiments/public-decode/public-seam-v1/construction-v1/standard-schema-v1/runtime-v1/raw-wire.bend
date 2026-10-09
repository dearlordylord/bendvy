import Base
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
# Explicit checked runtime token transport; no JSON module or JS callback injection.
type Read<V:Data> is Data:Read{value:V,rest:List<&2,String>} Refused{remaining:List<&2,String>}
type Numbers is Data:More{count:Nat,rest:List<&2,String>,values:List<&2,U32>} Complete{value:Read<List<&2,U32>>}
type Work is Data:Value{} ArrayNext{count:Nat,values:List<&2,D.Raw>} ObjectNext{count:Nat,fields:List<&2,D.Field>} FieldNext{name:String,count:Nat,fields:List<&2,D.Field>}
type State is Data:Running{work:List<&2,Work>,values:List<&2,D.Raw>,tokens:List<&2,String>} Finished{value:Read<D.Raw>}
def number_parsed(+rest:List<&2,String>,parsed:Maybe<&2,Nat>) -> Read<Nat>:
  match parsed:
    case None{}:Refused{rest}
    case Some{value}:Read{value,rest}



def number(value:List<&2,String>) -> Read<Nat>:
  match value:
    case []:Refused{[]}
    case head <> tail:number_parsed(tail,Nat.read(head))



def uint_checked(+value:Nat,+rest:List<&2,String>,okay:Bool) -> Read<U32>:
  match okay:
    case True{}:Read{U32.from_nat(value),rest}
    case False{}:Refused{rest}



def uint_result(value:Read<Nat>) -> Read<U32>:
  match value:
    case Refused{rest}:Refused{rest}
    case Read{+n,rest}:uint_checked(n,rest,Nat.is_le(n,4294967295n))



def uint(value:List<&2,String>) -> Read<U32>:uint_result(number(value))



def boolean_result(value:Read<U32>) -> Read<Bool>:
  match value:
    case Read{0,rest}:Read{False{},rest}
    case Read{1,rest}:Read{True{},rest}
    case Read{_,rest}:Refused{rest}
    case Refused{rest}:Refused{rest}



def boolean(value:List<&2,String>) -> Read<Bool>:boolean_result(uint(value))



def scalar(+n:U32) -> Bool:U32.is_le(n,1114111) && (U32.is_lt(n,55296) || U32.is_gt(n,57343))



def float_bits(value:U32) -> F32:
  match value:
    case U32{data}:F32{data}



def numbers_head(count:Nat,values:List<&2,U32>,value:Read<U32>) -> Numbers:
  match value:
    case Refused{rest}:Complete{Refused{rest}}
    case Read{code,rest}:More{count,rest,code <> values}

def numbers_step(value:Numbers) -> Numbers:
  match value:
    case Complete{value}:Complete{value}
    case More{0n,rest,values}:Complete{Read{List.reverse(&2,U32,values),rest}}
    case More{1n+tail,rest,values}:numbers_head(tail,values,uint(rest))

def numbers_loop(fuel:Nat,value:Numbers) -> Read<List<&2,U32>>:
  match fuel value:
    case _,Complete{result}:result
    case 0n,More{_,rest,_}:Refused{rest}
    case 1n+left,value:numbers_loop(left,numbers_step(value))

def units_count(value:Read<Nat>) -> Read<List<&2,U32>>:
  match value:
    case Refused{rest}:Refused{rest}
    case Read{+count,rest}:numbers_loop(1n+count,More{count,rest,[]})

def units(value:List<&2,String>) -> Read<List<&2,U32>>:units_count(number(value))

def scalar_list(value:List<&2,U32>) -> Bool:
  match value:
    case []:True{}
    case head <> tail:scalar(head) && scalar_list(tail)

def scalar_text(value:List<&2,U32>) -> String:
  match value:
    case []:SNil{}
    case head <> tail:SCon{Chr{head},scalar_text(tail)}

def text_checked(+codes:List<&2,U32>,rest:List<&2,String>,okay:Bool) -> Read<String>:
  match okay:
    case False{}:Refused{rest}
    case True{}:Read{scalar_text(codes),rest}

def text_done(value:Read<List<&2,U32>>) -> Read<String>:
  match value:
    case Refused{rest}:Refused{rest}
    case Read{+codes,rest}:text_checked(codes,rest,scalar_list(codes))

def text(value:List<&2,String>) -> Read<String>:text_done(units(value))

def number_0(value:Read<U32>) -> Read<D.Raw>:
  match value:
    case Refused{rest}:Refused{rest}
    case Read{value,rest}:Read{D.Number{value},rest}



def raw_number(value:List<&2,String>) -> Read<D.Raw>:number_0(uint(value))



def signed_1(+negative:Bool,value:Read<Nat>) -> Read<D.Raw>:
  match value:
    case Refused{rest}:Refused{rest}
    case Read{magnitude,rest}:Read{D.SignedInteger{negative,magnitude},rest}



def float_0(value:Read<U32>) -> Read<D.Raw>:
  match value:
    case Refused{rest}:Refused{rest}
    case Read{bits,rest}:Read{D.Float{float_bits(bits)},rest}



def raw_float(value:List<&2,String>) -> Read<D.Raw>:float_0(uint(value))



def binary64_1(+high:U32,value:Read<U32>) -> Read<D.Raw>:
  match value:
    case Refused{rest}:Refused{rest}
    case Read{low,rest}:Read{D.Binary64{high,low},rest}



def text_0(value:Read<String>) -> Read<D.Raw>:
  match value:
    case Refused{rest}:Refused{rest}
    case Read{value,rest}:Read{D.Text{value},rest}



def raw_text(value:List<&2,String>) -> Read<D.Raw>:text_0(text(value))



def utf16_0(value:Read<List<&2,U32>>) -> Read<D.Raw>:
  match value:
    case Refused{rest}:Refused{rest}
    case Read{units,rest}:Read{D.Utf16Text{units},rest}



def raw_utf16(value:List<&2,String>) -> Read<D.Raw>:utf16_0(units(value))



def bool_0(value:Read<Bool>) -> Read<D.Raw>:
  match value:
    case Refused{rest}:Refused{rest}
    case Read{value,rest}:Read{D.Boolean{value},rest}



def raw_bool(value:List<&2,String>) -> Read<D.Raw>:bool_0(boolean(value))



def handle_1(+namespace:U32,value:Read<U32>) -> Read<D.Raw>:
  match value:
    case Refused{rest}:Refused{rest}
    case Read{id,rest}:Read{D.Handle{namespace,id},rest}



def refused(tokens:List<&2,String>) -> State:Finished{Refused{tokens}}

def pushed(work:List<&2,Work>,values:List<&2,D.Raw>,result:Read<D.Raw>) -> State:
  match result:
    case Refused{rest}:refused(rest)
    case Read{raw,rest}:Running{work,raw <> values,rest}

def array_count(work:List<&2,Work>,values:List<&2,D.Raw>,result:Read<Nat>) -> State:
  match result:
    case Refused{rest}:refused(rest)
    case Read{0n,rest}:Running{work,D.Array{[]} <> values,rest}
    case Read{1n+tail,rest}:Running{Value{} <> ArrayNext{tail,[]} <> work,values,rest}

def field_name(count:Nat,fields:List<&2,D.Field>,work:List<&2,Work>,values:List<&2,D.Raw>,result:Read<String>) -> State:
  match result:
    case Refused{rest}:refused(rest)
    case Read{name,rest}:Running{Value{} <> FieldNext{name,count,fields} <> work,values,rest}

def object_count(work:List<&2,Work>,values:List<&2,D.Raw>,result:Read<Nat>) -> State:
  match result:
    case Refused{rest}:refused(rest)
    case Read{count,rest}:Running{ObjectNext{count,[]} <> work,values,rest}

def signed_0(value:Read<Bool>) -> Read<D.Raw>:
  match value:
    case Refused{rest}:Refused{rest}
    case Read{negative,rest}:signed_1(negative,number(rest))



def raw_signed(value:List<&2,String>) -> Read<D.Raw>:signed_0(boolean(value))



def binary64_0(value:Read<U32>) -> Read<D.Raw>:
  match value:
    case Refused{rest}:Refused{rest}
    case Read{high,rest}:binary64_1(high,uint(rest))



def raw_binary64(value:List<&2,String>) -> Read<D.Raw>:binary64_0(uint(value))



def handle_0(value:Read<U32>) -> Read<D.Raw>:
  match value:
    case Refused{rest}:Refused{rest}
    case Read{namespace,rest}:handle_1(namespace,uint(rest))



def raw_handle(value:List<&2,String>) -> Read<D.Raw>:handle_0(uint(value))




def tagged(name:String,work:List<&2,Work>,values:List<&2,D.Raw>,tokens:List<&2,String>) -> State:
  match name:
    case "missing":Running{work,D.Missing{} <> values,tokens}
    case "null":Running{work,D.Null{} <> values,tokens}
    case "number":pushed(work,values,raw_number(tokens))
    case "signed":pushed(work,values,raw_signed(tokens))
    case "float":pushed(work,values,raw_float(tokens))
    case "binary64":pushed(work,values,raw_binary64(tokens))
    case "text":pushed(work,values,raw_text(tokens))
    case "utf16":pushed(work,values,raw_utf16(tokens))
    case "bool":pushed(work,values,raw_bool(tokens))
    case "handle":pushed(work,values,raw_handle(tokens))
    case "array":array_count(work,values,number(tokens))
    case "object":object_count(work,values,number(tokens))
    case _:refused(tokens)

def step(value:State) -> State:
  match value:
    case Finished{value}:Finished{value}
    case Running{[],[value],tokens}:Finished{Read{value,tokens}}
    case Running{Value{} <> work,values,name <> tokens}:tagged(name,work,values,tokens)
    case Running{ArrayNext{0n,rev} <> work,head <> values,tokens}:Running{work,D.Array{List.reverse(&2,D.Raw,head <> rev)} <> values,tokens}
    case Running{ArrayNext{1n+tail,rev} <> work,head <> values,tokens}:Running{Value{} <> ArrayNext{tail,head <> rev} <> work,values,tokens}
    case Running{ObjectNext{0n,fields} <> work,values,tokens}:Running{work,D.Object{List.reverse(&2,D.Field,fields)} <> values,tokens}
    case Running{ObjectNext{1n+tail,fields} <> work,values,tokens}:field_name(tail,fields,work,values,text(tokens))
    case Running{FieldNext{name,count,fields} <> work,head <> values,tokens}:Running{ObjectNext{count,D.Field{name,head} <> fields} <> work,values,tokens}
    case Running{_,_,tokens}:refused(tokens)

def loop(fuel:Nat,value:State) -> Read<D.Raw>:
  match fuel value:
    case _,Finished{result}:result
    case 0n,Running{_,_,tokens}:Refused{tokens}
    case 1n+left,value:loop(left,step(value))

def read(fuel:Nat,value:List<&2,String>) -> Read<D.Raw>:loop(fuel,Running{[Value{}],[],value})

import Base

def literal_u32(value:U32) -> String:
  match value:
    case 0:"zero"
    case 7:"seven"
    case 4294967295:"max"
    case _:"other"
def wildcard_u32(value:U32) -> U32:
  match value:
    case 7:77
    case other:other
def remaining_u32(value:U32) -> Nat:
  match value:
    case U32{word}:Word.to_nat(32n,word)
def head_tail_u32(value:U32) -> String:
  match value:
    case U32{WCon{head,tail}}:Bool.show(head) ++ ":" ++ Nat.show(Word.to_nat(31n,tail))
def remaining_tail_u32(value:U32) -> Nat:
  match value:
    case U32{WCon{False{},tail}}:Word.to_nat(31n,tail)
    case U32{word}:Word.to_nat(32n,word)
def literal_f32(value:F32) -> String:
  match value:
    case 0.0:"zero"
    case 1.0:"one"
    case _:"other"
def wildcard_f32(value:F32) -> F32:
  match value:
    case 1.0:2.0
    case other:other
def remaining_f32(value:F32) -> Nat:
  match value:
    case F32{word}:Word.to_nat(32n,word)
def head_tail_f32(value:F32) -> String:
  match value:
    case F32{WCon{head,tail}}:Bool.show(head) ++ ":" ++ Nat.show(Word.to_nat(31n,tail))
def remaining_tail_f32(value:F32) -> Nat:
  match value:
    case F32{WCon{False{},tail}}:Word.to_nat(31n,tail)
    case F32{word}:Word.to_nat(32n,word)
def u32_record(+value:U32) -> String:
  U32.show(value) ++ ":" ++ literal_u32(value) ++ ":" ++ U32.show(wildcard_u32(value)) ++ ":" ++ Nat.show(remaining_u32(value)) ++ ":" ++ head_tail_u32(value) ++ ":" ++ Nat.show(remaining_tail_u32(value))
def f32_record(+value:F32) -> String:
  literal_f32(value) ++ ":" ++ Nat.show(F32.to_nat(wildcard_f32(value))) ++ ":" ++ Nat.show(remaining_f32(value)) ++ ":" ++ head_tail_f32(value) ++ ":" ++ Nat.show(remaining_tail_f32(value))
def main() -> String:
  "U32=" ++ List.show(&2,String,x=>x,[u32_record(0),u32_record(7),u32_record(8),u32_record(2147483648),u32_record(4294967295)]) ++ "|F32=" ++ List.show(&2,String,x=>x,[f32_record(0.0),f32_record(1.0),f32_record(2.0),f32_record(1.0000001192092896)])

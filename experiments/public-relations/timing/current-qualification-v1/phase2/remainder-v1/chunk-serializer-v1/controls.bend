import Base
import ../../../trace-value.bend as J
import serialize.bend as C

type Controls is Data:
  Controls{empty:String,zero_visit:String,one_visit:String,two_visit:String,compound:String}
def rendered(result:C.EncodeResult) -> String:
  match result:
    case C.EncodeComplete{text}:text
    case C.EncodeIncomplete{}:"<INCOMPLETE>"
def main() -> Controls:
  Controls{rendered(C.walk(0n,[],[])),rendered(C.walk(0n,[J.Visit{J.Null{}}],[])),rendered(C.walk(1n,[J.Visit{J.Null{}}],[])),rendered(C.walk(2n,[J.Visit{J.Null{}}],[])),rendered(C.encode(0,J.Object{[J.Field{"u32",J.Number{4294967295}},J.Field{"ascii",J.Text{"ABC xyz"}},J.Field{"items",J.Items{[J.Null{},J.Truth{True{}},J.Number{0}]}}]}))}

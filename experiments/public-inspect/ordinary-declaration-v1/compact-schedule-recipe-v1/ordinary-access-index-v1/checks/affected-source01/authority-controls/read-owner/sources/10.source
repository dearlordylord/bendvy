import Base
# JS strings are UTF-16 code-unit sequences, including lone surrogates.
# Bend String is Unicode-scalar text; no invalid Chr is constructed here.
def valid(units:List<&2,U32>) -> Bool:
  match units:
    case []: True{}
    case unit <> tail: U32.is_le(unit,65535) && valid(tail)
def empty(units:List<&2,U32>) -> Bool:
  match units:
    case []: True{}
    case _ <> _: False{}
def compared(+head:U32,other:List<&2,U32>,next:List<&2,U32> -> Bool) -> Bool:
  match other:
    case []: False{}
    case value <> tail: U32.is_eq(head,value) && next(tail)
def equal(left:List<&2,U32>,right:List<&2,U32>) -> Bool:
  match left:
    case []: empty(right)
    case head <> tail: compared(head,right,rest => equal(tail,rest))
def scalar(+code:U32,rest:List<&2,U32>,bmp:Bool) -> List<&2,U32>:
  match bmp:
    case True{}: code <> rest
    case False{}: U32.add(55296,U32.div(U32.sub(code,65536),1024)) <> U32.add(56320,U32.mod(U32.sub(code,65536),1024)) <> rest
def text(value:String) -> List<&2,U32>:
  match value:
    case SNil{}: []
    case SCon{Chr{+code},tail}: scalar(code,text(tail),U32.is_lt(code,65536))
def checked(+left:List<&2,U32>,+right:List<&2,U32>) -> Bool:
  valid(left) && valid(right) && equal(left,right)
def show(units:List<&2,U32>) -> String:
  List.show(&2,U32,U32.show,units)

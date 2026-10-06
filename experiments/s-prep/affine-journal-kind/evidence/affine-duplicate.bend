import Base
def build(count:Nat,+value:U32,values:List<&1,U32>) -> List<&1,U32>:
  match count:
    case 0n: values
    case 1n+rest: build(rest,U32.add(value,1),value <> values)
def sum(values:List<&1,U32>) -> U32:
  match values:
    case Nil{}: 0
    case Con{head,tail}: U32.add(head,sum(tail))
def main() -> IO(Unit):
  IO.print(U32.show(sum(build(8n,1,[]))))
def duplicate(values:List<U32>) -> List<U32> & List<U32>:
  (values,values)

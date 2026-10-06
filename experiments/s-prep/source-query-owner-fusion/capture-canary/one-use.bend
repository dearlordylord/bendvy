import Base

def invoke(~P:Type,~done:Unit -> P,arg:Unit) -> P:
  done(arg)
def captured(owner:Array<U32>) -> Array<U32>:
  invoke(~Array<U32>,~(_ => owner),Unit{})
def output(result:Array<U32> & U32) -> IO(Unit):
  match result:
    case (_,value): IO.print(U32.show(value))
def main() -> IO(Unit):
  output(Array.get(U32,Array.set(U32,captured([5:U32^2n]),0,9),0))

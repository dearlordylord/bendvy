import Base

def keep(~P:Type,owner:P,arg:Unit) -> P:
  owner
def invoke(~P:Type,~done:P -> Unit -> P,owner:P,arg:Unit) -> P:
  done(owner,arg)
def captured(owner:Array<U32>) -> Array<U32>:
  invoke(~Array<U32>,~keep(~Array<U32>),owner,Unit{})
def output(result:Array<U32> & U32) -> IO(Unit):
  match result:
    case (_,value): IO.print(U32.show(value))
def main() -> IO(Unit):
  output(Array.get(U32,Array.set(U32,captured([5:U32^2n]),0,9),0))

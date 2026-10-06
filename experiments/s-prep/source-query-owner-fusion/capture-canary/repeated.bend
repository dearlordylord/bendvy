import Base

def invoke(~P:Type,~done:Unit -> P,arg:Unit) -> P & P:
  (done(arg),done(Unit{}))
def captured(owner:Array<U32>) -> Array<U32> & Array<U32>:
  invoke(~Array<U32>,~(_ => owner),Unit{})
def output_right(left:U32,result:Array<U32> & U32) -> IO(Unit):
  match result:
    case (_,right): IO.print(U32.show(left) ++ ":" ++ U32.show(right))
def output_left(right:Array<U32>,result:Array<U32> & U32) -> IO(Unit):
  match result:
    case (_,left): output_right(left,Array.get(U32,right,0))
def mutate(result:Array<U32> & Array<U32>) -> IO(Unit):
  match result:
    case (left,right): output_left(right,Array.get(U32,Array.set(U32,left,0,9),0))
def main() -> IO(Unit):
  mutate(captured([5:U32^2n]))

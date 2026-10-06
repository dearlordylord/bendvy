import Base

def advance(~resume:Nat -> Array<U32> -> Array<U32>,rest:Nat,owner:Array<U32>) -> Array<U32>:
  resume(rest,owner)
def loop(remaining:Nat,owner:Array<U32>) -> Array<U32>:
  match remaining:
    case 0n: owner
    case 1n++rest: advance(~loop,rest,owner)
def printed(result:Array<U32> & U32) -> IO(Unit):
  match result:
    case (owner,value): IO.print(U32.show(value))
def main() -> IO(Unit):
  printed(Array.get(U32,loop(3n,[9 : U32^0n]),0))

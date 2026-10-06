import Base

def show_old(result:Array<U32> & U32) -> IO(Unit):
  match result:
    case (array,old): IO.print("OLD=" ++ U32.show(old))
def show_size(result:Array<U32> & U32) -> IO(Unit):
  match result:
    case (array,size):
      do IO<Unit>:
        IO.print("SIZE=" ++ U32.show(size))
        show_old(Array.swap(U32,array,2,9))
def main() -> IO(Unit):
  do IO<Unit>:
    IO.print("BEFORE")
    show_size(Array.size(U32,ANode{ANode{ALeaf{1},ALeaf{2}},ANode{ALeaf{3},ALeaf{4}}}))

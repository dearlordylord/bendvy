import Base
type Box is Type:
  Box{value:U32}
def read(owner:Box) -> Box & U32:
  match owner:
    case Box{+value}: (Box{value},value)
def write(owner:Box,value:U32) -> Box:
  match owner:
    case Box{_}: Box{value}
def callback_done(-Owner:Type,set:Owner -> U32 -> Owner,pair:Owner & U32) -> Owner & U32:
  match pair:
    case (owner,+value): (set(owner,U32.add(value,1)),value)
def callback(-Owner:Type,get:Owner -> Owner & U32,set:Owner -> U32 -> Owner,owner:Owner) -> Owner & U32:
  callback_done(Owner,set,get(owner))
def invoke(~client:@-Owner:Type -> (Owner -> Owner & U32) -> (Owner -> U32 -> Owner) -> Owner -> Owner & U32,~get:Box -> Box & U32,~set:Box -> U32 -> Box,owner:Box) -> Box & U32:
  client(Box,get,set,owner)
def result(pair:Box & U32) -> IO(Unit):
  match pair:
    case (Box{value},old): IO.print(U32.show(value) ++ ":" ++ U32.show(old))
def main() -> IO(Unit):
  result(invoke(~callback,~read,~write,Box{7}))

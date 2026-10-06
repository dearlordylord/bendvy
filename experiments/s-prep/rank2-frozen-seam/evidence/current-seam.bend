import Base
def getter(owner:U32) -> U32:
  U32.add(owner,1)
def body(~Owner:Type,~get:Owner -> U32,owner:Owner) -> U32:
  get(owner)
def invoke(~client:@-Owner:Type -> @-get:(Owner -> U32) -> Owner -> U32,owner:U32) -> U32:
  client(U32,getter,owner)
def main() -> IO(Unit):
  IO.print(U32.show(invoke(~body,41)))

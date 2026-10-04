import Base
import ./lifecycle.bend as L
import ../rc1-query/schemas.bend as S

def consume(h: L.Handle<S.MotionToken>) -> U32:
  match h:
    case L.Handle{_, slot}: slot
def main() -> U32:
  consume({L.Handle{0, 0} : L.Handle<S.MotionToken>})

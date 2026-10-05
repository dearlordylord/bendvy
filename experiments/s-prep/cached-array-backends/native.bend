import Base
import ./native-helpers.bend as C
import ./fixture.bend as F
def main() -> IO(Unit):
  F.run(C.swap(~Maybe<F.Main>),C.get(~U32),C.set(~U32))

import Base
import ./fixture.bend as F
def main() -> IO(Unit):
  F.loop(U32.to_nat(2430),0)

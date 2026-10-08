import Base
import ./fixture.bend as F
import ./gate.bend as G
def legal(~S:Data,owner:F.Payload) -> F.Payload & G.Field:
  F.ordinary(~S,owner)
def main() -> U32:
  0

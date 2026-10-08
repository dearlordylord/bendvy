import Base
import ./fixture.bend as F
import ./gate.bend as G
def illegal(~S:Data,owner:F.Payload) -> F.Payload & G.Field:
  G.export_owner(~S,~F.Payload,~F.declaration(~S),F.declaration(~S),owner)
def main() -> U32:
  0

import Base
import ./fixture.bend as F
import ./gate.bend as G
def legal(~S:Data,owner:F.Payload) -> F.Payload & G.Field:
  G.export_owner(~S,~F.Payload,~F.declaration(~S),G.transient(~S,~F.Payload,~F.declaration(~S)),owner)
def main() -> U32:
  0

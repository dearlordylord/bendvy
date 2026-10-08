import Base
import ./fixture.bend as F
import ./gate.bend as G
def illegal(owner:F.Payload) -> F.Payload & G.Field:
  G.export_owner(~F.Workshop,~F.Payload,~F.declaration(~F.Workshop),G.transient(~F.Garden,~F.Payload,~F.declaration(~F.Garden)),owner)
def main() -> U32:
  0

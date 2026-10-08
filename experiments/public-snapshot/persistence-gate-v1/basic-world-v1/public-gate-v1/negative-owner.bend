import Base
import ../fixture.bend as F
import ./save.bend as Save
import ./gate.bend as Gate
def illegal(owner:F.Payload) -> (F.Payload & Gate.Field) & (F.Payload & Gate.Field):
  (Save.saved(~F.Workshop,owner),Save.saved(~F.Workshop,owner))
def main() -> U32:
  0

import Base
import ./fixture.bend as F
import ./gate.bend as G
import ./reference-source/typed.bend as D
def legal(~S:Data,owner:F.Payload) -> F.Payload & G.Validation:
  G.validate_projection(~S,~F.Payload,~F.declaration(~S),128n,G.persisted(~S,~F.Payload,~F.declaration(~S),D.Integer{},F.project),owner)
def main() -> U32:
  0

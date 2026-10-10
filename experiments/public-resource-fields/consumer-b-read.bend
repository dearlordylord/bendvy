import Base
import ./binding.bend as B
import ./schema-b.bend as Other
import ./consumer-engine.bend as Engine
def main() -> String:
  Engine.scenario(~Other.Other,~Other.Resources(),~Other.ReadOps,~Other.read_declaration(),~Other.read_body,~Other.resource_view,B.validate(~Other.Other,~Other.Resources(),~Other.Index(),Other.layout()),Other.initial())

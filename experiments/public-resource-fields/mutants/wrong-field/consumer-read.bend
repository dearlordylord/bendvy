import Base
import ./binding.bend as B
import ./schema-a.bend as A
import ./consumer-engine.bend as Engine
def main() -> String:
  Engine.scenario(~A.A,~A.Resources(),~A.ReadOps,~A.read_declaration(),~A.read_body,~A.resource_view,B.validate(~A.A,~A.Resources(),~A.Index(),A.layout()),A.initial())

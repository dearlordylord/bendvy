import Base
import ./binding.bend as B
import ./schema-a.bend as A
import ./schema-b.bend as Other
import ./consumer-engine.bend as Engine
def main() -> String:
  "A|" ++ Engine.scenario(~A.A,~A.Resources(),~A.Ops,~A.declaration(),~A.body,~A.resource_view,B.validate(~A.A,~A.Resources(),~A.Index(),A.layout()),A.initial()) ++ "\nB|" ++ Engine.scenario(~Other.Other,~Other.Resources(),~Other.Ops,~Other.declaration(),~Other.body,~Other.resource_view,B.validate(~Other.Other,~Other.Resources(),~Other.Index(),Other.layout()),Other.initial())

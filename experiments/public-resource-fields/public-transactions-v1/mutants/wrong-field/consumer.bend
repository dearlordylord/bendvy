import Base
import ../../../../../src/ecs/resource-field-binding.bend as B
import schema-a.bend as A
import ../../normal/consumer-engine.bend as Engine
def main() -> String:
  Engine.scenario(~A.A,~A.Resources(),~A.Ops,~A.declaration(),~A.body,~A.resource_view,B.validate(~A.A,~A.Resources(),~A.Index(),A.layout()),A.initial())

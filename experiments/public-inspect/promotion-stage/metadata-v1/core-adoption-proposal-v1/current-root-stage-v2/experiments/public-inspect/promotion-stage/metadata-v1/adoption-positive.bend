import Base
import ../../../../src/ecs/check.bend as Check
import ../../../../src/ecs/inspector-query.bend as Query
import adoption-positive-workshop.bend as W
import adoption-positive-garden.bend as G
def joined(left:Unit,right:Unit) -> Unit:
  Unit{}
def main() -> Unit:
  joined(W.main(),G.main())

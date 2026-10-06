import Base
import positive.bend as P
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/world.bend as W

def run() -> Q.Executed<W.World<P.Schema,Unit,Array<U32>,U32>,Q.Error<Bool>,P.Observation>:
  Q.each(~P.Schema,~Unit,~Array<U32>,~U32,~P.Ops,~Bool,~Bool,~P.Observation,~P.plan(),~P.body,True{},P.initial())

def main() -> String:
  P.report(run())

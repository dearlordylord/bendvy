import Base
import ../../src/ecs/chunk-column.bend as C
import ../../src/ecs/chunk-query.bend as Q
import ../../src/ecs/change-tick.bend as Tick
import ./query.bend as F
def main() -> Q.Run<F.First,F.Input,F.Output,String>:
  Q.parallel(~F.First,~F.Input,~F.Output,~U32,~String,~F.project,~F.body,C.empty(~F.First,~F.Input),C.empty(~F.Second,~F.Output),0,Tick.zero())

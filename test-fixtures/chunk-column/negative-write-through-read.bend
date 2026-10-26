import Base
import ../../src/ecs/chunk-column.bend as C
import ../../src/ecs/chunk-query.bend as Q
import ../../src/ecs/change-tick.bend as Tick
import ./query.bend as F
def wrong_body(index:U32,read:F.Input,write:F.Output) -> F.Output & Maybe<&2,String>:
  (write,None{})
def main() -> Q.Run<F.First,F.Input,F.Output,String>:
  Q.parallel(~F.First,~F.Input,~F.Output,~U32,~String,~F.project,~wrong_body,C.empty(~F.First,~F.Input),C.empty(~F.First,~F.Output),0,Tick.zero())

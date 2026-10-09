import Base
import ../../core-consumer-v4/consumer.bend as R
import ../../owned-retry-consumer.bend as Retry
import ../../../../../src/ecs/capabilities.bend as Cap
import ../../../../../src/ecs/world.bend as W
def body(~H:Type,~cap:Cap.OwnedRequest<H,R.Input(),R.Output()>,input:R.Input(),target:W.Handle<R.Schema>,ctx:H) -> H & H:
  (ctx,ctx)

import Base
import ../../core-consumer-v4/consumer.bend as R
import ../../owned-retry-consumer.bend as Retry
import ../../../../../src/ecs/capabilities.bend as Cap
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/bundle-insert-adapter.bend as AD
type Other is Data:Other{}
def body(~H:Type,~cap:Cap.OwnedRequest<H,R.Input(),R.Output()>,input:R.Input(),target:W.Handle<Other>,ctx:H) -> H & (Maybe<&2,AD.Refusal<String>> & R.Output()):
  Retry.body(~R.Schema,~R.Raw(),~String,~H,~cap,input,target,ctx)

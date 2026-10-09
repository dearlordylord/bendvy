import ../../../../../src/ecs/bundle-insert-adapter.bend as AD
import Base
import ../../core-consumer-v4/consumer.bend as R
import ../../owned-retry-consumer.bend as Retry
import ../../../../../src/ecs/capabilities.bend as Cap
import ../../../../../src/ecs/world.bend as W
def body(~H:Type,~cap:Cap.ValueRead<H,U32>,input:R.Input(),target:W.Handle<R.Schema>,ctx:H) -> H & (Maybe<&2,AD.Refusal<String>> & R.Output()):
  Retry.body(~R.Schema,~R.Raw(),~String,~H,~cap,input,target,ctx)

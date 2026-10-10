import Base
import consumer.bend as Consumer
type Schema is Data:
  Schema{}
def main() -> List<&2,String>:[Consumer.scenario(~Schema,0n,True{}),Consumer.scenario(~Schema,2n,True{}),Consumer.scenario(~Schema,0n,False{}),Consumer.scenario(~Schema,2n,False{})]

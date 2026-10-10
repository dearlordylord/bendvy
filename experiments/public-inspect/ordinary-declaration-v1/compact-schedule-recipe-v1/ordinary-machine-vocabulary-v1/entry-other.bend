import Base
import consumer-public.bend as Consumer
type OtherSchema is Data:
  OtherSchema{}
def main() -> List<&2,String>:[Consumer.scenario(~OtherSchema,0n,True{}),Consumer.scenario(~OtherSchema,2n,True{}),Consumer.scenario(~OtherSchema,0n,False{}),Consumer.scenario(~OtherSchema,2n,False{})]

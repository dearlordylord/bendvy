import Base
import ../payloads.bend as Payload
def duplicate(index:U32,read:U32,+write:Payload.Output) -> Payload.Output & Payload.Output:
  (write,write)

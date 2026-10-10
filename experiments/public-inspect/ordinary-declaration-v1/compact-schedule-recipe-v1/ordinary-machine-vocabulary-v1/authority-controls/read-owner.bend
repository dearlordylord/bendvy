import Base
import ../consumer-public.bend as Consumer
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def observed(~S:Data,~Owner:Type,result:Owner & U32) -> Consumer.Application(~S) & String:
  match result:
    case (owner,_):Consumer.snapshot(~S,True{},owner)
def invalid(~S:Data,~Owner:Type,grant:Cap.ValueRead<Owner,U32>,owner:Owner) -> Consumer.Application(~S) & String:observed(~S,~Owner,Cap.value_read_field(~Owner,~U32,grant)(owner))
def main() -> Unit:Unit{}

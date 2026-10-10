import Base
import ../consumer-public.bend as Consumer
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
type Schema is Data:Schema{}
def observed(~Owner:Type,result:Owner & U32) -> Consumer.Application(~Schema) & String:
  match result:
    case (owner,_):Consumer.snapshot(~Schema,True{},owner)
def read(~Owner:Type,grant:Cap.ValueRead<Owner,U32>,owner:Owner) -> Consumer.Application(~Schema) & String:
  observed(~Owner,Cap.value_read_field(~Owner,~U32,grant)(owner))
def main() -> Unit:Unit{}

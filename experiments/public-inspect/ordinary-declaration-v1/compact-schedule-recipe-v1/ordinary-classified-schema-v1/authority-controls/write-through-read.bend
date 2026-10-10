import Base
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def write(~Owner:Type,~grant:Cap.ValueRead<Owner,U32>,owner:Owner,value:Array<U32>) -> Owner:
  Cap.value_set(~Owner,~Array<U32>,~U32,grant,owner,value)
def main() -> Unit:Unit{}

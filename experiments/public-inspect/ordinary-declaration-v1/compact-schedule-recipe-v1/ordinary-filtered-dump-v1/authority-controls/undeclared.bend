import Base
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
def read(~Owner:Type,~grant:Unit,owner:Owner) -> Owner & U32:
  Cap.value_read(~Owner,~U32,grant,owner)
def main() -> Unit:Unit{}

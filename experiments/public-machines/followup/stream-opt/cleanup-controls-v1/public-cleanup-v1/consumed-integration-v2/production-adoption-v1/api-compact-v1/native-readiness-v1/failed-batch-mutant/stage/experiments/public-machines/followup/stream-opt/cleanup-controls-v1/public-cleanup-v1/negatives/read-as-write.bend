import Base
import ../../../../../../../src/ecs/capabilities.bend as Cap

def denied(~F: Type,~read: Cap.ValueRead<F,U32>,frame: F) -> F:
  Cap.value_write(~F,~U32,~U32,~read,frame,1)

def main() -> Unit:
  Unit{}

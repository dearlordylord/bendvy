import Base
import systems.bend as Systems
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
# Read-only grants cannot enter the actual public callback write adapter.
def denied(-F:Type,read:Cap.ValueRead<F,U32>,owner:F) -> F:
  Systems.gameplay_write(F,read,owner,1)

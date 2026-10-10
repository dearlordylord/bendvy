import Base
import types.bend as T
import systems.bend as Systems
# Universally abstract gameplay owner is not trusted provisioning World.
def denied(-F:Type,owner:F) -> F:
  Systems.restore_resource(~T.SchemaA,owner,0)

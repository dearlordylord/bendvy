import Base
import systems.bend as Systems
# Identical abstract gameplay boundary with the declared typed grants.
def accepted(-F:Type,caps:Systems.Work<F>,owner:F) -> F:
  Systems.gameplay_body(F,caps,owner,1)

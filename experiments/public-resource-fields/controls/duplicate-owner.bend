import Base
import ../provider.bend as P
import ../operations.bend as O
import ../schema-a.bend as A
import ../schema-b.bend as Other
def attempt(~H:Type,owner:H) -> H & H:
  (owner,owner)

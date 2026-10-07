import Base
import metadata.bend as M
import ../../../src/ecs/lifecycle.bend as L
# Tick arrays remain one real owner, even though scalar values are Data.
def bad(metadata:M.Metadata) -> M.Metadata & M.Metadata:
  (M.set(metadata,1,L.Stamp{5,9}),M.set(metadata,2,L.Stamp{13,17}))

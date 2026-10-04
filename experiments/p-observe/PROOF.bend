import Base
import ./LAWS.bend as L
import ../p-observe-lookup/LAWS.bend as K
import ../p-observe-lookup/PROOF.bend as P

# The remaining six approved endpoints stay open until actual proofs land.
def L.lookup_full_exact(world,handle,selection):
  K.lookup_full_exact(world,handle,selection)

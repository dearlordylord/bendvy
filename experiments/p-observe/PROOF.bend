import Base
import ./LAWS.bend as L
import ../p-observe-lookup/LAWS.bend as K
import ../p-observe-lookup/PROOF.bend as P
import ../p-observe-queries/LAWS.bend as Q
import ../p-observe-queries/PROOF.bend as QueryProof

# Flush and both schedules remain open until actual proofs land.
def L.lookup_full_exact(world,handle,selection):
  K.lookup_full_exact(world,handle,selection)

def L.query_any_complete_ordered(limit,world):
  Q.query_any_complete_ordered(limit,world)

def L.query_present_complete_ordered(limit,world):
  Q.query_present_complete_ordered(limit,world)

def L.query_absent_complete_ordered(limit,world):
  Q.query_absent_complete_ordered(limit,world)

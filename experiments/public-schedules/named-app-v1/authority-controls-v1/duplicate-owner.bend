import Base
import ./common.bend as C
# A registered owner retains actual affine Local and cannot be duplicated.
def wrong(owner:C.Owner(~C.Workshop)) -> C.Owner(~C.Workshop) & C.Owner(~C.Workshop):
  (owner,owner)

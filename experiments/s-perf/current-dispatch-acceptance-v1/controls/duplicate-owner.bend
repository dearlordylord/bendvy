import Base
import ../../../public-captures/ordinary-owner-v1/payload.bend as P
def refused(owner:P.Pack) -> P.Pack & P.Pack:(owner,owner)

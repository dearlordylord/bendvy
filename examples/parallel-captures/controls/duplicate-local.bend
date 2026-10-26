import Base
import ../bodies.bend as Body

def duplicate(owner:Body.RightLocal()) -> Body.RightLocal() & Body.RightLocal():(owner,owner)

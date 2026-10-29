import Base
import ../bodies.bend as Body

def forbidden(local:Body.Local()) -> Body.Local() & Body.Local():(local,local)

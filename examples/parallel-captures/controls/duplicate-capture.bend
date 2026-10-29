import Base
import ../contexts.bend as Context

def duplicate(owner:Context.Count()) -> Context.Count() & Context.Count():
  (owner,owner)

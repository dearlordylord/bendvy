import Base

def escape(~H:Type,owner:H) -> H & H:
  (owner,owner)

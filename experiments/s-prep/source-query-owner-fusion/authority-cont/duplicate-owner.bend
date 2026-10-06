import Base
import ./query.bend as Q

def bad(~P:Type,p:P) -> P & P:
  (p,p)

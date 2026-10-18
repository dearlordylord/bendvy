import Base

# Arbitrarily nested heterogeneous actual Type owners; no fixed family arity.
type Pack<Head:Type,Tail:Type> is Type:
  Pack{head:Head,tail:Tail}

import Base
# Trusted experimental singleton carrier; recursive field forces copied C BOX.
# All construction below uses None. A nonempty witness contains only Unit,
# never another arbitrary payload owner; no public ownership/disposal contract.
type Owner<A:Type> is Type:
  Owner{value:A,link:Maybe<&1,Owner<Unit>>}
def hold(~A:Type,value:A) -> Owner<A>:
  Owner{value,None{}}

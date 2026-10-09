import Base
# Trusted experimental singleton carrier; recursive field forces copied C BOX.
# All construction below uses None; no user ownership/disposal contract.
type Owner<A:Type> is Type:
  Owner{value:A,link:Maybe<&1,Owner<A>>}
def hold(~A:Type,value:A) -> Owner<A>:
  Owner{value,None{}}

import Base
type Owner<A:Type> is Type:
  Owner{value:A,link:Maybe<&1,Owner<Unit>>}
def main() -> Owner<U32>:
  Owner{1,None{}}

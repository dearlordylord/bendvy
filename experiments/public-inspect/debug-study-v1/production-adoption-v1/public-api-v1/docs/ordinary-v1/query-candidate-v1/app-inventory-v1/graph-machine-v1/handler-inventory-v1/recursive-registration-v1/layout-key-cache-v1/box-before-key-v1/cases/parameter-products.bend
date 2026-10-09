import Base
type Holder<A:Type> is Type:
  Holder{value:A}
def main() -> Holder<U32> & Holder<Array<U32>>:
  (Holder{7},Holder{ALeaf{1}})

import Base
import ./consumer.bend as C
type Alpha is Data:Alpha{}
type Beta is Data:Beta{}
def main() -> List<&2,String>:[C.scenario(~Alpha,2n,True{}),C.scenario(~Beta,2n,True{})]

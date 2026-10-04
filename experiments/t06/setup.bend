import Base
import ./core.bend as A

def committed(result: A.Store & A.Outcome) -> A.Store:
  match result:
    case (s, _): s
# Exact core operations of Good; execute commit on the owned arrays, not a seed.
def good() -> A.Store:
  committed(A.finish((A.command(A.emit(A.set(A.begin(A.initial()), 5, 7, 13), 1), A.Remove{0}), A.Success{})))

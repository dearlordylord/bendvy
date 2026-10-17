import Base
import ../../graph-runtime-v1/fixture.bend as F
def wrong(~S:Data,owner:F.Owned(~S)) -> F.Owned(~S) & F.Owned(~S):(owner,owner)

import Base
import ../basic-world-statefree-v1/schema.bend as F
def wrong(~S:Data,owner:F.Owned(~S)) -> F.Owned(~S) & F.Owned(~S):(owner,owner)

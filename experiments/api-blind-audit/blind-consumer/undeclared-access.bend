import Base

type PositionToken is Data:
  PositionToken{}
type HealthToken is Data:
  HealthToken{}
def read(-P: Type,get: P -> PositionToken -> P & U32,owner: P) -> P & U32:
  get(owner,HealthToken{})

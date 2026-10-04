import Base
import ./api.bend as A
import ./system.bend as S

def bad() -> IO(Maybe<&1, A.Cell> & (Maybe<&1, A.Service> & A.Outcome)):
  A.provision(~S.schedule, Some{A.Cell{42}}, Some{A.Service{}})

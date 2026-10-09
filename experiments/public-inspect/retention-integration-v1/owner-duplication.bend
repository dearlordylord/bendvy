import Base
import main.bend as F
def duplicate(result:F.Host & F.Completion) -> F.Host & F.Host:
  match result:
    case (host,_):(host,host)
def rejected(host:F.Host) -> F.Host & F.Host:
  duplicate(F.inspect(host,False{}))

import Base
import ../../../core-v1/src/ecs/check.bend as K

type Observation is Data:
  Returned{value:Bool}
  Missing{resources:List<&2,String>}

def from_result(value:Result<&2,&2,K.Error,Bool>) -> Observation:
  match value:
    case Done{value}:Returned{value}
    case Fail{K.MissingRuntimeRequirements{resources}}:Missing{resources}

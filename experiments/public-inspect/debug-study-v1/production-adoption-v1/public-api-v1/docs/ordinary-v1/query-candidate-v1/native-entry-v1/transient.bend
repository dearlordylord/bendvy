import Base
import ../scenario-schema.bend as S
import ../scenario-dto.bend as DTO
import ../scenario-driver.bend as Driver

# Compilation partition: unchanged complete category execution and owner teardown.
type Output is Data:
  Report{report:DTO.ScenarioReport}
  Failure{category:String,details:Driver.Failure}
def done(delivered:Driver.Delivery<S.transient_store(),Driver.transient_owners()>) -> Output:
  match delivered:
    case Driver.Delivered{factory,world,owners,detached,report}:Report{report}
    case Driver.Rejected{failure}:Failure{"transient",failure}
def main() -> Output:
  done(Driver.transient())
